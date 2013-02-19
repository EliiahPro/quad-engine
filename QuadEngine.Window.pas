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

const
  WND_TITLE = 'QuadWindow';
  APP_NAME = 'QuadWindow';
  CLASS_NAME = APP_NAME;

  W_WIDTH = 512 + 6;
  W_HEIGHT = 512 + 32;


type
  TQuadWindow = class(TInterfacedObject, IQuadWindow)
  private
    FOnIdle : procedure;
  public
    procedure CreateWindow; stdcall;
    function GetHandle: Cardinal; stdcall;
    procedure SetDimentions(AWidth, AHeight: Integer); stdcall;
    procedure SetPosition(ATop, ALeft: Integer); stdcall;
  end;

var
  finished : boolean = False;
  h_Wnd : HWND;
  width, height : Integer;

  procedure EnterMainCycle;
  procedure CreateWindow;


implementation

//=============================================================================
//
//=============================================================================
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
begin
  case Msg of
    WM_CREATE :
      begin
        SetWindowText(hWnd, PChar(WND_TITLE));
        Result := 0;
      end;
    WM_DESTROY :
      begin
        PostQuitMessage(0);
        Result:= 0;
      end;
    WM_SIZE :
      begin
        Height := lParam shr 16;
        Width := lParam and $FFFF;
      end;
    WM_KEYDOWN :
      begin
        if wParam = VK_ESCAPE then
          finished:= True;
      end;
  else
    Result := DefWindowProc(hWnd, msg, wParam, lParam);
  end;
end;

//=============================================================================
//
//=============================================================================
Function WinMain(hInstance : HINST; hPrevInstance : HINST;
                 lpCmdLine : PChar; nCmdShow : Integer) : Integer; stdcall;
var
  msg : TMsg;
  wndClass : WndClassEx;
  dwStyle, dwExStyle : DWORD;
begin
  wndClass.cbSize        := SizeOf(wndClass);
  wndClass.style         := CS_HREDRAW or CS_VREDRAW;
  wndClass.lpfnWndProc   := @WndProc;
  wndClass.cbClsExtra    := 0;
  wndClass.cbWndExtra    := 0;
  wndClass.hInstance     := hInstance;
  wndClass.hIcon         := LoadIcon(0, 'icon.ico');
  wndClass.hIconSm       := LoadIcon(0, 'icon.ico');
  wndClass.hCursor       := LoadCursor(0, IDC_ARROW);
  wndClass.hbrBackground := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
  wndClass.lpszMenuName  := Nil;
  wndClass.lpszClassName := CLASS_NAME;

  RegisterClassEx(wndClass);

  dwStyle := WS_CAPTION or WS_BORDER or WS_SYSMENU;
  dwExStyle := WS_EX_APPWINDOW or WS_EX_WINDOWEDGE;

  h_Wnd := CreateWindowEx(dwExStyle,
                          CLASS_NAME,
                          PChar(APP_NAME),
                          dwStyle,
                          (GetSystemMetrics(SM_CXSCREEN) - W_WIDTH) div 2,
                          (GetSystemMetrics(SM_CYSCREEN) - W_HEIGHT) div 2,
                          W_WIDTH,
                          W_HEIGHT,
                          0,
                          0,
                          hInstance,
                          nil);

  if h_Wnd = 0 then
    Result := 0;

  ShowWindow(h_Wnd, SW_SHOW);
end;

//=============================================================================
//
//=============================================================================
procedure ProcessMessages;
var
  Msg : tagMSG;
begin
  if (PeekMessage(Msg, 0, 0, 0, PM_REMOVE)) then
  begin
    // если не получено сообщения выхода, обрабатываем сообщения
    if (msg.message = WM_QUIT) then finished := True
    else begin
    	TranslateMessage(msg);
      DispatchMessage(msg);
    end;
  end;
end;

//=============================================================================
//
//=============================================================================
procedure CreateWindow;
begin
  Randomize;
  WinMain(hInstance, hPrevInst, CmdLine, CmdShow);
end;

//=============================================================================
//
//=============================================================================
procedure EnterMainCycle;
begin
  while not finished do
  begin
    ProcessMessages;
//    if Assigned(OnIdle) then
//      OnIdle;
  end;
end;


{ TQuadWindowr }

procedure TQuadWindow.CreateWindow;
begin
  WinMain(hInstance, hPrevInst, CmdLine, CmdShow);
  EnterMainCycle;
end;

function TQuadWindow.GetHandle: Cardinal;
begin
  Result := h_Wnd;
end;

procedure TQuadWindow.SetDimentions(AWidth, AHeight: Integer);
begin
  SetWindowPos(GetHandle, 0, 0, 0, AWidth, AHeight, SWP_NOMOVE);
end;

procedure TQuadWindow.SetPosition(ATop, ALeft: Integer);
begin
  SetWindowPos(GetHandle, 0, ATop, ALeft, 0, 0, SWP_NOSIZE);
end;

end.
