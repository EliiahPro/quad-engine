unit QuadFX.FileLoader.XML;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Generics.Collections, sysutils, classes, XMLIntf, XMLDoc, Vec2f,
  QuadFX.FileLoader.CustomFormat, QuadFX.Helpers, EncdDecd;

type
  TQuadFXXMLFileFormat = class sealed(TQuadFXCustomFileFormat)
  private
    FDocument: IXMLDocument;
    FXMLAtlases: IXMLNode;
    FXMLEffects: IXMLNode;
    function SaveParams(AName: String; AParent: IXMLNode; AParams: PQuadFXParams): IXMLNode;
    procedure SaveSingleDiagram(AParent: IXMLNode; ASingleDiagram: PQuadFXSingleDiagram);
    procedure SaveColorDiagram(AParent: IXMLNode; AColorDiagram: PQuadFXColorDiagram);
    function SaveShape(AParent: IXMLNode; AEmitterShape: PQuadFXEmitterShape): IXMLNode;
  public
    class function CheckSignature(ASignature: TEffectSignature): Boolean; override;
    function SaveEmitterParams(AParent: IXMLNode; AEmitterParams: PQuadFXEmitterParams): IXMLNode;
    function SaveSprite(AParent: IXMLNode; ASprite: PQuadFXSprite): IXMLNode;

    procedure EffectLoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams); override;
    procedure AtlasLoadFromStream(const AAtlasName: PWideChar; AStream: TMemoryStream; AAtlas: IQuadFXAtlas); override;

    //procedure XMLInit(AStream: TMemoryStream);
    function XMLInit(AStream: TMemoryStream): IXMLNode;
    procedure LoadEffectParams(AXMLObject: IXMLNode);
    function LoadSingleDiagram(AXMLArray: IXMLNode): TQuadFXSingleDiagram;
    function LoadParams(AXMLObject: IXMLNode; ADefaulValue: Single = 0): TQuadFXParams;
    function LoadColorDiagram(AXMLArray: IXMLNode): TQuadFXColorDiagram;
    function LoadEmitterShape(AXMLObject: IXMLNode): TQuadFXEmitterShape;
    function LoadEmitterParams(AXMLObject: IXMLNode): PQuadFXEmitterParams;
    function LoadSprite(AId: Integer): PQuadFXSprite; overload;
    procedure LoadSprite(ASprite: PQuadFXSprite; AXMLObject: IXMLNode); overload;
    function LoadAtlas(AXMLObject: IXMLNode): IQuadFXAtlas;

    property XMLAtlases: IXMLNode read FXMLAtlases write FXMLAtlases;
  end;

implementation

uses
  QuadFX.Manager, QuadFX.EffectParams, QuadFX.Atlas, QuadFX.FileLoader;

function TQuadFXXMLFileFormat.LoadSingleDiagram(AXMLArray: IXMLNode): TQuadFXSingleDiagram;
var
  i: Integer;
  Item: IXMLNode;
begin
 { Result.Count := AXMLArray.Count;
  SetLength(Result.List, Result.Count);
  for i := 0 to Result.Count - 1 do
  begin
    Item := (AXMLArray.Items[i] as TXMLObject);
    Result.List[i].Life := (Item.GetValue('Life') as TXMLNumber).AsDouble;
    Result.List[i].Value := (Item.GetValue('Value') as TXMLNumber).AsDouble;
  end; }
end;

