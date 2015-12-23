program demo05;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, Windows, Vec2f, Math;

const
  WINDOW_WIDTH = 800;
  WINDOW_HEIGHT = 600;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;
  QuadInput: IQuadInput;
  Camera: IQuadCamera;

  QuadLogoTexture: IQuadTexture;

  CursorTexture: IQuadTexture;
  IsCursorMove: Boolean;


procedure ResetCursor;
var
  CursorPosition: TPoint;
begin
  if not IsCursorMove then
    Exit;

  CursorPosition.X := WINDOW_WIDTH div 2;
  CursorPosition.Y := WINDOW_HEIGHT div 2;
  ClientToScreen(QuadWindow.GetHandle, CursorPosition);
  QuadDevice.SetCursorPosition(CursorPosition.X, CursorPosition.Y);
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  MousePosition: TVec2f;
  MouseVector: TVec2f;
  MouseWheel: TVec2f;
begin
  QuadInput.Update;

  QuadInput.GetMousePosition(MousePosition);
  QuadInput.GetMouseVector(MouseVector);
  QuadInput.GetMouseWheel(MouseWheel);

  //Camera.Scale(max(0.1, min(3, Camera.GetScale + TVec2f(AVector).Normalize.Y / 10)));

  Camera.Translate(MouseVector);

  //ResetCursor;
  QuadRender.BeginRender;
  QuadRender.Clear($FF000000);

  QuadRender.SetBlendMode(qbmSrcAlpha);

  Camera.Enable;
  QuadLogoTexture.DrawRot(TVec2f.Zero, 0, 1);
  Camera.Disable;

  QuadRender.DrawQuadLine(
    TVec2f.Create(WINDOW_WIDTH div 2, WINDOW_HEIGHT div 2),
    MousePosition,
    5, 1, $FFFF0000, $FF00FF00
  );

  QuadRender.EndRender;
end;

procedure OnActivate; stdcall;
begin
  IsCursorMove := True;
  ResetCursor;
end;

procedure OnDeactivate; stdcall;
begin
  IsCursorMove := False;
end;

begin
  IsCursorMove := True;
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('Quad-engine cursor and camera demo');
  QuadWindow.SetSize(WINDOW_WIDTH, WINDOW_HEIGHT);
  QuadWindow.SetOnActivate(OnActivate);
  QuadWindow.SetOnDeactivate(OnDeactivate);

  QuadWindow.CreateInput(QuadInput);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, WINDOW_WIDTH, WINDOW_HEIGHT, false);

  QuadDevice.CreateAndLoadTexture(0, 'data\quadlogo.png', QuadLogoTexture);

  QuadDevice.ShowCursor(True);
  QuadDevice.CreateAndLoadTexture(0, 'data\cursor.png', CursorTexture);

  QuadDevice.SetCursorProperties(0, 0, CursorTexture);

  QuadDevice.CreateCamera(Camera);
  Camera.SetPosition(-TVec2f.Create(WINDOW_WIDTH, WINDOW_HEIGHT));

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);
  QuadWindow.Start;
end.
