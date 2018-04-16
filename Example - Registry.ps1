#Set Registry value EnableAeroPeek from Value 1 to 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\DWM -PSProperty EnableAeroPeek -Value 0
#Set Registry value EnableAeroPeek from Value 0 to 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\DWM -PSProperty EnableAeroPeek -Value 1