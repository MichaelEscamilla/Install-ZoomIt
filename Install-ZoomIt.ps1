<#PSScriptInfo

.VERSION 2024.12.2.2

.GUID b312895f-b4bf-44c2-82f3-9e64b509c5bb

.AUTHOR Michael Escamilla

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
2024.11.22.0    :   Initial release
2024.11.22.1    :   Changed Parameter ShowFirstRun to ShowOptions
2024.12.2.1     :   Added Check if ZoomIt is already in Destination Path
                    Added Check if ZoomIt version is newer than the existing version in the Destination Path
                    Added Check if Zoomit is already running on system
                    Modified the ShowTrayIcon parameter to always set a value
                    Added some functions for repeated tasks
2024.12.2.2     :   Changes to Publish to PSGallery
2024.12.2.3     :   Added Path option

.PRIVATEDATA

#> 



<#
.SYNOPSIS
This script downloads and installs ZoomIt from Sysinternals Live, and can optionally configure various settings such as running on startup, accepting the EULA, hiding the system tray icon, and hiding the first run dialog.

.DESCRIPTION
This script downloads and installs ZoomIt from Sysinternals Live and currently saves the EXE to the User's Documents folder. Choose between the x86 and x64 versions of ZoomIt by specifying the Architecture parameter. The script can also configure various settings such as running ZoomIt on startup, accepting the EULA, hiding the system tray icon, and hiding the Options Window on first run.
.PARAMETER Architecture
Specifies the architecture of the ZoomIt executable to download. Valid values are "x64" and "x86". Default is "x64", I would recommend using the x64 version unless you have a specific reason to use the x86 version. The x86 version will run the x64 version from %TEMP% on a 64-bit system.
.PARAMETER Path
Specifies the path to save the ZoomIt executable. Default is the User's Documents folder.
.PARAMETER AcceptEULA
Specifies whether to accept the End User License Agreement (EULA) by creating a registry entry for EulaAccepted. This Prevents the EULA dialog from appearing on first run.
.PARAMETER RunOnStartup
Specifies whether to run ZoomIt on startup by adding a registry entry to the Current User's Run key.
.PARAMETER ShowTrayIcon
Specifies whether to show the ZoomIt icon in the system tray. Will always set a value in the registry.
.PARAMETER ShowOptions
Specifies whether to show the Options Window on the first run.
.EXAMPLE
.\Install-ZoomIt.ps1 -AcceptEULA -RunOnStartup -ShowTrayIcon
.NOTES
Future Improvements:
Add support for setting a custom Save path.
Add support for other ZoomIt settings.
Loggging maybe

#>

param (
    [ValidateSet("x64", "x86")]
    [string]$Architecture = "x64",
    [switch]$Path,
    [switch]$AcceptEULA,
    [switch]$RunOnStartup,
    [switch]$ShowTrayIcon,
    [switch]$ShowOptions
)

####### Functions #######
#region Functions
function Stop-ProcessByName {
    param (
        [string]$ProcessName
    )
    
    try {
        # Get the process(es) by name
        $Processes = Get-Process -Name $ProcessName -ErrorAction Stop
        # Loop through each process and stop it
        foreach ($Process in $Processes) {
            # Stop the Process
            Stop-Process -Id $Process.Id -Force

            # Wait for the process to fully stop
            Start-Sleep -Seconds 1

            Write-Host "Stopped process: $($Process.Name) (ID: $($Process.Id))"
        }
    }
    catch {
        Write-Host "No process with the name '$ProcessName' was found."
    }
}

function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value,
        [ValidateSet("String", "ExpandString", "MultiString", "Binary", "DWord", "Qword")]
        [string]$PropertyType
    )
    
    # Create the registry path if it doesn't exist
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    
    # Create or update the registry entry
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -Force | Out-Null
    Write-Host "Successfully set registry key: [$Path] [$Name] = [$Value]" -ForegroundColor Green
}
#endregion
#########################

### Check if connected to the internet, No Internet, No ZoomIt
try {
    $null = Test-Connection -ComputerName google.com -Count 1 -ErrorAction Stop
}
catch {
    Write-Error "Not connected to the internet"
    exit 1
}

### Set Download URL based on architecture
if ($Architecture -eq "x64") {
    $DownloadURL = "https://live.sysinternals.com/ZoomIt64.exe"
}
else {
    $DownloadURL = "https://live.sysinternals.com/ZoomIt.exe"
}
Write-Host "Downloading ZoomIt from: [$DownloadURL]"

### Parse File Name from Download URL
$FileName = $DownloadURL.Split("/")[-1]

### Start all Zoomit Processes
Stop-ProcessByName -ProcessName "ZoomIt*"

