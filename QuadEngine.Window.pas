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
  QuadEngine;

type
  TQuadWindow = class(TInterfacedObject, IQuadWindow)
  private
    FWndClass: TWndClassEx;
    FHandle: THandle;
    FOnKeyDown: TOnKeyPress;
    FOnKeyUp: TOnKeyPress;
    FOnCreate: TOnCreate;
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
      if Assigned(FOnKeyDown) and (lparam and $FE = 0) then
      begin
        FOnKeyDown(wparam);
        Result := 0;
      end;
    end;
  WM_KEYUP:
    begin
      if Assigned(FOnKeyUp) and (lparam and $FE = 1) then
      begin
        FOnKeyUp(wparam);
        Result := 0;
      end;
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
begin
  NewWidth := AWidth;
  NewHeight := AHeight;

  SetWindowPos(FHandle, 0, 0, 0, NewWidth, NewHeight, SWP_NOMOVE or SWP_NOZORDER);
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

end.
