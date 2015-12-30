unit QuadEngine.Socket;

interface

uses
  Winapi.Windows, System.SyncObjs, winapi.WinSock, System.Classes, System.SysUtils, System.Generics.Collections, System.DateUtils;



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
    qsptOutPing = 4,
    qsptData = 5
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
    class var FActiveCount: Integer;
    class var FGlobalGUID: TGUID;
    FAddressList: TList<PQuadSocketAddressItem>;

    FSocket: Integer;
    FMemory: TMemoryStream;
    FtmpBuf: PByteArray;
    FType: TQuadSocketType;

    class procedure Connect;
    class procedure Disconnect;
    function FindAddress(const AAddr: TSockAddrIn; out AAddress: PQuadSocketAddressItem): Boolean;
    function AddressAdd(const AAddr: TSockAddrIn): PQuadSocketAddressItem;
    procedure SetPackedType(AType: TQuadSocketPackedType);
    function GetAddress(Index: Integer): PQuadSocketAddressItem;
    function GetAddressCount: Integer;
    procedure SendConnect(AAddress: PQuadSocketAddressItem);
    function Send(Addr: TSockAddrIn): Integer; overload;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateAddress(const AIP: PAnsiChar; APort: Word): PQuadSocketAddressItem;
    procedure InitSocket(APort: Word = 0);
    procedure Close;
    procedure Clear;
    procedure SetCode(ACode: Word);
    function Write(const ABuf; ACount: Integer): Boolean;
    function Send(AAddress: PQuadSocketAddressItem): Integer; overload;
    function Recv(out AAddress: PQuadSocketAddressItem; AMemory: TMemoryStream): Boolean;

    property Address[Index: integer]: PQuadSocketAddressItem read GetAddress;
    property AddressCount: Integer read GetAddressCount;
  end;

implementation

constructor TQuadSocket.Create;
begin
  FSocket := -1;
  Connect;

  FAddressList := TList<PQuadSocketAddressItem>.Create;

  FMemory := TMemoryStream.Create;
  if FtmpBuf = nil then
    GetMem(FtmpBuf, BUFFER_SIZE);
end;

destructor TQuadSocket.Destroy;
begin
  if FSocket > 0 then
    CloseSocket(FSocket);
  FAddressList.Free;
  FSocket := -1;
  FreeMem(FtmpBuf);
  FtmpBuf := nil;
  FMemory.Free;
  Disconnect;
  inherited;
end;

procedure TQuadSocket.Clear;
begin
  FMemory.Clear;
  SetPackedType(qsptData);
end;

procedure TQuadSocket.SetCode(ACode: Word);
begin
  Clear;
  Write(ACode, SizeOf(ACode));
end;

class procedure TQuadSocket.Connect;
var
  Data: WSAData;
  Error: integer;
begin
  if FActiveCount = 0 then
    Error := WSAStartup(MakeWord(2, 2), Data);
  Inc(FActiveCount);
end;

class procedure TQuadSocket.Disconnect;
begin
  if FActiveCount = 1 then
    WSACleanup;
  Dec(FActiveCount);
end;

procedure TQuadSocket.InitSocket(APort: Word = 0);
var
  flag: integer;
  i: integer;
  Address: TSockAddrIn;
begin
  i := 1;
  flag := 1;

  if APort > 0 then
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

function TQuadSocket.Write(const ABuf; ACount: Integer): Boolean;
var
  i: integer;
begin
  Result := False;
  if (FActiveCount > 0) or (FSocket <= 0) or (ACount <= 0) then
    Exit;

  if FMemory.Size + ACount < BUFFER_SIZE then
    Result := FMemory.Write(ABuf, ACount) > 0;
end;

function TQuadSocket.Recv(out AAddress: PQuadSocketAddressItem; AMemory: TMemoryStream): Boolean;
var
  Addr: TSockAddrIn;
  i: integer;
  GUID: TGUID;
  PackedType: TQuadSocketPackedType;
  Length: Integer;
begin
  if not Assigned(AMemory) then
    Exit;

  AMemory.Clear;
  Result := False;
  if (FActiveCount > 0) or (FSocket <= 0) then
    Exit;

  repeat
    i := SizeOf(Addr);
    Length := recvfrom(FSocket, FtmpBuf[0], BUFFER_SIZE, 0, Addr, i);
    if Length <= 0 then
      Exit;

    PackedType := TQuadSocketPackedType(FtmpBuf[0]);
    if FindAddress(Addr, AAddress) then
    begin
      case PackedType of
        qsptConnect:
          if FType = qstClient then
            SendConnect(AAddress);
        qsptDisconnect: FAddressList.Remove(AAddress);
        qsptPing:
          begin
            Clear;
            SetPackedType(qsptOutPing);
            Send(AAddress);
          end;
        qsptOutPing:
          begin
          end;
        qsptData:
          begin
            AMemory.Write(FtmpBuf[1], Length - 1);
            AMemory.Position := 0;
            Result := True;
          end;
      end;
    end
    else
      if PackedType = qsptConnect then
      begin
        Move(FtmpBuf[1], PByteArray(@GUID)[0], SizeOf(GUID));
        if IsEqualGUID(FGlobalGUID, GUID) then
        begin
          Clear;
          SetPackedType(qsptConnect);
          Send(AddressAdd(Addr));
        end;
      end
      else
        if FType = qstServer then
        begin
          Clear;
          SetPackedType(qsptConnect);
          Write(FGlobalGUID, SizeOf(FGlobalGUID));
          Send(Addr);
        end;

  until Result;
end;

function TQuadSocket.Send(AAddress: PQuadSocketAddressItem): Integer;
begin
  Result := Send(AAddress.Addr);
end;

function TQuadSocket.Send(Addr: TSockAddrIn): Integer;
begin
  Result := 0;
  if  (FActiveCount > 0) or (FSocket <= 0) or (FMemory.Size <= 0) then
    Exit;
  Result := SendTo(FSocket, PByteArray(FMemory.Memory)[0], FMemory.Size, 0, Addr, SizeOf(Addr));
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
    end
    else
      if IncSecond(AAddress.Time, 3) < Now then
        FAddressList.Delete(i);
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
  FMemory.Position := 0;
  FMemory.Write(Byte(AType), SizeOf(Byte));
end;

function TQuadSocket.CreateAddress(const AIP: PAnsiChar; APort: Word): PQuadSocketAddressItem;
var
  Addr: TSockAddrIn;
begin
  Addr.sin_addr.S_addr := inet_addr(AIP);
  Addr.sin_port := htons(APort);
  Result := AddressAdd(Addr);
  FAddressList.Add(Result);
  SendConnect(Result);
end;

procedure TQuadSocket.SendConnect(AAddress: PQuadSocketAddressItem);
begin
  Clear;
  SetPackedType(qsptConnect);
  Write(FGlobalGUID, SizeOf(FGlobalGUID));
  Send(AAddress);
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
  TQuadSocket.FActiveCount := 0;

finalization
  TQuadSocket.Disconnect;

end.
