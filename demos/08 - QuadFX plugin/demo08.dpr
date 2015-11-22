program demo08;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, QuadFX, Vec2f, QuadFX.Manager, System.SysUtils, Math;

const
  WIN_SIZE: TVec2i = (X: 1024; Y: 768);
  RENDER_SIZE: TVec2i = (X: 1024; Y: 768);

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

  Effect: IQuadFXEffect;

procedure OnKeyPress(const AKey: Word; const APressedButtons: TPressedKeyButtons); stdcall;
begin
  if Assigned(Effect) then
    case AKey of
      {Q}81: Effect.SetEnabled(not Effect.GetEnabled);
      {W}87: Effect.SetEmissionEnabled(not Effect.GetEmissionEnabled);
      {E}69: Effect.SetVisible(not Effect.GetVisible);
    end;
end;

procedure OnMouseDown(const APosition: TVec2i; const AButtons: TMouseButtons; const APressedButtons: TPressedMouseButtons); stdcall;
var
  Position: TVec2f;
begin
  Position := APosition / TVec2f(WIN_SIZE) * RENDER_SIZE;

  if AButtons = mbLeft then
    QuadFXLayer.CreateEffect(QuadFXEffectParams, Position, 0, 1.5);

  if (AButtons = mbRight) and not Assigned(Effect) then
    QuadFXLayer.CreateEffectEx(QuadFXEffectParams2, Position, Effect, DegToRad(45), 1);
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

  if Assigned(Effect) then
  begin
    QuadRender.SetBlendMode(qbmNone);
    if Effect.GetEnabled then
      QuadRender.Rectangle(TVec2f.Create(20, 20), TVec2f.Create(30, 30), $FFFF0000);

    if Effect.GetEmissionEnabled then
      QuadRender.Rectangle(TVec2f.Create(40, 20), TVec2f.Create(50, 30), $FFFF0000);

    if Effect.GetVisible then
      QuadRender.Rectangle(TVec2f.Create(60, 20), TVec2f.Create(70, 30), $FFFF0000);
  end;

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
  QuadWindow.SetOnKeyDown(OnKeyPress);

  QuadWindow.SetOnClose(OnClose);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, RENDER_SIZE.X, RENDER_SIZE.Y, False);

  QuadDevice.CreateAndLoadTexture(0, 'data\Background.png', Background);

  Manager := TQuadFXManager.Create(QuadDevice);
  QuadFXManager := Manager;
  //QuadFXManager := CreateQuadFXManager(QuadDevice);

  QuadFXManager.CreateLayer(QuadFXLayer);
  QuadFXLayer.SetGravitation(TVec2f.Create(10, 10));

 // QuadFXManager.CreateAtlas(QuadFXAtlas);
 // QuadFXAtlas.LoadFromFile('Atlas', 'data\QuadFX_Effect.json');

  QuadFXManager.CreateEffectParams(QuadFXEffectParams);
  QuadFXEffectParams.LoadFromFile('Effect1', 'data\QuadFX_Effect.json');

  QuadFXManager.CreateEffectParams(QuadFXEffectParams2);
  QuadFXEffectParams2.LoadFromFile('Effect2', 'data\QuadFX_Effect.json');
  //QuadFXEffectParams.CreateEmitterParams;

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);
  QuadWindow.Start;
end.
