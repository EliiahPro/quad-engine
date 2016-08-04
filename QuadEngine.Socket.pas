unit QuadEngine.Socket;

interface

uses
  Winapi.Windows, Winapi.Winsock2,  System.Generics.Collections, Winapi.Messages,
  System.Classes, System.SyncObjs, System.SysUtils;

const
  WM_SOCKETMESSAGE = WM_USER + 1;

type
  TQuadSocket = class
  private
    class var FWSAData: TWSAData;
    class procedure Startup;
    class procedure Cleanup;
  private
    FSocket: TSocket;
    FCriticalSection: TCriticalSection;
    FConnected: Boolean;
  public
    constructor Create(ASocket: TSocket);
    destructor Destroy; override;
    function ReceiveBuf(var ABuf; ACount: Integer): Integer;
    function ReceiveLength: Integer;
    function ReceiveText: AnsiString;
    function ReceiveStream(AMemory: TMemoryStream): Integer;
    function SendBuf(var ABuf; ACount: Integer): Integer;
    function SendText(const AText: AnsiString): Integer;
    function SendStream(AMemory: TMemoryStream): Integer;

    property Connected: Boolean read FConnected;
  end;

  TQuadCustomSocket = class(TQuadSocket)
  private
    FHandle: HWnd;
    FAddr: TSockAddrIn;
    procedure WndProc(var Message: TMessage);
    procedure WMSocketMessage(var Msg: TMessage); message WM_SOCKETMESSAGE;
    procedure DoRead(ASocket: TSocket); virtual;
    procedure DoWrite(ASocket: TSocket); virtual;
    procedure DoAccept(ASocket: TSocket); virtual;
    procedure DoConnect(ASocket: TSocket); virtual;
    procedure DoClose(ASocket: TSocket); virtual;
  protected
    procedure InitSocket(const AAddress: string; APort: Word);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Open; virtual;
  end;

  TQuadServerSocket = class;
  TQuadServerNotifyEvent = reference to procedure(AServer: TQuadServerSocket; AClient: TQuadSocket);

  TQuadServerSocket = class(TQuadCustomSocket)
  private
    FClients: TObjectList<TQuadSocket>;

    FOnClientConnect: TQuadServerNotifyEvent;
    FOnClientDisconnect: TQuadServerNotifyEvent;
    FOnRead: TQuadServerNotifyEvent;
    FOnWrite: TQuadServerNotifyEvent;

    function GetClient(Index: Integer): TQuadSocket;
    function GetClientCount: Integer;
    function FindClientBySocket(ASocket: TSocket): TQuadSocket;

    procedure DoRead(ASocket: TSocket); override;
   // procedure DoWrite(ASocket: TSocket); override;
    procedure DoAccept(ASocket: TSocket); override;
    procedure DoClose(ASocket: TSocket); override;
  public
    constructor Create(APort: Word);
    destructor Destroy; override;
    procedure Open; override;

    property Clients[Index: Integer]: TQuadSocket read GetClient;
    property ClientCount: Integer read GetClientCount;

    property OnClientConnect: TQuadServerNotifyEvent read FOnClientConnect write FOnClientConnect;
    property OnClientDisconnect: TQuadServerNotifyEvent read FOnClientDisconnect write FOnClientDisconnect;
    property OnRead: TQuadServerNotifyEvent read FOnRead write FOnRead;
    property OnWrite: TQuadServerNotifyEvent read FOnWrite write FOnWrite;
  end;

  TQuadClientSocket = class;
  TQuadClientNotifyEvent = reference to procedure(AClient: TQuadClientSocket);

  TQuadClientSocket = class(TQuadCustomSocket)
  private
    FOnConnect: TQuadClientNotifyEvent;
    FOnDisconnect: TQuadClientNotifyEvent;
    FOnRead: TQuadClientNotifyEvent;
    FOnWrite: TQuadClientNotifyEvent;

    procedure DoRead(ASocket: TSocket); override;
   // procedure DoWrite(ASocket: TSocket); override;
    procedure DoConnect(ASocket: TSocket); override;
    procedure DoClose(ASocket: TSocket); override;
  public
    constructor Create(const AAddress: string; APort: Word);
    destructor Destroy; override;
    procedure Open; override;

    property OnConnect: TQuadClientNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TQuadClientNotifyEvent read FOnDisconnect write FOnDisconnect;
    property OnRead: TQuadClientNotifyEvent read FOnRead write FOnRead;
    property OnWrite: TQuadClientNotifyEvent read FOnWrite write FOnWrite;
  end;

