unit QuadFX.Helpers;

interface

uses
  QuadFX, QuadEngine.Color, System.Json, System.SysUtils, Vec2f, System.Classes;

type
  TQuadFXSingleDiagramValueHelper = record helper for TQuadFXSingleDiagramValue
  public
    constructor Create(ALife: Double; AValue: Single);
  end;

  TQuadFXColorDiagramValueHelper = record helper for TQuadFXSingleDiagramValue
  public
    constructor Create(ALife: Double; AColor: TQuadColor);
  end;

  TQuadFXSingleStartValueHelper = record helper for TQuadFXSingleStartValue
  public
    function Value: Single;
  end;

  TQuadFXParamsHelper = record helper for TQuadFXParams
  public
    constructor Create(AValue: Single); overload;
    constructor Create(AValueMin, AValueMax: Single); overload;
  end;

  TQuadFXParticleValueHelper = record helper for TQuadFXParticleValue
  public
    constructor Create(AParams: PQuadFXParams);
    procedure Update(ALife: Double);
    function RandomValue: Single;
  end;

  TQuadFXSpriteHelper = record helper for TQuadFXSprite
  public
    procedure Recalculate(AAtlas: IQuadFXAtlas);
  end;

implementation

uses
  QuadFX.Atlas;

{ TQuadFXSingleDiagramValue }

constructor TQuadFXSingleDiagramValueHelper.Create(ALife: Double; AValue: Single);
begin
  Self.Life := ALife;
  Self.Value := AValue;
end;

{ TQuadFXColorDiagramValue }

constructor TQuadFXColorDiagramValueHelper.Create(ALife: Double; AColor: TQuadColor);
begin
  Self.Life := ALife;
  Self.Value := AColor;
end;

{ TQuadFXSingleStartValueHelper }

function TQuadFXSingleStartValueHelper.Value: Single;
begin
  if Max = Min then
    Result := Min
  else
    Result := Min + (Random(MaxInt) / MaxInt * (Max - Min));
end;

{ TQuadFXParticleValueHelper }

constructor TQuadFXParticleValueHelper.Create(AParams: PQuadFXParams);
begin
  Index[0] := 0;
  Index[1] := 0;
  Rand := Random(MaxInt) / MaxInt;
  Params := AParams;
  if Params <> nil then
  begin
    case Params.ParamsType of
      qpptRandomValue, qpptRandomCurve: Self.Value := Params.Value[0] + Rand * (Params.Value[1] - Params.Value[0]);
      qpptCurve: Self.Value := Params.Diagram[0].List[0].Value;
      else
        Self.Value := Params.Value[0];
    end;
  end
  else
    Self.Value := 0;
end;

procedure TQuadFXParticleValueHelper.Update(ALife: Double);
var
  SPrev, SNext: PQuadFXSingleDiagramValue;
  MinValue, MaxValue: Single;
begin
  if (Params = nil) or (Params.ParamsType in [qpptValue, qpptRandomValue]) or (Params.Diagram[0].Count = 0) then
    Exit;

  if ALife > Params.Diagram[0].List[0].Life then
  begin
    if (ALife < Params.Diagram[0].List[Params.Diagram[0].Count - 1].Life) and (Index[0] < Params.Diagram[0].Count) then
    begin
      while ALife > Params.Diagram[0].List[Index[0] + 1].Life do
        Inc(Index[0]);

      SPrev := @Params.Diagram[0].List[Index[0]];
      SNext := @Params.Diagram[0].List[Index[0] + 1];

      if SPrev.Value <> SNext.Value then
        MinValue := (SNext.Value - SPrev.Value) * (ALife - SPrev.Life) / (SNext.Life - SPrev.Life) + SPrev.Value
      else
        MinValue := SPrev.Value;
    end
    else
      MinValue := Params.Diagram[0].List[Params.Diagram[0].Count - 1].Value;
  end
  else
    MinValue := Params.Diagram[0].List[0].Value;

  if (Params.ParamsType = qpptRandomCurve) and (Params.Diagram[1].Count = 0) then
  begin
    if ALife > Params.Diagram[1].List[0].Life then
    begin
      if (ALife < Params.Diagram[1].List[Params.Diagram[1].Count - 1].Life) and (Index[1] < Params.Diagram[1].Count) then
      begin
        while ALife > Params.Diagram[1].List[Index[1] + 1].Life do
          Inc(Index[1]);

        SPrev := @Params.Diagram[1].List[Index[1]];
        SNext := @Params.Diagram[1].List[Index[1] + 1];
        if SPrev.Value <> SNext.Value then
          MaxValue := (SNext.Value - SPrev.Value) * (ALife - SPrev.Life) / (SNext.Life - SPrev.Life) + SPrev.Value
        else
          MaxValue := SPrev.Value;
      end
      else
        MaxValue := Params.Diagram[1].List[Params.Diagram[1].Count - 1].Value;
    end
    else
      MaxValue := Params.Diagram[1].List[0].Value;

    Self.Value := MinValue + Rand * (MaxValue - MinValue);
  end
  else
    Self.Value := MinValue;
end;

function TQuadFXParticleValueHelper.RandomValue: Single;
begin
  case Params.ParamsType of
    qpptRandomValue: Result := Params.Value[0] + (Random(MaxInt) / MaxInt) * (Params.Value[1] - Params.Value[0]);
    else Result := Self.Value;
  end;
end;

{ TQuadFXParamsHelper }

constructor TQuadFXParamsHelper.Create(AValue: Single);
var
  i: Integer;
begin
  ParamsType := qpptValue;
  for i := 0 to 1 do
  begin
    Value[i] := 0;
    Diagram[i].Count := 0;
    SetLength(Diagram[i].List, Diagram[i].Count);
  end;
  Value[0] := AValue;
end;

constructor TQuadFXParamsHelper.Create(AValueMin, AValueMax: Single);
var
  i: Integer;
begin
  ParamsType := qpptRandomValue;
  for i := 0 to 1 do
  begin
    Diagram[i].Count := 0;
    SetLength(Diagram[i].List, Diagram[i].Count);
  end;
  Value[0] := AValueMin;
  Value[1] := AValueMax;
end;

{ TQuadFXSpriteHelper }

procedure TQuadFXSpriteHelper.Recalculate(AAtlas: IQuadFXAtlas);
begin
  if Assigned(AAtlas) then
  begin
    Texture := TQuadFXAtlas(AAtlas).Texture;
    UVA := Position / AAtlas.GetSize;
    UVB := (Position + Size) / AAtlas.GetSize;
  end
  else
  begin
    Texture := nil;
    UVA := TVec2f.Zero;
    UVB := TVec2f.Create(1, 1);
  end;
end;

end.
