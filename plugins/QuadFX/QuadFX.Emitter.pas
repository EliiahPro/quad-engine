unit QuadFX.Emitter;

interface

uses
  QuadFX, QuadFX.Helpers, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.EffectEmitterProxy;

type
  TQuadFXEmitter = class(TInterfacedObject, IQuadFXEmitter)
  private
    FIsDebug: Boolean;
    FRect: record
      LeftTop, RightBottom: TVec2f;
    end;
    FActive: Boolean;
    FParams: PQuadFXEmitterParams;

    FVertexes: PVertexes;
    FVertexesLastRecord: PVertexes;
    FVertexeSize: Cardinal;
    FVertexesSize: Cardinal;

    FParticles: PQuadFXParticle;
    FParticlesCount: Cardinal;
    FParticlesLastRecord: PQuadFXParticle;
    FParticleSize: Cardinal;
    FParticlesSize: Cardinal;

    FPosition: record
      X: TQuadFXParticleValue;
      Y: TQuadFXParticleValue;
    end;

    FStartVelocity: TQuadFXParticleValue;
    FStartAngle: TQuadFXParticleValue;
    FDirection: TQuadFXParticleValue;
    FSpread: TQuadFXParticleValue;

    FTime: Double;
    FLastTime: Double;
    FLife: Double;
    FEmission: TQuadFXParticleValue;
    FValues: array[0..2] of Single;

    FParticleLastTime: TQuadFXParticleValue;

    FEffectEmitterProxy: IEffectEmitterProxy;

    function Add: PQuadFXParticle;
    procedure ParticleUpdate(AParticle: PQuadFXParticle; ADelta: Double);
    function GetEmitterParams: PQuadFXEmitterParams; stdcall;
    function GetParticleCount: integer; stdcall;
    function GetValue(Index: Integer): Single;
    function GetEmission: Single;
    function GetActive: Boolean; stdcall;
    procedure UpdateParams;
    function GetPosition: TVec2f;
    function GetDirection: Single;
    function GetSpread: Single;
    function GetStartVelocity: Single;
    function GetStartAngle: Single;
  public
    FValuesIndex: array[0..2] of Integer;
    constructor Create(AEffectEmitterProxy: IEffectEmitterProxy; AParams: PQuadFXEmitterParams);
    destructor Destroy; override;
    procedure Restart;
    procedure RestartParams;

    procedure Update(ADelta: Double); stdcall;
    property Position: TVec2f read GetPosition;
    property IsDebug: Boolean read FIsDebug write FIsDebug;

    property EmitterParams: PQuadFXEmitterParams read GetEmitterParams;
    property Vertexes: PVertexes read FVertexes;
    property Particle: PQuadFXParticle read FParticles;
    property ParticleCount: Cardinal read FParticlesCount;

    property Life: Double read FLife;
    property Time: Double read FTime;
    property Values[Index: Integer]: Single read GetValue;
    property Emission: Single read GetEmission;

    property Direction: Single read GetDirection;
    property Spread: Single read GetSpread;
    property StartVelocity: Single read GetStartVelocity;
    property StartAngle: Single read GetStartAngle;
  end;

implementation

uses
  Math, QuadEngine.Utils, QuadFX.Effect;

function TQuadFXEmitter.GetPosition: TVec2f;
var
  SinRad, CosRad: Single;
begin
  FEffectEmitterProxy.GetSinCos(SinRad, CosRad);

  Result := TVec2f.Create(
    FPosition.X.Value * CosRad - FPosition.Y.Value * SinRad,
    FPosition.X.Value * SinRad + FPosition.Y.Value * CosRad
  );
end;

function TQuadFXEmitter.GetDirection: Single;
begin
  Result := FDirection.Value;
end;

function TQuadFXEmitter.GetSpread: Single;
begin
  Result := FSpread.Value;
end;

procedure TQuadFXEmitter.RestartParams;
var
  i: Integer;
