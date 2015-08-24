unit QuadFX.EffectParamsLoader.JSON;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes, System.Json, Vec2f,
  QuadFX.EffectParamsLoader.CustomFormat, QuadFX.Helpers, EncdDecd;

type
  TQuadFXJSONEffectFormat = class sealed(TQuadFXCustomEffectFormat)
  private
    FEffectParams: IQuadFXEffectParams;
    FJSONObject: TJSONObject;
    FJSONAtlases: TJSONArray;
  public
    class function CheckSignature(ASignature: TEffectSignature): Boolean; override;
    procedure LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams); override;
    procedure LoadEffectParams(AJsonObject: TJSONObject);

    function LoadSingleDiagram(AJSONArray: TJSONArray): TQuadFXSingleDiagram;
    function LoadParams(AJsonObject: TJSONObject): TQuadFXParams;
    function LoadColorDiagram(AJSONArray: TJSONArray): TQuadFXColorDiagram;
    function LoadEmitterShape(AJsonObject: TJSONObject): TQuadFXEmitterShape;
    function LoadEmitterParams(AJsonObject: TJSONObject): PQuadFXEmitterParams;
    function LoadTextureInfo(AId: Integer): TQuadFXTextureInfo;
    function LoadAtlas(AJsonObject: TJSONObject): IQuadFXAtlas;
  end;

implementation

uses
  QuadFX.Manager, QuadFX.EffectParams, QuadFX.Atlas, QuadFX.EffectParamsLoader;

function TQuadFXJSONEffectFormat.LoadSingleDiagram(AJSONArray: TJSONArray): TQuadFXSingleDiagram;
var
  i: Integer;
  Item: TJSONObject;
begin
  Result.Count := AJSONArray.Count;
  SetLength(Result.List, Result.Count);
  for i := 0 to Result.Count - 1 do
  begin
    Item := (AJSONArray.Get(i) as TJSONObject);
    Result.List[i].Life := (Item.GetValue('Life') as TJSONNumber).AsDouble;
    Result.List[i].Value := (Item.GetValue('Value') as TJSONNumber).AsDouble;
  end;
end;

function TQuadFXJSONEffectFormat.LoadParams(AJsonObject: TJSONObject): TQuadFXParams;
begin
  Result := TQuadFXParams.Create(0);

  if not Assigned(AJsonObject) then
    Exit;

  Result.ParamsType := TQuadFXParamsType((AJsonObject.GetValue('Type') as TJSONNumber).AsInt);
  case Result.ParamsType of
    qpptValue: Result.Value[0] := (AJsonObject.GetValue('Value') as TJSONNumber).AsDouble;
    qpptRandomValue:
    begin
      Result.Value[0] := (AJsonObject.GetValue('ValueMin') as TJSONNumber).AsDouble;
      Result.Value[1] := (AJsonObject.GetValue('ValueMax') as TJSONNumber).AsDouble;
    end;
    qpptCurve: Result.Diagram[0] := LoadSingleDiagram(AJsonObject.GetValue('Curve') as TJSONArray);
    qpptRandomCurve:
    begin
      Result.Diagram[0] := LoadSingleDiagram(AJsonObject.GetValue('CurveMin') as TJSONArray);
      Result.Diagram[1] := LoadSingleDiagram(AJsonObject.GetValue('CurveMax') as TJSONArray);
    end;
  end;
end;

function TQuadFXJSONEffectFormat.LoadColorDiagram(AJSONArray: TJSONArray): TQuadFXColorDiagram;
var
  i: Integer;
  Item: TJSONObject;
begin
  Result.Count := AJSONArray.Count;
  SetLength(Result.List, Result.Count);
  for i := 0 to Result.Count - 1 do
  begin
    Item := AJSONArray.Get(i) as TJSONObject;
    Result.List[i].Life := (Item.GetValue('Life') as TJSONNumber).AsDouble;
    Result.List[i].Value := StrToIntDef(Item.GetValue('Color').Value, $FFFFFFFF);
  end;
end;

function TQuadFXJSONEffectFormat.LoadEmitterShape(AJsonObject: TJSONObject): TQuadFXEmitterShape;
var
  i: Integer;
begin
  Result.ShapeType := TQuadFXEmitterShapeType((AJsonObject.GetValue('Shape') as TJSONNumber).AsInt);
  Result.ParamType := TQuadFXParamsType((AJsonObject.GetValue('Type') as TJSONNumber).AsInt);
  case Result.ParamType of
    qpptValue:
      for i := 0 to 2 do
        Result.Value[i] := (AJsonObject.GetValue('Value'+IntToStr(i)) as TJSONNumber).AsDouble;
    qpptRandomValue:;
    qpptCurve:
      for i := 0 to 2 do
        Result.Diagram[i] := LoadSingleDiagram(AJsonObject.GetValue('Curve' + IntToStr(i)) as TJSONArray);
    qpptRandomCurve:;
  end;
