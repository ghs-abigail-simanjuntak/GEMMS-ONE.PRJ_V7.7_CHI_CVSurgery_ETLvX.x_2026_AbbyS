# Import the configuration
. .\config.ps1

# Initialize an array to hold the results
$results = @()

# Get all the files in the directory and its subdirectories
Get-ChildItem $dirPath -File -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $fileName = Split-Path $filePath -Leaf

    # Replace this part with the provided code chunk
    # Read the file line by line and keep track of the line number
$content = Get-Content $filePath
$groupNumber = 0
for ($i = 0; $i -lt $content.Length; $i++) {
    # If the line contains "c": or "r":
    if ($content[$i] -match '"c":' -or $content[$i] -match '"r":') {
        $groupNumber++
    }

    # Find all "w" occurrences and their following characters
    $matches = [regex]::Matches($content[$i], '"w":\s*(\d+)')
    foreach ($match in $matches) {
        # The captured characters are already the number after "w", so no need to remove commas
        $characters = $match.Groups[1].Value

        # Add the file name, group number, line number, and the characters to the results
        $results += New-Object PSObject -Property @{
            FileName = $fileName
            GroupNumber = $groupNumber
            LineNumber = $i + 1
            Characters = $characters
        } | Select-Object FileName, GroupNumber, LineNumber, Characters
    }
}
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputPath -NoTypeInformation

# Group the results by FileName and GroupNumber
$groupedResults = $results | Group-Object FileName, GroupNumber

# Initialize an array to hold the final results
$finalResults = @()

# Process each group
foreach ($group in $groupedResults) {
    # Sum the characters and concatenate the line numbers
    $totalWidth = ($group.Group | Measure-Object -Property Characters -Sum).Sum
    $lineNumbers = ($group.Group | ForEach-Object { $_.LineNumber }) -join " "

    # Determine if the width is correct
    $correctWidth = if ($totalWidth -gt 12) {
        "FALSE, JSON Width too large"
    } elseif ($totalWidth -lt 12) {
        "FALSE, JSON Width too small"
    } else {
        "TRUE"
    }

    # Add the file name, total width, line numbers, and correct width to the final results
    $finalResults += New-Object PSObject -Property @{
        FileName = $group.Name.Split(", ")[0]
        TotalWidth = $totalWidth
        LineNumbers = $lineNumbers
        CorrectWidth = $correctWidth
    } | Select-Object FileName, TotalWidth, LineNumbers, CorrectWidth
}

# Export the final results to a second CSV file
$finalResults | Export-Csv -Path $finalOutputPath -NoTypeInformation