implementation

uses
  QuadEngine.Device;

{ TQuadSocket }

class procedure TQuadSocket.Startup;
begin
  WSAStartup(MakeWord(2, 2), FWSAData);
end;

class procedure TQuadSocket.Cleanup;
begin
  WSACleanup;
end;

constructor TQuadSocket.Create(ASocket: TSocket);
begin
  FCriticalSection := TCriticalSection.Create;
  FSocket := ASocket;
end;

destructor TQuadSocket.Destroy;
begin
  FCriticalSection.Free;
  inherited;
end;

function TQuadSocket.SendBuf(var ABuf; ACount: Integer): Integer;
begin
  FCriticalSection.Enter;
  try
    Result := send(FSocket, Pointer(@ABuf)^, ACount, 0);
  finally
    FCriticalSection.Leave;
  end;
end;

function TQuadSocket.SendText(const AText: AnsiString): Integer;
begin
  Result := SendBuf(Pointer(AText)^, Length(AText) * SizeOf(AnsiChar));
end;

function TQuadSocket.SendStream(AMemory: TMemoryStream): Integer;
var
  Len: Integer;
begin
  if Assigned(AMemory) and (AMemory.Size > 0) then
    Result := SendBuf(PByteArray(AMemory.Memory)[0], AMemory.Size);
end;

function TQuadSocket.ReceiveBuf(var ABuf; ACount: Integer): Integer;
var
  Cnt: Cardinal;
  ErrorCode: Integer;
begin
  Result := 0;
  FCriticalSection.Enter;
  try
    if ACount >= 0 then
    begin
      if ioctlsocket(FSocket, FIONREAD, Cnt) = 0 then
      begin
        if (Cnt > 0) and (Integer(Cnt) < ACount) then
          ACount := Cnt;
      end;

      Result := recv(FSocket, ABuf, ACount, 0);
      if Result = SOCKET_ERROR then
      begin
        ErrorCode := WSAGetLastError; //Form2.AddLog(Format('Error %d', [ErrorCode]));
      end;
    end
    else
      ioctlsocket(FSocket, FIONREAD, Cardinal(Result));
  finally
    FCriticalSection.Leave;
  end;
end;

function TQuadSocket.ReceiveStream(AMemory: TMemoryStream): Integer;
var
  Len: Integer;
begin
  if not Assigned(AMemory) then
    Exit;
  AMemory.Clear;
  Len := ReceiveLength;
  AMemory.SetSize(Len);
  ReceiveBuf(Pointer(AMemory.Memory)^, Len);
  AMemory.Position := 0;
end;

function TQuadSocket.ReceiveLength: Integer;
begin
  Result := ReceiveBuf(Pointer(nil)^, -1);
end;

function TQuadSocket.ReceiveText: AnsiString;
var
  LenStr: Integer;
begin
  LenStr := ReceiveLength;
  if LenStr <= 0 then
    Exit('');
  SetLength(Result, LenStr);
  ReceiveBuf(Pointer(Result)^, LenStr);
end;

{ TQuadCustomSocket }

constructor TQuadCustomSocket.Create;
begin
  Startup;
  FHandle := AllocateHwnd(WndProc);
  inherited Create(socket(PF_INET, SOCK_STREAM, IPPROTO_IP));
end;

destructor TQuadCustomSocket.Destroy;
begin
  if FHandle <> 0 then
    DeallocateHWnd(FHandle);
  Cleanup;
  inherited;
end;

procedure TQuadCustomSocket.InitSocket(const AAddress: string; APort: Word);
begin
  FAddr.sin_family := PF_INET;
  if AAddress <> '' then
    FAddr.sin_addr.s_addr := inet_addr(PAnsiChar(AnsiString(AAddress)))
  else
    FAddr.sin_addr.s_addr := INADDR_ANY;
  FAddr.sin_port := htons(APort);
  FillChar(FAddr.sin_zero, SizeOf(FAddr.sin_zero), 0);
end;

procedure TQuadCustomSocket.Open;
begin
  WSAAsyncSelect(FSocket, FHandle, WM_SOCKETMESSAGE, FD_WRITE or FD_READ or FD_CONNECT or FD_ACCEPT or FD_CLOSE);
end;

