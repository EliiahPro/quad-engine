unit QPTreeNode;

interface

uses
  Vcl.ComCtrls, QuadFX, IcomList, Quad.EffectTimeLine, System.SysUtils, System.Json, System.Classes,
  QuadFX.Helpers, Vec2f;

type
  TEmitterNode = class(TCustomTreeNode)
  private
    FEmitterParams: PQuadFXEmitterParams;
    FEmitter: IQuadFXEmitter;
    FVisible: Boolean;
    FTimeLine: TEffectTimeLineItem;
    procedure SetTimeLine(Value: TEffectTimeLineItem);
    procedure ChangeTimeLine(ATimeFrom, ATimeTo: Single);
  public
    constructor Create(AOwner: TTreeNodes); override;
    destructor Destroy; override;
    property Emitter: IQuadFXEmitter read FEmitter write FEmitter;
    property EmitterParams: PQuadFXEmitterParams read FEmitterParams write FEmitterParams;
    property Visible: Boolean read FVisible write FVisible;
    property TimeLine: TEffectTimeLineItem read FTimeLine write SetTimeLine;
  end;

  TEffectNode = class(TCustomTreeNode)
  private
    FEffectParams: IQuadFXEffectParams;
    FEffect: IQuadFXEffect;
  public
    constructor Create(AOwner: TTreeNodes); override;
    destructor Destroy; override;
    function CreateEmitter(AEmitter: IQuadFXEmitter = nil): TEmitterNode;
    property EffectParams: IQuadFXEffectParams read FEffectParams write FEffectParams;
    property Effect: IQuadFXEffect read FEffect write FEffect;
  end;

  TFileFormat = (
    ffNone = 0,
    ffQFX = 1,
    ffJSON = 2,
    ffXML = 3
  );

  TPackNode = class(TCustomTreeNode)
  private
    FGUID: TGUID;
    FFileName: String;
    FFileFormat: TFileFormat;
    procedure LoadFromJson;
    procedure SaveToJson;
  public
    constructor Create(AOwner: TTreeNodes); override;
    destructor Destroy; override;
    function CreateEffect(AEffectParams: IQuadFXEffectParams = nil): TEffectNode;
    procedure LoadFromFile(AFileName: String);
    procedure SaveToFile(ASaveAs: Boolean = False);
    property GUID: TGUID read FGUID;
  end;

implementation

uses
  QuadFX.EffectParams, Main, Frame.Globals, QuadFX.FileLoader.JSON, QuadFX.Effect,
  Textures, Sprite, RenderPanel;

{ TPackNode }

constructor TPackNode.Create(AOwner: TTreeNodes);
begin
  inherited Create(AOwner);
  CreateGUID(FGUID);
  FFileName := '';
  FFileFormat := ffNone;
  ImageIndex := -1;
  SelectedIndex := -1;
end;

destructor TPackNode.Destroy;
begin
  inherited;
end;

procedure TPackNode.LoadFromFile(AFileName: String);
begin
  FFileName := AFileName;
  FFileFormat := ffJSON;
  LoadFromJson;
end;

procedure TPackNode.SaveToFile(ASaveAs: Boolean = False);
begin
  if (FFileName = '') or ASaveAs then
  begin
    if fMain.SaveDialog.Execute then
    begin
      CreateGUID(FGUID);
      FFileName := fMain.SaveDialog.FileName
    end
    else
      Exit;
  end;

  case FFileFormat of
    ffJSON: SaveToJson;
  end;
end;

function TPackNode.CreateEffect(AEffectParams: IQuadFXEffectParams = nil): TEffectNode;
var
  i: Integer;
  Effect: IQuadFXEffect;
  Emitter: IQuadFXEmitter;
begin
  dmIcomList.TreeNodeCreateClass := TEffectNode;
  Result := fMain.tvEffectList.Items.AddChild(Self, 'Effect') as TEffectNode;

  if not Assigned(AEffectParams) then
    fMain.RenderPreview.Manager.CreateEffectParams(AEffectParams);
  Result.EffectParams := AEffectParams;

  fMain.RenderPreview.Layer.CreateEffectEx(Result.EffectParams, TVec2f.Zero, Effect);

  Result.Effect := Effect;

  for i := 0 to Effect.GetEmitterCount - 1 do
  begin
    Effect.GetEmitter(i, Emitter);
    Result.CreateEmitter(Emitter);
  end;
end;

