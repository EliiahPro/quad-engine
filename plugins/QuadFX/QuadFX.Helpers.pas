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

  TQuadFXSingleDiagramHelper = record helper for TQuadFXSingleDiagram
  public
    function ToMemory: TMemoryStream;
    procedure FromMemory(AMemory: TStream);

    function ToJson: TJSONArray;
    procedure FromJson(AJSONArray: TJSONArray);
  end;

  TQuadFXParamsHelper = record helper for TQuadFXParams
  public
    constructor Create(AValue: Single); overload;
    constructor Create(AValueMin, AValueMax: Single); overload;
    function ToMemory: TMemoryStream;
    procedure FromMemory(AMemory: TStream; ADefaultValue: Single = 0);
    function ToJson: TJSONObject;
    procedure FromJson(AJsonObject: TJSONObject; ADefaultValue: Single = 0);
  end;

  TQuadFXParticleValueHelper = record helper for TQuadFXParticleValue
  public
    constructor Create(AParams: PQuadFXParams);
    procedure Update(ALife: Double);
    function RandomValue: Single;
  end;

  TQuadFXColorDiagramHelper = record helper for TQuadFXColorDiagram
  public
    function ToMemory: TMemoryStream;
    procedure FromMemory(AMemory: TStream);
    function ToJson: TJSONArray;
    procedure FromJson(AJSONArray: TJSONArray);
  end;

  TQuadFXEmitterShapeHelper = record helper for TQuadFXEmitterShape
  public
    function ToMemory: TMemoryStream;
    procedure FromMemory(AMemory: TStream);
    function ToJson: TJSONObject;
    procedure FromJson(AJsonObject: TJSONObject);
  end;

  TQuadFXEmitterParamsHelper = record helper for TQuadFXEmitterParams
  public
    function ToMemory: TMemoryStream;
    procedure FromMemory(AMemory: TStream);
    function ToJson: TJSONObject;
    procedure FromJson(AJsonObject: TJSONObject);
  end;

  TQuadFXTextureInfoHelper = record helper for TQuadFXTextureInfo
  public
    function ToMemory: TMemoryStream;
    procedure FromMemory(AMemory: TStream);
    function ToJson: TJSONObject;
    procedure FromJson(AJsonObject: TJSONObject);
    procedure Recalculate(AAtlasSize: TVec2f);
  end;

  TMemoryStreamHelper = class helper for TMemoryStream
  public
    procedure WriteStream(AMemory: TMemoryStream);
  end;

implementation


procedure TMemoryStreamHelper.WriteStream(AMemory: TMemoryStream);
var
  Sz: Integer;
begin
  if not Assigned(AMemory) then
    Exit;

  Sz := AMemory.Size;
  Write(Sz, SizeOf(Sz));
  Write(AMemory.Memory, Sz);
  AMemory.Free;
end;

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

{ TQuadFXSingleDiagramHelper }

function TQuadFXSingleDiagramHelper.ToMemory: TMemoryStream;
var
  i: Integer;
begin
  Result := TMemoryStream.Create;
  Result.Write(Count, SizeOf(Count));
  for i := 0 to Count - 1 do
  begin
    Result.Write(List[i].Life, SizeOf(List[i].Life));
    Result.Write(List[i].Value, SizeOf(List[i].Value));
  end;
end;

procedure TQuadFXSingleDiagramHelper.FromMemory(AMemory: TStream);
var
  i: Integer;
begin
  AMemory.Read(Count, SizeOf(Count));
  SetLength(List, Count);
  for i := 0 to Count - 1 do
  begin
    AMemory.Read(List[i].Life, SizeOf(List[i].Life));
    AMemory.Read(List[i].Value, SizeOf(List[i].Value));
  end;
end;


function TQuadFXSingleDiagramHelper.ToJson: TJSONArray;
var
  i: Integer;
  Item: TJSONObject;
