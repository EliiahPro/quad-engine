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

  TQuadProfilerTag = class;

  TOnSendMessageEvent = procedure(ATag: TQuadProfilerTag; AMessage: PWideChar; AMessageType: TQuadProfilerMessageType) of object;

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
    FOnSendMessage: TOnSendMessageEvent;
  public
    constructor Create(const AName: PWideChar);
    procedure BeginCount; stdcall;
    procedure EndCount; stdcall;
    function GetName: PWideChar; stdcall;
    procedure SendMessage(AMessage: PWideChar; AMessageType: TQuadProfilerMessageType = pmtMessage); stdcall;
    procedure Refresh;
    procedure SetTime(ATime: TDateTime);
    procedure SetOnSendMessage(AOnSendMessage: TOnSendMessageEvent);

    property ID: Word read FID;
    property Name: WideString read FName;
    property Call: TAPICall read FCurrentAPICall;
  end;

  TQuadProfilerMessage = record
    ID: Word;
    DateTime: TDateTime;
    MessageType: TQuadProfilerMessageType;
    MessageText: WideString;
  end;

  TQuadProfiler = class(TInterfacedObject, IQuadProfiler)
  private
    FConnected: Boolean;
    FGUID: TGUID;
    FName: WideString;
    FIsSend: Boolean;
    FServerAdress: AnsiString;
    FServerPort: Word;

    FTags: TList<TQuadProfilerTag>;

    FMemory: TMemoryStream;
    FClientSocket: TQuadClientSocket;

    FMessages: TQueue<TQuadProfilerMessage>;

    procedure LoadFromIniFile;
    procedure AddMessage(ATag: TQuadProfilerTag; AMessage: PWideChar; AMessageType: TQuadProfilerMessageType);
    procedure ClientSocketRead(AClient: TQuadClientSocket);
    procedure ClientSocketConnect(AClient: TQuadClientSocket);
    procedure ClientSocketDisconnect(AClient: TQuadClientSocket);
  public
    constructor Create(AName: PWideChar);
    destructor Destroy; override;
    function CreateTag(AName: PWideChar; out ATag: IQuadProfilerTag): HResult; stdcall;
    procedure BeginTick; stdcall;
    procedure EndTick; stdcall;
    procedure SetAdress(AAddress: PAnsiChar; APort: Word = 17788); stdcall;
    procedure SetGUID(const AGUID: TGUID); stdcall;
    procedure SendMessage(AMessage: PWideChar; AMessageType: TQuadProfilerMessageType = pmtMessage); stdcall;
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

procedure TQuadProfilerTag.BeginCount;
begin
  QueryPerformanceCounter(FCurrentAPICallStartTime);
end;

procedure TQuadProfilerTag.EndCount;
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

function TQuadProfilerTag.GetName: PWideChar;
begin
  Result := PWideChar(FName);
end;

procedure TQuadProfilerTag.SetTime(ATime: TDateTime);
begin
  FCurrentAPICall.Time := ATime;
end;

procedure TQuadProfilerTag.SetOnSendMessage(AOnSendMessage: TOnSendMessageEvent);
begin
  FOnSendMessage := AOnSendMessage;
end;

procedure TQuadProfilerTag.SendMessage(AMessage: PWideChar; AMessageType: TQuadProfilerMessageType = pmtMessage);
begin
  if Assigned(FOnSendMessage) then
    FOnSendMessage(Self, AMessage, AMessageType);
end;

{ TQuadProfiler }

function TQuadProfiler.CreateTag(AName: PWideChar; out ATag: IQuadProfilerTag): HResult;
var
  Tag: TQuadProfilerTag;
begin
  Tag := TQuadProfilerTag.Create(AName);
  FTags.Add(Tag);
  Tag.SetOnSendMessage(AddMessage);
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
  FConnected := False;
  FName := AName;
  FTags := TList<TQuadProfilerTag>.Create;
  FIsSend := False;
  CreateGUID(FGUID);
  FMemory := TMemoryStream.Create;
  FMessages := TQueue<TQuadProfilerMessage>.Create;
  FClientSocket := nil;
  LoadFromIniFile;
  if FIsSend then
    SetAdress(PAnsiChar(FServerAdress), FServerPort);
end;

procedure TQuadProfiler.SetAdress(AAddress: PAnsiChar; APort: Word = 17788);
begin
  FIsSend := True;
  if not Assigned(FClientSocket) then
  begin
    FClientSocket := TQuadClientSocket.Create(FServerAdress, FServerPort);
    FClientSocket.OnConnect := ClientSocketConnect;
    FClientSocket.OnDisconnect := ClientSocketDisconnect;
    FClientSocket.OnRead := ClientSocketRead;
    FClientSocket.Open;
  end;
end;

destructor TQuadProfiler.Destroy;
begin
  if Assigned(FClientSocket) then
    FClientSocket.Free;
  if Assigned(FMessages) then
    FMessages.Free;
  if Assigned(FMemory) then
    FMemory.Free;
  if Assigned(FTags) then
    FTags.Free;
  inherited;
