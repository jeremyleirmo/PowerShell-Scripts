#Compare-Object of Processes by name
# <= Present only in reference, => Presnt only in Difference Object
# Equal not represented by default
Compare-Object -ReferenceObject (Import-Clixml .\reference.xml) -DifferenceObject (Get-Process) -Property Name


# Include Equal
Compare-Object -ReferenceObject (Import-Clixml .\reference.xml) -DifferenceObject (Get-Process) -Property Name -IncludeEqual

# <= Reference Set
# => Difference Set
$Reference = Import-Clixml -Path C:\Labs\procs.xml
Compare-Object -ReferenceObject (Import-Clixml $Reference ) -DifferenceObject (Get-Process) `
-Property Name