function TQuadFXXMLFileFormat.LoadParams(AXMLObject: IXMLNode; ADefaulValue: Single = 0): TQuadFXParams;
begin
  {Result := TQuadFXParams.Create(ADefaulValue);

  if not Assigned(AXMLObject) then
    Exit;

  Result.ParamsType := TQuadFXParamsType((AXMLObject.GetValue('Type') as TXMLNumber).AsInt);
  case Result.ParamsType of
    qpptValue: Result.Value[0] := (AXMLObject.GetValue('Value') as TXMLNumber).AsDouble;
    qpptRandomValue:
    begin
      Result.Value[0] := (AXMLObject.GetValue('ValueMin') as TXMLNumber).AsDouble;
      Result.Value[1] := (AXMLObject.GetValue('ValueMax') as TXMLNumber).AsDouble;
    end;
    qpptCurve: Result.Diagram[0] := LoadSingleDiagram(AXMLObject.GetValue('Curve') as TXMLArray);
    qpptRandomCurve:
    begin
      Result.Diagram[0] := LoadSingleDiagram(AXMLObject.GetValue('CurveMin') as TXMLArray);
      Result.Diagram[1] := LoadSingleDiagram(AXMLObject.GetValue('CurveMax') as TXMLArray);
    end;
  end;  }
end;

function TQuadFXXMLFileFormat.LoadColorDiagram(AXMLArray: IXMLNode): TQuadFXColorDiagram;
var
  i: Integer;
  Item: IXMLNode;
begin
{  Result.Count := AXMLArray.Count;
  SetLength(Result.List, Result.Count);
  for i := 0 to Result.Count - 1 do
  begin
    Item := AXMLArray.Items[i] as TXMLObject;
    Result.List[i].Life := (Item.GetValue('Life') as TXMLNumber).AsDouble;
    Result.List[i].Value := StrToIntDef(Item.GetValue('Color').Value, MaxInt);
  end;   }
end;

function TQuadFXXMLFileFormat.LoadEmitterShape(AXMLObject: IXMLNode): TQuadFXEmitterShape;
var
  i: Integer;
begin
 { Result.ShapeType := TQuadFXEmitterShapeType((AXMLObject.GetValue('Shape') as TXMLNumber).AsInt);
  Result.ParamType := TQuadFXParamsType((AXMLObject.GetValue('Type') as TXMLNumber).AsInt);
  case Result.ParamType of
    qpptValue:
      for i := 0 to 2 do
        Result.Value[i] := (AXMLObject.GetValue('Value'+IntToStr(i)) as TXMLNumber).AsDouble;
    qpptRandomValue:;
    qpptCurve:
      for i := 0 to 2 do
        Result.Diagram[i] := LoadSingleDiagram(AXMLObject.GetValue('Curve' + IntToStr(i)) as TXMLArray);
    qpptRandomCurve:;
  end;  }
end;

function TQuadFXXMLFileFormat.LoadAtlas(AXMLObject: IXMLNode): IQuadFXAtlas;
var
  Stream: TMemoryStream;
  Bytes: TBytes;
  Texture: IQuadTexture;
  AtlasName: WideString;
begin
{  AtlasName := (AXMLObject.GetValue('Name') as TXMLString).Value;
  Result := Manager.AtlasByName(FPackName, AtlasName);
  if Assigned(Result) then
    Exit;

  Manager.CreateAtlas(Result);
  TQuadFXAtlas(Result).PackName := FPackName;
  TQuadFXAtlas(Result).Name := AtlasName;

  if Assigned(AXMLObject.GetValue('Data')) then
  begin
    Bytes := DecodeBase64(AnsiString((AXMLObject.Get('Data').XMLValue as TXMLString).Value));
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
  end;  }
end;

procedure TQuadFXXMLFileFormat.LoadSprite(ASprite: PQuadFXSprite; AXMLObject: IXMLNode);
begin
  {ASprite.Texture := nil;
  ASprite.ID := (AXMLObject.Get('ID').XMLValue as TXMLNumber).AsInt;
  ASprite.Position := TVec2f.Create(
    (AXMLObject.Get('Left').XMLValue as TXMLNumber).AsInt,
    (AXMLObject.Get('Top').XMLValue as TXMLNumber).AsInt
  );
  ASprite.Size := TVec2f.Create(
    (AXMLObject.Get('Width').XMLValue as TXMLNumber).AsInt,
    (AXMLObject.Get('Height').XMLValue as TXMLNumber).AsInt
  );
  ASprite.Axis := TVec2f.Create(
    (AXMLObject.Get('AxisLeft').XMLValue as TXMLNumber).AsInt,
    (AXMLObject.Get('AxisTop').XMLValue as TXMLNumber).AsInt
  );   }
