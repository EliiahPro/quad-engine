unit QuadEngine.Socket;

interface

uses
  Winapi.Windows, winapi.WinSock, System.Classes, System.SysUtils, System.Generics.Collections, System.DateUtils;

const
  BUFFER_SIZE = 1024;

type
  TQuadSocketType = (
    qstServer = 0,
    qstClient = 1
  );

  TQuadSocketPackedType = (
    qsptNone = 0,
    qsptConnect = 1,
    qsptDisconnect = 2,
    qsptPing = 3,
    qsptData = 4
  );

  PByteArray = ^TByteArray;
  TByteArray = array [0..(BUFFER_SIZE - 1)] of Byte;

  PQuadSocketAddressItem = ^TQuadSocketAddressItem;
  TQuadSocketAddressItem = packed record
    Addr: TSockAddrIn;
    Time: TDateTime;
  end;

  TQuadSocket = class
  private
    class var FActive: Boolean;
    class var FGlobalGUID: TGUID;
    FAddressList: TList<PQuadSocketAddressItem>;

    FSocket: Integer;
    FSendBuf: PByteArray;
    FSendBufLen: integer;
    FtmpBuf: PByteArray;
    FType: TQuadSocketType;

    class procedure Connect;
    class procedure Disconnect;
    function FindAddress(const AAddr: TSockAddrIn; out AAddress: PQuadSocketAddressItem): Boolean;
    function AddressAdd(const AAddr: TSockAddrIn): PQuadSocketAddressItem;
    procedure SetPackedType(AType: TQuadSocketPackedType);
    function GetAddress(Index: Integer): PQuadSocketAddressItem;
    function GetAddressCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateAddress(const AIP: PAnsiChar; APort: Word): PQuadSocketAddressItem;
    procedure InitSocket(APort: Word = 0);
    procedure Close;
    procedure Clear;
    function Write(ABuf: Pointer; ACount: Integer): Boolean;
    function Send(AAddress: PQuadSocketAddressItem): Integer;
    function Recv(out AAddress: PQuadSocketAddressItem; ABuffer: Pointer; var ALength: Integer): Boolean;

    property Address[Index: integer]: PQuadSocketAddressItem read GetAddress;
    property AddressCount: Integer read GetAddressCount;
  end;

implementation

constructor TQuadSocket.Create;
begin
  FSocket := -1;
  Connect;

  FAddressList := TList<PQuadSocketAddressItem>.Create;

  if FSendBuf = nil then
    GetMem(FSendBuf, BUFFER_SIZE);

  if FtmpBuf = nil then
    GetMem(FtmpBuf, BUFFER_SIZE);
end;

destructor TQuadSocket.Destroy;
begin
  if FSocket > 0 then
    CloseSocket(FSocket);
  FAddressList.Free;
  FSocket := -1;
  FreeMem(FSendBuf);
  FSendBuf := nil;
  FSendBufLen := 0;
  FreeMem(FtmpBuf);
  FtmpBuf := nil;

  Disconnect;
  inherited;
end;

procedure TQuadSocket.Clear;
begin
  SetPackedType(qsptData);
  FSendBufLen := 1;
end;

class procedure TQuadSocket.Connect;
var
  Data: WSAData;
  Error: integer;
begin
  if not FActive then
  begin
    Error := WSAStartup(MakeWord(2, 2), Data);
    if Error = 0 then
      FActive := True;
  end;
end;

class procedure TQuadSocket.Disconnect;
begin
  if FActive then
  begin
    WSACleanup;
    FActive := False;
  end;
end;

procedure TQuadSocket.InitSocket(APort: Word = 0);
var
  flag: integer;
  i: integer;
  Address: TSockAddrIn;
begin
  i := 1;
  flag := 1;

  if APort = 0 then
    FType := qstServer
  else
    FType := qstClient;

  if FSocket > 0 then
    CloseSocket(FSocket);

  FSocket := socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if FSocket = -1 then
    Exit;

  if ioctlsocket(FSocket, FIONBIO, flag) = -1 then
    Exit;

  setsockopt(FSocket, SOL_SOCKET, SO_BROADCAST, PAnsiChar(@i), SizeOf(i));

  Address.sin_addr.S_addr := INADDR_ANY;
  Address.sin_port        := htons(APort);
  Address.sin_family      := AF_INET;

  if bind(FSocket, Address, sizeof(Address)) = -1 then
  begin
    CloseSocket(FSocket);
    FSocket := -1;
  end;
end;

procedure TQuadSocket.Close;
begin
  if FSocket > 0 then
    CloseSocket(FSocket);
