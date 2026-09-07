; Pharmacy System — Windows Installer Script (Inno Setup)
; Place this file at: installer/pharmacy_system.iss
; The GitHub Actions workflow runs this automatically after `flutter build windows --release`.

#define MyAppName "Pharmacy System"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Al-Shifa Pharmacy"
#define MyAppExeName "pharmacy_system.exe"
; ^ IMPORTANT: replace with your actual .exe name.
; It matches the "name:" field in pubspec.yaml, e.g. if pubspec.yaml has
; "name: pharmacy_system", the built exe will be build/windows/x64/runner/Release/pharmacy_system.exe

[Setup]
AppId={{B2E4C1A0-7F3D-4A9B-9C1E-PHARMACYSYS01}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=PharmacySystem-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Uncomment and set a real .ico path if you have an app icon:
; SetupIconFile=..\assets\icon\app_icon.ico
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Copies EVERYTHING from the Flutter Release output (exe + all required DLLs, including sqlite3.dll,
; plus the data/ folder Flutter needs) into the install directory.
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Remove the local SQLite database on uninstall is a DESTRUCTIVE choice — left commented out.
; Only enable this if you want "Uninstall" to also wipe all pharmacy data.
; Type: filesandordirs; Name: "{userappdata}\{#MyAppName}"
