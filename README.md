# Install-ZoomIt
A powershell script to Install ZoomIt from Sysinternals Live. Configure various setting to customize the behavior.

## PSGallery
[Available through the PSGallery](https://www.powershellgallery.com/packages/Install-ZoomIt)
```powershell
Install-Script -Name Install-ZoomIt
```

## SYNTAX
```powershell
Install-ZoomIt.ps1 [-Architecture] [-Destination] [-AcceptEULA] [-RunOnStartup] [-ShowTrayIcon] [-ShowOptions] [-StartZoomIt]
```
## Description
This script downloads and installs ZoomIt from Sysinternals.<br>
Choose between the x86 and x64 versions of ZoomIt by specifying the Architecture parameter.<br>
The script can also configure various settings such as running ZoomIt on startup,
accepting the EULA, hiding the system tray icon, and hiding the Options Window on first run.

## Sysinternals Registry Key
Current User Registry Key where the ZoomIt settings are stored. These are the current 3 settings that are configurable using the script.<br>
![Sysinternals Registry Key - ZoomIt](/Images/Install-ZoomIt_SysinternalsKey-ZoomIt.png)

## Current User Run Key
Current User Run key. Regardless of what Architecutre EXE is used, the Value needs to be "ZoomIt" and the Data will be the path to the EXE file.<br>
![Current User Run Key - ZoomIt](/Images/Install-ZoomIt_CU-RunKey-ZoomIt.png)

## Example

### Example 1

```powershell
.\Install-ZoomIt.ps1 -RunOnStartup -AcceptEULA -StartZoomIt
```

This will install ZoomIt64.exe to the Documents folder, set to run on Startup, Accept the EULA so it doesn't appear, disable the Tray Icon, and disable the Options Windows from appear on the first run. After all that, start the Zoomit64.exe.

## PARAMETERS

### -Architecture

Specify the architecture of the ZoomIt file you want to download. Defaults to 'x64'

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 0
Default value: x64
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination

Specifies the destination folder where ZoomIt will be installed. Defaults to the user's Documents folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases: None

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AcceptEULA

Specifies whether to accept the End User License Agreement (EULA) by creating a registry value 'EulaAccepted' with the data value '1' in the key "HKCU:\Software\Sysinternals\ZoomIt". This Prevents the EULA dialog from appearing on first run.

```yaml
Type: Switch
Parameter Sets: (All)
Aliases: None

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RunOnStartup

Specifies whether to run ZoomIt on startup by adding a registry entry to the Current User's Run key.

```yaml
Type: Switch
Parameter Sets: (All)
Aliases: None

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowTrayIcon

Specifies whether to show the ZoomIt icon in the system tray. Controled by the Registry value "ShowTrayIcon" in the key "HKCU:\Software\Sysinternals\ZoomIt". 

```yaml
Type: Switch
Parameter Sets: (All)
Aliases: None

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowOptions

Specifies whether to show the Options Window on the first run. Controled by the Registry value "OptionsShown" in the key "HKCU:\Software\Sysinternals\ZoomIt". 

```yaml
Type: Switch
Parameter Sets: (All)
Aliases: None

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartZoomIt

Specifies whether to start ZoomIt immediately after installation.

```yaml
Type: Switch
Parameter Sets: (All)
Aliases: None

Required: False
Position: 6
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```