procedure TPackNode.LoadFromJson;
var
  i, j: Integer;
  JSONObject, JSONTextures, JSONAtlas: TJSONObject;
  JSONArray, JSONSpriteArray: TJSONArray;
  QuadFXAtlas: IQuadFXAtlas;
  S: TStringList;
  EffectParams: IQuadFXEffectParams;
  EffectNode: TEffectNode;
  EffectFormat: TQuadFXJSONFileFormat;
  Sprite: PQuadFXSprite;
begin
  EffectFormat := TQuadFXJSONFileFormat.Create;
  S := TStringList.Create;
  S.LoadFromFile(FFileName);
  JSONObject := TJSONObject.ParseJSONValue(S.Text) as TJSONObject;
  Text := JSONObject.GetValue('PackName').Value;
  if Assigned(JSONObject.GetValue('GUID')) then
    FGUID := StringToGUID(JSONObject.GetValue('GUID').Value);

  EffectFormat.SetPackName(Text);
  fTextures.Clear;
  try
    if Assigned(JSONObject.Get('Textures')) then
    begin
      //fTextures.FromJson(JSONObject.Get('Textures').JsonValue as TJSONObject);
      JSONTextures := JSONObject.Get('Textures').JsonValue as TJSONObject;
      if Assigned(JSONTextures.Get('Atlases')) then
      begin
        JSONArray := JSONTextures.Get('Atlases').JsonValue as TJSONArray;
        EffectFormat.JSONAtlases := JSONArray;
        for i := 0 to JSONArray.Count - 1 do
        begin
          JSONAtlas := JSONArray.Items[i] as TJSONObject;
          QuadFXAtlas := EffectFormat.LoadAtlas(JSONAtlas);
          if Assigned(JSONAtlas.Get('Sprites')) then
          begin
            JSONSpriteArray := JSONAtlas.Get('Sprites').JsonValue as TJSONArray;
            for j := 0 to JSONSpriteArray.Count - 1 do
            begin
              QuadFXAtlas.CreateSprite(Sprite);
              EffectFormat.LoadSprite(Sprite, JSONSpriteArray.Items[j] as TJSONObject);
              Sprite.Recalculate(QuadFXAtlas);
            end;
          end;

          fTextures.CreateAtlas(QuadFXAtlas, JSONArray.Items[i] as TJSONObject);
        end;
      end;
    end;

    if Assigned(JSONObject.Get('Effects')) then
    begin
      JSONArray := JSONObject.Get('Effects').JsonValue as TJSONArray;
      for i := 0 to JSONArray.Count - 1 do
      begin
        fMain.RenderPreview.Manager.CreateEffectParams(EffectParams);

        EffectFormat.SetEffectParams(EffectParams);
        EffectFormat.LoadEffectParams(JSONArray.Items[i] as TJSONObject);

        EffectNode := CreateEffect(EffectParams);
        if Assigned(EffectNode)  then
          EffectNode.Text := TQuadFXEffectParams(EffectNode.EffectParams).Name;
      end;
    end;
  finally
    JSONObject.Destroy;
    S.Free;
    EffectFormat.Free;
  end;
end;

procedure TPackNode.SaveToJson;

  function EffectParamsToJson(AEffectParams: IQuadFXEffectParams): TJSONObject;
  var
    i: Integer;
    JSONEmitters: TJSONArray;
    EffectParams: TQuadFXEffectParams;
    EmitterParams: PQuadFXEmitterParams;
    FileFormat: TQuadFXJSONFileFormat;
  begin
    Result := TJSONObject.Create;
    EffectParams := TQuadFXEffectParams(AEffectParams);

    Result.AddPair('Name', TJSONString.Create(EffectParams.Name));

    JSONEmitters := TJSONArray.Create;

    FileFormat := TQuadFXJSONFileFormat.Create;
    try
      for i := 0 to EffectParams.GetEmitterParamsCount - 1 do
      begin
        EffectParams.GetEmitterParams(i, EmitterParams);
        JSONEmitters.Add(FileFormat.SaveEmitterParams(EmitterParams));
      end;
    finally
      FileFormat.Free;
    end;

    Result.AddPair('Emitters', JSONEmitters);
  end;

var
  JSONObject: TJSONObject;
  JSONEffects: TJSONArray;
  S: TStringList;
  i: Integer;
