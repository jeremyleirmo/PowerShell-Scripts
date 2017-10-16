Get-ADUser -Filter "sAMAccountName -eq ""$SamAc"""
Get-ADUser -Filter "sAMAccountName -eq `"$SamAc`""
Get-ADUser -Filter "sAMAccountName -eq '$SamAc'"
Get-ADUser -Filter ('sAMAccountName -eq "' + $SamAc + '"')