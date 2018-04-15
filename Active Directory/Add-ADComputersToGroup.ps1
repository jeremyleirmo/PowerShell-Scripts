#requires -version 4
<#
.SYNOPSIS
  <Short Overview of script>

.DESCRIPTION
  <Long description of script>

.PARAMETER <Parameter_Name>

  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None>

.NOTES
  Name:           Add-ADComputersToGroup
  Version:        1.0
  Author:         Jeremy Leirmo
  Creation Date:  4-14-2018
  Purpose/Change: Add AD Computer to AD Group

.EXAMPLE
  <Example explanation goes here>


  <Example goes here. Repeat this attribute for more than one example>

#>
#---------------------------------------------------[Initialisations]---------------------------------------------------

    #Set Error Action to Silently Continue

    $ErrorActionPreference = 'SilentlyContinue'

#-----------------------------------------------------------[Execution]-------------------------------------------------

$computers = get-content "C:\Reports\gpo.txt"
$cred = Get-Credential
$group = "SVR-Servers_Secure_Baseline"
foreach ($computer in $computers){
    $CompObj = Get-ADComputer -Identity $computer
    Add-ADGroupMember -Identity $group -Members $CompObj -Credential $cred
}