begin
  Result := TJSONArray.Create;
  for i := 0 to Count - 1 do
  begin
    Item := TJSONObject.Create;
    Item.AddPair('Life', TJSONNumber.Create(List[i].Life));
    Item.AddPair('Value', TJSONNumber.Create(List[i].Value));
    Result.Add(Item);
  end;
end;

procedure TQuadFXSingleDiagramHelper.FromJson(AJSONArray: TJSONArray);
var
  i: Integer;
  Item: TJSONObject;
begin
  Count := AJSONArray.Count;
  SetLength(List, Count);
  for i := 0 to Count - 1 do
  begin
    Item := (AJSONArray.Get(i) as TJSONObject);
    List[i].Life := (Item.GetValue('Life') as TJSONNumber).AsDouble;
    List[i].Value := (Item.GetValue('Value') as TJSONNumber).AsDouble;
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

function TQuadFXParamsHelper.ToMemory: TMemoryStream;
var
  B: Byte;
begin
  Result := TMemoryStream.Create;
  B := Byte(ParamsType);
  Result.Write(B, SizeOf(B));
  case ParamsType of
    qpptValue:
      Result.Write(Value[0], SizeOf(Value[0]));
    qpptRandomValue:
      begin
        Result.Write(Value[0], SizeOf(Value[0]));
        Result.Write(Value[1], SizeOf(Value[1]));
      end;
    qpptCurve:
        Result.WriteStream(Diagram[0].ToMemory);
    qpptRandomCurve:
      begin
        Result.WriteStream(Diagram[0].ToMemory);
        Result.WriteStream(Diagram[1].ToMemory);
      end;
  end;
end;

procedure TQuadFXParamsHelper.FromMemory(AMemory: TStream; ADefaultValue: Single = 0);
var
  B: Byte;
  Size: Integer;
begin
  Self := TQuadFXParams.Create(ADefaultValue);

  if not Assigned(AMemory) then
    Exit;

  AMemory.Read(B, SizeOF(B));
  ParamsType := TQuadFXParamsType(B);
  case ParamsType of
    qpptValue: AMemory.Read(Value[0], SizeOf(Value[0]));
    qpptRandomValue:
      begin
        AMemory.Read(Value[0], SizeOf(Value[0]));
        AMemory.Read(Value[1], SizeOf(Value[1]));
      end;
    qpptCurve:
      begin
        AMemory.Read(Size, SizeOf(Size));
        Diagram[0].FromMemory(AMemory);
      end;
    qpptRandomCurve:
      begin
        AMemory.Read(Size, SizeOf(Size));
        Diagram[0].FromMemory(AMemory);
        AMemory.Read(Size, SizeOf(Size));
        Diagram[1].FromMemory(AMemory);
      end;
  end;
end;

function TQuadFXParamsHelper.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('Type', TJSONNumber.Create(Integer(ParamsType)));

  case ParamsType of
    qpptValue:
      Result.AddPair('Value', TJSONNumber.Create(Value[0]));
    qpptRandomValue:
    begin
      Result.AddPair('ValueMin', TJSONNumber.Create(Value[0]));
      Result.AddPair('ValueMax', TJSONNumber.Create(Value[1]));
    end;
    qpptCurve:
      begin
        Result.AddPair('Curve', Diagram[0].ToJson);
      end;
    qpptRandomCurve:
    begin
      Result.AddPair('CurveMin', Diagram[0].ToJson);
      Result.AddPair('CurveMax', Diagram[1].ToJson);
    end;
  end;
end;

