unit QuadFX.Profiler;

interface

uses
  Winapi.Windows, System.SysUtils, System.SyncObjs;

type
  TQuadFXProfiler = class
  private
    FFilename: string;
    FSync: TCriticalSection;

    FPerformanceFrequency: Int64;
    FPerformanceLastCounter: Int64;
    FPerformanceCounter: Int64;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function StartPerformanceCounter: Int64;
    procedure EndPerformanceCounter(const AText: WideString; AStart: Int64);
    procedure Write(AString: PWideChar); stdcall;
  end;

var
  Profiler: TQuadFXProfiler;

implementation

constructor TQuadFXProfiler.Create;
var
  f: TextFile;
begin
  FSync := TCriticalSection.Create;
  FFilename := 'QuadFX.log';
  if FileExists(FFilename) then
    DeleteFile(Pchar(FFilename));

  AssignFile(f, FFilename);
  try
    Rewrite(f);
  finally
    CloseFile(f);
  end;

  QueryPerformanceFrequency(FPerformanceFrequency);
  QueryPerformanceCounter(FPerformanceCounter);
  FPerformanceLastCounter := FPerformanceCounter;
end;

destructor TQuadFXProfiler.Destroy;
begin
  FSync.Free;
  inherited;
end;

function TQuadFXProfiler.StartPerformanceCounter: Int64;
begin
  QueryPerformanceCounter(Result);
end;

procedure TQuadFXProfiler.EndPerformanceCounter(const AText: WideString; AStart: Int64);
var
  Counter: Int64;
begin
  QueryPerformanceCounter(Counter);
  Write(PWideChar(
    AText + ' - ' + IntToStr(Counter - AStart)
  ));
end;

procedure TQuadFXProfiler.Write(AString: PWideChar);
var
  f: TextFile;
begin
  FSync.Enter;
  AssignFile(f, FFilename);

  try
    Append(f);
    Writeln(f, PWideChar(aString));
  finally
    CloseFile(f);
  end;
  FSync.Leave;
end;

initialization
  Profiler := TQuadFXProfiler.Create;

finalization
  if Assigned(Profiler) then
    Profiler.Free;

end.
