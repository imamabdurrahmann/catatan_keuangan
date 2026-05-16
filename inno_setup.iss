[Setup]
; Unique ID for the app
AppId={{5C17173D-6E53-43EB-AC57-9F8F89A48C9A}
AppName=Catatan Keuangan
AppVersion=1.0.0
AppPublisher=DompetKu
AppPublisherURL=https://github.com
AppSupportURL=https://github.com
AppUpdatesURL=https://github.com
DefaultDirName={autopf}\CatatanKeuangan
DisableProgramGroupPage=yes
; The setup icon (Uses the generated Android logo which was converted to .ico)
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\catatan_keuangan.exe
Compression=lzma
SolidCompression=yes
WizardStyle=modern
OutputDir=build\installer
OutputBaseFilename=Setup_Catatan_Keuangan

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\catatan_keuangan.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Catatan Keuangan"; Filename: "{app}\catatan_keuangan.exe"
Name: "{autodesktop}\Catatan Keuangan"; Filename: "{app}\catatan_keuangan.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\catatan_keuangan.exe"; Description: "{cm:LaunchProgram,Catatan Keuangan}"; Flags: nowait postinstall skipifsilent
