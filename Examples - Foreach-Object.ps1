#Get WSUS service and set status .Stop() ;
#Second command on object, Get the object name, Select output Name,Status
Get-Service wuauserv |
    ForEach-Object {$_.Stop() ; Get-Service $_.Name | Select-Object Name, Status }


#Export each object to XML at Path current(name of service).xml format
Get-Service | ForEach-Object { Export-Clixml -InputObject $_ -Path "$($_.name).xml
"}