$regpath - 'HKLM:\Software\Microsoft\Windows'
$regpath = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$Computers = Get-content C:\Reports\computers.txt
$Computers = "ComputerName"
$Computers = @(
    'ComputerName'
    'ComputerName'
)
$Computers = Import-csv C:\Reports\InactiveComputers.csv
$Computers = (Get-ADComputer -Filter * -SearchBase "OU=development,OU=Servers,DC=NWTC,DC=EDU").name