end;

function TQuadFXXMLFileFormat.LoadSprite(AId: Integer): PQuadFXSprite;
var
  i, j: Integer;
  AtlasObject: IXMLNode;
  Sprites: IXMLNode;
  SpriteObject: IXMLNode;
  Atlas: IQuadFXAtlas;
begin
  {if Assigned(FXMLAtlases) then
  begin
    for i := 0 to FXMLAtlases.Count - 1 do
    begin
      AtlasObject := (FXMLAtlases.Items[i] as TXMLObject);
      Sprites := AtlasObject.Get('Sprites').XMLValue as TXMLArray;
      for j := 0 to Sprites.Count - 1 do
      begin
        SpriteObject := (Sprites.Items[j] as TXMLObject);
        if (SpriteObject.Get('ID').XMLValue as TXMLNumber).AsInt = AId then
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
  end; }
end;

function TQuadFXXMLFileFormat.LoadEmitterParams(AXMLObject: IXMLNode): PQuadFXEmitterParams;
var
  i: Integer;
  XMLArray: IXMLNode;
begin
{  EffectParams.CreateEmitterParams(Result);
  Result.Name := (AXMLObject.GetValue('Name') as TXMLString).Value;
  Result.BlendMode := TQuadBlendMode((AXMLObject.GetValue('BlendMode') as TXMLNumber).AsInt);

  Result.BeginTime := (AXMLObject.GetValue('BeginTime') as TXMLNumber).AsDouble;
  Result.EndTime := (AXMLObject.GetValue('EndTime') as TXMLNumber).AsDouble;
  Result.IsLoop := AXMLObject.GetValue('Loop') is TXMLTrue;

  Result.MaxParticles := (AXMLObject.GetValue('MaxParticles') as TXMLNumber).AsInt;

  Result.Position.X := LoadParams(AXMLObject.GetValue('PositionX') as TXMLObject);
  Result.Position.Y := LoadParams(AXMLObject.GetValue('PositionY') as TXMLObject);
  Result.Direction := LoadParams(AXMLObject.GetValue('Direction') as TXMLObject);
  Result.Spread := LoadParams(AXMLObject.GetValue('Spread') as TXMLObject);

  if Assigned(AXMLObject.GetValue('Textures')) then
  begin
    XMLArray := AXMLObject.GetValue('Textures') as TXMLArray;
    Result.TextureCount := XMLArray.Count;
    SetLength(Result.Textures, Result.TextureCount);
    for i := 0 to Result.TextureCount - 1 do
      Result.Textures[i] := LoadSprite((XMLArray.Items[i] as TXMLNumber).AsInt);
  end;

  if Assigned(AXMLObject.GetValue('Shape')) then
    Result.Shape := LoadEmitterShape(AXMLObject.GetValue('Shape') as TXMLObject);

  Result.DirectionFromCenter := AXMLObject.GetValue('FromCenter') is TXMLTrue;

  Result.Particle.Color := LoadColorDiagram(AXMLObject.GetValue('Color') as TXMLArray);

  Result.Emission := LoadParams(AXMLObject.GetValue('Emission') as TXMLObject, 10);
  Result.Particle.LifeTime := LoadParams(AXMLObject.GetValue('ParticleLifeTime') as TXMLObject);
  Result.Particle.StartVelocity := LoadParams(AXMLObject.GetValue('ParticleStartVelocity') as TXMLObject, 1);
  Result.Particle.Velocity := LoadParams(AXMLObject.GetValue('ParticleVelocity') as TXMLObject, 1);
  Result.Particle.Opacity := LoadParams(AXMLObject.GetValue('ParticleOpacity') as TXMLObject, 1);
  Result.Particle.Scale := LoadParams(AXMLObject.GetValue('ParticleScale') as TXMLObject, 1);
  Result.Particle.StartAngle := LoadParams(AXMLObject.GetValue('ParticleStartAngle') as TXMLObject);
  Result.Particle.Spin := LoadParams(AXMLObject.GetValue('ParticleSpin') as TXMLObject);
  Result.Particle.Gravitation := LoadParams(AXMLObject.GetValue('ParticleGravitation') as TXMLObject, 1);
  }
