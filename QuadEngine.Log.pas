{//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//=============================================================================}

unit QuadEngine.Log;

interface

uses
  Winapi.Windows, QuadEngine.Utils, QuadEngine, System.SysUtils, System.SyncObjs;

type
  TQuadLog = class(TInterfacedObject, IQuadLog)
  private
    FFilename: string;
    FSync: TCriticalSection;
  public
    constructor Create(const AFilename: string = 'log.txt'); reintroduce;
    destructor Destroy; override;

    procedure Write(AString: PWideChar); stdcall;
  end;

implementation

//uses QuadRender;

{ TQuadLog }

//=============================================================================
//
//=============================================================================
constructor TQuadLog.Create(const AFilename: string);
var
  f: TextFile;
begin
  FSync := TCriticalSection.Create;
  FFilename := aFilename;
  if FileExists(FFilename) then
    DeleteFile(Pchar(FFilename));

  AssignFile(f, FFilename);
  try
    Rewrite(f);
  finally
    CloseFile(f);
  end;
end;

//=============================================================================
//
//=============================================================================
destructor TQuadLog.Destroy;
begin
  FSync.Free;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadLog.Write(AString: PWideChar);
var
  f: TextFile;
begin
  FSync.Enter;
  AssignFile(f, FFilename);

  try
    Append(f);
    Writeln(f, PWideChar('[' + IntToStr(GetCurrentThreadId) + ']: ' + aString));
  finally
    CloseFile(f);
  end;
  FSync.Leave;
end;

end.
