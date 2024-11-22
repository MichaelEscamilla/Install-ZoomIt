# Install-ZoomIt
A powershell script to Install ZoomIt from Sysinternals Live to the Users Documents folder. Configure various setting to customize the behavior.

## SYNTAX

```powershell
Install-ZoomIt.ps1 [-Architecture] [-AcceptEULA] [-RunOnStartup] [-ShowTrayIcon] [-ShowOptions]
```
## Description

This script downloads and installs ZoomIt from Sysinternals Live and currently saves the EXE to the User's Documents folder.<br>
Choose between the x86 and x64 versions of ZoomIt by specifying the Architecture parameter.<br>
The script can also configure various settings such as running ZoomIt on startup,
accepting the EULA, hiding the system tray icon, and hiding the Options Window on first run.

## Sysinternal Registry Key
Current User Registry Key where the ZoomIt settings are stored. These are the current 3 settings that are configurable using the script.<br>
![Sysinternals Registry Key - ZoomIt](/Images/Install-ZoomIt_SysinternalsKey-ZoomIt.png)

## Current User Run Key
Current User Run key. Regardless of what Architecutre EXE is used, the Value needs to be "ZoomIt" and the Data will be the path to the EXE file.<br>
![Current User Run Key - ZoomIt](/Images/Install-ZoomIt_CU-RunKey-ZoomIt.png)

## Example

### Example 1

```powershell
.\Install-ZoomIt.ps1 -RunOnStartup -AcceptEULA
```

This will install ZoomIt64.exe to the Documents folder, set to run on Startup, Accept the EULA so it doesn't appear, disable the Tray Icon, and disable the Options Windows from appear on the first run.

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

### -AcceptEULA

Specifies whether to accept the End User License Agreement (EULA) by creating a registry value 'EulaAccepted' with the data value '1' in the key "HKCU:\Software\Sysinternals\ZoomIt". This Prevents the EULA dialog from appearing on first run.

```yaml
Type: Switch
Parameter Sets: (All)
Aliases: None

Required: False
Position: 1
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
Position: 2
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
Position: 2
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```