end;

procedure TQuadFXXMLFileFormat.LoadEffectParams(AXMLObject: IXMLNode);
var
  i: Integer;
  XMLEmitters: IXMLNode;
begin
{  TQuadFXEffectParams(EffectParams).Clear;
  TQuadFXEffectParams(EffectParams).Name := AXMLObject.GetValue('Name').Value;
  XMLEmitters := AXMLObject.GetValue('Emitters') as TXMLArray;
  for i := 0 to XMLEmitters.Count - 1 do
    LoadEmitterParams(XMLEmitters.Items[i] as TXMLObject);  }
end;

procedure TQuadFXXMLFileFormat.AtlasLoadFromStream(const AAtlasName: PWideChar; AStream: TMemoryStream; AAtlas: IQuadFXAtlas);
var
  i, j: Integer;
  AtlasObject: IXMLNode;
  IsLoaded: Boolean;
  Name: String;
  Sprites: IXMLNode;
  SpriteObject: IXMLNode;
  XMLObject: IXMLNode;
begin
  inherited;
 { XMLObject := XMLInit(AStream);
  try
    IsLoaded := False;

    if Assigned(FXMLAtlases) then
    begin
      for i := 0 to FXMLAtlases.Count - 1 do
      begin
        Name := (FXMLAtlases.Items[i] as TXMLObject).GetValue('Name').Value;
        if Name = AAtlasName then
        begin
          AtlasObject := (FXMLAtlases.Items[i] as TXMLObject);
          Sprites := AtlasObject.Get('Sprites').XMLValue as TXMLArray;
          for j := 0 to Sprites.Count - 1 do
          begin
            SpriteObject := (Sprites.Items[j] as TXMLObject);
            LoadSprite((SpriteObject.Get('ID').XMLValue as TXMLNumber).AsInt);
          end;
        end;
      end;

      if not IsLoaded then
        Manager.AddLog(PWideChar('QuadFX: Atlas "' + AAtlasName + '" not found'));
    end;
  finally
    XMLObject.Destroy;
  end;  }
end;

procedure TQuadFXXMLFileFormat.EffectLoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
var
  i: Integer;
  IsLoaded: Boolean;
  Name: String;
  XMLObject: IXMLNode;
begin
  inherited;
 { XMLObject := XMLInit(AStream);
  try
    IsLoaded := False;

    if Assigned(FXMLEffects) then
    begin
      for i := 0 to FXMLEffects.Count - 1 do
      begin
        Name := (FXMLEffects.Items[i] as TXMLObject).GetValue('Name').Value;
        if Name = AEffectName then
        begin
          LoadEffectParams(FXMLEffects.Items[i] as TXMLObject);
          IsLoaded := True;
          Break;
        end;
      end;

      if not IsLoaded then
        Manager.AddLog(PWideChar('QuadFX: Effect "' + AEffectName + '" not found'));
    end;
  finally
    XMLObject.Destroy;
  end;   }
end;

function TQuadFXXMLFileFormat.XMLInit(AStream: TMemoryStream): IXMLNode;
var
  S: TStringList;
  XMLTextures: IXMLNode;
