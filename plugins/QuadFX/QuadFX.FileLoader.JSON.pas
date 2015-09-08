unit QuadFX.FileLoader.JSON;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Generics.Collections, sysutils, classes, System.Json, Vec2f,
  QuadFX.FileLoader.CustomFormat, QuadFX.Helpers, EncdDecd;

type
  TQuadFXJSONFileFormat = class sealed(TQuadFXCustomFileFormat)
  private
    FJSONAtlases: TJSONArray;
    FJSONEffects: TJSONArray;
    class function SaveParams(AParams: PQuadFXParams): TJSONObject;
    class function SaveSingleDiagram(ASingleDiagram: PQuadFXSingleDiagram): TJSONArray;
    class function SaveColorDiagram(AColorDiagram: PQuadFXColorDiagram): TJSONArray;
    class function SaveShape(AEmitterShape: PQuadFXEmitterShape): TJSONObject;
  public
    class function CheckSignature(ASignature: TEffectSignature): Boolean; override;
    class function SaveEmitterParams(AEmitterParams: PQuadFXEmitterParams): TJSONObject;
    class function SaveSprite(ASprite: PQuadFXSprite): TJSONObject;

    procedure EffectLoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams); override;
    procedure AtlasLoadFromStream(const AAtlasName: PWideChar; AStream: TMemoryStream; AAtlas: IQuadFXAtlas); override;

    //procedure JSONInit(AStream: TMemoryStream);
    function JSONInit(AStream: TMemoryStream): TJSONObject;
    procedure LoadEffectParams(AJsonObject: TJSONObject);
    function LoadSingleDiagram(AJSONArray: TJSONArray): TQuadFXSingleDiagram;
    function LoadParams(AJsonObject: TJSONObject): TQuadFXParams;
    function LoadColorDiagram(AJSONArray: TJSONArray): TQuadFXColorDiagram;
    function LoadEmitterShape(AJsonObject: TJSONObject): TQuadFXEmitterShape;
    function LoadEmitterParams(AJsonObject: TJSONObject): PQuadFXEmitterParams;
    function LoadSprite(AId: Integer): PQuadFXSprite; overload;
    procedure LoadSprite(ASprite: PQuadFXSprite; AJsonObject: TJSONObject); overload;
    function LoadAtlas(AJsonObject: TJSONObject): IQuadFXAtlas;

    property JSONAtlases: TJSONArray read FJSONAtlases write FJSONAtlases;
  end;

implementation

uses
  QuadFX.Manager, QuadFX.EffectParams, QuadFX.Atlas, QuadFX.FileLoader;

function TQuadFXJSONFileFormat.LoadSingleDiagram(AJSONArray: TJSONArray): TQuadFXSingleDiagram;
var
  i: Integer;
  Item: TJSONObject;
begin
  Result.Count := AJSONArray.Count;
  SetLength(Result.List, Result.Count);
  for i := 0 to Result.Count - 1 do
  begin
    Item := (AJSONArray.Items[i] as TJSONObject);
    Result.List[i].Life := (Item.GetValue('Life') as TJSONNumber).AsDouble;
    Result.List[i].Value := (Item.GetValue('Value') as TJSONNumber).AsDouble;
  end;
end;

function TQuadFXJSONFileFormat.LoadParams(AJsonObject: TJSONObject): TQuadFXParams;
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

function TQuadFXJSONFileFormat.LoadColorDiagram(AJSONArray: TJSONArray): TQuadFXColorDiagram;
var
  i: Integer;
  Item: TJSONObject;
begin
  Result.Count := AJSONArray.Count;
  SetLength(Result.List, Result.Count);
  for i := 0 to Result.Count - 1 do
  begin
    Item := AJSONArray.Items[i] as TJSONObject;
    Result.List[i].Life := (Item.GetValue('Life') as TJSONNumber).AsDouble;
    Result.List[i].Value := StrToIntDef(Item.GetValue('Color').Value, MaxInt);
  end;
end;

function TQuadFXJSONFileFormat.LoadEmitterShape(AJsonObject: TJSONObject): TQuadFXEmitterShape;
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

function TQuadFXJSONFileFormat.LoadAtlas(AJsonObject: TJSONObject): IQuadFXAtlas;
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
      Result.SetTexture(Texture);
    finally
      FreeAndNil(Stream);
    end;
  end;
end;

