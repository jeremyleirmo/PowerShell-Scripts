#References
# https://blogs.technet.microsoft.com/heyscriptingguy/2014/07/18/trim-your-strings-with-powershell/
# TRIM Menthod
#1 Trim white space from both ends of a string
$string = " a String"
$string.Trim()

#2 Trim Specific Characters. remove all A's
$string = "a String a"
$string1 = $string.Trim("a", " ")

#3 Remove Characters based on Unicode
# Unicode reference https://en.wikipedia.org/wiki/List_of_Unicode_characters
$string = "a String a"
$string1 = $string.Trim([char]0x0061, [char]0x0020)

# TRIMEND Methods



$content = Get-Content "C:\Reports\scopes.txt"
$content | ForEach-Object {$_.TrimEnd()} | Set-Content File

#2
