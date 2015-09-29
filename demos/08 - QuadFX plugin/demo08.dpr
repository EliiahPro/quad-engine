program demo08;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, QuadFX, Vec2f, QuadFX.Manager, System.SysUtils;

const
  WIN_SIZE: TVec2i = (X: 160; Y: 90);
  RENDER_SIZE: TVec2i = (X: 160; Y: 90);

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;

  Background: IQuadTexture;

  QuadFXManager: IQuadFXManager;
  QuadFXLayer: IQuadFXLayer;
  QuadFXEffectParams: IQuadFXEffectParams;
  QuadFXEffectParams2: IQuadFXEffectParams;

  QuadFXAtlas: IQuadFXAtlas;

procedure OnMouseDown(const APosition: TVec2i; const AButtons: TMouseButtons; const APressedButtons: TPressedMouseButtons); stdcall;
var
  Position: TVec2f;
begin
  Position := APosition / TVec2f(WIN_SIZE) * RENDER_SIZE;

  if AButtons = mbLeft then
    QuadFXLayer.CreateEffect(QuadFXEffectParams, Position, 0, 0.5);

  if AButtons = mbRight then
    QuadFXLayer.CreateEffect(QuadFXEffectParams2, Position, 45, 1);
end;

procedure DrawBackground;
var
  X, Y: Integer;
begin
  QuadRender.SetBlendMode(qbmNone);
  for Y := 0 to RENDER_SIZE.Y div 65 do
    for X := 0 to RENDER_SIZE.X div 65 do
      Background.Draw(TVec2f.Create(X * 65, Y * 65));
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  Effect: IQuadFXEffect;
  i: Integer;
begin
//  for i := 1 to 7 do
//    QuadFXLayer.CreateEffect(QuadFXEffectParams, TVec2f.Create(Random(RENDER_SIZE.X - 128) + 64, Random(RENDER_SIZE.Y - 128) + 64), Effect);

  QuadFXLayer.Update(delta);

  QuadWindow.SetCaption(PWideChar(Format('%f %f %d', [QuadTimer.GetCPUload, QuadTimer.GetFPS, QuadFXLayer.GetParticleCount])));

  QuadRender.BeginRender;
  QuadRender.Clear($FFCCCCCC);
  DrawBackground;
  QuadFXLayer.Draw;
  QuadRender.EndRender;
end;

procedure OnClose; stdcall;
begin
  QuadTimer.SetState(False);
  sleep(500);

  Background := nil;

  QuadFXEffectParams := nil;
  QuadFXEffectParams2 := nil;
  QuadFXAtlas := nil;
  QuadFXLayer := nil;
  QuadFXManager := nil;

  QuadTimer := nil;
  QuadRender := nil;
  QuadWindow := nil;
  QuadDevice := nil;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  Randomize;
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadFX plugin demo');
  QuadWindow.SetSize(WIN_SIZE.X, WIN_SIZE.Y);
  QuadWindow.SetOnMouseDown(OnMouseDown);
  QuadWindow.SetOnClose(OnClose);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, RENDER_SIZE.X, RENDER_SIZE.Y, False);

  QuadDevice.CreateAndLoadTexture(0, 'data\Background.png', Background);

  Manager := TQuadFXManager.Create(QuadDevice);
  QuadFXManager := Manager;
  //QuadFXManager := CreateQuadFXManager(QuadDevice);

  QuadFXManager.CreateLayer(QuadFXLayer);

  QuadFXManager.CreateAtlas(QuadFXAtlas);
  QuadFXAtlas.LoadFromFile('Atlas', 'data\QuadFX_Effect.json');

  QuadFXManager.CreateEffectParams(QuadFXEffectParams);
  QuadFXEffectParams.LoadFromFile('Effect1', 'data\QuadFX_Effect.json');

  QuadFXManager.CreateEffectParams(QuadFXEffectParams2);
  QuadFXEffectParams2.LoadFromFile('Effect2', 'data\QuadFX_Effect.json');
  //QuadFXEffectParams.CreateEmitterParams;

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);
  QuadWindow.Start;
end.