procedure TQuadFXJSONFileFormat.LoadSprite(ASprite: PQuadFXSprite; AJsonObject: TJSONObject);
begin
  ASprite.Texture := nil;
  ASprite.ID := (AJsonObject.Get('ID').JsonValue as TJSONNumber).AsInt;
  ASprite.Position := TVec2f.Create(
    (AJsonObject.Get('Left').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('Top').JsonValue as TJSONNumber).AsInt
  );
  ASprite.Size := TVec2f.Create(
    (AJsonObject.Get('Width').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('Height').JsonValue as TJSONNumber).AsInt
  );
  ASprite.Axis := TVec2f.Create(
    (AJsonObject.Get('AxisLeft').JsonValue as TJSONNumber).AsInt,
    (AJsonObject.Get('AxisTop').JsonValue as TJSONNumber).AsInt
  );
end;

function TQuadFXJSONFileFormat.LoadSprite(AId: Integer): PQuadFXSprite;
var
  i, j: Integer;
  AtlasObject: TJSONObject;
  Sprites: TJSONArray;
  SpriteObject: TJSONObject;
  Atlas: IQuadFXAtlas;
begin
  if Assigned(FJSONAtlases) then
  begin
    for i := 0 to FJSONAtlases.Count - 1 do
    begin
      AtlasObject := (FJSONAtlases.Items[i] as TJSONObject);
      Sprites := AtlasObject.Get('Sprites').JsonValue as TJSONArray;
      for j := 0 to Sprites.Count - 1 do
      begin
        SpriteObject := (Sprites.Items[j] as TJSONObject);
        if (SpriteObject.Get('ID').JsonValue as TJSONNumber).AsInt = AId then
        begin
          Atlas := LoadAtlas(AtlasObject);
          Atlas.SpriteByID(AId, Result);
          if not Assigned(Result) then
          begin
            Atlas.CreateSprite(Result);
            LoadSprite(Result, SpriteObject);
            Result.Recalculate(Atlas);
          end;
          Exit;
        end;
      end;
    end;
  end;
end;

function TQuadFXJSONFileFormat.LoadEmitterParams(AJsonObject: TJSONObject): PQuadFXEmitterParams;
var
  i: Integer;
  JSONArray: TJSONArray;
begin
  Result := EffectParams.CreateEmitterParams;
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
      Result.Textures[i] := LoadSprite((JSONArray.Items[i] as TJSONNumber).AsInt);
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

procedure TQuadFXJSONFileFormat.LoadEffectParams(AJsonObject: TJSONObject);
var
  i: Integer;
  JSONEmitters: TJSONArray;
begin
  TQuadFXEffectParams(EffectParams).Clear;
  TQuadFXEffectParams(EffectParams).Name := AJsonObject.GetValue('Name').Value;
  JSONEmitters := AJsonObject.GetValue('Emitters') as TJSONArray;
  for i := 0 to JSONEmitters.Count - 1 do
    LoadEmitterParams(JSONEmitters.Items[i] as TJSONObject);
end;

procedure TQuadFXJSONFileFormat.AtlasLoadFromStream(const AAtlasName: PWideChar; AStream: TMemoryStream; AAtlas: IQuadFXAtlas);
var
  i, j: Integer;
  AtlasObject: TJSONObject;
  IsLoaded: Boolean;
  Name: String;
  Sprites: TJSONArray;
  SpriteObject: TJSONObject;
  JSONObject: TJSONObject;
begin
  inherited;
  JSONObject := JSONInit(AStream);
  try
    IsLoaded := False;

    if Assigned(FJSONAtlases) then
    begin
      for i := 0 to FJSONAtlases.Count - 1 do
      begin
        Name := (FJSONAtlases.Items[i] as TJSONObject).GetValue('Name').Value;
        if Name = AAtlasName then
        begin
          AtlasObject := (FJSONAtlases.Items[i] as TJSONObject);
          Sprites := AtlasObject.Get('Sprites').JsonValue as TJSONArray;
          for j := 0 to Sprites.Count - 1 do
          begin
            SpriteObject := (Sprites.Items[j] as TJSONObject);
            Manager.AddLog(PWideChar('QuadFX: Load sprite "' + AAtlasName + '"'));
            LoadSprite((SpriteObject.Get('ID').JsonValue as TJSONNumber).AsInt);
          end;
        end;
      end;

      if not IsLoaded then
        Manager.AddLog(PWideChar('QuadFX: Atlas "' + AAtlasName + '" not found'));
    end;
  finally
    JSONObject.Destroy;
  end;