procedure TQuadFXParamsHelper.FromJson(AJsonObject: TJSONObject; ADefaultValue: Single = 0);
begin
  Self := TQuadFXParams.Create(ADefaultValue);

  if not Assigned(AJsonObject) then
    Exit;

  ParamsType := TQuadFXParamsType((AJsonObject.GetValue('Type') as TJSONNumber).AsInt);
  case ParamsType of
    qpptValue: Value[0] := (AJsonObject.GetValue('Value') as TJSONNumber).AsDouble;
    qpptRandomValue:
    begin
      Value[0] := (AJsonObject.GetValue('ValueMin') as TJSONNumber).AsDouble;
      Value[1] := (AJsonObject.GetValue('ValueMax') as TJSONNumber).AsDouble;
    end;
    qpptCurve: Diagram[0].FromJson(AJsonObject.GetValue('Curve') as TJSONArray);
    qpptRandomCurve:
    begin
      Diagram[0].FromJson(AJsonObject.GetValue('CurveMin') as TJSONArray);
      Diagram[1].FromJson(AJsonObject.GetValue('CurveMax') as TJSONArray);
    end;
  end;
end;

{ TQuadFXEmitterShapeHelper }

function TQuadFXEmitterShapeHelper.ToMemory: TMemoryStream;
var
  i: Integer;
  B: Byte;
begin
  Result := TMemoryStream.Create;
  B := Byte(ShapeType);
  Result.Write(B, SizeOf(B));
  B := Byte(ParamType);
  Result.Write(B, SizeOf(B));

  case ParamType of
    qpptValue:
      for i := 0 to 2 do
        Result.Write(Value[i], SizeOf(Value[i]));

    qpptRandomValue:;
    qpptCurve:
      for i := 0 to 2 do
        Result.WriteStream(Diagram[i].ToMemory);
    qpptRandomCurve:;
  end;
end;

procedure TQuadFXEmitterShapeHelper.FromMemory(AMemory: TStream);
var
  i, Size: Integer;
  B: Byte;
begin
  AMemory.Read(B, SizeOf(B));
  ShapeType := TQuadFXEmitterShapeType(B);
  AMemory.Read(B, SizeOf(B));
  ParamType := TQuadFXParamsType(B);

  case ParamType of
    qpptValue:
      for i := 0 to 2 do
        AMemory.Read(Value[i], SizeOf(Value[i]));
    qpptRandomValue:;
    qpptCurve:
      for i := 0 to 2 do
      begin
        AMemory.Read(Size, SizeOf(Size));
        Diagram[i].FromMemory(AMemory);
      end;
    qpptRandomCurve:;
  end;
end;

function TQuadFXEmitterShapeHelper.ToJson: TJSONObject;
var
  i: Integer;
begin
  Result := TJSONObject.Create;

  Result.AddPair('Shape', TJSONNumber.Create(Integer(ShapeType)));
  Result.AddPair('Type', TJSONNumber.Create(Integer(ParamType)));

  case ParamType of
    qpptValue:
      for i := 0 to 2 do
        Result.AddPair('Value' + IntToStr(i), TJSONNumber.Create(Value[i]));

    qpptRandomValue:;
    qpptCurve:
      for i := 0 to 2 do
        Result.AddPair('Curve' + IntToStr(i), Diagram[i].ToJson);
    qpptRandomCurve:;
  end;
end;

procedure TQuadFXEmitterShapeHelper.FromJson(AJsonObject: TJSONObject);
var
  i: Integer;
begin
  ShapeType := TQuadFXEmitterShapeType((AJsonObject.GetValue('Shape') as TJSONNumber).AsInt);
  ParamType := TQuadFXParamsType((AJsonObject.GetValue('Type') as TJSONNumber).AsInt);
  case ParamType of
    qpptValue:
      for i := 0 to 2 do
        Value[i] := (AJsonObject.GetValue('Value'+IntToStr(i)) as TJSONNumber).AsDouble;
    qpptRandomValue:;
    qpptCurve:
      for i := 0 to 2 do
        Diagram[i].FromJson(AJsonObject.GetValue('Curve' + IntToStr(i)) as TJSONArray);
    qpptRandomCurve:;
  end;
end;

{ TQuadFXColorDiagramHelper }

function TQuadFXColorDiagramHelper.ToMemory: TMemoryStream;
var
  i: Integer;
  Color: Cardinal;
