program demo08;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, QuadFX, Vec2f{, QuadFX.Manager};

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;

  QuadFXManager: IQuadFXManager;
  QuadFXLayer: IQuadFXLayer;
  QuadFXEffectParams: IQuadFXEffectParams;
  QuadFXEffectParams2: IQuadFXEffectParams;

procedure OnMouseDown(const APosition: TVec2i; const AButtons: TMouseButtons; const APressedButtons: TPressedMouseButtons); stdcall;
var
  Effect: IQuadFXEffect;
begin
  if AButtons = mbLeft then
    QuadFXLayer.CreateEffect(QuadFXEffectParams, APosition, Effect);

  if AButtons = mbRight then
    QuadFXLayer.CreateEffect(QuadFXEffectParams2, APosition, Effect);
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadFXLayer.Update(delta);

  QuadRender.BeginRender;
  QuadRender.Clear($FFCCCCCC);
  QuadFXLayer.Draw;
  QuadRender.EndRender;
end;

begin
  Randomize;
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadFX plugin demo');
  QuadWindow.SetSize(1024, 768);
  QuadWindow.SetOnMouseDown(OnMouseDown);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, 1024, 768, False);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  //Manager := TQuadFXManager.Create(QuadDevice);
  //QuadFXManager := Manager;
  QuadFXManager := CreateQuadFXManager(QuadDevice);

  QuadFXManager.CreateLayer(QuadFXLayer);

  QuadFXManager.CreateEffectParams(QuadFXEffectParams);
  QuadFXEffectParams.LoadFromFile('Effect1', 'data\QuadFX_Effect.json');

  QuadFXManager.CreateEffectParams(QuadFXEffectParams2);
  QuadFXEffectParams2.LoadFromFile('Effect2', 'data\QuadFX_Effect.json');
  //QuadFXEffectParams.CreateEmitterParams;

  QuadWindow.Start;
end.
