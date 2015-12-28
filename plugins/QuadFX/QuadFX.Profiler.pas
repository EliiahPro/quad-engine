unit QuadFX.Profiler;

interface

uses
  Winapi.Windows, System.SysUtils, System.SyncObjs, TypInfo, QuadEngine.Socket;

type
  TQuadFXProfilerType = (
    ptUpdate = 0,
    ptDraw = 1,
    ptEffects = 2,
    ptEmitters = 3,
    ptParticlesAdd = 4,
    ptParticles = 5,
    ptParticlesUpdate = 6,
    ptParticlesVertexes = 7,
    ptParticlesParams = 8
  );

  TQuadFXProfilerItem = packed record
    Num: Cardinal;
    Count: Int64;
    CountFastest: Int64;
    CountSlowest: Int64;
  end;

  TQuadFXProfiler = class
  private
    FFilename: string;
    FSync: TCriticalSection;
    FSocket: TQuadSocket;
    FSocketAddress: PQuadSocketAddressItem;

    FPerformanceFrequency: Int64;
    FTime: Double;
    FCountStart: array[TQuadFXProfilerType] of Int64;
    FData: array[TQuadFXProfilerType] of TQuadFXProfilerItem;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    procedure BeginCount(AType: TQuadFXProfilerType);
    procedure EndCount(AType: TQuadFXProfilerType);
    procedure BeginTick(const ADelta: Double);
    procedure EndTick;

    procedure Write(AString: PWideChar); stdcall;
  end;

//var
  //Profiler: TQuadFXProfiler;

implementation

constructor TQuadFXProfiler.Create;
var
  f: TextFile;
  Str, Name: String;
  i: TQuadFXProfilerType;
begin
  FTime := 0;
  FSync := TCriticalSection.Create;
  QueryPerformanceFrequency(FPerformanceFrequency);
  {
  FFilename := 'QuadFX.csv';
  if FileExists(FFilename) then
    DeleteFile(Pchar(FFilename));

  AssignFile(f, FFilename);
  try
    Rewrite(f);
  finally
    CloseFile(f);
  end;

  Str := '';
  for i := Low(TQuadFXProfilerType) to High(TQuadFXProfilerType) do
  begin
    Name := GetEnumName(System.TypeInfo(TQuadFXProfilerType), Integer(i));
    Str := Str + Name + ';';
  end;

  for i := Low(TQuadFXProfilerType) to High(TQuadFXProfilerType) do
  begin
    Name := GetEnumName(System.TypeInfo(TQuadFXProfilerType), Integer(i));
    Str := Str +
      Name + 'N;' +
      Name + 'F;' +
      Name + 'S;';
  end;
  Write(PWideChar(Str));
  }
  FSocket := TQuadSocket.Create;
  FSocket.InitSocket;
  FSocketAddress := FSocket.CreateAddress('127.0.0.1', 17788);
end;

destructor TQuadFXProfiler.Destroy;
begin
  FSocket.Free;
  FSync.Free;
  inherited;
end;

procedure TQuadFXProfiler.BeginCount(AType: TQuadFXProfilerType);
begin
  QueryPerformanceCounter(FCountStart[AType]);
end;

procedure TQuadFXProfiler.EndCount(AType: TQuadFXProfilerType);
var
  Counter: Int64;
begin
  QueryPerformanceCounter(Counter);
  Counter := (Counter - FCountStart[AType]);
  FData[AType].Count := FData[AType].Count + Counter;

  Inc(FData[AType].Num);

  if FData[AType].CountFastest > Counter then
    FData[AType].CountFastest := Counter;

  if FData[AType].CountSlowest < Counter then
    FData[AType].CountSlowest := Counter;
end;

procedure TQuadFXProfiler.BeginTick(const ADelta: Double);
var
  i: TQuadFXProfilerType;
begin
  FTime := FTime + ADelta;
  for i := Low(TQuadFXProfilerType) to High(TQuadFXProfilerType) do
  begin
    FData[i].Num := 0;
    FData[i].Count := 0;
    FData[i].CountFastest := MAXDWORD;
    FData[i].CountSlowest := 0;
  end;
end;

procedure TQuadFXProfiler.EndTick;
type
  TCell = packed record
    ID: Integer;
    Time: Double;
    Value: Double;
    ValueFastest: Double;
    ValueSlowest: Double;
    ValueCount: Integer;
  end;

  function ToTime(ACount: Int64): Double;
  begin
    Result := ACount / FPerformanceFrequency * 1000;
  end;
var
  i: TQuadFXProfilerType;
  //Str: String;
  Cell: TCell;
begin
{
  Str := '';
    Str := Str + ToTime(FData[i].Count);

  for i := Low(TQuadFXProfilerType) to High(TQuadFXProfilerType) do
    Str := Str + IntToStr(FData[i].Num) + ';' + ToTime(FData[i].CountFastest) + ToTime(FData[i].CountSlowest);

  Write(PWideChar(Str));
  }
  Cell.Time := FTime;
  for i := Low(TQuadFXProfilerType) to High(TQuadFXProfilerType) do
  begin
    Cell.ID := Integer(i);
    Cell.Value := ToTime(FData[i].Count);
    Cell.ValueFastest := ToTime(FData[i].CountFastest);
    Cell.ValueSlowest := ToTime(FData[i].CountSlowest);
    Cell.ValueCount := FData[i].Num;
    FSocket.Clear;
    FSocket.Write(@Cell, SizeOf(Cell));
    FSocket.Send(FSocketAddress);
  end;

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
     {
initialization
  Profiler := TQuadFXProfiler.Create;

finalization
  if Assigned(Profiler) then
    Profiler.Free;
       }
end.