begin
  Result := TMemoryStream.Create;
  Result.Write(Count, SizeOf(Count));
  for i := 0 to Count - 1 do
  begin
    Result.Write(List[i].Life, SizeOf(List[i].Life));
    Color := List[i].Value;
    Result.Write(Color, SizeOf(Color));
  end;
end;

procedure TQuadFXColorDiagramHelper.FromMemory(AMemory: TStream);
var
  i: Integer;
  Color: Cardinal;
begin
  AMemory.Read(Count, SizeOf(Count));
  SetLength(List, Count);
  for i := 0 to Count - 1 do
  begin
    AMemory.Read(List[i].Life, SizeOf(List[i].Life));
    AMemory.Read(Color, SizeOf(Color));
    List[i].Value := Color;
  end;
end;

function TQuadFXColorDiagramHelper.ToJson: TJSONArray;
var
  i: Integer;
  Item: TJSONObject;
begin
  Result := TJSONArray.Create;

  for i := 0 to Count - 1 do
  begin
    Item := TJSONObject.Create;
    Item.AddPair('Life', TJSONNumber.Create(List[i].Life));
    Item.AddPair('Color', '$' + IntToHex(List[i].Value, 6));
    Result.Add(Item);
  end;
end;

procedure TQuadFXColorDiagramHelper.FromJson(AJSONArray: TJSONArray);
var
  i: Integer;
  Item: TJSONObject;
begin
  Count := AJSONArray.Count;
  SetLength(List, Count);
  for i := 0 to Count - 1 do
  begin
    Item := AJSONArray.Get(i) as TJSONObject;
    List[i].Life := (Item.GetValue('Life') as TJSONNumber).AsDouble;
    List[i].Value := StrToIntDef(Item.GetValue('Color').Value, $FFFFFFFF);
  end;
end;

{ TQuadFXEmitterParamsHelper }

function TQuadFXEmitterParamsHelper.ToMemory: TMemoryStream;
var
  Size: Integer;
  B: Byte;
begin
  Result := TMemoryStream.Create;
  Size := Length(Name);
  Result.Write(Size, SizeOf(Size));
  Result.Write(Name[1], Size * 2);

  B := Byte(BlendMode);
  Result.Write(B, SizeOf(B));
  Result.Write(BeginTime, SizeOf(BeginTime));
  Result.Write(EndTime, SizeOf(EndTime));
  B := Byte(IsLoop);
  Result.Write(B, SizeOf(B));

  Result.WriteStream(Position.X.ToMemory);
  Result.WriteStream(Position.Y.ToMemory);
  Result.WriteStream(Direction.ToMemory);
  Result.WriteStream(Spread.ToMemory);

  { todo: Texture Load }

  Result.WriteStream(Shape.ToMemory);
  B := Byte(DirectionFromCenter);
  Result.Write(B, SizeOf(B));

  Result.WriteStream(Particle.Color.ToMemory);
  Result.WriteStream(Emission.ToMemory);
  Result.WriteStream(Particle.LifeTime.ToMemory);
  Result.WriteStream(Particle.StartVelocity.ToMemory);
  Result.WriteStream(Particle.Velocity.ToMemory);
  Result.WriteStream(Particle.Opacity.ToMemory);
  Result.WriteStream(Particle.Scale.ToMemory);
  Result.WriteStream(Particle.StartAngle.ToMemory);
  Result.WriteStream(Particle.Spin.ToMemory);
end;

procedure TQuadFXEmitterParamsHelper.FromMemory(AMemory: TStream);
begin

end;

function TQuadFXEmitterParamsHelper.ToJson: TJSONObject;
var
  i: Integer;
  JSONArray: TJSONArray;
