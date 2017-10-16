## DSCSimpleConfig.ps1
##
##This script will create a .MOF file for installing the Web Server (IIS) role
##It will also test the running og he configuration on a remote system

#Configuration Block
Configuration WebServerConfig {

    #Node Block userd to determine Target, allows targeting to a computer
    Node $ComputerName {

        ##Resource Block used to configure resources
        ##Windows Feature is a built-in Resource Block
        WindowsFeature IIS {

            Name   = 'web-server'  #FeatureName
            Ensure = 'Present'   #Determines install status. To uninstall the role set ensure to Absent
        }
    }
}

##Variable for Name of Computer that configurations will apply to
$ComputerName = "SERVERNAME"

##Executes the WebServerConfig configurations to creat the .MOF file
WebServerConfig -outputpath C:\reports

#To run the process for Configuration on $ComputerName
Start-DscConfiguration -Path C:\Reports -ComputerName "ServerName" -WhatIf -Wait


