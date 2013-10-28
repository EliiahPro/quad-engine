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

unit QuadEngine.Window;

interface

uses
  windows,
  messages,
  QuadEngine,
  Vec2f;

type
  TQuadWindow = class(TInterfacedObject, IQuadWindow)
  private
    FWndClass: TWndClassEx;
    FHandle: THandle;
    FOnKeyDown: TOnKeyPress;
    FOnKeyUp: TOnKeyPress;
    FOnCreate: TOnCreate;
    FOnMouseMove: TOnMouseMoveEvent;
    FOnMousDown: TOnMouseEvent;
    FOnMouseUp: TOnMouseEvent;
    FOnMouseDblClick: TOnMouseEvent;
    FOnMouseWheel: TOnMouseWheelEvent;

    function OnMouseEvent(msg: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT;
  protected
    function WindowProc(wnd: HWND; msg: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT;
  public
    constructor Create;
    procedure Start; stdcall;
    procedure SetCaption(ACaption: PChar); stdcall;
    procedure SetSize(AWidth, AHeight: Integer); stdcall;
    procedure SetPosition(AXpos, AYPos: Integer); stdcall;
    function GetHandle: THandle; stdcall;

    procedure SetOnKeyDown(OnKeyDown: TOnKeyPress); stdcall;
    procedure SetOnKeyUp(OnKeyUp: TOnKeyPress); stdcall;
    procedure SetOnCreate(OnCreate: TOnCreate); stdcall;
    procedure SetOnMouseMove(OnMouseMove: TOnMouseMoveEvent); stdcall;
    procedure SetOnMouseDown(OnMouseDown: TOnMouseEvent); stdcall;
    procedure SetOnMouseUp(OnMouseUp: TOnMouseEvent); stdcall;
    procedure SetOnMouseDblClick(OnMouseDblClick: TOnMouseEvent); stdcall;
    procedure SetOnMouseWheel(OnMouseWheel: TOnMouseWheelEvent); stdcall;
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
      PostQuitMessage(0);
      Result := 0;
    end;
  WM_KEYDOWN:
    begin
      if Assigned(FOnKeyDown) {and (lparam and $FE = 0)} then
      begin
        FOnKeyDown(wparam);
        Result := 0;
      end;
    end;
  WM_KEYUP:
    begin
      if Assigned(FOnKeyUp) {and (lparam and $FE = 1)} then
      begin
        FOnKeyUp(wparam);
        Result := 0;
      end;
    end;

  WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN, WM_XBUTTONDOWN,
  WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP,
  WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK, WM_XBUTTONDBLCLK,
  WM_MOUSEMOVE, WM_MOUSEWHEEL, WM_MOUSEHWHEEL:
    begin
      Result := OnMouseEvent(msg, wparam, lparam);
    end;
  WM_SIZE:
    begin
      if wparam = SIZE_MINIMIZED then
        Result := 0;
    end;
  WM_ACTIVATEAPP:
    begin
     if wparam <> WA_INACTIVE then
       if Assigned(Device) then
        if Device.Render.IsInitialized then
          Device.Render.ResetDevice;

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
  FWndClass.hIcon := LoadIcon (0, IDI_APPLICATION);
  FWndClass.hCursor := LoadCursor (0, IDC_ARROW);
  FWndClass.hbrBackground := CreateSolidBrush(0);
  FWndClass.lpszMenuName := nil;
  FWndClass.lpszClassName := 'Main_Window';

  RegisterClassEx(FWndClass);

  FHandle := CreateWindowEx(0, 'Main_Window', 'Quad-engine window',
                            WS_OVERLAPPEDWINDOW or WS_VISIBLE,
                            100, 100,
                            300, 300,
                            0, 0,
                            Hinstance, nil);

  SetWindowLong(FHandle, 0, Integer(Self));

  FOnKeyDown := nil;
  FOnKeyUp := nil;
  FOnCreate := nil;
end;

function TQuadWindow.GetHandle: THandle;
begin
  Result := FHandle;
end;

function TQuadWindow.OnMouseEvent(msg: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT;

  function ParamToPressedMouseButtons(Param: Cardinal): TPressedMouseButtons;
  begin
    Result.Left := Param and MK_LBUTTON >= 1;
    Result.Right := Param and MK_RBUTTON >= 1;
    Result.Middle := Param and MK_MBUTTON >= 1;
    Result.X1 := Param and $0020 >= 1;
    Result.X2 := Param and $0040 >= 1;
  end;

  function ParamToPosition(Param: Cardinal): TVec2i;
  begin
    Result := TVec2i.Create(SmallInt($FFFF and Param), SmallInt(($FFFF0000 and Param) shr 16));
  end;

var
  XParam: TVec2i;
begin
  case msg of
    WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN, WM_XBUTTONDOWN:
      if Assigned(FOnMousDown) then
      begin
        case msg of
          WM_LBUTTONDOWN: FOnMousDown(ParamToPosition(lparam), mbLeft, ParamToPressedMouseButtons(wparam));
          WM_MBUTTONDOWN: FOnMousDown(ParamToPosition(lparam), mbMiddle, ParamToPressedMouseButtons(wparam));
          WM_RBUTTONDOWN: FOnMousDown(ParamToPosition(lparam), mbRight, ParamToPressedMouseButtons(wparam));
          WM_XBUTTONDOWN:
            begin
              XParam := ParamToPosition(WPARAM);
              case XParam.Y of
                1: FOnMousDown(ParamToPosition(lparam), mbX1, ParamToPressedMouseButtons(XParam.X));
                2: FOnMousDown(ParamToPosition(lparam), mbX2, ParamToPressedMouseButtons(XParam.X));
              end;
            end;
        end;
        Result := 0;
      end;

    WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_XBUTTONUP:
      if Assigned(FOnMouseUp) then
      begin
        case msg of
          WM_LBUTTONUP: FOnMouseUp(ParamToPosition(lparam), mbLeft, ParamToPressedMouseButtons(wparam));
          WM_MBUTTONUP: FOnMouseUp(ParamToPosition(lparam), mbMiddle, ParamToPressedMouseButtons(wparam));
          WM_RBUTTONUP: FOnMouseUp(ParamToPosition(lparam), mbRight, ParamToPressedMouseButtons(wparam));
          WM_XBUTTONUP:
            begin
              XParam := ParamToPosition(WPARAM);
              case XParam.Y of
                $0001: FOnMouseUp(ParamToPosition(lparam), mbX1, ParamToPressedMouseButtons(XParam.X));
                $0002: FOnMouseUp(ParamToPosition(lparam), mbX2, ParamToPressedMouseButtons(XParam.X));
              end;
            end;
        end;
        Result := 0;
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
        Result := 0;
      end;
    end;

    WM_MOUSEMOVE:
      if Assigned(FOnMouseMove) then
      begin
        FOnMouseMove(ParamToPosition(lparam), ParamToPressedMouseButtons(wparam));
        Result := 0;
      end;

    WM_MOUSEWHEEL, WM_MOUSEHWHEEL:
      if Assigned(FOnMouseWheel) then
      begin
        XParam := ParamToPosition(WPARAM);
        case msg of
          WM_MOUSEWHEEL: FOnMouseWheel(ParamToPosition(lparam), TVec2i.Create(0, XParam.Y), ParamToPressedMouseButtons(XParam.X));
          WM_MOUSEHWHEEL: FOnMouseWheel(ParamToPosition(lparam), TVec2i.Create(XParam.Y, 0), ParamToPressedMouseButtons(XParam.X));
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
//  if PeekMessage(Mmsg, FHandle, 0, 0, PM_NOREMOVE) then
  begin
    TranslateMessage(Mmsg);
    DispatchMessage(Mmsg);
  end;
end;

procedure TQuadWindow.SetSize(AWidth, AHeight: Integer);
var
  NewWidth, NewHeight: Integer;
  Client, Window: TRect;
  Diff: TPoint;
begin
  NewWidth := AWidth;
  NewHeight := AHeight;

  GetClientRect(Self.FHandle, Client);
  GetWindowRect(Self.FHandle, Window);

  if (AHeight >= GetSystemMetrics(SM_CYSCREEN)) and
     (AWidth >= GetSystemMetrics(SM_CXSCREEN)) then
    SetWindowLong(FHandle, GWL_STYLE, GetWindowLong(FHandle, GWL_STYLE) and not WS_BORDER and not WS_SIZEBOX and not WS_DLGFRAME)
  else
  begin
    Diff.X := Window.Right - Window.Left - Client.Right;
    Diff.Y := Window.Bottom - Window.Top - Client.Bottom;
  end;

  MoveWindow(Self.FHandle, 0, 0, AWidth + Diff.X, AHeight + Diff.Y, True);
//  SetWindowPos(FHandle, 0, 0, 0, NewWidth, NewHeight, SWP_NOMOVE or SWP_NOZORDER);
end;

procedure TQuadWindow.SetPosition(AXpos, AYPos: Integer);
begin
  SetWindowPos(FHandle, 0, AXpos, AYPos, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
end;

procedure TQuadWindow.SetOnCreate(OnCreate: TOnCreate);
begin
  FOnCreate := OnCreate;
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
  FOnMousDown := OnMouseDown;
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

end.