begin
  Result := TJSONObject.Create;

  Result.AddPair('Name', TJSONString.Create(Name));
  Result.AddPair('BlendMode', TJSONNumber.Create(Integer(BlendMode)));

  Result.AddPair('BeginTime', TJSONNumber.Create(BeginTime));
  Result.AddPair('EndTime', TJSONNumber.Create(EndTime));
  if IsLoop then
    Result.AddPair('Loop', TJSONTrue.Create)
  else
    Result.AddPair('Loop', TJSONFalse.Create);

  Result.AddPair('PositionX', Position.X.ToJson);
  Result.AddPair('PositionY', Position.Y.ToJson);
  Result.AddPair('Direction', Direction.ToJson);
  Result.AddPair('Spread', Spread.ToJson);

  if TextureCount > 0 then
  begin
    JSONArray := TJSONArray.Create;
    for i := 0 to TextureCount - 1 do
      if Assigned(Textures[i].Data) then
        JSONArray.Add(Textures[i].ID);
    Result.AddPair('Textures', JSONArray);
  end;

  Result.AddPair('Shape', Shape.ToJson);
  if DirectionFromCenter then
    Result.AddPair('FromCenter', TJSONTrue.Create)
  else
    Result.AddPair('FromCenter', TJSONFalse.Create);

  Result.AddPair('Color', Particle.Color.ToJson);

  Result.AddPair('Emission', Emission.ToJson);
  Result.AddPair('ParticleLifeTime', Particle.LifeTime.ToJson);
  Result.AddPair('ParticleStartVelocity', Particle.StartVelocity.ToJson);
  Result.AddPair('ParticleVelocity', Particle.Velocity.ToJson);
  Result.AddPair('ParticleOpacity', Particle.Opacity.ToJson);
  Result.AddPair('ParticleScale', Particle.Scale.ToJson);
  Result.AddPair('ParticleStartAngle', Particle.StartAngle.ToJson);
  Result.AddPair('ParticleSpin', Particle.Spin.ToJson);
end;

procedure TQuadFXEmitterParamsHelper.FromJson(AJsonObject: TJSONObject);
var
  i: Integer;
  JSONArray: TJSONArray;
begin
  Name := (AJsonObject.GetValue('Name') as TJSONString).Value;
  BlendMode := TQuadFXBlendMode((AJsonObject.GetValue('BlendMode') as TJSONNumber).AsInt);

  BeginTime := (AJsonObject.GetValue('BeginTime') as TJSONNumber).AsDouble;
  EndTime := (AJsonObject.GetValue('EndTime') as TJSONNumber).AsDouble;
  IsLoop := AJsonObject.GetValue('Loop') is TJSONTrue;

  Position.X.FromJson(AJsonObject.GetValue('PositionX') as TJSONObject);
  Position.Y.FromJson(AJsonObject.GetValue('PositionY') as TJSONObject);
  Direction.FromJson(AJsonObject.GetValue('Direction') as TJSONObject);
  Spread.FromJson(AJsonObject.GetValue('Spread') as TJSONObject);

 { if Assigned(AJsonObject.GetValue('Textures')) then
  begin
    JSONArray := AJsonObject.GetValue('Textures') as TJSONArray;
    TextureCount := JSONArray.Count;
    SetLength(Textures, TextureCount);
    for i := 0 to TextureCount - 1 do
    begin
      Sprite := fTextures.Sprite[(JSONArray.Get(i) as TJSONNumber).AsInt];
      if Assigned(Sprite) then
      begin
        Atlas := TAtlasNode(Sprite.Parent);
        AtlasSize := TVec2f.Create(Atlas.Width, Atlas.Height);
        Textures[i].Data := Sprite;
        Textures[i].Texture := @Atlas.QuadTexture;
        Textures[i].Position := TVec2f.Create(Sprite.Position.X, Sprite.Position.Y);
        Textures[i].Size := TVec2f.Create(Sprite.Width, Sprite.Height);
        Textures[i].UVA := Textures[i].Position / AtlasSize;
        Textures[i].UVB := (Textures[i].Position + Textures[i].Size) / AtlasSize;
      end;
    end;
  end;   }

  if Assigned(AJsonObject.GetValue('Shape')) then
    Shape.FromJson(AJsonObject.GetValue('Shape') as TJSONObject);

  DirectionFromCenter := AJsonObject.GetValue('FromCenter') is TJSONTrue;

  Particle.Color.FromJson(AJsonObject.GetValue('Color') as TJSONArray);

  Emission.FromJson(AJsonObject.GetValue('Emission') as TJSONObject);
  Particle.LifeTime.FromJson(AJsonObject.GetValue('ParticleLifeTime') as TJSONObject);
  Particle.StartVelocity.FromJson(AJsonObject.GetValue('ParticleStartVelocity') as TJSONObject);
  Particle.Velocity.FromJson(AJsonObject.GetValue('ParticleVelocity') as TJSONObject);
  Particle.Opacity.FromJson(AJsonObject.GetValue('ParticleOpacity') as TJSONObject);
  Particle.Scale.FromJson(AJsonObject.GetValue('ParticleScale') as TJSONObject);
  Particle.StartAngle.FromJson(AJsonObject.GetValue('ParticleStartAngle') as TJSONObject);
  Particle.Spin.FromJson(AJsonObject.GetValue('ParticleSpin') as TJSONObject);