begin
  FTime := FTime - (FParams.EndTime - FParams.BeginTime);
  FLife := 0;
  FActive := True;

  for i := 0 to 2 do
    FValuesIndex[i] := 0;

  FParticleLastTime := TQuadFXParticleValue.Create(@FParams.Particle.LifeTime);
  FEmission := TQuadFXParticleValue.Create(@FParams.Emission);
  FPosition.X := TQuadFXParticleValue.Create(@FParams.Position.X);
  FPosition.Y := TQuadFXParticleValue.Create(@FParams.Position.Y);
  FDirection := TQuadFXParticleValue.Create(@FParams.Direction);
  FSpread := TQuadFXParticleValue.Create(@FParams.Spread);
  FStartVelocity := TQuadFXParticleValue.Create(@FParams.Particle.StartVelocity);
  FStartAngle := TQuadFXParticleValue.Create(@FParams.Particle.StartAngle);
end;

procedure TQuadFXEmitter.Restart;
var
  P: PQuadFXParticle;
  V: PVertexes;
begin
  RestartParams;
  FTime := 0;

  P := FParticles;
  while Cardinal(P) < Cardinal(FParticlesLastRecord) do
  begin
    Dec(FParticlesLastRecord);
    Dec(FVertexesLastRecord);
    V := P.Vertexes;
    P^ := FParticlesLastRecord^;
    V^ := FParticlesLastRecord.Vertexes^;
    P.Vertexes := V;
    Dec(FParticlesCount);
  end;
end;

function TQuadFXEmitter.GetStartVelocity: Single;
begin
  Result := FStartVelocity.Value;
end;

function TQuadFXEmitter.GetStartAngle: Single;
begin
  Result := FStartAngle.Value;
end;

function TQuadFXEmitter.GetActive: Boolean;
begin
  Result := FActive;
end;

function TQuadFXEmitter.GetEmission: Single;
begin
  Result := FEmission.Value;
end;

function TQuadFXEmitter.GetParticleCount: integer; stdcall;
begin
  Result := FParticlesCount;
end;

function TQuadFXEmitter.GetEmitterParams: PQuadFXEmitterParams; stdcall;
begin
  Result := FParams;
end;

function TQuadFXEmitter.GetValue(Index: Integer): Single;
begin
  Result := FValues[Index];
end;

constructor TQuadFXEmitter.Create(AEffectEmitterProxy: IEffectEmitterProxy; AParams: PQuadFXEmitterParams);
//var
//  i: Integer;
begin
  FEffectEmitterProxy := AEffectEmitterProxy;
  FActive := True;
  FIsDebug := False;
  FTime := 0;
  FLife := 0;
  FLastTime := 0;
  FParticlesCount := 0;
  FParticleSize := SizeOf(TQuadFXParticle);
  FParticlesSize := FParticleSize * AParams.MaxParticles;
  GetMem(FParticles, FParticlesSize);

  FVertexeSize := SizeOf(TVertexes);
  FVertexesSize := FVertexeSize * AParams.MaxParticles;
  GetMem(FVertexes, FVertexesSize);

  FVertexesLastRecord := FVertexes;
  FParticlesLastRecord := FParticles;

  FParams := AParams;
  RestartParams;
  FTime := 0;
end;

procedure TQuadFXEmitter.UpdateParams;
var
  i: Integer;
  SPrev, SNext: PQuadFXSingleDiagramValue;
begin

  if (FParams.Shape.ParamType = qpptCurve) and (FParams.Shape.ShapeType <> qeftPoint) then
  begin
    for i := 0 to 2 do
      if FParams.Shape.Diagram[i].Count > 1 then
      begin
        if FLife > FParams.Shape.Diagram[i].List[0].Life then
        begin
          if (FLife < FParams.Shape.Diagram[i].List[FParams.Shape.Diagram[i].Count - 1].Life) and (FValuesIndex[i] < FParams.Shape.Diagram[i].Count) then
          begin
            while FLife > FParams.Shape.Diagram[i].List[FValuesIndex[i]].Life do
              FValuesIndex[i] := FValuesIndex[i] + 1;

            SPrev := @FParams.Shape.Diagram[i].List[FValuesIndex[i] - 1];
            SNext := @FParams.Shape.Diagram[i].List[FValuesIndex[i]];
            FValues[i] := (SNext.Value - SPrev.Value) * (FLife - SPrev.Life) / (SNext.Life - SPrev.Life) + SPrev.Value;
          end
          else
            FValues[i] := FParams.Shape.Diagram[i].List[FParams.Shape.Diagram[i].Count - 1].Value;
        end
        else
          FValues[i] := FParams.Shape.Diagram[i].List[0].Value;
      end
      else
        if FParams.Shape.Diagram[i].Count = 1 then
          FValues[i] := FParams.Shape.Diagram[i].List[0].Value
        else
          FValues[i] := 0;
  end
  else
  begin
    for i := 0 to 2 do
      FValues[i] := FParams.Shape.Value[i];
  end;

  FEmission.Update(FLife);
  FDirection.Update(FLife);
  FSpread.Update(FLife);
  FParticleLastTime.Update(FLife);
