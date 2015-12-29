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

  Camera.Scale(max(0.1, min(3, Camera.GetScale + TVec2f(MouseWheel).Normalize.Y / 10)));

  Camera.Translate(MouseVector);

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

begin
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadEngine - Demo05 - Cursor and Camera');
  QuadWindow.SetSize(WINDOW_WIDTH, WINDOW_HEIGHT);

  QuadWindow.CreateInput(QuadInput);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, WINDOW_WIDTH, WINDOW_HEIGHT, false);

  QuadDevice.CreateAndLoadTexture(0, 'data\quadlogo.png', QuadLogoTexture);

  QuadDevice.CreateAndLoadTexture(0, 'data\cursor.png', CursorTexture);

  QuadDevice.ShowCursor(True);
 // QuadDevice.SetCursorProperties(0, 0, CursorTexture);

  QuadDevice.CreateCamera(Camera);
  Camera.SetPosition(-TVec2f.Create(WINDOW_WIDTH, WINDOW_HEIGHT));

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);
  QuadWindow.Start;
end.
