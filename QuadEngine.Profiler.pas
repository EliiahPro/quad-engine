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
  TProfilerInfo = packed record
    GUID: TGUID;
    DateTime: Double;
    TagsCount: Byte;
  end;

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
    function GetName: PWideChar; stdcall;
    procedure Refresh;
    property Name: WideString read FName;
    property Call: TAPICall read FCurrentAPICall;
  end;

  TQuadProfiler = class(TInterfacedObject, IQuadProfiler)
  private
    FName: WideString;
    FIsSend: Boolean;
    FServerAdress: AnsiString;
    FServerPort: Word;

    FInfo: TProfilerInfo;
    FTags: TList<TQuadProfilerTag>;
    FSocket: TQuadSocket;
    FSocketAddress: PQuadSocketAddressItem;
    procedure LoadFromIniFile;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateTag(AName: PWideChar; out ATag: IQuadProfilerTag): HResult; stdcall;
    procedure BeginTick; stdcall;
    procedure EndTick; stdcall;
    procedure SetAdress(AAdress: PAnsiChar; APort: Word = 17788); stdcall;
    procedure SetGUID(const AGUID: TGUID); stdcall;
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

function TQuadProfilerTag.GetName: PWideChar; stdcall;
begin
  Result := PWideChar(FName);
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

procedure TQuadProfiler.LoadFromIniFile;
var
  ini: TIniFile;
begin
  if not FileExists('QuadConfig.ini') then
    Exit;

  ini := TIniFile.Create('QuadConfig.ini');
  try
    FServerAdress := ini.ReadString('Profiler', 'Adress', '127.0.0.1');
    FServerPort := ini.ReadInteger('Profiler', 'Port', 17788);
    FIsSend := True;
  finally
    ini.Free;
  end;

end;

constructor TQuadProfiler.Create;
begin
  inherited Create;
  FTags := TList<TQuadProfilerTag>.Create;
  FIsSend := False;
  CreateGUID(FInfo.GUID);

  LoadFromIniFile;
  if FIsSend then
    SetAdress(PAnsiChar(FServerAdress), FServerPort);
end;

procedure TQuadProfiler.SetAdress(AAdress: PAnsiChar; APort: Word = 17788); stdcall;
begin
  if not Assigned(FSocket) then
    FSocket := TQuadSocket.Create;

  FIsSend := True;
  FServerAdress := AAdress;
  FServerPort := APort;
  FSocket.InitSocket;
  FSocketAddress := FSocket.CreateAddress(PAnsiChar(FServerAdress), FServerPort);
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
var
  Tag: TQuadProfilerTag;
begin
  if FIsSend and Assigned(FSocket) then
  begin
    FSocket.Clear;
    FInfo.TagsCount := FTags.Count;
    FSocket.Write(@FInfo, SizeOf(FInfo));

    for Tag in FTags do
      FSocket.Write(@Tag.Call, SizeOf(Tag.Call));

    FSocket.Send(FSocketAddress);
  end;
end;

procedure TQuadProfiler.SetGUID(const AGUID: TGUID);
begin
  FInfo.GUID := AGUID;
end;

initialization
  TQuadProfilerTag.Init;

end.