end;

function TQuadSocket.Write(ABuf: Pointer; ACount: Integer): Boolean;
var
  i: integer;
begin
  Result := False;
  if not FActive or (FSocket <= 0) or (ACount <= 0) then
    Exit;

  if FSendBufLen + ACount < BUFFER_SIZE then
  begin
    for i := FSendBufLen to FSendBufLen + ACount - 1 do
      FSendBuf[i] := PByteArray(ABuf)[i - FSendBufLen];
    FSendBufLen := FSendBufLen + ACount;
    Result := True;
  end;
end;

function TQuadSocket.Recv(out AAddress: PQuadSocketAddressItem; ABuffer: Pointer; var ALength: Integer): Boolean;
var
  Addr: TSockAddrIn;
  i: integer;
  GUID: TGUID;
  PackedType: TQuadSocketPackedType;
begin
  Result := False;
  if not FActive or (FSocket <= 0) then
    Exit;

  repeat
    i := SizeOf(Addr);
    ALength := recvfrom(FSocket, FtmpBuf[0], BUFFER_SIZE, 0, Addr, i);

    if ALength <= 0 then
      Exit;

    PackedType := TQuadSocketPackedType(FtmpBuf[0]);
    if FindAddress(Addr, AAddress) then
    begin
      case PackedType of
        qsptDisconnect: FAddressList.Remove(AAddress);
        qsptPing: ;
        qsptData:
          begin
            Move(FtmpBuf[1], PByteArray(ABuffer)[0], ALength - 1);
            Result := True;
          end;
      end;
    end
    else
      if PackedType = qsptConnect then
      begin
        Move(FtmpBuf[1], PByteArray(@GUID)[0], SizeOf(GUID));
        if IsEqualGUID(FGlobalGUID, GUID) then
          AddressAdd(Addr);
      end;

  until Result;
  AAddress := nil;
end;

function TQuadSocket.Send(AAddress: PQuadSocketAddressItem): Integer;
begin
  Result := 0;
  if not FActive or (FSocket <= 0) or (FSendBufLen <= 0) then
    Exit;
  Result := SendTo(FSocket, FSendBuf[0], FSendBufLen, 0, AAddress.Addr, SizeOf(AAddress.Addr));
end;

function TQuadSocket.FindAddress(const AAddr: TSockAddrIn; out AAddress: PQuadSocketAddressItem): Boolean;
var
  i: Integer;
begin
  for i := FAddressList.Count - 1 downto 0 do
  begin
    AAddress := FAddressList[i];
    if (AAddress.Addr.sin_port = AAddr.sin_port) and (AAddress.Addr.sin_addr.S_addr = AAddr.sin_addr.S_addr) then
    begin
      AAddress.Time := Now;
      Exit(True);
    end; {
    else
      if IncSecond(AAddress.Time, 30) < Now then
        FAddressList.Delete(i); }
  end;
  Result := False;
  AAddress := nil;
end;

function TQuadSocket.AddressAdd(const AAddr: TSockAddrIn): PQuadSocketAddressItem;
begin
  New(Result);
  Result.Addr.sin_port := AAddr.sin_port;
  Result.Addr.sin_addr := AAddr.sin_addr;

  Result.Addr.sin_family := AF_INET;
  FillChar(Result.Addr.sin_zero, SizeOf(Result.Addr.sin_zero), 0);
  Result.Time := Now;

  FAddressList.Add(Result);
end;

procedure TQuadSocket.SetPackedType(AType: TQuadSocketPackedType);
begin
  FSendBuf[0] := Byte(AType);
end;

function TQuadSocket.CreateAddress(const AIP: PAnsiChar; APort: Word): PQuadSocketAddressItem;
var
  Addr: TSockAddrIn;
begin
  Addr.sin_addr.S_addr := inet_addr(AIP);
  Addr.sin_port := htons(APort);
  Result := AddressAdd(Addr);
  Clear;
  SetPackedType(qsptConnect);
  Write(PByteArray(@FGlobalGUID), SizeOf(FGlobalGUID));
  Send(Result);
end;

function TQuadSocket.GetAddress(Index: Integer): PQuadSocketAddressItem;
begin
  Result := FAddressList[Index];
end;

function TQuadSocket.GetAddressCount: Integer;
begin
  Result := FAddressList.Count;
end;

initialization
  TQuadSocket.FGlobalGUID := StringToGUID('{D4523A77-065E-4EB4-A249-6F75B416F8BE}');
  TQuadSocket.FActive := False;

finalization
  TQuadSocket.Disconnect;

end.