end;

function TQuadFXJSONEffectFormat.LoadAtlas(AJsonObject: TJSONObject): IQuadFXAtlas;
var
  Stream: TMemoryStream;
  Bytes: TBytes;
  Texture: IQuadTexture;
  AtlasName: WideString;
begin
  AtlasName := (AJsonObject.GetValue('Name') as TJSONString).Value;
  Result := Manager.AtlasByName(FPackName, AtlasName);
  if Assigned(Result) then
    Exit;

  Manager.CreateAtlas(Result);
  TQuadFXAtlas(Result).PackName := FPackName;
  TQuadFXAtlas(Result).Name := AtlasName;

  if Assigned(AJsonObject.GetValue('Data')) then
  begin
    Bytes := DecodeBase64(AnsiString((AJsonObject.Get('Data').JsonValue as TJSONString).Value));
    Stream := TMemoryStream.Create;
    try
      if Bytes <> nil then
        Stream.Write(Bytes[0], Length(Bytes));

      Manager.QuadDevice.CreateTexture(Texture);
      Texture.LoadFromStream(0, Stream.Memory, Stream.Size);
      TQuadFXAtlas(Result).Texture := Texture;
    finally
      FreeAndNil(Stream);
    end;
  end;
end;

function TQuadFXJSONEffectFormat.LoadTextureInfo(AId: Integer): TQuadFXTextureInfo;
var
  i, j: Integer;
  AtlasObject: TJSONObject;
  Sprites: TJSONArray;
  SpriteObject: TJSONObject;
  IsFind: Boolean;
  Atlas: IQuadFXAtlas;
begin
  if not Assigned(FJSONAtlases) then
    Exit;

  for i := 0 to FJSONAtlases.Count - 1 do
  begin
    AtlasObject := (FJSONAtlases.Get(i) as TJSONObject);
    Sprites := AtlasObject.Get('Sprites').JsonValue as TJSONArray;
    for j := 0 to Sprites.Count - 1 do
    begin
      SpriteObject := (Sprites.Get(j) as TJSONObject);
      if (SpriteObject.Get('ID').JsonValue as TJSONNumber).AsInt = AId then
      begin
        Atlas := LoadAtlas(AtlasObject);
        Result.Texture := TQuadFXAtlas(Atlas).Texture;
        Result.ID := (SpriteObject.Get('ID').JsonValue as TJSONNumber).AsInt;
        Result.Position := TVec2f.Create(
          (SpriteObject.Get('Left').JsonValue as TJSONNumber).AsInt,
          (SpriteObject.Get('Top').JsonValue as TJSONNumber).AsInt
        );
        Result.Size := TVec2f.Create(
          (SpriteObject.Get('Width').JsonValue as TJSONNumber).AsInt,
          (SpriteObject.Get('Height').JsonValue as TJSONNumber).AsInt
        );
        Result.Axis := TVec2f.Create(
          (SpriteObject.Get('AxisLeft').JsonValue as TJSONNumber).AsInt,
          (SpriteObject.Get('AxisTop').JsonValue as TJSONNumber).AsInt
        );
        Result.Recalculate(Atlas.Size);
        Exit;
      end;
    end;
  end;

end;

function TQuadFXJSONEffectFormat.LoadEmitterParams(AJsonObject: TJSONObject): PQuadFXEmitterParams;
var
  i: Integer;
  JSONArray: TJSONArray;
  Texture: PQuadFXTextureInfo;