begin
{  S := TStringList.Create;
  try
    S.LoadFromStream(AStream);
    Result := TXMLObject.ParseXMLValue(S.Text) as TXMLObject;

    if Assigned(Result.Get('PackName')) then
      FPackName := Result.GetValue('PackName').Value;

    if Assigned(Result.Get('Textures')) then
    begin
      XMLTextures := Result.Get('Textures').XMLValue as TXMLObject;
      if Assigned(XMLTextures.Get('Atlases')) then
        FXMLAtlases := XMLTextures.Get('Atlases').XMLValue as TXMLArray;
    end;

    if Assigned(Result.Get('Effects')) then
      FXMLEffects := Result.Get('Effects').XMLValue as TXMLArray;

  finally
    S.Free;
  end;  }
end;

function TQuadFXXMLFileFormat.SaveEmitterParams(AParent: IXMLNode; AEmitterParams: PQuadFXEmitterParams): IXMLNode;
var
  i: Integer;
  Node, Node1: IXMLNode;
begin
  Result := AParent.OwnerDocument.CreateNode('EmitterParams');

  Result.Attributes['Name'] := AEmitterParams.Name;
  Result.Attributes['BlendMode'] := Integer(AEmitterParams.BlendMode);

  Result.Attributes['BeginTime'] := AEmitterParams.BeginTime;
  Result.Attributes['EndTime'] := AEmitterParams.EndTime;

  Result.Attributes['Loop'] := AEmitterParams.IsLoop;

  Result.Attributes['MaxParticles'] := AEmitterParams.MaxParticles;

  Result.Attributes['FromCenter'] := AEmitterParams.DirectionFromCenter;

  SaveParams('PositionX', Result, @AEmitterParams.Position.X);
  SaveParams('PositionY', Result, @AEmitterParams.Position.Y);
  SaveParams('Direction', Result, @AEmitterParams.Direction);
  SaveParams('Spread', Result, @AEmitterParams.Spread);


  Node := AParent.OwnerDocument.CreateNode('Textures');
  if AEmitterParams.TextureCount > 0 then
    for i := 0 to AEmitterParams.TextureCount - 1 do
    begin
      Node1 := AParent.OwnerDocument.CreateNode('Item');
      Node1.NodeValue := AEmitterParams.Textures[i].ID;
      Node.ChildNodes.Add(Node1);
    end;
  Result.ChildNodes.Add(Node);

  SaveShape(Result, @AEmitterParams.Shape);

  Node := AParent.OwnerDocument.CreateNode('Color');
  SaveColorDiagram(Node, @AEmitterParams.Particle.Color);
  Result.ChildNodes.Add(Node);

  SaveParams('Emission', Result, @AEmitterParams.Emission);
  SaveParams('ParticleLifeTime', Result, @AEmitterParams.Particle.LifeTime);
  SaveParams('ParticleStartVelocity', Result, @AEmitterParams.Particle.StartVelocity);
  SaveParams('ParticleVelocity', Result, @AEmitterParams.Particle.Velocity);
  SaveParams('ParticleOpacity', Result, @AEmitterParams.Particle.Opacity);
  SaveParams('ParticleScale', Result, @AEmitterParams.Particle.Scale);
  SaveParams('ParticleStartAngle', Result, @AEmitterParams.Particle.StartAngle);
  SaveParams('ParticleSpin', Result, @AEmitterParams.Particle.Spin);
  SaveParams('ParticleGravitation', Result, @AEmitterParams.Particle.Gravitation);

  AParent.ChildNodes.Add(Result);
end;

function TQuadFXXMLFileFormat.SaveParams(AName: String; AParent: IXMLNode; AParams: PQuadFXParams): IXMLNode;
var
  Node: IXMLNode;