end;

destructor TQuadFXEmitter.Destroy;
begin
  FreeMem(FParticles);
  FreeMem(FVertexes);
  FEffectEmitterProxy := nil;
  inherited;
end;

procedure TQuadFXEmitter.Update(ADelta: Double);
var
  P: PQuadFXParticle;
  EmissionTime: Double;
  LifePos: Single;
  V: PVertexes;
begin
  if not Assigned(FParams) then
    Exit;

  P := FParticles;

  if FIsDebug then
  begin
    FRect.LeftTop := Position;
    FRect.RightBottom := FRect.LeftTop;
  end;

  while Cardinal(P) < Cardinal(FParticlesLastRecord) do
  begin
    if (P.Time + ADelta <= P.LifeTime) then
    begin
      ParticleUpdate(P, ADelta);
      Inc(P);
    end
    else
    begin
      Dec(FParticlesLastRecord);
      Dec(FVertexesLastRecord);
      V := P.Vertexes;
      P^ := FParticlesLastRecord^;
      V^ := FParticlesLastRecord.Vertexes^;
      P.Vertexes := V;
      Dec(FParticlesCount);
    end;
  end;

  FTime := FTime + ADelta;

  if FParams.BeginTime > FTime then
    Exit;

  if FTime > FParams.EndTime then
  begin
    if not FParams.IsLoop then
    begin
      FActive := False;
      Exit;
    end
    else
      RestartParams;
  end;

  FLife := (FTime - FParams.BeginTime) / (FParams.EndTime - FParams.BeginTime);
  UpdateParams;
  if FEmission.Value > 0 then
  begin
    LifePos := FLife + FLastTime;
    EmissionTime := 1 / FEmission.Value;
    FLastTime := FLastTime + ADelta;
    while (FLastTime >= EmissionTime) and (FParticlesCount < FParams.MaxParticles) do
    begin
      FPosition.X.Update(LifePos);
      FPosition.Y.Update(LifePos);
      FStartVelocity.Update(LifePos);
      FStartAngle.Update(LifePos);
      LifePos := LifePos + EmissionTime;
      FLastTime := FLastTime - EmissionTime;
      ParticleUpdate(Add, FLastTime);
    end;
  end;
end;

procedure TQuadFXEmitter.ParticleUpdate(AParticle: PQuadFXParticle; ADelta: Double);
  function RealMod(const n, d: single): single;
  var
    i: integer;
  begin
    i := trunc(n / d);
    result := n - d * i;
  end;
var
  CPrev, CNext: PQuadFXColorDiagramValue;
  SinRad, CosRad: Single;
  p1, p2: TVec2f;
