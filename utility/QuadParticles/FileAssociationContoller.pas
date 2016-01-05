unit FileAssociationContoller;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, Vcl.Forms, Vcl.Dialogs, System.SysUtils;

type
  TFileAssociationContollerEvent = procedure(ACommand: WideString) of object;

  TEventWaitThread = class(TThread)
  protected
    procedure Execute; override;
  end;

  TFileAssociationContoller = class
  private
  const
    MAILSLOT_NAME = '\\.\mailslot\QuadParticle_Viewer_FileCommand';
    EVENT_NAME = 'QuadParticle_Viewer_Command_Event';
  private
    FHWnd: HWND;
    FThread: TEventWaitThread;
    FIsAssociation: Boolean;
    FServerMailslotHandle: THandle;
    FCommandEvent: THandle;
    FOnCommandEvent: TFileAssociationContollerEvent;
    class var FInstance: TFileAssociationContoller;
    procedure SendMessage;
    procedure WndMethod(var Msg: TMessage); virtual;
  public
    class function NewInstance: TObject; override;
    constructor Create;
    destructor Destroy; override;
    function ReadStringFromMailslot: WideString;
    procedure GoToForeground;
    procedure SetOnCommandEvent(AOnCommandEvent: TFileAssociationContollerEvent);
    procedure Show;

    property IsAssociation: Boolean read FIsAssociation;
  end;

implementation
uses
  Main;

const
  WM_CommandArrived = WM_USER + 1;

{ TEventWaitThread }

procedure TEventWaitThread.Execute;
begin
  with TFileAssociationContoller.FInstance do
    while not Terminated do
    begin
      if WaitForSingleObject(FCommandEvent, INFINITE) <> WAIT_OBJECT_0 then
        Exit;
      PostMessage(FHWnd, WM_CommandArrived, 0, 0);
    end;
end;

{ TFileAssociationContoller }

class function TFileAssociationContoller.NewInstance: TObject;
begin
  if not Assigned(FInstance) then
    Result := inherited NewInstance as Self
  else
    Result := FInstance;
end;

constructor TFileAssociationContoller.Create;
begin
  inherited Create;
  if Assigned(FInstance) then
    Exit;
  FInstance := Self;
  FIsAssociation := False;
  FServerMailslotHandle := CreateMailSlot(MAILSLOT_NAME, 0, MAILSLOT_WAIT_FOREVER, nil);
  if (ParamCount > 0) and (FServerMailslotHandle = INVALID_HANDLE_VALUE) then
  begin
   // if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      SendMessage;
      FIsAssociation := True;
      Exit;
    end;
  end;

  FCommandEvent := CreateEvent(nil, False, False, EVENT_NAME);
  FHWnd := AllocateHWnd(WndMethod);
end;

destructor TFileAssociationContoller.Destroy;
begin
  if Assigned(FThread) then
    FThread.Terminate;
  DeallocateHWnd(FHWnd);
  CloseHandle(FServerMailslotHandle);
  CloseHandle(FCommandEvent);
  inherited;
end;

procedure TFileAssociationContoller.Show;
//var
//  OpenForView: Boolean;
begin
  if not Assigned(FThread) then
    FThread := TEventWaitThread.Create(False);
end;

procedure TFileAssociationContoller.SendMessage;
var
  i: Integer;
  Str: WideString;
  BytesCount: DWORD;
  ClientMailslotHandle: THandle;
begin
  Str := '';
  for i := 1 to ParamCount do
  begin
    if i > 1 then
      Str := Str + ' ';
    Str := ParamStr(i);
  end;

  ClientMailslotHandle := CreateFile(MAILSLOT_NAME, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  WriteFile(ClientMailslotHandle, Str[1], Length(Str) * 2, BytesCount, nil);

  FCommandEvent := OpenEvent(EVENT_MODIFY_STATE, False, EVENT_NAME);
  SetEvent(FCommandEvent);

  CloseHandle(ClientMailslotHandle);
end;

function TFileAssociationContoller.ReadStringFromMailslot: WideString;
var
  MessageSize: DWORD;
begin
  GetMailslotInfo(FServerMailslotHandle, nil, MessageSize, nil, nil);

  if MessageSize = MAILSLOT_NO_MESSAGE then
  begin
    Result := '';
    Exit;
  end;

  SetLength(Result, MessageSize div 2);
  ReadFile(FServerMailslotHandle, Result[1], MessageSize, MessageSize, nil);
end;

procedure TFileAssociationContoller.WndMethod(var Msg: TMessage);
var
  Str: WideString;
begin
  if Msg.Msg = WM_CommandArrived then
  begin
    GoToForeground;
    if Assigned(FOnCommandEvent) then
    begin
      Str := ReadStringFromMailslot;
      while Str <> '' do
      begin
        FOnCommandEvent(Str);
        Str := ReadStringFromMailslot;
      end;
    end;
    Msg.Result := 0;
  end
  else
    Msg.Result := DefWindowProc(FHWnd, Msg.Msg, Msg.WParam, Msg.LParam);
end;

procedure TFileAssociationContoller.GoToForeground;
var
  Info: TAnimationInfo;
  Animation: Boolean;
begin                                {
  ShowWindow(fMain.Handle, SW_SHOWNORMAL);
  SetForegroundWindow(fMain.Handle);   }

  Info.cbSize := SizeOf(TAnimationInfo);
  Animation := SystemParametersInfo(SPI_GETANIMATION, SizeOf(Info), @Info, 0) and (Info.iMinAnimate <> 0);

  if Animation then
  begin
    Info.iMinAnimate := 0;
    SystemParametersInfo(SPI_SETANIMATION, SizeOf(Info), @Info, 0);
  end;

  if not IsIconic(Application.Handle) then
    Application.Minimize;

  Application.Restore;

  if Animation then
  begin
    Info.iMinAnimate := 1;
    SystemParametersInfo(SPI_SETANIMATION, SizeOf(Info), @Info, 0);
  end;
end;

procedure TFileAssociationContoller.SetOnCommandEvent(AOnCommandEvent: TFileAssociationContollerEvent);
begin
  FOnCommandEvent := AOnCommandEvent;
end;

initialization

finalization
  if Assigned(TFileAssociationContoller.FInstance) then
    TFileAssociationContoller.FInstance.Free;

end.
