Invoke-Command -ComputerName (Get-ADComputer –filter 'Name -like "*"' -SearchBase "OU=Servers,DC=NWTC,DC=EDU").name -ScriptBlock {
    #Insert Code Here

}


