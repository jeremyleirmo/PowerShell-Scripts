<#
.SYNOPSIS
  Creates DHCP Scopes for GBDHCP03.NWTC.EDU

.DESCRIPTION
  This script will create a DHCP Scope based on information provided within a .csv files.
  The .csv is provided to the script through a Parameter -Path and should contain the follow.
  ScopeID,StartIP,EndIP,SubNet,ScopeName,Router,DNS1,DNS2
  This script will prompt your for the SCCM Server to use for PXE and the following are valid servers.
  GBSCCM01,AUSCCMDP01,CRSCCMDP01,LUSCCMDP01,MNSCCMDP01,NCSCCMDP01,OFSCCMDP01,SBSCCMDP01,SHSCCMDP01,TCSCCMDP01,UDSCCMDP01
  If a valid Server is not entered the script will bypass adding any SCCM PXE options

.PARAMETER Path
  Specifies a path to one or more locations. The default location is the current directory.

.INPUTS
  None. You cannot pip objects into Add-DHCPScope.ps1

.OUTPUTS
  TypeName: System.Management.Automation.PSCustomObject

.NOTES
  Name: Add-DHCPScope
  Version:        1.3
  Author:         Jeremy Leirmo
  Creation Date:  9/6/2017
  Purpose/Change: Combine Multiple DHCP scripts and SCCM PXE script

.EXAMPLE
  .\Add-DHCPScopeV4.ps1 -Path .\Scopes.csv

  This example uses Q:\NEW\Documentation\Scripts\DHCP\Scopes.csv to read all parameters for DHCP Scope creation
  with the prompt at the location of the script
.EXAMPLE
  Q:\NEW\Documentation\Scripts\DHCP\Add-DHCPScope.ps1 -Path Q:\NEW\Documentation\Scripts\DHCP\Scopes.csv
This example uses Q:\NEW\Documentation\Scripts\DHCP\Scopes.csv to read all parameters for DHCP Scope creation
  with the prompt at any location
#>

#---------------------------------------------------------[Script Parameters]-------------------------------------------

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Path

)

#---------------------------------------------------[Initialisations]---------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#----------------------------------------------------------[Declarations]-----------------------------------------------

#Any Global Declarations go here
#Static DHCP Scope Settings for Lease Time and maxClient
$lease = "1.00:00:00"
$maxClient = "4294967295"
#Variable to hold DHCP Server this will be run on
$DHCPServer = "gbdhcp03.nwtc.edu"
#Variable to hold failover replication
$failover = "gbdhcp03.nwtc.edu-gbdhcp04.nwtc.edu"

#-----------------------------------------------------------[Functions]-------------------------------------------------
Function Set-SCCMPXE {
    Param(
        #SCCM PXE option
        [Parameter(Mandatory = $true)]
        [string]$SCCMPXE
    )
    #Set SCCM PXE Options
    #Add DHCP Policy PXEClient (BIOS x86 x64) Set process order 1 and Vendor Class
    Add-DhcpServerv4Policy -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -Name 'PXEClient (BIOS x86 & x64)' -Description `
        'Sets the correct server and filename for Legacy BIOS x86 and x64 PXE boot clients' `
        -Enabled $true -ProcessingOrder 1 -Condition Or -VendorClass EQ, 'PXEClient (BIOS x86 & x64)*'

    #Add DHCP Policy PXEClient (UEFI x64) Set process order 2 and Vendor Class
    Add-DhcpServerv4Policy -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -Name 'PXEClient (UEFI x64)' -Description `
        'Sets the correct server and filename for UEFI x64 PXE boot clients' `
        -Enabled $true -ProcessingOrder 2 -Condition Or -VendorClass EQ, 'PXEClient (UEFI x64)*'

    #Set Scope Option 066 Boot Server Host Name (BIOS x86 x64)
    Set-DhcpServerv4OptionValue -ScopeID $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (BIOS x86 & x64)' -OptionId 66 -Value $SCCMPXE
    #Set Scope Option 0067 Bootfile Name (BIOS x86 x64)
    Set-DhcpServerv4OptionValue -ScopeID $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (BIOS x86 & x64)' -OptionId 67 -Value 'smsboot\x64\wdsnbp.com'
    #Set Scope Option 060 PXEClient (UEFI x64 & BIOS x86 x64)
    Set-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -OptionId 60 -Value 'PXEClient' -PolicyName 'PXEClient (UEFI x64)'
    #Set Scope Option 066 Boot Server Host Name (UEFI x64)
    Set-DhcpServerv4OptionValue -ScopeID $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (UEFI x64)' -OptionId 66 -Value $SCCMPXE
    #Set Scope Option 067 Bootfile Name (UEFI x64)
    Set-DhcpServerv4OptionValue -ScopeID $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (UEFI x64)' -OptionId 67 -Value 'smsboot\x64\wdsmgfw.efi'
}

