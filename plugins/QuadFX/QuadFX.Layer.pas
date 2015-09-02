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
    FParticleCount: Integer;
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
    function GetParticleCount: Integer; stdcall;
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

function TQuadFXLayer.GetParticleCount: Integer; stdcall;
begin
  Result := FParticleCount;
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
  FParticleCount := 0;
  for i := FEffects.Count - 1 downto 0 do
    if TQuadFXEffect(FEffects[i]).IsNeedToKill then
    begin
      //FEffects[i] := nil;
      FEffects.Delete(i);
    end
    else
    begin
      FEffects[i].Update(ADelta);
      FParticleCount := FParticleCount + FEffects[i].ParticleCount;
    end;
end;

procedure TQuadFXLayer.Draw; stdcall;
var
  Ef, Em: Integer;
  Emitter: TQuadFXEmitter;
  i: Integer;
  P: PQuadFXParticle;
  Sprite: PQuadFXSprite;
  Color: TQuadColor;
begin
  for Ef := 0 to FEffects.Count - 1 do
  begin
    for Em := 0 to FEffects[Ef].GetEmitterCount - 1 do
    begin
      Emitter := TQuadFXEmitter(FEffects[Ef].GetEmitter(Em));
      if not Assigned(FOnDraw) then
      begin
        Manager.QuadRender.SetBlendMode(Emitter.EmitterParams.BlendMode);
        Manager.QuadRender.FlushBuffer;
        Manager.QuadRender.SetTexture(0, Emitter.EmitterParams.Textures[0].Texture.GetTexture(0));
        Manager.QuadRender.AddTrianglesToBuffer(Emitter.Vertexes^, 6 * Emitter.ParticleCount);
        Manager.QuadRender.FlushBuffer;
        P := Emitter.Particle;
        for i := 0 to Emitter.ParticleCount - 1 do
        begin
          if (Emitter.EmitterParams.TextureCount > 0) then
          begin
            Color := $FF00FF00;
            Color.A := 1 - P.Time / P.LifeTime;
            Manager.QuadRender.DrawCircle(TVec2f.Create((i mod 100) * 1, 1 + (i div 100) * 5), 1, 0, Color );

          //  Manager.QuadRender.DrawQuadLine(TVec2f.Create(P.Vertexes[0].x, P.Vertexes[0].Y), TVec2f.Create(P.Vertexes[1].x, P.Vertexes[1].Y), 2, 2, $FFFF0000, $FF00FF00);
          //  Manager.QuadRender.DrawQuadLine(TVec2f.Create(P.Vertexes[2].x, P.Vertexes[2].Y), TVec2f.Create(P.Vertexes[5].x, P.Vertexes[5].Y), 2, 2, $FFFF0000, $FF00FF00);

           // Sprite := Emitter.EmitterParams.Textures[P.TextureIndex];
           // if Assigned(Sprite) and Assigned(Sprite.Texture) then
           //     Sprite.Texture.DrawMapRotAxis(
           //     P.Position - Sprite.Size / 2, P.Position + Sprite.Size / 2,
           //     Sprite.UVA, Sprite.UVB, P.Position, P.Angle, P.Scale.Value, P.Color
           //   );
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
