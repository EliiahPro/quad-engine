program demo10;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, Vec2f;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;
  Lighting: IQuadTexture;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadRender.BeginRender;
  QuadRender.Clear($FF000000);
  QuadRender.SetBlendMode(qbmNone);
  QuadRender.Rectangle(TVec2f.Create(426, 0), TVec2f.Create(853, 720), $FF888888);
  QuadRender.Rectangle(TVec2f.Create(853, 0), TVec2f.Create(1280, 720), $FFFFFFFF);

  QuadRender.SetBlendMode(qbmBlendAdd);
  Lighting.Draw(TVec2f.Create(100, 000));
  Lighting.Draw(TVec2f.Create(500, 000));
  Lighting.Draw(TVec2f.Create(900, 000));

  QuadRender.SetBlendMode(qbmSrcAlphaAdd);
  Lighting.Draw(TVec2f.Create(100, 256));
  Lighting.Draw(TVec2f.Create(500, 256));
  Lighting.Draw(TVec2f.Create(900, 256));

  QuadRender.SetBlendMode(qbmSrcAlpha);
  Lighting.Draw(TVec2f.Create(100, 512));
  Lighting.Draw(TVec2f.Create(500, 512));
  Lighting.Draw(TVec2f.Create(900, 512));

  QuadRender.EndRender;
end;

begin
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('Quad-engine blendmodes demo');
  QuadWindow.SetSize(1280, 720);
  QuadWindow.SetPosition(100, 100);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 1280, 720, False);

  QuadDevice.CreateAndLoadTexture(0, 'data\lighting.png', Lighting);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 50, True);

  QuadWindow.Start;
end.