end;

procedure TQuadFXJSONFileFormat.EffectLoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
var
  i: Integer;
  IsLoaded: Boolean;
  Name: String;
  JSONObject: TJSONObject;
begin
  inherited;
  JSONObject := JSONInit(AStream);
  try
    IsLoaded := False;

    if Assigned(FJSONEffects) then
    begin
      for i := 0 to FJSONEffects.Count - 1 do
      begin
        Name := (FJSONEffects.Items[i] as TJSONObject).GetValue('Name').Value;
        if Name = AEffectName then
        begin
          LoadEffectParams(FJSONEffects.Items[i] as TJSONObject);
          IsLoaded := True;
          Break;
        end;
      end;

      if not IsLoaded then
        Manager.AddLog(PWideChar('QuadFX: Effect "' + AEffectName + '" not found'));
    end;
  finally
    JSONObject.Destroy;
  end;
end;

function TQuadFXJSONFileFormat.JSONInit(AStream: TMemoryStream): TJSONObject;
var
  S: TStringList;
  JSONTextures: TJSONObject;
begin
  S := TStringList.Create;
  try
    S.LoadFromStream(AStream);
    Result := TJSONObject.ParseJSONValue(S.Text) as TJSONObject;

    if Assigned(Result.Get('PackName')) then
      FPackName := Result.GetValue('PackName').Value;

    if Assigned(Result.Get('Textures')) then
    begin
      JSONTextures := Result.Get('Textures').JsonValue as TJSONObject;
      if Assigned(JSONTextures.Get('Atlases')) then
        FJSONAtlases := JSONTextures.Get('Atlases').JsonValue as TJSONArray;
    end;

    if Assigned(Result.Get('Effects')) then
      FJSONEffects := Result.Get('Effects').JsonValue as TJSONArray;

  finally
    S.Free;
  end;
end;

class function TQuadFXJSONFileFormat.SaveEmitterParams(AEmitterParams: PQuadFXEmitterParams): TJSONObject;
var
  i: Integer;
  JSONArray: TJSONArray;
begin
  Result := TJSONObject.Create;

  Result.AddPair('Name', TJSONString.Create(AEmitterParams.Name));
  Result.AddPair('BlendMode', TJSONNumber.Create(Integer(AEmitterParams.BlendMode)));

  Result.AddPair('BeginTime', TJSONNumber.Create(AEmitterParams.BeginTime));
  Result.AddPair('EndTime', TJSONNumber.Create(AEmitterParams.EndTime));
  if AEmitterParams.IsLoop then
    Result.AddPair('Loop', TJSONTrue.Create)
  else
    Result.AddPair('Loop', TJSONFalse.Create);

  Result.AddPair('PositionX', SaveParams(@AEmitterParams.Position.X));
  Result.AddPair('PositionY', SaveParams(@AEmitterParams.Position.Y));
  Result.AddPair('Direction', SaveParams(@AEmitterParams.Direction));
  Result.AddPair('Spread', SaveParams(@AEmitterParams.Spread));

  if AEmitterParams.TextureCount > 0 then
  begin
    JSONArray := TJSONArray.Create;
    for i := 0 to AEmitterParams.TextureCount - 1 do
        JSONArray.Add(AEmitterParams.Textures[i].ID);
    Result.AddPair('Textures', JSONArray);
  end;

  Result.AddPair('Shape', SaveShape(@AEmitterParams.Shape));
  if AEmitterParams.DirectionFromCenter then
    Result.AddPair('FromCenter', TJSONTrue.Create)
  else
    Result.AddPair('FromCenter', TJSONFalse.Create);

  Result.AddPair('Color', SaveColorDiagram(@AEmitterParams.Particle.Color));

  Result.AddPair('Emission', SaveParams(@AEmitterParams.Emission));
  Result.AddPair('ParticleLifeTime', SaveParams(@AEmitterParams.Particle.LifeTime));
  Result.AddPair('ParticleStartVelocity', SaveParams(@AEmitterParams.Particle.StartVelocity));
  Result.AddPair('ParticleVelocity', SaveParams(@AEmitterParams.Particle.Velocity));
  Result.AddPair('ParticleOpacity', SaveParams(@AEmitterParams.Particle.Opacity));
  Result.AddPair('ParticleScale', SaveParams(@AEmitterParams.Particle.Scale));
  Result.AddPair('ParticleStartAngle', SaveParams(@AEmitterParams.Particle.StartAngle));
  Result.AddPair('ParticleSpin', SaveParams(@AEmitterParams.Particle.Spin));
