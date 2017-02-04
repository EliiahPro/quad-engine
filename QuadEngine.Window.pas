//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//
// For license see COPYING
//=============================================================================

unit QuadEngine.Window;

interface

uses
  windows,
  messages,
  QuadEngine,
  Vec2f,
  QuadEngine.Input;

type
  TQuadWindow = class(TInterfacedObject, IQuadWindow)
  private
    FWndClass: TWndClassEx;
    FHandle: THandle;
    FOnKeyDown: TOnKeyPress;
    FOnKeyChar: TOnKeyChar;
    FOnKeyUp: TOnKeyPress;
    FOnCreate: TOnEvent;
    FOnClose: TOnEvent;
    FOnActivate: TOnEvent;
    FOnDeactivate: TOnEvent;
    FOnMouseMove: TOnMouseMoveEvent;
    FOnMouseDown: TOnMouseEvent;
    FOnMouseUp: TOnMouseEvent;
    FOnMouseDblClick: TOnMouseEvent;
    FOnMouseWheel: TOnMouseWheelEvent;
    FOnMove: TOnWindowMove;
    FOnDeviceRestored: TOnEvent;

    FInput: TQuadInput;

    procedure OnMouseEvent(msg: Integer; wparam: WPARAM; lparam: LPARAM);
    procedure OnKeyEvent(msg: Integer; wparam: WPARAM; lparam: LPARAM);
  protected
    function WindowProc(wnd: HWND; msg: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateInput(out pQuadInput: IQuadInput): HResult; stdcall;
    procedure Start; stdcall;
    procedure SetCaption(ACaption: PChar); stdcall;
    procedure SetSize(AWidth, AHeight: Integer); stdcall;
    procedure SetPosition(AXpos, AYPos: Integer); stdcall;
    function GetHandle: THandle; stdcall;

    procedure SetOnKeyDown(OnKeyDown: TOnKeyPress); stdcall;
    procedure SetOnKeyUp(OnKeyUp: TOnKeyPress); stdcall;
    procedure SetOnKeyChar(OnKeyChar: TOnKeyChar); stdcall;
    procedure SetOnCreate(OnCreate: TOnEvent); stdcall;
    procedure SetOnClose(OnClose: TOnEvent); stdcall;
    procedure SetOnActivate(OnActivate: TOnEvent); stdcall;
    procedure SetOnDeactivate(OnDeactivate: TOnEvent); stdcall;
    procedure SetOnMouseMove(OnMouseMove: TOnMouseMoveEvent); stdcall;
    procedure SetOnMouseDown(OnMouseDown: TOnMouseEvent); stdcall;
    procedure SetOnMouseUp(OnMouseUp: TOnMouseEvent); stdcall;
    procedure SetOnMouseDblClick(OnMouseDblClick: TOnMouseEvent); stdcall;
    procedure SetOnMouseWheel(OnMouseWheel: TOnMouseWheelEvent); stdcall;
    procedure SetOnWindowMove(OnWindowMove: TOnWindowMove); stdcall;
    procedure SetOnDeviceRestored(OnDeviceRestored: TOnEvent); stdcall;
  end;

function WinMain(wnd: HWND; msg: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT; stdcall;

implementation

uses
  QuadEngine.Device;

function WinMain(wnd: HWND; msg: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT;
begin
  Result := TQuadWindow(GetWindowLong(wnd, 0)).WindowProc(wnd, msg, wparam, lparam);
end;

function TQuadWindow.WindowProc(wnd: HWND; msg: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT;
begin
  Result := 0;

  case msg of
  WM_DESTROY:
    begin
      if Assigned(FOnClose) then
        FOnClose;

      PostQuitMessage(0);
      Result := 0;
    end;

  { KEYBOARD }
  WM_KEYDOWN, WM_KEYUP, WM_CHAR:
    begin
      OnKeyEvent(msg, wparam, lparam);
      Result := 0;
    end;

  { MOUSE }
  WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN, WM_XBUTTONDOWN,
  WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP,
  WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_XBUTTONDBLCLK,
  WM_MOUSEMOVE, WM_MOUSEWHEEL, WM_MOUSEHWHEEL:
    begin
  //    if Device.IsHardwareCursor then
   //     Device.SetCursorPosition(SmallInt($FFFF and lParam), SmallInt(($FFFF0000 and lParam) shr 16));

      OnMouseEvent(msg, wparam, lparam);
      Result := 0;
    end;

  WM_SIZE:
    begin
      if wparam = SIZE_MINIMIZED then
        Result := 0;
    end;

  WM_MOVE:
    begin
      if Assigned(Self) and Assigned(FOnMove) then
        FOnMove(Integer(lparam and $FFFF), Integer((lparam shr 16) and $FFFF));

      Result := 0;
    end;

  {Prevent setting GDI cursor}
  WM_SETCURSOR:
    if Device.IsHardwareCursor then
    begin
      Device.Render.D3DDevice.ShowCursor(True);
      Result := 0;
    end;

  WM_ACTIVATEAPP:
    begin
      if wparam <> WA_INACTIVE then
      begin
        if Assigned(Device) then
          if Device.Render.IsInitialized then
          begin
            Device.Render.ResetDevice;
            if Assigned(Self) and Assigned(FOnDeviceRestored) then
              FOnDeviceRestored;
          end;

        if Assigned(Self) and Assigned(FOnActivate) then
          FOnActivate;
      end
      else
        if Assigned(Self) and Assigned(FOnDeactivate) then
          FOnDeactivate;

      Result := 0;
    end;

  else
    Result := DefWindowProc(wnd, msg, wparam, lparam);
  end;
end;

constructor TQuadWindow.Create;
begin
  FWndClass.cbSize := SizeOf(TWndClassEx);
  FWndClass.style := CS_HREDRAW or CS_VREDRAW;
  FWndClass.lpfnWndProc := @WinMain;
  FWndClass.cbClsExtra := 0;
  FWndClass.cbWndExtra := 4;
  FWndClass.hInstance := HInstance;
  FWndClass.hIcon := LoadIcon(0, IDI_APPLICATION);
  FWndClass.hCursor := LoadCursor(0, IDC_ARROW);
  FWndClass.hbrBackground := CreateSolidBrush(0);
  FWndClass.lpszMenuName := nil;
  FWndClass.lpszClassName := 'Main_Window';

  RegisterClassEx(FWndClass);

  FHandle := CreateWindowEx(0, 'Main_Window', 'Quad-engine window',
                            WS_DLGFRAME or WS_SYSMENU or WS_MINIMIZEBOX or WS_VISIBLE,
                            100, 100,
                            300, 300,
                            0, 0,
                            HInstance, nil);

  SetWindowLong(FHandle, 0, Integer(Self));

  ShowWindow(Self.FHandle, CmdShow);
  UpdateWindow(Self.FHandle);

  FOnKeyDown := nil;
  FOnKeyUp := nil;
  FOnCreate := nil;
  FOnMove := nil;
  FOnActivate := nil;
  FOnDeactivate := nil;
  FInput := nil;
end;

destructor TQuadWindow.Destroy;
begin
  inherited;
end;

function TQuadWindow.CreateInput(out pQuadInput: IQuadInput): HResult; stdcall;
begin
  if not Assigned(FInput) then
    FInput := TQuadInput.Create;

  pQuadInput := FInput;

  if Assigned(pQuadInput) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadWindow.GetHandle: THandle;
begin
  Result := FHandle;
end;

procedure TQuadWindow.OnKeyEvent(msg: Integer; wparam: WPARAM; lparam: LPARAM);

  function GetPressedKeyButtons: TPressedKeyButtons;
  var
    State: TKeyboardState;
  begin
    GetKeyboardState(State);
    Result.LShift := ((State[VK_LSHIFT] and 128) <> 0);
    Result.RShift := ((State[VK_RSHIFT] and 128) <> 0);
    Result.Shift := Result.LShift or Result.RShift;

    Result.LCtrl := ((State[VK_LCONTROL] and 128) <> 0);
    Result.RCtrl := ((State[VK_RCONTROL] and 128) <> 0);
    Result.Ctrl := Result.LCtrl or Result.RCtrl;

    Result.LAlt := ((State[VK_LMENU] and 128) <> 0);
    Result.RAlt := ((State[VK_RMENU] and 128) <> 0);
    Result.Alt := Result.LAlt or Result.RAlt;

    Result.None := not (Result.Shift or Result.Ctrl or Result.Alt);
  end;

begin
  case msg of
  WM_KEYDOWN:
    begin
      if Assigned(FInput) then
        FInput.SetKeyState(wparam, True);

      if Assigned(FOnKeyDown) then
        FOnKeyDown(wparam, GetPressedKeyButtons);
    end;

  WM_KEYUP:
    begin
      if Assigned(FInput) then
        FInput.SetKeyState(wparam, False);

      if Assigned(FOnKeyUp) then
        FOnKeyUp(wparam, GetPressedKeyButtons);
    end;

  WM_CHAR:
    if Assigned(FOnKeyChar) then
      FOnKeyChar(wparam, GetPressedKeyButtons);
  end;
end;

procedure TQuadWindow.OnMouseEvent(msg: Integer; wparam: WPARAM; lparam: LPARAM);

  function ParamToPressedMouseButtons(AParam: Cardinal): TPressedMouseButtons;
  begin
    Result.Left := AParam and MK_LBUTTON = MK_LBUTTON;
    Result.Right := AParam and MK_RBUTTON = MK_RBUTTON;
    Result.Middle := AParam and MK_MBUTTON = MK_MBUTTON;
    Result.X1 := AParam and $0020 = $0020;
    Result.X2 := AParam and $0040 = $0040;
  end;

  function ParamToPosition(AParam: Cardinal): TVec2i;
  begin
    Result := TVec2i.Create(SmallInt($FFFF and AParam), SmallInt(($FFFF0000 and AParam) shr 16));
  end;

var
  XParam: TVec2i;
  Button: TMouseButtons;
begin
  case msg of
    WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN, WM_XBUTTONDOWN:
      if Assigned(FOnMouseDown) or Assigned(FInput) then
      begin
        case msg of
          WM_LBUTTONDOWN:
            begin
              if Assigned(FInput) then
                FInput.SetMouseButtonState(mbLeft, True);
              if Assigned(FOnMouseDown) then
                FOnMouseDown(ParamToPosition(lparam), mbLeft, ParamToPressedMouseButtons(wparam));
            end;
          WM_MBUTTONDOWN:
            begin
              if Assigned(FInput) then
                FInput.SetMouseButtonState(mbMiddle, True);
              if Assigned(FOnMouseDown) then
                FOnMouseDown(ParamToPosition(lparam), mbMiddle, ParamToPressedMouseButtons(wparam));
            end;
          WM_RBUTTONDOWN:
            begin
              if Assigned(FInput) then
                FInput.SetMouseButtonState(mbRight, True);
              if Assigned(FOnMouseDown) then
                FOnMouseDown(ParamToPosition(lparam), mbRight, ParamToPressedMouseButtons(wparam));
            end;
          WM_XBUTTONDOWN:
            begin
              XParam := ParamToPosition(WPARAM);
              case XParam.Y of
                1:
                  begin
                    if Assigned(FInput) then
                      FInput.SetMouseButtonState(mbX1, True);
                    if Assigned(FOnMouseDown) then
                      FOnMouseDown(ParamToPosition(lparam), mbX1, ParamToPressedMouseButtons(XParam.X));
                  end;
                2:
                  begin
                    if Assigned(FInput) then
                      FInput.SetMouseButtonState(mbX2, True);
                    if Assigned(FOnMouseDown) then
                      FOnMouseDown(ParamToPosition(lparam), mbX2, ParamToPressedMouseButtons(XParam.X));
                  end;
              end;
            end;
        end;
      end;

    WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
      if Assigned(FOnMouseUp) or Assigned(FInput) then
      begin
        case msg of
          WM_LBUTTONUP:
            begin
              if Assigned(FInput) then
                FInput.SetMouseButtonState(mbLeft, False);
              if Assigned(FOnMouseUp) then
                FOnMouseUp(ParamToPosition(lparam), mbLeft, ParamToPressedMouseButtons(wparam));
            end;
          WM_MBUTTONUP:
            begin
              if Assigned(FInput) then
                FInput.SetMouseButtonState(mbMiddle, False);
              if Assigned(FOnMouseUp) then
                FOnMouseUp(ParamToPosition(lparam), mbMiddle, ParamToPressedMouseButtons(wparam));
            end;
          WM_RBUTTONUP:
            begin
              if Assigned(FInput) then
                FInput.SetMouseButtonState(mbRight, False);
              if Assigned(FOnMouseUp) then
                FOnMouseUp(ParamToPosition(lparam), mbRight, ParamToPressedMouseButtons(wparam));
            end;
          WM_XBUTTONUP:
            begin
              XParam := ParamToPosition(WPARAM);
              case XParam.Y of
                $0001:
                  begin
                    if Assigned(FInput) then
                      FInput.SetMouseButtonState(mbX1, False);
                    if Assigned(FOnMouseUp) then
                      FOnMouseUp(ParamToPosition(lparam), mbX1, ParamToPressedMouseButtons(XParam.X));
                  end;
                $0002:
                  begin
                    if Assigned(FInput) then
                      FInput.SetMouseButtonState(mbX2, False);
                    if Assigned(FOnMouseUp) then
                      FOnMouseUp(ParamToPosition(lparam), mbX2, ParamToPressedMouseButtons(XParam.X));
                  end;
              end;
            end;
        end;
      end;

    WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_XBUTTONDBLCLK:
    begin
      if Assigned(FOnMouseDblClick) then
      begin
        case msg of
          WM_LBUTTONDBLCLK: FOnMouseDblClick(ParamToPosition(lparam), mbLeft, ParamToPressedMouseButtons(wparam));
          WM_MBUTTONDBLCLK: FOnMouseDblClick(ParamToPosition(lparam), mbMiddle, ParamToPressedMouseButtons(wparam));
          WM_RBUTTONDBLCLK: FOnMouseDblClick(ParamToPosition(lparam), mbRight, ParamToPressedMouseButtons(wparam));
          WM_XBUTTONDBLCLK:
            begin
              XParam := ParamToPosition(WPARAM);
              case XParam.Y of
                $0001: FOnMouseDblClick(ParamToPosition(lparam), mbX1, ParamToPressedMouseButtons(XParam.X));
                $0002: FOnMouseDblClick(ParamToPosition(lparam), mbX2, ParamToPressedMouseButtons(XParam.X));
              end;
            end;
        end;
      end;
    end;

    WM_MOUSEMOVE:
      if Assigned(FOnMouseMove) or Assigned(FInput) then
      begin
        XParam := ParamToPosition(lparam);
        if Assigned(FInput) then
          FInput.SetMousePosition(XParam);
        if Assigned(FOnMouseMove) then
          FOnMouseMove(XParam, ParamToPressedMouseButtons(wparam));
      end;

    WM_MOUSEWHEEL, WM_MOUSEHWHEEL:
      if Assigned(FOnMouseWheel) or Assigned(FInput) then
      begin
        XParam := ParamToPosition(wparam);
        case msg of
          WM_MOUSEWHEEL:
            begin
              if Assigned(FInput) then
                FInput.SetMouseWheel(TVec2i.Create(0, XParam.Y));
              if Assigned(FOnMouseWheel) then
                FOnMouseWheel(ParamToPosition(lparam), TVec2i.Create(0, XParam.Y), ParamToPressedMouseButtons(XParam.X));
            end;
          WM_MOUSEHWHEEL:
            begin
              if Assigned(FInput) then
                FInput.SetMouseWheel(TVec2i.Create(XParam.Y, 0));
              if Assigned(FOnMouseWheel) then
                FOnMouseWheel(ParamToPosition(lparam), TVec2i.Create(XParam.Y, 0), ParamToPressedMouseButtons(XParam.X));
            end;
        end;
      end;
  end;
end;

procedure TQuadWindow.SetCaption(ACaption: PChar);
begin
  SetWindowText(FHandle, ACaption);
end;

procedure TQuadWindow.Start;
var
  Mmsg: MSG;
begin
  if Assigned(FOnCreate) then
    FOnCreate;

  while GetMessage(Mmsg, 0, 0, 0) do
  begin
    TranslateMessage(Mmsg);
    DispatchMessage(Mmsg);
  end;
end;

procedure TQuadWindow.SetSize(AWidth, AHeight: Integer);
var
  Client, Window: TRect;
  Diff: TPoint;
begin
  GetClientRect(Self.FHandle, Client);
  GetWindowRect(Self.FHandle, Window);

  Diff.X := 0;
  Diff.Y := 0;

  if (AHeight >= GetSystemMetrics(SM_CYSCREEN)) or
     (AWidth >= GetSystemMetrics(SM_CXSCREEN)) then
    SetWindowLong(FHandle, GWL_STYLE, GetWindowLong(FHandle, GWL_STYLE) and not WS_BORDER and not WS_SIZEBOX and not WS_DLGFRAME)
  else
  begin
    Diff.X := Window.Right - Window.Left - Client.Right;
    Diff.Y := Window.Bottom - Window.Top - Client.Bottom;
  end;

  MoveWindow(Self.FHandle, 0, 0, AWidth + Diff.X, AHeight + Diff.Y, True);
end;

procedure TQuadWindow.SetPosition(AXpos, AYPos: Integer);
begin
  SetWindowPos(FHandle, 0, AXpos, AYPos, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
end;

procedure TQuadWindow.SetOnActivate(OnActivate: TOnEvent);
begin
  FOnActivate := OnActivate;
end;

procedure TQuadWindow.SetOnDeviceRestored(OnDeviceRestored: TOnEvent);
begin
  FOnDeviceRestored := OnDeviceRestored;
end;

procedure TQuadWindow.SetOnCreate(OnCreate: TOnEvent);
begin
  FOnCreate := OnCreate;
end;

procedure TQuadWindow.SetOnClose(OnClose: TOnEvent);
begin
  FOnClose := OnClose;
end;

procedure TQuadWindow.SetOnDeactivate(OnDeactivate: TOnEvent);
begin
  FOnDeactivate := OnDeactivate;
end;

procedure TQuadWindow.SetOnKeyChar(OnKeyChar: TOnKeyChar);
begin
  FOnKeyChar := OnKeyChar;
end;

procedure TQuadWindow.SetOnKeyDown(OnKeyDown: TOnKeyPress);
begin
  FOnKeyDown := OnKeyDown;
end;

procedure TQuadWindow.SetOnKeyUp(OnKeyUp: TOnKeyPress);
begin
  FOnKeyUp := OnKeyUp;
end;

procedure TQuadWindow.SetOnMouseDblClick(OnMouseDblClick: TOnMouseEvent);
begin
  FOnMouseDblClick := OnMouseDblClick;
end;

procedure TQuadWindow.SetOnMouseDown(OnMouseDown: TOnMouseEvent);
begin
  FOnMouseDown := OnMouseDown;
end;

procedure TQuadWindow.SetOnMouseMove(OnMouseMove: TOnMouseMoveEvent);
begin
  FOnMouseMove := OnMouseMove;
end;

procedure TQuadWindow.SetOnMouseUp(OnMouseUp: TOnMouseEvent);
begin
  FOnMouseUp := OnMouseUp;
end;

procedure TQuadWindow.SetOnMouseWheel(OnMouseWheel: TOnMouseWheelEvent);
begin
  FOnMouseWheel := OnMouseWheel;
end;

procedure TQuadWindow.SetOnWindowMove(OnWindowMove: TOnWindowMove);
begin
  FOnMove := OnWindowMove;
end;

end.