begin
  fMain.ListBox1.Items.Add(Format('SaveJson: %s;', [FFileName]));
  S := TStringList.Create;
  JSONObject := TJSONObject.Create;

  JSONObject.AddPair('Type', TJSONString.Create('QuadFX'));
  JSONObject.AddPair('PackName', TJSONString.Create(Text));
  JSONObject.AddPair('GUID', TJSONString.Create(GUIDToString(FGUID)));

  JSONObject.AddPair('Textures', fTextures.ToJson);

  JSONEffects := TJSONArray.Create;
  for i := 0 to fMain.tvEffectList.Items.Count - 1 do
    if fMain.tvEffectList.Items[i] is TEffectNode then
      JSONEffects.Add(EffectParamsToJson(TEffectNode(fMain.tvEffectList.Items[i]).EffectParams));

  JSONObject.AddPair('Effects', JSONEffects);

  S.Add(JSONObject.ToString);
  S.SaveToFile(FFileName);
  S.Free;
  JSONObject.Destroy;
end;

{ TEffectTreeNode }

constructor TEffectNode.Create(AOwner: TTreeNodes);
begin
  inherited Create(AOwner);
  ImageIndex := 0;
  SelectedIndex := 0;
  FEffectParams := nil;
  FEffect := nil;
end;

destructor TEffectNode.Destroy;
begin
  FEffectParams := nil;
  FEffect := nil;
  inherited;
end;

function TEffectNode.CreateEmitter(AEmitter: IQuadFXEmitter = nil): TEmitterNode;
var
  EmitterParams: PQuadFXEmitterParams;
begin
  dmIcomList.TreeNodeCreateClass := TEmitterNode;
  Result := (fMain.tvEffectList.Items.AddChild(Self, 'Emitter') as TEmitterNode);
  if not Assigned(AEmitter) then
  begin
    TQuadFXEffectParams(EffectParams).CreateEmitterParams(EmitterParams);
    Result.EmitterParams := EmitterParams;
    Result.Emitter := TQuadFXEffect(Effect).CreateEmitter(Result.EmitterParams);
  end
  else
  begin
    Result.Emitter := AEmitter;
    Result.Emitter.GetEmitterParams(EmitterParams);
    Result.EmitterParams := EmitterParams;
  end;

  Result.Text := Result.EmitterParams.Name;
  Result.TimeLine := fMain.EffectTimeLine.Lines.Add;
  Expanded := True;
end;

{ TEmitterTreeNode }

constructor TEmitterNode.Create(AOwner: TTreeNodes);
begin
  inherited Create(AOwner);
  ImageIndex := 1;
  SelectedIndex := 1;
  FVisible := True;
  FEmitterParams := nil;
  FEmitter := nil;
  FTimeLine := nil;
end;

destructor TEmitterNode.Destroy;
var
  ParentNode: TEffectNode;
begin
  if Assigned(Parent) and (Parent is TEffectNode) then
  begin
    ParentNode := TEffectNode(Parent);
    if Assigned(ParentNode.Effect) then
      TQuadFXEffect(ParentNode.Effect).DeleteEmitter(FEmitterParams);
    ParentNode.EffectParams.DeleteEmitterParams(FEmitterParams);
    FTimeLine.Free;
  end;

  FTimeLine := nil;
  FEmitterParams := nil;
  FEmitter := nil;
  inherited;
end;

procedure TEmitterNode.SetTimeLine(Value: TEffectTimeLineItem);
begin
  FTimeLine := Value;
  if not Assigned(FTimeLine) then
    Exit;
  FTimeLine.BeginUpdate;
  FTimeLine.OnChange := ChangeTimeLine;
  FTimeLine.Name := Text;
  FTimeLine.TimeTo := FEmitterParams.EndTime;
  FTimeLine.TimeFrom := FEmitterParams.BeginTime;
  FTimeLine.Loop := FEmitterParams.IsLoop;
  FTimeLine.EndUpdate;
end;

procedure TEmitterNode.ChangeTimeLine(ATimeFrom, ATimeTo: Single);
begin
  if FEmitterParams = nil then
    Exit;

  FEmitterParams.BeginTime := ATimeFrom;
  FEmitterParams.EndTime := ATimeTo;
  if Assigned(fMain.ParamFrame) and (fMain.ParamFrame is TFrameGlobals) and (TFrameGlobals(fMain.ParamFrame).Params = FEmitterParams) then
  begin
    TFrameGlobals(fMain.ParamFrame).seTimeFrom.Value := ATimeFrom;
    TFrameGlobals(fMain.ParamFrame).seTimeTo.Value := ATimeTo;
  end;
end;

end.