end;

class function TQuadFXJSONFileFormat.SaveParams(AParams: PQuadFXParams): TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('Type', TJSONNumber.Create(Integer(AParams.ParamsType)));

  case AParams.ParamsType of
    qpptValue:
      Result.AddPair('Value', TJSONNumber.Create(AParams.Value[0]));
    qpptRandomValue:
    begin
      Result.AddPair('ValueMin', TJSONNumber.Create(AParams.Value[0]));
      Result.AddPair('ValueMax', TJSONNumber.Create(AParams.Value[1]));
    end;
    qpptCurve:
      begin
        Result.AddPair('Curve', SaveSingleDiagram(@AParams.Diagram[0]));
      end;
    qpptRandomCurve:
    begin
      Result.AddPair('CurveMin', SaveSingleDiagram(@AParams.Diagram[0]));
      Result.AddPair('CurveMax', SaveSingleDiagram(@AParams.Diagram[1]));
    end;
  end;
end;

class function TQuadFXJSONFileFormat.SaveSingleDiagram(ASingleDiagram: PQuadFXSingleDiagram): TJSONArray;
var
  i: Integer;
  Item: TJSONObject;
begin
  Result := TJSONArray.Create;
  for i := 0 to ASingleDiagram.Count - 1 do
  begin
    Item := TJSONObject.Create;
    Item.AddPair('Life', TJSONNumber.Create(ASingleDiagram.List[i].Life));
    Item.AddPair('Value', TJSONNumber.Create(ASingleDiagram.List[i].Value));
    Result.Add(Item);
  end;
end;

class function TQuadFXJSONFileFormat.SaveShape(AEmitterShape: PQuadFXEmitterShape): TJSONObject;
var
  i: Integer;
begin
  Result := TJSONObject.Create;

  Result.AddPair('Shape', TJSONNumber.Create(Integer(AEmitterShape.ShapeType)));
  Result.AddPair('Type', TJSONNumber.Create(Integer(AEmitterShape.ParamType)));

  case AEmitterShape.ParamType of
    qpptValue:
      for i := 0 to 2 do
        Result.AddPair('Value' + IntToStr(i), TJSONNumber.Create(AEmitterShape.Value[i]));

    qpptRandomValue:;
    qpptCurve:
      for i := 0 to 2 do
        Result.AddPair('Curve' + IntToStr(i), SaveSingleDiagram(@AEmitterShape.Diagram[i]));
    qpptRandomCurve:;
  end;
end;

class function TQuadFXJSONFileFormat.SaveColorDiagram(AColorDiagram: PQuadFXColorDiagram): TJSONArray;
var
  i: Integer;
  Item: TJSONObject;
begin
  Result := TJSONArray.Create;

  for i := 0 to AColorDiagram.Count - 1 do
  begin
    Item := TJSONObject.Create;
    Item.AddPair('Life', TJSONNumber.Create(AColorDiagram.List[i].Life));
    Item.AddPair('Color', '$' + IntToHex(AColorDiagram.List[i].Value, 6));
    Result.Add(Item);
  end;
end;

class function TQuadFXJSONFileFormat.SaveSprite(ASprite: PQuadFXSprite): TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(ASprite.ID)));

  Result.AddPair(TJSONPair.Create('Left', TJSONNumber.Create(ASprite.Position.X)));
  Result.AddPair(TJSONPair.Create('Top', TJSONNumber.Create(ASprite.Position.Y)));

  Result.AddPair(TJSONPair.Create('Width', TJSONNumber.Create(ASprite.Size.X)));
  Result.AddPair(TJSONPair.Create('Height', TJSONNumber.Create(ASprite.Size.Y)));

  Result.AddPair(TJSONPair.Create('AxisLeft', TJSONNumber.Create(ASprite.Axis.X)));
  Result.AddPair(TJSONPair.Create('AxisTop', TJSONNumber.Create(ASprite.Axis.Y)));
end;

class function TQuadFXJSONFileFormat.CheckSignature(ASignature: TEffectSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 1) = '{';
end;

initialization
  TQuadFXFileLoader.Register(TQuadFXJSONFileFormat);

end.
