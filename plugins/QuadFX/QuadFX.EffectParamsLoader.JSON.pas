unit QuadFX.EffectParamsLoader.JSON;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes, System.Json, Vec2f,
  QuadFX.EffectParamsLoader.CustomFormat, QuadFX.Helpers;

type
  TQuadFXJSONEffectFormat = class sealed(TQuadFXCustomEffectFormat)
  private
    FEffectParams: IQuadFXEffectParams;
  public
    class function CheckSignature(ASignature: TEffectSignature): Boolean; override;
    procedure LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams); override;
    procedure LoadEffectParams(AJsonObject: TJSONObject);

    function LoadSingleDiagram(AJSONArray: TJSONArray): TQuadFXSingleDiagram;
    function LoadParams(AJsonObject: TJSONObject): TQuadFXParams;
    function LoadColorDiagram(AJSONArray: TJSONArray): TQuadFXColorDiagram;
    function LoadEmitterShape(AJsonObject: TJSONObject): TQuadFXEmitterShape;
    function LoadEmitterParams(AJsonObject: TJSONObject): PQuadFXEmitterParams;
    function LoadTextureInfo(AJsonObject: TJSONObject): TQuadFXTextureInfo;
  end;

implementation

uses
  QuadFX.Manager, QuadFX.EffectParams;

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

function TQuadFXJSONEffectFormat.LoadTextureInfo(AJsonObject: TJSONObject): TQuadFXTextureInfo;
begin
  Result.ID := (AJsonObject.Get('ID').JsonValue as TJSONNumber).AsInt;
  Result.Position := TVec2f.Create(
    (AJsonObject.Get('Left').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('Top').JsonValue as TJSONNumber).AsInt
  );
  Result.Size := TVec2f.Create(
    (AJsonObject.Get('Width').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('Height').JsonValue as TJSONNumber).AsInt
  );
  Result.Axis := TVec2f.Create(
    (AJsonObject.Get('AxisLeft').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('AxisTop').JsonValue as TJSONNumber).AsInt
  );
end;

function TQuadFXJSONEffectFormat.LoadEmitterParams(AJsonObject: TJSONObject): PQuadFXEmitterParams;
//var
 // i: Integer;
 // JSONArray: TJSONArray;
begin
  Result := FEffectParams.CreateEmitterParams;
  Result.Name := (AJsonObject.GetValue('Name') as TJSONString).Value;
  Result.BlendMode := TQuadFXBlendMode((AJsonObject.GetValue('BlendMode') as TJSONNumber).AsInt);

  Result.BeginTime := (AJsonObject.GetValue('BeginTime') as TJSONNumber).AsDouble;
  Result.EndTime := (AJsonObject.GetValue('EndTime') as TJSONNumber).AsDouble;
  Result.IsLoop := AJsonObject.GetValue('Loop') is TJSONTrue;

  Result.Position.X := LoadParams(AJsonObject.GetValue('PositionX') as TJSONObject);
  Result.Position.Y := LoadParams(AJsonObject.GetValue('PositionY') as TJSONObject);
  Result.Direction := LoadParams(AJsonObject.GetValue('Direction') as TJSONObject);
  Result.Spread := LoadParams(AJsonObject.GetValue('Spread') as TJSONObject);

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
  JSONObject: TJSONObject;
  JSONEffects: TJSONArray;
  S: TStringList;
  Log: IQuadLog;
  IsLoaded: Boolean;
  Name: String;
begin
  FEffectParams := AEffectParams;
  IsLoaded := False;
  if Assigned(Manager.QuadDevice) then
    Manager.QuadDevice.CreateLog(Log);
  S := TStringList.Create;
  S.LoadFromStream(AStream);
  JSONObject := TJSONObject.ParseJSONValue(S.Text) as TJSONObject;
  try

    if Assigned(JSONObject.Get('Effects')) then
    begin
      JSONEffects := JSONObject.Get('Effects').JsonValue as TJSONArray;
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

      if not IsLoaded and Assigned(Log) then
        Log.Write(PWideChar('QuadFX: Effect "' + AEffectName + '" not found'));
    end;

  finally
    JSONObject.Destroy;
    S.Free;
  end;
end;

class function TQuadFXJSONEffectFormat.CheckSignature(ASignature: TEffectSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 1) = '{';
end;

end.
