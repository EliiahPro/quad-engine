//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//=============================================================================

unit QuadEngine.Profiler;

interface

uses
  Windows;

type
  TAPIType = (
              atInvalid = 0,
              atBeginScene = 1,
              atEndScene = 2,
              atClear = 3,
              atDraw = 4,
              atRectangle = 5,
              atSetRenderTarget = 6,
              atFlushBuffer = 7,
              atSetBlendMode = 8
              );

  TAPICall = packed record
    Calls: Cardinal;
    Time: Double;
    TimeFastest: Double;
    TimeSlowest: Double;
  end;

  TAPICalls = array[TAPIType] of TAPICall;

  TQuadProfiler = class
  strict private
    class var FInstance: TQuadProfiler;
    procedure Initialize;
  private
    FCurrentAPICalls: TAPICalls;
    FCurrentAPICallsStartTime: array[TAPIType] of Int64;
    FCurrentTickStartTime: Int64;
    FPerformanceFrequency: Int64;
  public
    procedure BeginCount(APItype: TAPIType);
    procedure EndCount(APItype: TAPIType);
    procedure BeginTick;
    procedure EndTick;

    class function Create: TQuadProfiler;
    procedure FreeInstance; override;
  end;

implementation

uses
  Math;

{ TQuadProfiler }

procedure TQuadProfiler.BeginCount(APItype: TAPIType);
begin
  QueryPerformanceCounter(FCurrentAPICallsStartTime[APItype]);
end;

procedure TQuadProfiler.BeginTick;
var
  i: TAPIType;
begin
  QueryPerformanceCounter(FCurrentTickStartTime);

  for i := Low(TAPIType) to High(TAPIType) do
  begin
    FCurrentAPICalls[i].Calls := 0;
    FCurrentAPICalls[i].Time := 0.0;
    FCurrentAPICalls[i].TimeFastest := MaxDouble;
    FCurrentAPICalls[i].TimeSlowest := 0.0;
  end;
end;

class function TQuadProfiler.Create: TQuadProfiler;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := inherited NewInstance as Self;
    FInstance.Initialize;
  end;

  Result := FInstance;
end;

procedure TQuadProfiler.EndCount(APItype: TAPIType);
var
  Counter: Int64;
  Time: Double;
begin
  Inc(FCurrentAPICalls[APItype].Calls);

  QueryPerformanceCounter(Counter);
  Time := (Counter - FCurrentAPICallsStartTime[APItype]) / FPerformanceFrequency;

  FCurrentAPICalls[APItype].Time := FCurrentAPICalls[APItype].Time + Time;

  if FCurrentAPICalls[APItype].TimeFastest > Time then
    FCurrentAPICalls[APItype].TimeFastest := Time;

  if FCurrentAPICalls[APItype].TimeSlowest < Time then
    FCurrentAPICalls[APItype].TimeSlowest := Time;
end;

procedure TQuadProfiler.EndTick;
begin

end;

procedure TQuadProfiler.FreeInstance;
begin
  if Assigned(FInstance) then
    FInstance := nil;

  inherited FreeInstance;
end;


procedure TQuadProfiler.Initialize;
begin
  QueryPerformanceFrequency(FPerformanceFrequency);

  FillChar(FCurrentAPICalls, SizeOf(FCurrentAPICalls), 0);
end;

end.