begin
  Result := AParent.OwnerDocument.CreateNode(AName);

  Result.Attributes['Type'] := Integer(AParams.ParamsType);

  case AParams.ParamsType of
    qpptValue:
      Result.Attributes['Value'] := AParams.Value[0];
    qpptRandomValue:
    begin
      Result.Attributes['ValueMin'] := AParams.Value[0];
      Result.Attributes['ValueMax'] := AParams.Value[1];
    end;
    qpptCurve:
      begin
        SaveSingleDiagram(Result, @AParams.Diagram[0]);
      end;
    qpptRandomCurve:
    begin
      Node := AParent.OwnerDocument.CreateNode('CurveMin');
      SaveSingleDiagram(Node, @AParams.Diagram[0]);
      Result.ChildNodes.Add(Node);
      Node := AParent.OwnerDocument.CreateNode('CurveMax');
      SaveSingleDiagram(Node, @AParams.Diagram[1]);
      Result.ChildNodes.Add(Node);
    end;
  end;

  AParent.ChildNodes.Add(Result);
end;

procedure TQuadFXXMLFileFormat.SaveSingleDiagram(AParent: IXMLNode; ASingleDiagram: PQuadFXSingleDiagram);
var
  i: Integer;
  Node: IXMLNode;
begin
  for i := 0 to ASingleDiagram.Count - 1 do
  begin
    Node := AParent.OwnerDocument.CreateNode('Item');
    Node.Attributes['Life'] := ASingleDiagram.List[i].Life;
    Node.Attributes['Value'] := ASingleDiagram.List[i].Value;
    AParent.ChildNodes.Add(Node);
  end;
end;

function TQuadFXXMLFileFormat.SaveShape(AParent: IXMLNode; AEmitterShape: PQuadFXEmitterShape): IXMLNode;
var
  i: Integer;
  Node: IXMLNode;
begin
  Result := AParent.OwnerDocument.CreateNode('Shape');

  Result.Attributes['Shape'] := Integer(AEmitterShape.ShapeType);
  Result.Attributes['Type'] := Integer(AEmitterShape.ParamType);

  case AEmitterShape.ParamType of
    qpptValue:
      for i := 0 to 2 do
        Result.Attributes['Value' + IntToStr(i)] := AEmitterShape.Value[i];

    qpptRandomValue:;
    qpptCurve:
      for i := 0 to 2 do
      begin
        Node := AParent.OwnerDocument.CreateNode('Value' + IntToStr(i));
        SaveSingleDiagram(Node, @AEmitterShape.Diagram[i]);
        Result.ChildNodes.Add(Node);
      end;
    qpptRandomCurve:;
  end;

  AParent.ChildNodes.Add(Result);
end;

procedure TQuadFXXMLFileFormat.SaveColorDiagram(AParent: IXMLNode; AColorDiagram: PQuadFXColorDiagram);
var
  i: Integer;
  Node: IXMLNode;
begin
  for i := 0 to AColorDiagram.Count - 1 do
  begin
    Node := AParent.OwnerDocument.CreateNode('Item');
    Node.Attributes['Life'] := AColorDiagram.List[i].Life;
    Node.Attributes['Color'] := IntToHex(AColorDiagram.List[i].Value, 6);
    AParent.ChildNodes.Add(Node);
  end;
end;

function TQuadFXXMLFileFormat.SaveSprite(AParent: IXMLNode; ASprite: PQuadFXSprite): IXMLNode;
begin
  Result := AParent.OwnerDocument.CreateNode('Sprite');

  Result.Attributes['ID'] := ASprite.ID;

  Result.Attributes['Left'] := Round(ASprite.Position.X);
  Result.Attributes['Top'] := Round(ASprite.Position.Y);

  Result.Attributes['Width'] := Round(ASprite.Size.X);
  Result.Attributes['Height'] := Round(ASprite.Size.Y);

  Result.Attributes['AxisLeft'] := Round(ASprite.Axis.X);
  Result.Attributes['AxisTop'] := Round(ASprite.Axis.Y);

  AParent.ChildNodes.Add(Result);
end;

class function TQuadFXXMLFileFormat.CheckSignature(ASignature: TEffectSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 1) = '{';
end;

initialization
  TQuadFXFileLoader.Register(TQuadFXXMLFileFormat);

end.
