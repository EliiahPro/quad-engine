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
    FEffects: TList<IQuadFXEffect>;
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
  FEffects := TList<IQuadFXEffect>.Create;
end;

destructor TQuadFXLayer.Destroy;
begin
  Clear;
  FEffects.Free;
  inherited;
end;

procedure TQuadFXLayer.CreateEffect(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; out AEffect: IQuadFXEffect); stdcall;
var
  NewEffect: IQuadFXEffect;
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
    if TQuadFXEffect(FEffects[i]).IsNeedToKill then
    begin
      //FEffects[i] := nil;
      FEffects.Delete(i);
    end
    else
      FEffects[i].Update(ADelta);
end;

procedure TQuadFXLayer.Draw; stdcall;
var
  Ef, Em: Integer;
  Emitter: TQuadFXEmitter;
  i: Integer;
  P: PQuadFXParticle;
  Texture: PQuadFXTextureInfo;
begin
  for Ef := 0 to FEffects.Count - 1 do
  begin
    for Em := 0 to FEffects[Ef].GetEmitterCount - 1 do
    begin
      Emitter := TQuadFXEmitter(FEffects[Ef].GetEmitter(Em));
      Manager.QuadRender.SetBlendMode(Emitter.EmitterParams.BlendMode);
      if not Assigned(FOnDraw) then
      begin
        P := Emitter.Particle;
        for i := 0 to Emitter.ParticleCount - 1 do
        begin
          if (Emitter.EmitterParams.TextureCount > 0) then
          begin
            Texture := @Emitter.EmitterParams.Textures[P.TextureIndex];
            if Assigned(Texture) then
              Texture.Texture.DrawMapRotAxis(
                P.Position - Texture.Size / 2, P.Position + Texture.Size / 2,
                Texture.UVA, Texture.UVB, P.Position, P.Angle, P.Scale.Value, P.Color
              );
          end;
         // else
         //   QuadRender.DrawCircle(P.Position, 3 * P.Scale.Value, 2 * P.Scale.Value, P.Color);
          Inc(P);
        end;
      end
      else
        FOnDraw(Emitter, Emitter.Particle, Emitter.ParticleCount);
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