end;

{ TQuadFXTextureInfoHelper }

function TQuadFXTextureInfoHelper.ToMemory: TMemoryStream;
begin
  Result := TMemoryStream.Create;
  Result.Write(ID, SizeOf(ID));

  Result.Write(Position.X, SizeOf(Position.X));
  Result.Write(Position.Y, SizeOf(Position.Y));

  Result.Write(Size.X, SizeOf(Size.X));
  Result.Write(Size.Y, SizeOf(Size.Y));

  Result.Write(Axis.X, SizeOf(Axis.X));
  Result.Write(Axis.Y, SizeOf(Axis.Y));
end;

procedure TQuadFXTextureInfoHelper.FromMemory(AMemory: TStream);
begin
  AMemory.Read(ID, SizeOf(ID));

  AMemory.Read(Position.X, SizeOf(Position.X));
  AMemory.Read(Position.Y, SizeOf(Position.Y));

  AMemory.Read(Size.X, SizeOf(Size.X));
  AMemory.Read(Size.Y, SizeOf(Size.Y));

  AMemory.Read(Axis.X, SizeOf(Axis.X));
  AMemory.Read(Axis.Y, SizeOf(Axis.Y));
end;

function TQuadFXTextureInfoHelper.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(ID)));

  Result.AddPair(TJSONPair.Create('Left', TJSONNumber.Create(Position.X)));
  Result.AddPair(TJSONPair.Create('Top', TJSONNumber.Create(Position.Y)));

  Result.AddPair(TJSONPair.Create('Width', TJSONNumber.Create(Size.X)));
  Result.AddPair(TJSONPair.Create('Height', TJSONNumber.Create(Size.Y)));

  Result.AddPair(TJSONPair.Create('AxisLeft', TJSONNumber.Create(Axis.X)));
  Result.AddPair(TJSONPair.Create('AxisTop', TJSONNumber.Create(Axis.Y)));
end;

procedure TQuadFXTextureInfoHelper.FromJson(AJsonObject: TJSONObject);
begin
  ID := (AJsonObject.Get('ID').JsonValue as TJSONNumber).AsInt;

  Position := TVec2f.Create(
    (AJsonObject.Get('Left').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('Top').JsonValue as TJSONNumber).AsInt
  );
  Size := TVec2f.Create(
    (AJsonObject.Get('Width').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('Height').JsonValue as TJSONNumber).AsInt
  );
  Axis := TVec2f.Create(
    (AJsonObject.Get('AxisLeft').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('AxisTop').JsonValue as TJSONNumber).AsInt
  );
end;

procedure TQuadFXTextureInfoHelper.Recalculate(AAtlasSize: TVec2f);
begin
  UVA := Position / AAtlasSize;
  UVB := (Position + Size) / AAtlasSize;
end;

end.
