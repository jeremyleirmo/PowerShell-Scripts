$FreeSpace = (Get-Volume -DriveLetter C).SizeRemaining / (Get-Volume -DriveLetter C).size
[int]$Size = [math]::Round($FreeSpace, 2) * 100
return $Size