end;

procedure TQuadProfiler.SendMessage(AMessage: PWideChar; AMessageType: TQuadProfilerMessageType = pmtMessage);
begin
  AddMessage(nil, AMessage, AMessageType);
end;

procedure TQuadProfiler.AddMessage(ATag: TQuadProfilerTag; AMessage: PWideChar; AMessageType: TQuadProfilerMessageType);
var
  Msg: TQuadProfilerMessage;
begin
  Msg.DateTime := Now;
  if Assigned(ATag) then
    Msg.ID := ATag.ID
  else
    Msg.ID := 0;
  Msg.MessageType := AMessageType;
  Msg.MessageText := AMessage;
  FMessages.Enqueue(Msg);
end;

procedure TQuadProfiler.BeginTick;
var
  Tag: TQuadProfilerTag;
begin
  for Tag in FTags do
    Tag.Refresh;
end;

procedure TQuadProfiler.ClientSocketConnect(AClient: TQuadClientSocket);
var
  Mem: TMemoryStream;
  Code: Word;
begin
  Mem := TMemoryStream.Create;
  try
    Code := 2;
    Mem.Write(Code, SizeOf(Code));
    Mem.Write(FGUID, SizeOf(FGUID));
    AClient.SendStream(Mem);
  finally
    Mem.Free;
  end;
  FConnected := True;
end;

procedure TQuadProfiler.ClientSocketDisconnect(AClient: TQuadClientSocket);
begin
  FConnected := False;
end;

procedure TQuadProfiler.ClientSocketRead(AClient: TQuadClientSocket);
var
  Code, ID: Word;
  StrLength: Byte;
  Tag: TQuadProfilerTag;
  Mem: TMemoryStream;
begin
  if AClient.ReceiveStream(FMemory) <= 0 then
    Exit;

  Mem := TMemoryStream.Create;
  try
    FMemory.Read(Code, SizeOf(Code));
    case Code of
      2: // return profiler info
        begin
          Mem.Write(Code, SizeOf(Code));
          Mem.Write(FGUID, SizeOf(FGUID));
          StrLength := Length(FName);
          Mem.Write(StrLength, SizeOf(StrLength));
          Mem.Write(FName[1], StrLength * 2);
          AClient.SendStream(Mem);
        end;
      3: // return tag name
        begin
          FMemory.Read(ID, SizeOf(ID));
          for Tag in FTags do
            if Tag.ID = ID then
            begin
              Mem.Write(Code, SizeOf(Code));
              Mem.Write(FGUID, SizeOf(FGUID));
              Mem.Write(ID, SizeOf(ID));
              StrLength := Length(Tag.Name);
              Mem.Write(StrLength, SizeOf(StrLength));
              Mem.Write(Tag.Name[1], StrLength * 2);
              AClient.SendStream(Mem);
              Break;
            end;
        end;
    end;
  finally
    Mem.Free;
  end;
end;

procedure TQuadProfiler.EndTick;
var
  Tag: TQuadProfilerTag;
  Code: Word;
  TagsCount: Word;
  i: Integer;
  Msg: TQuadProfilerMessage;
  StrLength: Byte;
  Mem: TMemoryStream;
begin
  if not FConnected then
    Exit;

  if FIsSend and Assigned(FClientSocket) then
  begin
    Mem := TMemoryStream.Create;
    try
      Code := 1;
      Mem.Write(Code, SizeOf(Code));
      Mem.Write(FGUID, SizeOf(FGUID));
      TagsCount := FTags.Count;
      Mem.Write(TagsCount, SizeOf(TagsCount));

      for Tag in FTags do
      begin
        Tag.SetTime(Now);
        Mem.Write(Tag.ID, SizeOf(Tag.ID));
        Mem.Write(Tag.Call, SizeOf(Tag.Call));
      end;

      FClientSocket.SendStream(Mem);

      for i := 0 to FMessages.Count - 1 do
      begin
        Code := 4;
        Msg := FMessages.Dequeue;

        Mem.Clear;
        Mem.Write(Code, SizeOf(Code));
        Mem.Write(FGUID, SizeOf(FGUID));
        Mem.Write(Msg.ID, SizeOf(Msg.ID));
        Mem.Write(Msg.DateTime, SizeOf(Msg.DateTime));
        Mem.Write(Msg.MessageType, SizeOf(Msg.MessageType));

        StrLength := Length(Msg.MessageText);
        Mem.Write(StrLength, SizeOf(StrLength));
        Mem.Write(Msg.MessageText[1], StrLength * 2);

        FClientSocket.SendStream(Mem);
      end;
    finally
      Mem.Free;
    end;
  end;
end;

procedure TQuadProfiler.SetGUID(const AGUID: TGUID);
begin
  FGUID := AGUID;
end;

initialization
  TQuadProfilerTag.Init;

end.
