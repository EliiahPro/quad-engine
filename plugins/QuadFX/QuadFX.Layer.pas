unit QuadFX.Layer;

interface

uses
  QuadFX, QuadFX.Emitter, QuadEngine, QuadEngine.Color, Vec2f,
  System.Generics.Collections, QuadFX.Effect;

type
  TQuadFXLayer = class(TInterfacedObject, IQuadFXLayer)
  private
    FOnDraw: TQuadFXEmitterDrawEvent;
    FOnDebugDraw: TQuadFXEmitterDrawEvent;
    FEffects: TList<TQuadFXEffect>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure EffectAdd(AEffect: TQuadFXEffect);
    procedure Update(const ADelta: Double); stdcall;
    procedure Draw; stdcall;
    procedure Clear; stdcall;
    procedure CreateEffect(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; out AEffect: IQuadFXEffect); stdcall;
    procedure SetOnDraw(AOnDraw: TQuadFXEmitterDrawEvent);
    procedure SetOnDebugDraw(AOnDebugDraw: TQuadFXEmitterDrawEvent);
    function GetEffectCount: Integer; stdcall;
  end;

implementation

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
  FEffects := TList<TQuadFXEffect>.Create;
end;

destructor TQuadFXLayer.Destroy;
begin
  Clear;
  FEffects.Free;
  inherited;
end;

procedure TQuadFXLayer.CreateEffect(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; out AEffect: IQuadFXEffect); stdcall;
var
  NewEffect: TQuadFXEffect;
begin
  if not Assigned(AEffectParams) then
    Exit;

  NewEffect := TQuadFXEffect.Create(AEffectParams, APosition);
  FEffects.Add(NewEffect);

  //NewEffect.Update(1.2);
  AEffect := NewEffect;
end;

function TQuadFXLayer.GetEffectCount: Integer; stdcall;
begin
  Result := FEffects.Count;
end;

procedure TQuadFXLayer.Clear; stdcall;
var
  i: Integer;
begin
  for i := FEffects.Count - 1 downto 0 do
    if Assigned(FEffects[i]) then
      FEffects[i] := nil;
end;

procedure TQuadFXLayer.Update(const ADelta: Double); stdcall;
var
  i: Integer;
begin
  for i := FEffects.Count - 1 downto 0 do
    if FEffects[i].IsNeedToKill then
    begin
      FEffects[i] := nil;
      FEffects.Remove(FEffects[i]);
    end
    else
      FEffects[i].Update(ADelta);
end;

procedure TQuadFXLayer.Draw; stdcall;
var
  Ef, Em: Integer;
  Emitter: TQuadFXEmitter;
begin
  if not Assigned(FOnDraw) then
    Exit;

  for Ef := 0 to FEffects.Count - 1 do
  begin
    for Em := 0 to FEffects[Ef].GetEmitterCount - 1 do
    begin
      Emitter := TQuadFXEmitter(FEffects[Ef].GetEmitter(Em));
      FOnDraw(Emitter, Emitter.Particle, Emitter.ParticleCount)
    end;
  end;
 // for i := 0 to FEffects.Count - 1 do
 //   FEffects[i].Draw;
end;

procedure TQuadFXLayer.EffectAdd(AEffect: TQuadFXEffect);
begin
  FEffects.Add(AEffect);
end;

end.
