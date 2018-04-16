#Formating
#Create Hash Table during formating, Change KB to MB
Get-Process |
Format-Table Name, @{Label = 'VM(GB)'; expression = {$_.VM / 1GB -as [int]}} -AutoSize

#Use formating additional Keys, E=Expression, N=Name
# FormatString, Width, Alignment
Get-Process |
    Format-Table Name,
    @{name='VM(MB';expression={$_.VM};formatstring='F2';align='right'} -AutoSize

Get-Process | Format-Table -Property Name, Id,
    @{l='VirtualMB';e={$_.vm/1mb}},
    @{l='PhysicalMB';e={$_.workingset/1MB}} -AutoSize

Get-EventLog -List | Format-Table -Property Log,
    @{l='LogName';e={$_.LogDisplayname}},
    @{l='RetDays';e={$_.MinimumRetentionDays}} -AutoSize

Get-ChildItem C:\Windows\*.exe | Format-List -Property Name,VersionInfo,
    @{Name="Size";expression={$_.Length}}

Get-ChildItem C:\Windows\*.exe | Format-Table -Property Name,
    @{Name="Version";Expression={$_.VersionInfo.ProductVersion}},
    @{Name="Size";expression={$_.Length/1kb}} -AutoSize
