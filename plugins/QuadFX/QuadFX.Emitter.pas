unit QuadFX.Emitter;

interface

uses
  QuadFX, QuadFX.Helpers, QuadEngine, QuadEngine.Color, Vec2f;

type
  TQuadFXEmitter = class(TInterfacedObject, IQuadFXEmitter)
  private
    FEffectPosition: PVec2f;
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
    constructor Create(AParams: PQuadFXEmitterParams; APosition: PVec2f);
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
  Math, QuadEngine.Utils;

function TQuadFXEmitter.GetPosition: TVec2f;
begin
  Result := TVec2f.Create(FPosition.X.Value, FPosition.Y.Value);
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

constructor TQuadFXEmitter.Create(AParams: PQuadFXEmitterParams; APosition: PVec2f);
//var
//  i: Integer;
begin
  FEffectPosition := APosition;
  FActive := True;
  FIsDebug := False;
  FTime := 0;
  FLife := 0;
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
  {

  //FParams.Texture := AParams.Texture;
  FParams.TextureCount := AParams.TextureCount;
  FParams.Textures := AParams.Textures;

  FParams.BlendMode := AParams.BlendMode;
  FParams.LifeTime := AParams.LifeTime;
  for i := 0 to 2 do
    FValuesIndex[i] := 0;
  FParams.Shape := AParams.Shape;
  FParams.Position := AParams.Position;

  FParams.Particle := AParams.Particle;

  // Emission
  FParams.Emission := AParams.Emission;

  // Direction
  FParams.Direction := AParams.Direction;
  FParams.Spread := AParams.Spread;
          }
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
    EmissionTime := 1 / FEmission.Value;{ FParams.Emission.List[0].Value};
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
  with AParticle^ do
  begin
    Time := Time + ADelta;
    Life := Time / LifeTime;

    // Velocity
    Velocity.Update(Life);

    Position := Position + StartVelocity * Velocity.Value * ADelta;

    // Spin
    Spin.Update(Life);
    Angle := RealMod(StartAngle * Spin.Value, 360);
    // Scale
    Scale.Update(Life);
    // Color
    if Life > FParams.Particle.Color.List[0].Life then
    begin
      if (Life < FParams.Particle.Color.List[FParams.Particle.Color.Count - 1].Life) and (ColorIndex < FParams.Particle.Color.Count) then
      begin
        while Life > FParams.Particle.Color.List[ColorIndex + 1].Life do
          Inc(ColorIndex);

        CPrev := @FParams.Particle.Color.List[ColorIndex];
        CNext := @FParams.Particle.Color.List[ColorIndex + 1];

        if Cardinal(CPrev.Value) = Cardinal(CNext.Value) then
          Color := FParams.Particle.Color.List[ColorIndex].Value
        else
          Color := CPrev.Value.Lerp(CNext.Value, (Life - CPrev.Life) / (CNext.Life - CPrev.Life));
      end
      else
        Color := FParams.Particle.Color.List[FParams.Particle.Color.Count - 1].Value;
    end
    else
      Color := FParams.Particle.Color.List[0].Value;
    // Opacity
    Opacity.Update(Life);
    Color.A := Opacity.Value;

    if Angle <> 0 then
    begin
      FastSinCos(Angle * (pi / 180), CosRad, SinRad);
      p1 := -FParams.Textures[TextureIndex].Size / 2 * Scale.Value;
      p2 := -p1;

      Vertexes[0].x := p1.X * CosRad - p1.Y * SinRad + Position.X;
      Vertexes[0].y := p1.X * SinRad + p1.Y * CosRad + Position.Y;

      Vertexes[1].x := p2.X * CosRad - p1.Y * SinRad + Position.X;
      Vertexes[1].y := p2.X * SinRad + p1.Y * CosRad + Position.Y;

      Vertexes[2].x := p1.X * CosRad - p2.Y * SinRad + Position.X;
      Vertexes[2].y := p1.X * SinRad + p2.Y * CosRad + Position.Y;

      Vertexes[5].x := p2.X * CosRad - p2.Y * SinRad + Position.X;
      Vertexes[5].y := p2.X * SinRad + p2.Y * CosRad + Position.Y;
    end
    else
    begin
      p2 := FParams.Textures[TextureIndex].Size * Scale.Value;
      p1 := Position - p2 / 2;

      Vertexes[0].x := p1.X;
      Vertexes[0].y := p1.Y;

      Vertexes[1].x := p1.X + p2.X;
      Vertexes[1].y := p1.Y;

      Vertexes[2].x := p1.X;
      Vertexes[2].y := p1.Y + p2.Y;

      Vertexes[5].x := p1.X + p2.X;
      Vertexes[5].y := p1.Y + p2.Y;
    end;

    Vertexes[0].Color := Color;
    Vertexes[1].Color := Color;
    Vertexes[2].Color := Color;
    Vertexes[5].Color := Color;

    Vertexes[3] := Vertexes[2];
    Vertexes[4] := Vertexes[1];

       {
    if FIsDebug then
    begin
      FRect.LeftTop.X := Min(FRect.LeftTop.X, Position.X - FParams.Texture.GetPatternWidth / 2 * Scale);
      FRect.LeftTop.Y := Min(FRect.LeftTop.Y, Position.Y - FParams.Texture.GetPatternHeight / 2 * Scale);
      FRect.RightBottom.X := Max(FRect.RightBottom.X, Position.X + FParams.Texture.GetPatternWidth / 2 * Scale);
      FRect.RightBottom.Y := Max(FRect.RightBottom.Y, Position.Y + FParams.Texture.GetPatternHeight / 2 * Scale);
    end;    }
  end;
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

  with Result^ do
  begin
    TextureIndex := Random(FParams.TextureCount);
    RandAnglePosition := 0;
    case FParams.Shape.ShapeType of
      qeftLine:
        begin
          RandAnglePosition := RadToDeg(FValues[1]);
          FastSinCos(RandAnglePosition, CosRad, SinRad);
          Position := TVec2f.Create(CosRad, SinRad) * FValues[0] * (Random(MaxInt) / (MaxInt / 2) - 1);
        end;
      qeftCircle:
        begin
          Radius := FValues[0] + Random(MaxInt) / MaxInt * (FValues[1] - FValues[0]);
          RandAnglePosition := Random(MaxInt) / MaxInt * 2 * Pi;
          FastSinCos(RandAnglePosition, CosRad, SinRad);
          Position := TVec2f.Create(CosRad, SinRad) * Radius;
        end;
      qeftRect:
        begin
          FastSinCos(FValues[2], CosRad, SinRad);

          P := Tvec2f.Create(
            (Random(MaxInt) / MaxInt) * FValues[0] - FValues[0] / 2,
            (Random(MaxInt) / MaxInt) * FValues[1] - FValues[1] / 2
          );

          Position.X := (P.X * CosRad - P.Y * SinRad);
          Position.Y := (P.X * SinRad + P.Y * CosRad);
        end;
      else
        Position := TVec2f.Zero;
    end;

    Position := Position + Self.Position + FEffectPosition^;

    Life := 0;
    Time := 0;

    LifeTime := FParticleLastTime.Value;

    RandomAngle := (Random(MaxInt) / MaxInt - 0.5) * FSpread.Value + FDirection.Value;
    if FParams.DirectionFromCenter then
      RandomAngle := RandomAngle + RandAnglePosition;

    Rand := FStartVelocity.RandomValue;
    FastSinCos(RandomAngle, CosRad, SinRad);
    StartVelocity := TVec2f.Create(CosRad * Rand, SinRad * Rand);
    Velocity := TQuadFXParticleValue.Create(@FParams.Particle.Velocity);

    ColorIndex := 0;
    Color := FParams.Particle.Color.List[0].Value;

    // Opacity
    Opacity := TQuadFXParticleValue.Create(@FParams.Particle.Opacity);
    Color.A := Opacity.Value;

    // Scale
    Scale := TQuadFXParticleValue.Create(@FParams.Particle.Scale);
   // StartScale := FParams.StartScale.Value;

    // Spin
    Spin := TQuadFXParticleValue.Create(@FParams.Particle.Spin);
    Angle := RadToDeg(RandomAngle) + FStartAngle.RandomValue;
    StartAngle := Angle;

    Vertexes[0].z := 0;
    Vertexes[1].z := 0;
    Vertexes[2].z := 0;
    Vertexes[5].z := 0;

    with FParams.Textures[TextureIndex]^ do
    begin
      Result.Vertexes[0].u := UVA.X;
      Result.Vertexes[0].v := UVA.Y;
      Result.Vertexes[1].u := UVB.X;
      Result.Vertexes[1].v := UVA.Y;
      Result.Vertexes[2].u := UVA.X;
      Result.Vertexes[2].v := UVB.Y;
      Result.Vertexes[5].u := UVB.X;
      Result.Vertexes[5].v := UVB.Y;
    end;
  end;
end;

end.
