program demo03;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, Vec2f, QuadEngine.Color;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;

  Xpos, Ypos: Integer;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadRender.BeginRender;
  QuadRender.Clear(0);

  QuadRender.Rectangle(TVec2f.Create(100, 100), TVec2f.Create(400, 400), TQuadColor.Blue);
  QuadRender.Rectangle(TVec2f.Create(200, 200), TVec2f.Create(500, 500), TQuadColor.Lime.Lerp(TQuadColor.Red, Xpos/800));

  QuadRender.SetBlendMode(qbmSrcAlpha);
  QuadRender.DrawCircle(TVec2f.Create(400, 400), 100, 95, TQuadColor.Blue);
  QuadRender.DrawCircle(TVec2f.Create(Xpos, Ypos), 30, 27, TQuadColor.Aqua);

  QuadRender.DrawQuadLine(TVec2f.Create(400, 400), TVec2f.Create(Xpos, Ypos), 5, 5, TQuadColor.Blue, TQuadColor.Aqua);

  QuadRender.EndRender;
end;

procedure OnMouseMove(const APosition: TVec2i; const APressedButtons: TPressedMouseButtons); stdcall;
begin
  Xpos := APosition.X;
  Ypos := APosition.Y;
end;

begin
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadEngine - Demo03 - Primitives');
  QuadWindow.SetSize(800, 600);
  QuadWindow.SetOnMouseMove(OnMouseMove);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 800, 600, False);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