begin
  AParticle.Time := AParticle.Time + ADelta;
  AParticle.Life := AParticle.Time / AParticle.LifeTime;

  // Velocity
  AParticle.Velocity.Update(AParticle.Life);
  AParticle.Position := AParticle.Position + AParticle.StartVelocity * AParticle.Velocity.Value * ADelta * FEffectEmitterProxy.GetScale;

  // Spin
  AParticle.Spin.Update(AParticle.Life);
  AParticle.Angle := RealMod(AParticle.StartAngle * AParticle.Spin.Value, 360);
  // Scale
  AParticle.Scale.Update(AParticle.Life);
  // Color
  if AParticle.Life > FParams.Particle.Color.List[0].Life then
  begin
    if (AParticle.Life < FParams.Particle.Color.List[FParams.Particle.Color.Count - 1].Life) and (AParticle.ColorIndex < FParams.Particle.Color.Count) then
    begin
      while AParticle.Life > FParams.Particle.Color.List[AParticle.ColorIndex + 1].Life do
        Inc(AParticle.ColorIndex);

      CPrev := @FParams.Particle.Color.List[AParticle.ColorIndex];
      CNext := @FParams.Particle.Color.List[AParticle.ColorIndex + 1];

      if Cardinal(CPrev.Value) = Cardinal(CNext.Value) then
        AParticle.Color := FParams.Particle.Color.List[AParticle.ColorIndex].Value
      else
        AParticle.Color := CPrev.Value.Lerp(CNext.Value, (AParticle.Life - CPrev.Life) / (CNext.Life - CPrev.Life));
    end
    else
      AParticle.Color := FParams.Particle.Color.List[FParams.Particle.Color.Count - 1].Value;
  end
  else
    AParticle.Color := FParams.Particle.Color.List[0].Value;
  // Opacity
  AParticle.Opacity.Update(AParticle.Life);
  AParticle.Color.A := AParticle.Opacity.Value;

  if AParticle.Angle <> 0 then
  begin
    FastSinCos(AParticle.Angle * (pi / 180), SinRad, CosRad);
    if FParams.TextureCount > 0 then
      p1 := -FParams.Textures[AParticle.TextureIndex].Size / 2 * AParticle.Scale.Value * FEffectEmitterProxy.GetScale
    else
      p1 := -TVec2f.Create(0.5, 0.5) * AParticle.Scale.Value * FEffectEmitterProxy.GetScale;

    p2 := -p1;

    AParticle.Vertexes[0].x := p1.X * CosRad - p1.Y * SinRad + AParticle.Position.X;
    AParticle.Vertexes[0].y := p1.X * SinRad + p1.Y * CosRad + AParticle.Position.Y;

    AParticle.Vertexes[1].x := p2.X * CosRad - p1.Y * SinRad + AParticle.Position.X;
    AParticle.Vertexes[1].y := p2.X * SinRad + p1.Y * CosRad + AParticle.Position.Y;

    AParticle.Vertexes[2].x := p1.X * CosRad - p2.Y * SinRad + AParticle.Position.X;
    AParticle.Vertexes[2].y := p1.X * SinRad + p2.Y * CosRad + AParticle.Position.Y;

    AParticle.Vertexes[5].x := p2.X * CosRad - p2.Y * SinRad + AParticle.Position.X;
    AParticle.Vertexes[5].y := p2.X * SinRad + p2.Y * CosRad + AParticle.Position.Y;
  end
  else
  begin
    if FParams.TextureCount > 0 then
      p2 := FParams.Textures[AParticle.TextureIndex].Size * AParticle.Scale.Value * FEffectEmitterProxy.GetScale
    else
      p2 := TVec2f.Create(1, 1) * AParticle.Scale.Value * FEffectEmitterProxy.GetScale;

    p1 := AParticle.Position - p2 / 2;

    AParticle.Vertexes[0].x := p1.X;
    AParticle.Vertexes[0].y := p1.Y;

    AParticle.Vertexes[1].x := p1.X + p2.X;
    AParticle.Vertexes[1].y := p1.Y;

    AParticle.Vertexes[2].x := p1.X;
    AParticle.Vertexes[2].y := p1.Y + p2.Y;

    AParticle.Vertexes[5].x := p1.X + p2.X;
    AParticle.Vertexes[5].y := p1.Y + p2.Y;
  end;

  AParticle.Vertexes[0].Color := AParticle.Color;
  AParticle.Vertexes[1].Color := AParticle.Color;
  AParticle.Vertexes[2].Color := AParticle.Color;
  AParticle.Vertexes[5].Color := AParticle.Color;

  if FParams.TextureCount > 0 then
  begin
    with FParams.Textures[AParticle.TextureIndex]^ do
    begin
      AParticle.Vertexes[0].u := UVA.X;
      AParticle.Vertexes[0].v := UVA.Y;
      AParticle.Vertexes[1].u := UVB.X;
      AParticle.Vertexes[1].v := UVA.Y;
      AParticle.Vertexes[2].u := UVA.X;
      AParticle.Vertexes[2].v := UVB.Y;
      AParticle.Vertexes[5].u := UVB.X;
      AParticle.Vertexes[5].v := UVB.Y;
    end;
  end
  else
  begin
    AParticle.Vertexes[0].u := 0;
    AParticle.Vertexes[0].v := 0;
    AParticle.Vertexes[1].u := 1;
    AParticle.Vertexes[1].v := 0;
    AParticle.Vertexes[2].u := 0;
    AParticle.Vertexes[2].v := 1;
    AParticle.Vertexes[5].u := 1;
    AParticle.Vertexes[5].v := 1;
  end;

  AParticle.Vertexes[3] := AParticle.Vertexes[2];
  AParticle.Vertexes[4] := AParticle.Vertexes[1];

  {
  if FIsDebug then
  begin
    FRect.LeftTop.X := Min(FRect.LeftTop.X, Position.X - FParams.Texture.GetPatternWidth / 2 * Scale);
    FRect.LeftTop.Y := Min(FRect.LeftTop.Y, Position.Y - FParams.Texture.GetPatternHeight / 2 * Scale);
    FRect.RightBottom.X := Max(FRect.RightBottom.X, Position.X + FParams.Texture.GetPatternWidth / 2 * Scale);
    FRect.RightBottom.Y := Max(FRect.RightBottom.Y, Position.Y + FParams.Texture.GetPatternHeight / 2 * Scale);
  end;
  }
