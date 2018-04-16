Function Get-CommandInfo(
$command =
$command | Get-Member
($command).gettype()
Get-Help $command -ShowWindow