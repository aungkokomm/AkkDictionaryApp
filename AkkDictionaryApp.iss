; Inno Setup Script for AKK En-to-MM Dictionary
; Generated for .NET 8 WPF Application

#define MyAppName "AKK En-to-MM Dictionary"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "AKK Dictionary Team"
#define MyAppExeName "AKK En-to-MM Dictionary.exe"
#define MyAppUrl "https://github.com"
#define SourcePath "bin\Release\net8.0-windows\win-x64\publish"

[Setup]
AppId={{8F2E3E8C-9E7D-4F3D-8C5B-2E1A4F7C3B9D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppUrl}
AppSupportURL={#MyAppUrl}
AppUpdatesURL={#MyAppUrl}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENSE.txt
OutputDir=bin\Installers
OutputBaseFilename=AKK_En-to-MM_Dictionary_Setup_v{#MyAppVersion}
SetupIconFile=Assets\akk.ico
WizardStyle=modern
WizardSizePercent=100
UsePreviousAppDir=yes
DisableReadyPage=no
UninstallDisplayName={#MyAppName}
VersionInfoVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIconTask}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIconTask}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked and compat2and3
Name: "startmenu"; Description: "Create Start Menu shortcut"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checked

[Files]
Source: "{#SourcePath}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourcePath}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "dictionary.db"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Add LICENSE file if it exists
Source: "LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion; Check: FileExists('{#SourcePath}\..\..\..\LICENSE.txt')

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFileName: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFileName: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Registry]
Root: "HKCU"; Subkey: "Software\{#MyAppPublisher}\{#MyAppName}"; Flags: uninsdeletekey

[Code]
function FileExists(const FileName: string): boolean;
begin
  Result := FileExists(ExpandConstant(FileName));
end;