end;

function TQuadFXEmitter.Add: PQuadFXParticle;
var
  RandomAngle: Single;
  Radius: Single;
  Rand: Single;
  RandAnglePosition: Single;
  SinRad, CosRad: Single;
  P: TVec2f;
begin
  Result := FParticlesLastRecord;
  Result.Vertexes := FVertexesLastRecord;
  Inc(FParticlesLastRecord);
  Inc(FVertexesLastRecord);
  Inc(FParticlesCount);

  Result.TextureIndex := Random(FParams.TextureCount);
  RandAnglePosition := 0;
  case FParams.Shape.ShapeType of
    qeftLine:
      begin
        RandAnglePosition := FValues[1] + FEffectEmitterProxy.GetAngle;
        FastSinCos(RandAnglePosition, SinRad, CosRad);
        Result.Position := TVec2f.Create(CosRad, SinRad) * FValues[0] * (Random(MaxInt) / (MaxInt / 2) - 1);
      end;
    qeftCircle:
      begin
        Radius := FValues[0] + Random(MaxInt) / MaxInt * (FValues[1] - FValues[0]);
        RandAnglePosition := Random(MaxInt) / MaxInt * 2 * Pi;
        FastSinCos(RandAnglePosition, SinRad, CosRad);
        Result.Position := TVec2f.Create(CosRad, SinRad) * Radius;
      end;
    qeftRect:
      begin
        FastSinCos(FValues[2] + FEffectEmitterProxy.GetAngle, CosRad, SinRad);

        P := Tvec2f.Create(
          (Random(MaxInt) / MaxInt) * FValues[0] - FValues[0] / 2,
          (Random(MaxInt) / MaxInt) * FValues[1] - FValues[1] / 2
        );

        Result.Position := TVec2f.Create(P.X * CosRad - P.Y * SinRad, P.X * SinRad + P.Y * CosRad);
      end;
    else
      Result.Position := TVec2f.Zero;
  end;

  Result.Position := FEffectEmitterProxy.GetPosition + (Self.Position + Result.Position) * FEffectEmitterProxy.GetScale;

  Result.Life := 0;
  Result.Time := 0;

  Result.LifeTime := FParticleLastTime.Value;

  RandomAngle := FEffectEmitterProxy.GetAngle + (Random(MaxInt) / MaxInt - 0.5) * FSpread.Value + FDirection.Value;
  if FParams.DirectionFromCenter then
    RandomAngle := RandomAngle + RandAnglePosition;

  Rand := FStartVelocity.RandomValue;
  FastSinCos(RandomAngle, SinRad, CosRad);
  Result.StartVelocity := TVec2f.Create(CosRad, SinRad) * Rand;
  Result.Velocity := TQuadFXParticleValue.Create(@FParams.Particle.Velocity);

  Result.ColorIndex := 0;
  Result.Color := FParams.Particle.Color.List[0].Value;

  // Opacity
  Result.Opacity := TQuadFXParticleValue.Create(@FParams.Particle.Opacity);
  Result.Color.A := Result.Opacity.Value;

  // Scale
  Result.Scale := TQuadFXParticleValue.Create(@FParams.Particle.Scale);
  // StartScale := FParams.StartScale.Value;

  // Spin
  Result.Spin := TQuadFXParticleValue.Create(@FParams.Particle.Spin);
  Result.Angle := RadToDeg(RandomAngle) + FStartAngle.RandomValue;
  Result.StartAngle := Result.Angle;

  Vertexes[0].z := 0;
  Vertexes[1].z := 0;
  Vertexes[2].z := 0;
  Vertexes[5].z := 0;
end;

end.
