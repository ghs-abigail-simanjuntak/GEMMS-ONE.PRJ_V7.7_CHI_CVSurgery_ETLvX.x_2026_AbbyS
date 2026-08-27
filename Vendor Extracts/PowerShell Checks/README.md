# Introduction 
The provided PowerShell scriptS is designed to analyze JSON files in a specified directory (including subdirectories), checking for specific patterns and calculating the total width of characters based on certain JSON keys. It outputs the results into CSV files for easy review. Below is a brief explanation of each part of the script

# Getting Started
This guide is tailored for setting up and running the scripts using Visual Studio Code (VS Code)

## Prerequisites
Before you begin, ensure the following software is installed on your system:
- Install [Visual Studio Code (VS Code)](https://code.visualstudio.com/download)


## Installing PowerShell Extension for VS Code

1. Open VS Code.
2. Go to the Extensions view by clicking on the square icon on the sidebar.
3. Search for `PowerShell`.
4. Click on `Install` next to the PowerShell extension, which is provided by Microsoft.
5. Once installed, you can open any `.ps1` file or create a new one, and VS Code will recognize and provide appropriate language support for PowerShell.


# Config
To properly use the scripts, you must configure the paths in the `config.ps1` file to reflect your local environment. Here's how to set it up:

1. **Open the `config.ps1` file**:  
        You can open the file by navigating to File > Open File... from the menu and selecting your config.ps1 file.
        Alternatively, you can use the Ctrl+P shortcut to open the command palette, type the path to your config.ps1 file, and press Enter to open it directly.
2. **Modify the Paths**: Replace the placeholders with the actual directory paths where your project scripts are loaded. 
 Example configuration:
 
    ```powershell
    # Path to your Scripts Directory (script is recursive through sub-directories)
    $dirPath = "C:\Path\To\Your\Cloned\Scripts\Directory"


    # Path to prep output CSV (you won't need anything in this file)
    $outputPath = "C:\Path\To\Your\\Cloned\Scripts\Directory\PrepOutput.csv"


    # Path to final output CSV (this is the output of every json table occurrence in your scripts, if total width != 12 then ColumnWidth will be FALSE)
    $finalOutputPath = "C:\Path\To\Your\Cloned\Scripts\Directory\FinalOutput.csv"
    ```

3. **Save the File**: After updating the paths, save the changes to `config.ps1`. 

## Running the Scripts

1. Open your PowerShell script in VS Code.
2. On the text editor window, select `Run`, or press `F5` to run the script.
3. Ensure that your JSON files are in the specified directory that the script references, or modify the script to point to the correct directory.


# Contribute
We welcome contributions! Here are some ways you can contribute:
- **Reporting bugs**: Open an issue if you find a bug.
- **Suggesting enhancements**: Have an idea to make the script better? Open an issue and tag it as a feature request.
- **Pull requests**: Want to contribute directly to the codebase? Branch the repository, make your changes, and submit a pull request.

