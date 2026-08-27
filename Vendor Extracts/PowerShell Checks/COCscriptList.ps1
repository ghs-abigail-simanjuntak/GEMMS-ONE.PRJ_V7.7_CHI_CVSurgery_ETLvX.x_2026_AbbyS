# Execute the following powershell command to create a list of all the scripts you were provided. UPDATE filepaths in the command.

Get-ChildItem -Path "C:\folder" -Recurse | Select-Object -ExpandProperty Name | Out-File -FilePath "C:\folder\FileList.txt"