### Set Temporary Save Path - Temporarily save the file in the user's temp directory before moving it to the destination
$SavePath = [System.IO.Path]::GetTempPath()

## Set Destination Path
if ($Path) {
    Write-Host "Save Path option selected, checking if path exists"
    # Check if the specified path exists else create it
    if (-not (Test-Path $Path)) {
        Write-Host "Path does not exist, creating path: [$Path]"
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
    # Set the Destination Path to the specified path
    $DestinationPath = $Path
}
else {
    $DestinationPath = [Environment]::GetFolderPath('MyDocuments')
}
Write-Host "Destination Path set to: [$Path]"

### Build Save Path and Destination Path with File Name
$SaveFile = Join-Path -Path $SavePath -ChildPath $FileName
$DestinationFile = Join-Path -Path $DestinationPath -ChildPath $FileName

### Download ZoomIt to the Save Path
try {
    Invoke-WebRequest -Uri $DownloadURL -OutFile $SaveFile -ErrorAction Stop
}
catch {
    Write-Error "Failed to download ZoomIt from $DownloadURL"
    exit 2
}

### Get the version of the downloaded ZoomIt
$SaveFile_FileVersion = (Get-Item -Path $SaveFile).VersionInfo.FileVersion
Write-Host "Downloaded ZoomIt: [$SaveFile] : [$SaveFile_FileVersion]"

### Check if File already exists in Destination Path
if ((Test-Path $DestinationFile)) {
    # Get the version of the existing ZoomIt file in the destination path
    $DestinationFile_FileVersion = (Get-Item -Path $DestinationFile).VersionInfo.FileVersion
    Write-Host "Existing ZoomIt: [$DestinationFile] : [$DestinationFile_FileVersion]"

    # Compare the version of the existing file with the downloaded file
    if ([version]$DestinationFile_FileVersion -lt [version]$SaveFile_FileVersion) {
        # Stop any running ZoomIt processes
        Stop-ProcessByName -ProcessName "ZoomIt*"

        # Overwrite the existing file with the new version if the downloaded version is newer
        Copy-Item -Path $SaveFile -Destination $DestinationFile -Force
        Write-Host "Successfully Updated Existing ZoomIt to version: [$SaveFile_FileVersion]" -ForegroundColor Green
    }
    else {
        # Output a message indicating that the existing version is up to date
        Write-Host "The existing version of ZoomIt is up to date."
    }
}
else {
    # Copy the downloaded ZoomIt file to the destination path
    Copy-Item -Path $SaveFile -Destination $DestinationFile
    Write-Host "Successfully Saved ZoomIt: [$DestinationFile] : [$SaveFile_FileVersion]" -ForegroundColor Green
}

### Cleanup the downloaded ZoomIt file from the Save Path
Remove-Item -Path $SaveFile -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host "Removed downloaded ZoomIt file: [$SaveFile]"

### Create Accept EULA Registry Key if AcceptEULA switch is set
if ($AcceptEULA) {
    Write-Host "Accept EULA option selected"

    # Define the registry settings for ZoomIt
    $RegPath = "HKCU:\Software\Sysinternals\ZoomIt"
    $RegName = "EulaAccepted"
    $RegValue = "1"
    
    # Create or update the registry entry to accept the EULA
    Set-RegistryValue -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord
}

### Show First Run
if (!($ShowOptions)) {
    Write-Host "Show Options option selected"

    # Define the registry settings for ZoomIt
    $RegPath = "HKCU:\Software\Sysinternals\ZoomIt"
    $RegName = "OptionsShown"
    $RegValue = "1"
    
    # Create or update the registry entry to indicate first run has been completed
    Set-RegistryValue -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord
}

### Set the System Tray value
if ($null -ne $ShowTrayIcon) {
    Write-Host "Show Tray Icon option selected"

    # Define the registry settings for ZoomIt
    $RegPath = "HKCU:\Software\Sysinternals\ZoomIt"
    $RegName = "ShowTrayIcon"
    if ($ShowTrayIcon) {
        $RegValue = "1"
    }
    else {
        $RegValue = "0"
    }
    
    # Create or update the registry entry to hide the system tray icon
    Set-RegistryValue -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord
}

### Run On Startup via Registry
if ($RunOnStartup) {
    Write-Host "Run On Startup option selected"

    # Define the registry settings for startup programs
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $RegName = "ZoomIt"
    $RegValue = $DestinationFile
    
    # Create or update the registry entry to run ZoomIt on startup
    Set-RegistryValue -Path $RegPath -Name $RegName -Value $RegValue -PropertyType String
}
