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
  Winapi.Windows, System.SysUtils, System.SyncObjs, TypInfo, QuadEngine.Socket, IniFiles, QuadEngine,
  System.Generics.collections;

type
  TAPICall = packed record
    Calls: Cardinal;
    Time: Double;
    TimeFastest: Double;
    TimeSlowest: Double;
  end;

  TQuadProfilerTag = class(TInterfacedObject, IQuadProfilerTag)
  private
    class var FPerformanceFrequency: Int64;
    class procedure Init;
  private
    FName: WideString;
    FCurrentAPICallStartTime: Int64;
    FCurrentAPICall: TAPICall;
  public
    constructor Create(const AName: PWideChar);
    procedure BeginCount; stdcall;
    procedure EndCount; stdcall;
    procedure Refresh;
    property Name: WideString read FName;
  end;

  TQuadProfiler = class(TInterfacedObject, IQuadProfiler)
  private
    FTags: TList<TQuadProfilerTag>;
    //FSocket: TQuadSocket;
    //FSocketAddress: PQuadSocketAddressItem;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateTag(AName: PWideChar; out ATag: IQuadProfilerTag): HResult; stdcall;
    procedure BeginTick; stdcall;
    procedure EndTick; stdcall;
  end;

implementation

uses
  Math;

{ TQuadProfilerTag }

class procedure TQuadProfilerTag.Init;
begin
  QueryPerformanceFrequency(FPerformanceFrequency);
end;

constructor TQuadProfilerTag.Create(const AName: PWideChar);
begin
  inherited Create;
  FName := AName;
  Refresh;
end;

procedure TQuadProfilerTag.BeginCount; stdcall;
begin
  QueryPerformanceCounter(FCurrentAPICallStartTime);
end;

procedure TQuadProfilerTag.EndCount; stdcall;
var
  Counter: Int64;
  Time: Double;
begin
  Inc(FCurrentAPICall.Calls);

  QueryPerformanceCounter(Counter);
  Time := (Counter - FCurrentAPICallStartTime) / FPerformanceFrequency;

  FCurrentAPICall.Time := FCurrentAPICall.Time + Time;

  if FCurrentAPICall.TimeFastest > Time then
    FCurrentAPICall.TimeFastest := Time;

  if FCurrentAPICall.TimeSlowest < Time then
    FCurrentAPICall.TimeSlowest := Time;
end;

procedure TQuadProfilerTag.Refresh;
begin
  FCurrentAPICall.Calls := 0;
  FCurrentAPICall.Time := 0.0;
  FCurrentAPICall.TimeFastest := MaxDouble;
  FCurrentAPICall.TimeSlowest := 0.0;
end;

{ TQuadProfiler }

function TQuadProfiler.CreateTag(AName: PWideChar; out ATag: IQuadProfilerTag): HResult; stdcall;
var
  Tag: TQuadProfilerTag;
begin
  Tag := TQuadProfilerTag.Create(AName);
  FTags.Add(Tag);
  ATag := Tag;
  if Assigned(ATag) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

constructor TQuadProfiler.Create;
begin
  inherited Create;
  FTags := TList<TQuadProfilerTag>.Create;

  //FSocket := TQuadSocket.Create;
  //FSocket.InitSocket;
  //FSocketAddress := FSocket.CreateAddress('127.0.0.1', 17788);
end;

destructor TQuadProfiler.Destroy;
begin
  FTags.Free;
  inherited;
end;

procedure TQuadProfiler.BeginTick;
var
  Tag: TQuadProfilerTag;
begin
  for Tag in FTags do
    Tag.Refresh;

end;

procedure TQuadProfiler.EndTick;
begin

end;

initialization
  TQuadProfilerTag.Init;

end.
