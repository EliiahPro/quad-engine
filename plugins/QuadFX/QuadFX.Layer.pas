unit QuadFX.Layer;

interface

uses
  QuadFX, QuadFX.Emitter, QuadEngine, QuadEngine.Color, Vec2f,
  System.Generics.Collections, QuadFX.Effect, Winapi.Windows, QuadFX.LayerEffectProxy;

type
  TQuadFXLayer = class(TInterfacedObject, IQuadFXLayer)
  private
    FOnDraw: TQuadFXEmitterDrawEvent;
    FOnDebugDraw: TQuadFXEmitterDrawEvent;
    FEffects: TList<IQuadFXEffect>;
    FParticleCount: Integer;
    FLayerEffectProxy: TLayerEffectProxy;
  public
    constructor Create;
    destructor Destroy; override;
    procedure EffectAdd(AEffect: TQuadFXEffect);
    procedure Update(const ADelta: Double); stdcall;
    procedure Draw; stdcall;
    procedure Clear; stdcall;
    function CreateEffect(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; AAngle: Single = 0; AScale: Single = 1): HResult; stdcall;
    function CreateEffectEx(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; out AEffect: IQuadFXEffect; AAngle: Single = 0; AScale: Single = 1): HResult; stdcall;
    procedure SetOnDraw(AOnDraw: TQuadFXEmitterDrawEvent);
    procedure SetOnDebugDraw(AOnDebugDraw: TQuadFXEmitterDrawEvent);
    procedure SetGravitation(Avector: TVec2f); stdcall;
    function GetEffectCount: Integer; stdcall;
    function GetParticleCount: Integer; stdcall;
    function GetEffect(AIndex: Integer; out AEffect: IQuadFXEffect): HResult; stdcall;
    function GetGravitation: TVec2f; stdcall;
  end;

implementation

uses
  QuadFX.Manager;

procedure TQuadFXLayer.SetOnDraw(AOnDraw: TQuadFXEmitterDrawEvent);
begin
  FOnDraw := AOnDraw;
end;

procedure TQuadFXLayer.SetOnDebugDraw(AOnDebugDraw: TQuadFXEmitterDrawEvent);
begin
  FOnDebugDraw := AOnDebugDraw;
end;

constructor TQuadFXLayer.Create;
begin
  FParticleCount := 0;
  FEffects := TList<IQuadFXEffect>.Create;
  FLayerEffectProxy := TLayerEffectProxy.Create;
end;

destructor TQuadFXLayer.Destroy;
begin
  FLayerEffectProxy.Free;
  FEffects.Free;
  inherited;
end;

function TQuadFXLayer.CreateEffect(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; AAngle: Single = 0; AScale: Single = 1): HResult; stdcall;
var
  NewEffect: IQuadFXEffect;
begin
  Result := CreateEffectEx(AEffectParams, APosition, NewEffect, AAngle, AScale);
end;

function TQuadFXLayer.CreateEffectEx(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; out AEffect: IQuadFXEffect; AAngle: Single = 0; AScale: Single = 1): HResult; stdcall;
var
  NewEffect: IQuadFXEffect;
begin
  AEffect := nil;
  if Assigned(AEffectParams) then
  begin
    AEffect := Manager.GetEffectFromPool(AEffectParams);
    if not Assigned(AEffect) then
      AEffect := TQuadFXEffect.Create(AEffectParams, APosition, AAngle, AScale)
    else
      TQuadFXEffect(AEffect).Restart(APosition, AAngle, AScale);

    TQuadFXEffect(AEffect).SetLayerEffectProxy(FLayerEffectProxy);

    if Assigned(AEffect) then
      FEffects.Add(AEffect);

    //NewEffect.Update(1.2);
  end;

  if Assigned(AEffect) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadFXLayer.GetEffectCount: Integer; stdcall;
begin
  Result := FEffects.Count;
end;

function TQuadFXLayer.GetEffect(AIndex: Integer; out AEffect: IQuadFXEffect): HResult; stdcall;
begin
  AEffect := FEffects[AIndex];
  if Assigned(AEffect) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadFXLayer.GetParticleCount: Integer; stdcall;
begin
  Result := FParticleCount;
end;

procedure TQuadFXLayer.Clear; stdcall;
begin
  FEffects.Clear;
end;

procedure TQuadFXLayer.Update(const ADelta: Double); stdcall;
var
  i: Integer;
begin
  FParticleCount := 0;
  for i := FEffects.Count - 1 downto 0 do
    if TQuadFXEffect(FEffects[i]).IsNeedToKill then
    begin
      Manager.AddEffectToPool(FEffects[i]);
      FEffects.Delete(i);
    end
    else
    begin
      FEffects[i].Update(ADelta);
      FParticleCount := FParticleCount + FEffects[i].GetParticleCount;
    end;
end;

procedure TQuadFXLayer.Draw; stdcall;
var
  i: Integer;
  Effect: IQuadFXEffect;
  Emitter: IQuadFXEmitter;
begin
  for Effect in FEffects do
  begin
    if Assigned(FOnDraw) then
    begin
      for i := 0 to Effect.GetEmitterCount - 1 do
      begin
        Effect.GetEmitter(i, Emitter);
        FOnDraw(Emitter, TQuadFXEmitter(Emitter).Particle, Emitter.GetParticleCount);
      end;
    end
    else
      Effect.Draw;
  end;
end;

procedure TQuadFXLayer.EffectAdd(AEffect: TQuadFXEffect);
begin
  FEffects.Add(AEffect);
end;

procedure TQuadFXLayer.SetGravitation(AVector: TVec2f); stdcall;
begin
  FLayerEffectProxy.Gravitation := AVector;
end;

function TQuadFXLayer.GetGravitation: TVec2f; stdcall;
begin
  Result := FLayerEffectProxy.Gravitation;
end;

end.
