<#
.SYNOPSIS
This script downloads and installs ZoomIt from Sysinternals Live, and can optionally configure various settings
such as running on startup, accepting the EULA, hiding the system tray icon, and hiding the first run dialog.

.DESCRIPTION
This script downloads and installs ZoomIt from Sysinternals Live and currently saves the EXE to the User's Documents folder.
Choose between the x86 and x64 versions of ZoomIt by specifying the Architecture parameter.
The script can also configure various settings such as running ZoomIt on startup,
accepting the EULA, hiding the system tray icon, and hiding the Options Window on first run.

.PARAMETER AcceptEULA
Specifies whether to accept the End User License Agreement (EULA) by creating a registry entry for EulaAccepted.
This Prevents the EULA dialog from appearing on first run.

.PARAMETER RunOnStartup
Specifies whether to run ZoomIt on startup by adding a registry entry to the Current User's Run key.

.PARAMETER ShowTrayIcon
Specifies whether to show the ZoomIt icon in the system tray.

.PARAMETER ShowOptions
Specifies whether to show the Options Window on the first run.

.PARAMETER Architecture
Specifies the architecture of the ZoomIt executable to download. Valid values are "x64" and "x86".
Default is "x64".

.EXAMPLE
Provide examples of how to use the script, including sample input and expected output.

.NOTES
Author: Michael Escamilla
Date: 11/22/2024

Version History:
2024.11.22.0 - Initial release
2024.11.22.1 - Changed Parameter ShowFirstRun to ShowOptions

Future Improvements:
- Check if ZoomIt is already running on system
- Check if zoomIt is already installed
- Check if the installed version is the latest version
- Add support for selecting a custom save path.
- Add support for other ZoomIt settings.
- Loggging maybe?
#>
param (
    [ValidateSet("x64", "x86")]
    [string]$Architecture = "x64",
    [switch]$AcceptEULA,
    [switch]$RunOnStartup,
    [switch]$ShowTrayIcon,
    [switch]$ShowOptions
)

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

### Parse File Name from Download URL
$FileName = $DownloadURL.Split("/")[-1]

### Set Save Path
# This method will grab the OneDrive folder if Backup is enabled
$SavePath = [Environment]::GetFolderPath('MyDocuments')

### Combine Save Path and File Name
$SaveFile = Join-Path -Path $SavePath -ChildPath $FileName

### Download ZoomIt
try {
    Invoke-WebRequest -Uri $DownloadURL -OutFile $SaveFile -ErrorAction Stop
}
catch {
    Write-Error "Failed to download ZoomIt from $DownloadURL"
    exit 2
}

### Create Accept EULA Registry Key if AcceptEULA switch is set
if ($AcceptEULA) {
    # Define the registry path for ZoomIt settings
    $RegPath = "HKCU:\Software\Sysinternals\ZoomIt"
    
    # Define the registry entry name for EULA acceptance
    $RegName = "EulaAccepted"
    
    # Define the registry entry value to indicate EULA acceptance
    $RegValue = "1"
    
    # Create the registry path if it doesn't exist
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    # Create or update the registry entry to accept the EULA
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord -Force | Out-Null
}

### Show First Run
if (!($ShowOptions)) {
    # Define the registry path for ZoomIt settings
    $RegPath = "HKCU:\Software\Sysinternals\ZoomIt"
    
    # Define the registry entry name for first run
    $RegName = "OptionsShown"
    
    # Define the registry entry value to indicate first run has been completed
    $RegValue = "1"
    
    # Create the registry path if it doesn't exist
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    # Create or update the registry entry to indicate first run has been completed
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord -Force | Out-Null
}

### Remove from System Tray
if (!($ShowTrayIcon)) {
    # Define the registry path for ZoomIt settings
    $RegPath = "HKCU:\Software\Sysinternals\ZoomIt"
    
    # Define the registry entry name for showing the system tray icon
    $RegName = "ShowTrayIcon"
    
    # Define the registry entry value to hide the system tray icon
    $RegValue = "0"
    
    # Create the registry path if it doesn't exist
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    # Create or update the registry entry to hide the system tray icon
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord -Force | Out-Null
}

### Run On Startup via Registry
if ($RunOnStartup) {
    # Define the registry path for startup programs
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    
    # Define the registry entry name for ZoomIt
    $RegName = "ZoomIt"
    
    # Define the registry entry value as the path to the ZoomIt executable
    $RegValue = $SaveFile
    
    # Create or update the registry entry to run ZoomIt on startup
    New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType String -Force | Out-Null
}