procedure TQuadCustomSocket.WndProc(var Message: TMessage);
begin
  Dispatch(Message);
end;

procedure TQuadCustomSocket.WMSocketMessage(var Msg: TMessage);
begin
  case WSAGetSelectEvent(Msg.lParam) of
    FD_ACCEPT: DoAccept(TSocket(Msg.WParam));
    FD_CONNECT: DoConnect(TSocket(Msg.WParam));
    FD_CLOSE: DoClose(TSocket(Msg.WParam));
    FD_READ: DoRead(TSocket(Msg.WParam));
    FD_WRITE: DoWrite(TSocket(Msg.WParam));
  end;
end;

procedure TQuadCustomSocket.DoRead(ASocket: TSocket);
begin

end;

procedure TQuadCustomSocket.DoWrite(ASocket: TSocket);
begin

end;

procedure TQuadCustomSocket.DoAccept(ASocket: TSocket);
begin

end;

procedure TQuadCustomSocket.DoConnect(ASocket: TSocket);
begin

end;

procedure TQuadCustomSocket.DoClose(ASocket: TSocket);
begin
  shutdown(ASocket, SD_SEND);
  closesocket(ASocket);
end;

{ TQuadServerSocket }

constructor TQuadServerSocket.Create(APort: Word);
begin
  inherited Create;
  FClients := TObjectList<TQuadSocket>.Create;
  InitSocket('', APort);
end;

destructor TQuadServerSocket.Destroy;
begin
  FClients.Free;
  inherited;
end;

procedure TQuadServerSocket.Open;
begin
  bind(FSocket, PSockAddr(@FAddr)^, SizeOf(FAddr));
  inherited Open;
  listen(FSocket, SOMAXCONN);
end;

procedure TQuadServerSocket.DoAccept(ASocket: TSocket);
var
  Client: TQuadSocket;
  Sock: TSocket;
  Addr: TSockAddrIn;
  Len: Integer;
begin
  Len := SizeOf(Addr);
  Sock := accept(ASocket, @Addr, @Len);
  if Sock <> INVALID_SOCKET then
  begin
    Client := TQuadSocket.Create(Sock);
    FClients.Add(Client);
    if Assigned(FOnClientConnect) then
      FOnClientConnect(Self, Client);
  end;
end;

procedure TQuadServerSocket.DoRead(ASocket: TSocket);
var
  Client: TQuadSocket;
begin
  Client := FindClientBySocket(ASocket);
  if Assigned(Client) and Assigned(FOnRead) then
    FOnRead(Self, Client);
end;

procedure TQuadServerSocket.DoClose(ASocket: TSocket);
var
  Client: TQuadSocket;
begin
  Client := FindClientBySocket(ASocket);
  if Assigned(Client) then
  begin
    if Assigned(FOnClientDisconnect) then
      FOnClientDisconnect(Self, Client);
    FClients.Remove(Client);
  end;
  inherited;
end;

function TQuadServerSocket.GetClient(Index: Integer): TQuadSocket;
begin
  if (Index < 0) or (Index >= FClients.Count) then
    Exit(nil);
  Result := FClients[Index];
end;

function TQuadServerSocket.GetClientCount: Integer;
begin
  Result := FClients.Count;
end;

function TQuadServerSocket.FindClientBySocket(ASocket: TSocket): TQuadSocket;
var
  Client: TQuadSocket;
begin
  for Client in FClients do
    if Client.FSocket = ASocket then
      Exit(Client);
  Result := nil;
end;

{ TQuadClientSocket }

constructor TQuadClientSocket.Create(const AAddress: string; APort: Word);
begin
  inherited Create;
  InitSocket(AAddress, APort);
end;

destructor TQuadClientSocket.Destroy;
begin

  inherited;
end;

procedure TQuadClientSocket.Open;
begin
  inherited Open;
  connect(FSocket, PSockAddr(@FAddr)^, SizeOf(FAddr));
end;

procedure TQuadClientSocket.DoConnect(ASocket: TSocket);
begin
  if Assigned(FOnConnect) then
    FOnConnect(Self);
end;

procedure TQuadClientSocket.DoClose(ASocket: TSocket);
begin
  if Assigned(FOnDisconnect) then
    FOnDisconnect(Self);
  inherited;
end;

procedure TQuadClientSocket.DoRead(ASocket: TSocket);
begin
  if Assigned(FOnDisconnect) then
    FOnRead(Self);
end;
        
end.
