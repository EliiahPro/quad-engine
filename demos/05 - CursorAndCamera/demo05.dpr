program demo05;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, Windows, Vec2f, Math;

const
  WINDOW_WIDTH = 300;
  WINDOW_HEIGHT = 240;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;

  QuadLogoTexture: IQuadTexture;

  CursorTexture: IQuadTexture;
  IsCursorMove: Boolean;
  CursorMove: TVec2i;

  Camera: IQuadCamera;

procedure ResetCursor;
var
  CursorPosition: TPoint;
begin
  if not IsCursorMove then
    Exit;

  CursorPosition.X := WINDOW_WIDTH div 2;
  CursorPosition.Y := WINDOW_HEIGHT div 2;
  CursorMove.Create(CursorPosition.X, CursorPosition.Y);
  ClientToScreen(QuadWindow.GetHandle, CursorPosition);
  QuadDevice.SetCursorPosition(CursorPosition.X, CursorPosition.Y);
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  Camera.Translate(CursorMove - TVec2i.Create(WINDOW_WIDTH div 2, WINDOW_HEIGHT div 2));

  ResetCursor;
  QuadRender.BeginRender;
  QuadRender.Clear($FF000000);

  QuadRender.SetBlendMode(qbmSrcAlpha);

  Camera.Enable;
  QuadLogoTexture.DrawRot(TVec2f.Zero, 0, 1);
  Camera.Disable;

  QuadRender.DrawQuadLine(
    TVec2f.Create(WINDOW_WIDTH div 2, WINDOW_HEIGHT div 2),
    CursorMove,
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

procedure OnMouseMove(const APosition: TVec2i; const APressedButtons: TPressedMouseButtons); stdcall;
begin
  CursorMove := APosition;
end;

procedure OnMouseWheel(const APosition: TVec2i; const AVector: TVec2i; const APressedButtons: TPressedMouseButtons); stdcall;
begin
  Camera.Scale(max(0.1, min(3, Camera.GetScale + TVec2f(AVector).Normalize.Y / 10)));
end;

begin
  IsCursorMove := True;
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('Quad-engine cursor and camera demo');
  QuadWindow.SetSize(WINDOW_WIDTH, WINDOW_HEIGHT);
  QuadWindow.SetOnActivate(OnActivate);
  QuadWindow.SetOnDeactivate(OnDeactivate);
  QuadWindow.SetOnMouseMove(OnMouseMove);
  QuadWindow.SetOnMouseWheel(OnMouseWheel);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, WINDOW_WIDTH, WINDOW_HEIGHT, false);

  QuadDevice.CreateAndLoadTexture(0, 'data\quadlogo.png', QuadLogoTexture);

  QuadDevice.ShowCursor(True);
  QuadDevice.CreateAndLoadTexture(0, 'data\cursor.png', CursorTexture);

  QuadDevice.SetCursorProperties(0, 0, CursorTexture);

  QuadDevice.CreateCamera(Camera);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);
  QuadWindow.Start;
end.
