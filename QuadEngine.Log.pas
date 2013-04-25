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
  Winapi.Windows, QuadEngine.Utils, QuadEngine, System.SysUtils;

type
  TQuadLog = class(TInterfacedObject, IQuadLog)
  private
    FFilename: string;
  public
    constructor Create(const AFilename: string = 'log.txt'); reintroduce;

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
procedure TQuadLog.Write(AString: PWideChar);
var
  f: TextFile;
begin
  AssignFile(f, FFilename);

  try
    Append(f);
    Writeln(f, {TimeToStr(Now) + ' : ' +} aString);
  finally
    CloseFile(f);
  end;
end;

end.