begin
  Result := FEffectParams.CreateEmitterParams;
  Result.Name := (AJsonObject.GetValue('Name') as TJSONString).Value;
  Result.BlendMode := TQuadBlendMode((AJsonObject.GetValue('BlendMode') as TJSONNumber).AsInt);

  Result.BeginTime := (AJsonObject.GetValue('BeginTime') as TJSONNumber).AsDouble;
  Result.EndTime := (AJsonObject.GetValue('EndTime') as TJSONNumber).AsDouble;
  Result.IsLoop := AJsonObject.GetValue('Loop') is TJSONTrue;

  Result.MaxParticles := (AJsonObject.GetValue('MaxParticles') as TJSONNumber).AsInt;

  Result.Position.X := LoadParams(AJsonObject.GetValue('PositionX') as TJSONObject);
  Result.Position.Y := LoadParams(AJsonObject.GetValue('PositionY') as TJSONObject);
  Result.Direction := LoadParams(AJsonObject.GetValue('Direction') as TJSONObject);
  Result.Spread := LoadParams(AJsonObject.GetValue('Spread') as TJSONObject);

  if Assigned(AJsonObject.GetValue('Textures')) then
  begin
    JSONArray := AJsonObject.GetValue('Textures') as TJSONArray;
    Result.TextureCount := JSONArray.Count;
    SetLength(Result.Textures, Result.TextureCount);
    for i := 0 to Result.TextureCount - 1 do
      Result.Textures[i] := LoadTextureInfo((JSONArray.Get(i) as TJSONNumber).AsInt);
  end;

  if Assigned(AJsonObject.GetValue('Shape')) then
    Result.Shape := LoadEmitterShape(AJsonObject.GetValue('Shape') as TJSONObject);

  Result.DirectionFromCenter := AJsonObject.GetValue('FromCenter') is TJSONTrue;

  Result.Particle.Color := LoadColorDiagram(AJsonObject.GetValue('Color') as TJSONArray);

  Result.Emission := LoadParams(AJsonObject.GetValue('Emission') as TJSONObject);
  Result.Particle.LifeTime := LoadParams(AJsonObject.GetValue('ParticleLifeTime') as TJSONObject);
  Result.Particle.StartVelocity := LoadParams(AJsonObject.GetValue('ParticleStartVelocity') as TJSONObject);
  Result.Particle.Velocity := LoadParams(AJsonObject.GetValue('ParticleVelocity') as TJSONObject);
  Result.Particle.Opacity := LoadParams(AJsonObject.GetValue('ParticleOpacity') as TJSONObject);
  Result.Particle.Scale := LoadParams(AJsonObject.GetValue('ParticleScale') as TJSONObject);
  Result.Particle.StartAngle := LoadParams(AJsonObject.GetValue('ParticleStartAngle') as TJSONObject);
  Result.Particle.Spin := LoadParams(AJsonObject.GetValue('ParticleSpin') as TJSONObject);
end;

procedure TQuadFXJSONEffectFormat.LoadEffectParams(AJsonObject: TJSONObject);
var
  i: Integer;
  JSONEmitters: TJSONArray;
begin
  TQuadFXEffectParams(FEffectParams).Clear;
  TQuadFXEffectParams(FEffectParams).Name := AJsonObject.GetValue('Name').Value;
  JSONEmitters := AJsonObject.GetValue('Emitters') as TJSONArray;
  for i := 0 to JSONEmitters.Count - 1 do
    LoadEmitterParams(JSONEmitters.Get(i) as TJSONObject);
end;

procedure TQuadFXJSONEffectFormat.LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
var
  i: Integer;
  JSONEffects: TJSONArray;
  JSONTextures: TJSONObject;
  S: TStringList;
  IsLoaded: Boolean;
  Name: String;
begin
  FJSONAtlases := nil;
  FEffectParams := AEffectParams;
  IsLoaded := False;
  S := TStringList.Create;
  S.LoadFromStream(AStream);
  FJSONObject := TJSONObject.ParseJSONValue(S.Text) as TJSONObject;
  try
    if Assigned(FJSONObject.Get('PackName')) then
      FPackName := FJSONObject.GetValue('PackName').Value;
    FEffectName := AEffectName;

    if Assigned(FJSONObject.Get('Textures')) then
    begin
      JSONTextures := FJSONObject.Get('Textures').JsonValue as TJSONObject;
      if Assigned(JSONTextures.Get('Atlases')) then
        FJSONAtlases := JSONTextures.Get('Atlases').JsonValue as TJSONArray;
    end;

    if Assigned(FJSONObject.Get('Effects')) then
    begin
      JSONEffects := FJSONObject.Get('Effects').JsonValue as TJSONArray;
      for i := 0 to JSONEffects.Count - 1 do
      begin
        Name := (JSONEffects.Items[i] as TJSONObject).GetValue('Name').Value;
        if Name = AEffectName then
        begin
          LoadEffectParams(JSONEffects.Items[i] as TJSONObject);
          IsLoaded := True;
          Break;
        end;
      end;

      if not IsLoaded then
        Manager.AddLog(PWideChar('QuadFX: Effect "' + AEffectName + '" not found'));
    end;

  finally
    FJSONObject.Destroy;
    S.Free;
  end;
end;

class function TQuadFXJSONEffectFormat.CheckSignature(ASignature: TEffectSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 1) = '{';
end;

initialization
  TQuadFXEffectLoader.Register(TQuadFXJSONEffectFormat);

end.
