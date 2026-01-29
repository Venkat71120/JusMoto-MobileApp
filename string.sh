#!/bin/bash

# Function to copy to clipboard (macOS)
copy_to_clipboard() {
    echo "$1" | pbcopy
}

# Input variable name and value
read -p "Enter the variable name: " varName
read -p "Enter the variable value: " varValue

# Locate the local_keys.g.dart file
filePath=$(find . -type f -name "local_keys.g.dart")

if [ -z "$filePath" ]; then
    echo "File local_keys.g.dart not found. Please make sure the file exists in a subfolder."
    exit 1
fi

echo "Found file at: $filePath"

# Create a new private variable and a getter for it at the end of current variables
newPrivateVariable="  static const String _$varName = \"$varValue\";"
newGetter="  static String get $varName => _$varName.tr();"
newLine=""
newMapValue="   _$varName: \"\","

# Insert the new private variable before the closing brace }
sed -i '' "/variable ends here/i\\
$newPrivateVariable\\
" "$filePath"


sed -i '' "/getter starts here/a\\
$newGetter\\
" "$filePath"

# Add the variable name to the stringsMap
sed -i '' "/};/i\\
$newMapValue
" "$filePath"

# Copy the variable name to the clipboard
copy_to_clipboard "$varName"

echo "Variable $varName added successfully and copied to clipboard."
