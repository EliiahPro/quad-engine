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
  System.Generics.collections, System.Classes;

type
  TAPICall = record
    Time: TDateTime;
    Value: Double;
    Count: Integer;
    MaxValue: Double;
    MinValue: Double;
  end;

  TQuadProfilerTag = class(TInterfacedObject, IQuadProfilerTag)
  private
    class var FPerformanceFrequency: Int64;
    class var FNextID: Word;
    class procedure Init;
  private
    FID: Word;
    FName: WideString;
    FCurrentAPICallStartTime: Int64;
    FCurrentAPICall: TAPICall;
  public
    constructor Create(const AName: PWideChar);
    procedure BeginCount; stdcall;
    procedure EndCount; stdcall;
    function GetName: PWideChar; stdcall;
    procedure Refresh;
    procedure SetTime(ATime: TDateTime);

    property ID: Word read FID;
    property Name: WideString read FName;
    property Call: TAPICall read FCurrentAPICall;
  end;

  TQuadProfiler = class(TInterfacedObject, IQuadProfiler)
  private
    FGUID: TGUID;
    FName: WideString;
    FIsSend: Boolean;
    FServerAdress: AnsiString;
    FServerPort: Word;

    FTags: TList<TQuadProfilerTag>;

    FMemory: TMemoryStream;
    FSocket: TQuadSocket;
    FSocketAddress: PQuadSocketAddressItem;
    procedure LoadFromIniFile;
    procedure Recv;
  public
    constructor Create(AName: PWideChar);
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
  FNextID := 0;
end;

constructor TQuadProfilerTag.Create(const AName: PWideChar);
begin
  inherited Create;
  Inc(FNextID);
  FID := FNextID;
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
  Value: Double;
begin
  Inc(FCurrentAPICall.Count);

  QueryPerformanceCounter(Counter);
  Value := (Counter - FCurrentAPICallStartTime) / FPerformanceFrequency;

  FCurrentAPICall.Value := FCurrentAPICall.Value + Value;

  if FCurrentAPICall.MinValue > Value then
    FCurrentAPICall.MinValue := Value;

  if FCurrentAPICall.MaxValue < Value then
    FCurrentAPICall.MaxValue := Value;
end;

procedure TQuadProfilerTag.Refresh;
begin
  FCurrentAPICall.Count := 0;
  FCurrentAPICall.Value := 0.0;
  FCurrentAPICall.MaxValue := 0.0;
  FCurrentAPICall.MinValue := MaxDouble;
end;

function TQuadProfilerTag.GetName: PWideChar; stdcall;
begin
  Result := PWideChar(FName);
end;

procedure TQuadProfilerTag.SetTime(ATime: TDateTime);
begin
  FCurrentAPICall.Time := ATime;
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

constructor TQuadProfiler.Create(AName: PWideChar);
begin
  inherited Create;
  FName := AName;
  FTags := TList<TQuadProfilerTag>.Create;
  FIsSend := False;
  CreateGUID(FGUID);
  FMemory := TMemoryStream.Create;

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
  FMemory.Free;
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

procedure TQuadProfiler.Recv;
var
  Address: PQuadSocketAddressItem;
  Code, ID: Word;
  StrLength: Byte;
  Tag: TQuadProfilerTag;
begin
  while FSocket.Recv(Address, FMemory) do
    if FMemory.Size > 0 then
    begin

      FMemory.Read(Code, SizeOf(Code));
      case Code of
        2: // return profiler info
          begin
            FSocket.Clear;
            FSocket.SetCode(Code);
            FSocket.Write(FGUID, SizeOf(FGUID));
            StrLength := Length(FName);
            FSocket.Write(StrLength, SizeOf(StrLength));
            FSocket.Write(FName[1], StrLength * 2);
            FSocket.Send(Address);
          end;
        3: // return tag name
          begin
            FMemory.Read(ID, SizeOf(ID));
            for Tag in FTags do
              if Tag.ID = ID then
              begin
                FSocket.Clear;
                FSocket.SetCode(Code);
                FSocket.Write(FGUID, SizeOf(FGUID));
                FSocket.Write(ID, SizeOf(ID));
                StrLength := Length(Tag.Name);
                FSocket.Write(StrLength, SizeOf(StrLength));
                FSocket.Write(Tag.Name[1], StrLength * 2);
                FSocket.Send(Address);
                Break;
              end;
          end;
      end;
    end;
end;

procedure TQuadProfiler.EndTick;
var
  Tag: TQuadProfilerTag;
  Code: Word;
  TagsCount: Word;
begin
  if FIsSend and Assigned(FSocket) then
  begin
    Recv;

    FSocket.Clear;
    Code := 1;
    FSocket.Write(Code, SizeOf(Code));
    FSocket.Write(FGUID, SizeOf(FGUID));
    TagsCount := FTags.Count;
    FSocket.Write(TagsCount, SizeOf(TagsCount));

    for Tag in FTags do
    begin
      Tag.SetTime(Now);
      FSocket.Write(Tag.ID, SizeOf(Tag.ID));
      FSocket.Write(Tag.Call, SizeOf(Tag.Call));
    end;

    FSocket.Send(FSocketAddress);
  end;
end;

procedure TQuadProfiler.SetGUID(const AGUID: TGUID);
begin
  FGUID := AGUID;
end;

initialization
  TQuadProfilerTag.Init;

end.
