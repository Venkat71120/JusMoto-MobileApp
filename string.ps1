# PowerShell Script

# Function to copy to clipboard (Windows)
function Copy-ToClipboard {
    param (
        [Parameter(Mandatory=$true)]
        [string]$text
    )
    $text | Set-Clipboard
}

function Get-FromClipboard {
    return Get-Clipboard
}


# Input variable name and value
$varName = Get-FromClipboard
$varValue = Read-Host "Enter the variable value"

# Locate the local_keys.g.dart file
$filePath = Get-ChildItem -Recurse -Filter "local_keys.g.dart" | Select-Object -First 1

if (-not $filePath) {
    Write-Host "File local_keys.g.dart not found. Please make sure the file exists in a subfolder."
    exit
}

Write-Host "Found file at: $filePath"

# Create a new private variable and a getter for it at the end of current variables
$newPrivateVariable = "  static const String _${varName} = `"${varValue}`";"
$newGetter = "  static String get ${varName} => _${varName}.tr();"
$newMapValue = "   _${varName}: '',"

# Read the content of the file
$content = Get-Content -Path $filePath.FullName

# Insert the new private variable before the closing brace }
$updatedContent = $content -replace "(//variable ends here)", "${newPrivateVariable}`n//variable ends here"
$updatedContent = $updatedContent -replace "(getter starts here)", "getter starts here`n${newGetter}"
$updatedContent = $updatedContent -replace "(};)", "${newMapValue}`n};"

# Write the updated content back to the file
Set-Content -Path $filePath.FullName -Value $updatedContent

# Copy the variable name to the clipboard
Copy-ToClipboard -text $varName

Write-Host "Variable $varName added successfully and copied to clipboard."