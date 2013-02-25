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
    constructor Create(const aFilename: string = 'log.txt'); reintroduce;
    
    procedure Write(const aString: string); stdcall;
  end;

implementation

//uses QuadRender;

{ TQuadLog }

//=============================================================================
//
//=============================================================================
constructor TQuadLog.Create(const aFilename: string);
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
procedure TQuadLog.Write(const aString: string);
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
