program demo08;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, QuadFX, Vec2f, QuadFX.Manager;

type
  TEffectDraw = class
    procedure Draw(AEmitter: IQuadFXEmitter; AParticles: PQuadFXParticle; AParticleCount: Integer); stdcall;
  end;

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;

  QuadFXManager: IQuadFXManager;
  QuadFXLayer: IQuadFXLayer;
  QuadFXEffectParams: IQuadFXEffectParams;

  EffectDraw: TEffectDraw;

  ic: Integer;

procedure OnMouseDown(const APosition: TVec2i; const AButtons: TMouseButtons; const APressedButtons: TPressedMouseButtons); stdcall;
var
  Effect: IQuadFXEffect;
begin
  if AButtons = mbLeft then
    QuadFXLayer.CreateEffect(QuadFXEffectParams, APosition, Effect);
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadFXLayer.Update(delta);

  QuadRender.BeginRender;
  QuadRender.Clear($FFCCCCCC);
  ic := 0;
  QuadFXLayer.Draw;
  QuadRender.EndRender;
end;

procedure TEffectDraw.Draw(AEmitter: IQuadFXEmitter; AParticles: PQuadFXParticle; AParticleCount: Integer); stdcall;
var
  i: Integer;
  P: PQuadFXParticle;
begin
  P := AParticles;
  QuadRender.DrawCircle(TVec2f.Create(5 * ic, 5), 2, 0, $FFFF0000);
  inc(ic);
  for i := 0 to AParticleCount - 1 do
  begin
    //QuadRender.DrawCircle(TVec2f.Create(5 * i, 10 + 5 * ic), 2, 0, $FF00FF00);
    QuadRender.DrawCircle(P.Position, 5, 0, $FF000000);
    Inc(P);
  end;
end;

begin
  Randomize;
  QuadDevice := CreateQuadDevice;

  QuadFXManager := TQuadFXManager.Create(QuadDevice);
 // CreateQuadFXManager(QuadDevice);
  QuadFXManager.CreateLayer(QuadFXLayer);

  EffectDraw := TEffectDraw.Create;
  QuadFXLayer.SetOnDraw(EffectDraw.Draw);
  QuadFXManager.CreateEffectParams(QuadFXEffectParams);

  QuadFXEffectParams.CreateEmitterParams;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadFX plugin demo');
  QuadWindow.SetSize(100, 70);
  QuadWindow.SetOnMouseDown(OnMouseDown);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 100, 70, False);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  QuadWindow.Start;
end.
