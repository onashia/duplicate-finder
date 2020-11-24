function Get-Duplicates {
    <#
    .NAME
        Get-Duplicates
    .SYNOPSIS
        Find duplicates within selected folder
    .DESCRIPTION
        Prompt for a folder containing duplicates and a location to move the duplicates to
    .LINKS
        https://github.com/onashia
    #>

    # Show gui prompt to select folder to find duplicates in
    $SourcePath = Get-Folder 'Select folder containing duplicates'
    # Show gui prompt to select fodler to move duplicates to
    $DestinationPath = Get-Folder 'Select folder to move duplicates to'

    # Ensure path is valid then search for duplicate files
    if (Test-Path $SourcePath) {
        Write-Warning 'Searching for duplicates'

        # Store any duplicates found by comparing hash values
        $Duplicates = Get-ChildItem $SourcePath -File -Recurse -ErrorAction SilentlyContinue | Get-FileHash | Group-Object -Property Hash | Where-Object Count -gt 1

        if ($Duplicates.Count -lt 1) {
            Write-Warning 'No duplicates found'
            break
        } else {
            Write-Warning 'Duplicates found'

            # Move any duplicates found to the proivided folder
            Move-Files $Duplicates $DestinationPath
        }
    }
}

function Get-Folder ($DialogMessage) {
    <#
    .NAME
        Get-Folder
    .SYNOPSIS
        Returns a folder path.
    .DESCRIPTION
        Shows a GUI dialog box to select then return a folder path.
    .PARAMETER DialogMessage
        Provide a message to display in the dialog box.
    #>

    # Import windows forms for a GUI folder selection
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    # Store the folder path for returning
    $FolderPath = ""

    # Display a dialog box to select a source folder
    $Dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $Dialog.Description = $DialogMessage
    $Dialog.RootFolder = "MyComputer"

    # Only write to FolderPath if the OK button is clicked in the dialog window
    if ($Dialog.ShowDialog() -eq "OK") {
        $FolderPath = $Dialog.SelectedPath
    }

    return $FolderPath
}

function Show-Duplicates {

}

function Temp-Files ($Files, $DestinationPath) {
    <#
    .NAME
        Move-Files
    .SYNOPSIS
        Move files to the destination directory
    .DESCRIPTION
        Move all of the files within the $Files object to the directory at the $DestinationPath
    .PARAMETER Files
        An object containing file information
    .PARAMETER DestinationPath
        The path to move the files to
    #>

    $CurrentDate = Get-Date -Format "MM-dd-yyyy-HH-mm-ss"
    $LogFile = $DestinationPath + '\DuplicatesLog-' + $CurrentDate + '.log'
    $DestinationPath = $DestinationPath + '\Duplicates-' + $CurrentDate 

    foreach ($f in $Files) {
        
    }

}

function Move-Files ($Files, $DestinationPath) {
    <#
    .NAME
        Move-Files
    .SYNOPSIS
        Move files to the destination directory
    .DESCRIPTION
        Move all of the files within the $Files object to the directory at the $DestinationPath
    .PARAMETER Files
        An object containing file information
    .PARAMETER DestinationPath
        The path to move the files to
    #>

    $CurrentDate = Get-Date -Format "MM-dd-yyyy-HH-mm-ss"

    # Format data within the Files object 
    $FilesToMove = foreach ($f in $Files) {
        # Get the path and hash of every file
        $f.Group | Select -Skip 1 | Select-Object -Property Path, Hash

        # Output to a log file all of the files to be moved
        $LogFile = $DestinationPath + '\DuplicatesLog-' + $CurrentDate + '.log'
        $FileList = $f.Group | Select -Skip 1 | Select-Object -Property Path | Add-Content $LogFile
    }

    Write-Warning ('{0} files are being moved' -f $FilesToMove.Count)

    # Move the files to the destination path
    if ($FilesToMove) {

        # Create a folder with the current date to store duplicates in
        $DestinationPath = $DestinationPath + '\Duplicates-' + $CurrentDate 

        # Move all duplicate items to the new folder in the destination path
        New-Item -ItemType Directory -Path $DestinationPath -Force
        Move-Item $FilesToMove.Path -Destination $DestinationPath -Force

        Write-Warning 'All duplicate files have been moved to the destaination!'
    }
}