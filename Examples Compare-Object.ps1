# <= Reference Set
# => Difference Set
$Reference = Import-Clixml -Path C:\Labs\procs.xml
Compare-Object -ReferenceObject (Import-Clixml $Reference ) -DifferenceObject (Get-Process) `
-Property Name