#-----------------------------------------------------------[Execution]-------------------------------------------------

#Gather info from .csv and place in $Scopes variable
$Scopes = Import-Csv -Path $Path

#Creation on DHCP Scopes
foreach ($Scope in $Scopes) {
    #Create the new scope
    Add-DhcpServerv4Scope -StartRange $Scope.StartIP -EndRange $Scope.EndIP -SubnetMask $Scope.SubNet -Name $Scope.ScopeName `
        -ComputerName $DHCPServer -ActivatePolicies $true -Delay 0 -LeaseDuration $lease -MaxBootpClients $maxClient -state Active -Type Dhcp

    #Set new Scopes failover relationship
    Add-DhcpServerv4FailoverScope -Name $failover -ScopeId $Scope.ScopeID -ComputerName $DHCPServer

    #Set DNS and Default Gateway options
    #Set DNS entries to an Array
    $DNSArray = $Scope.DNS1, $Scope.DNS2
    Set-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -Router $Scope.Router -DnsServer $DNSArray -ComputerName $DHCPServer -Force
    Set-DhcpServerv4DnsSetting -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -DynamicUpdates Always -UpdateDnsRRForOlderClients:$true
    Set-DhcpServerv4DnsSetting -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -NameProtection $true

    #Call Function SCCM-PXE to set PXE location
    #Prompt User for SCCM PXE Server
    $SCCMPXE = Read-host "Please enter the SCCM Server FQDN Name this Scope will use for PXE or Hit Enter to bypass"
    Switch ($SCCMPXE) {
        gbsccm01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        mnsccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        ausccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        crsccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        lusccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        ncsccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        ofsccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        sbsccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        shsccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        tcsmmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        udsccmdp01.nwtc.edu {Set-SCCMPXE -SCCMPXE $SCCMPXE}
        default {write-host "No PXE Server was selected" -ForegroundColor green}
    }

    #Gather the changes for output to the console for verification of changes to DHCP
    $DHCPINFO1 = Get-DhcpServerv4Scope -ScopeId $Scope.ScopeID -ComputerName $DHCPServer | Select-Object -Property Name, ScopeId, SubnetMask, StartRange, EndRange
    $DNSServer = Get-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -OptionId 6
    $Router = Get-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -OptionId 3
    $BIOPXE66 = Get-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (BIOS x86 & x64)' -OptionId 66 -ErrorAction SilentlyContinue
    $BIOPXE67 = Get-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (BIOS x86 & x64)' -OptionId 67 -ErrorAction SilentlyContinue
    $UEFI60 = Get-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (UEFI x64)' -OptionId 60 -ErrorAction SilentlyContinue
    $UEFI66 = Get-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (UEFI x64)' -OptionId 66 -ErrorAction SilentlyContinue
    $UEFI67 = Get-DhcpServerv4OptionValue -ScopeId $Scope.ScopeID -ComputerName $DHCPServer -PolicyName 'PXEClient (UEFI x64)' -OptionId 67 -ErrorAction SilentlyContinue

    #Create new object to output from
    $object = [PSCustomObject]@{
        'Name'          = $DHCPINFO1.Name;
        'Scope ID'      = $DHCPINFO1.ScopeID;
        'Subnet Mask'   = $DHCPINFO1.SubnetMask;
        'Start Range'   = $DHCPINFO1.StartRange;
        'End Range'     = $DHCPINFO1.EndRange;
        'DNS IPAddress' = $DNSServer.Value;
        'Router IP'     = $Router.Value;
        'PXE BIO66'     = $BIOPXE66.Value;
        'PXE BIO67'     = $BIOPXE67.Value;
        'PXE UEFI60'    = $UEFI60.Value;
        'PXE UEFI66'    = $UEFI66.Value;
        'PXE UEFI67'    = $UEFI67.Value
    }
    #Return Information Gathered about the new creation
    $object

}

#Force DHCP failover to GBDHCP04 force without confirmation and suppress output
Invoke-DhcpServerv4FailoverReplication -ComputerName $DHCPServer -Name $failover
