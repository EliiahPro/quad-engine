unit Frame.Texture;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Vcl.StdCtrls, Vcl.ActnList,
  QuadFX, Vcl.ComCtrls, Vec2f, Vcl.ExtCtrls, Textures,
  Vcl.ToolWin, GDIPAPI, GDIPOBJ, GDIPUTIL, Sprite, Atlas, QuadFX.Atlas,
  Vcl.Menus;

type
  TFrameTexture = class(TCustomParamFrame)
    lvList: TListView;
    pCaption: TPanel;
    lCaption: TLabel;
    cbAtlases: TComboBox;
    bTextures: TButton;
    procedure lvListDeletion(Sender: TObject; Item: TListItem);
    procedure lvListResize(Sender: TObject);
    procedure lvListEdited(Sender: TObject; Item: TListItem; var S: string);
    procedure cbAtlasesChange(Sender: TObject);
    procedure lvListItemChecked(Sender: TObject; Item: TListItem);
  private
    FIsRefresh: Boolean;
    procedure RefreshAtlasList;
    procedure RefreshSpriteList;
    function ExistsEnabledSprite(ASprite: PQuadFXSprite): Boolean;
  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
    procedure Refresh;
  end;

  TListItemTextures = class(TCustomParamListItem)
  private
  public
    constructor CreateEx(AOwner: TListItems);
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
  end;

implementation

{$R *.dfm}

uses IcomList, Main;

{ TListItemTextures }

constructor TListItemTextures.CreateEx(AOwner: TListItems);
begin
  inherited CreateEx(AOwner);
  Caption := 'Textures';
end;

function TListItemTextures.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
begin
  Result := TFrameTexture.CreateEx(AOwner, AParams);
end;

{ TFrameTextures }

procedure TFrameTexture.cbAtlasesChange(Sender: TObject);
begin
  RefreshSpriteList;
end;

constructor TFrameTexture.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
var
  i: Integer;
  Item: TListItem;
  Sprite: TSpriteNode;
begin
  inherited;
  FIsRefresh := False;
  Refresh;
end;

procedure TFrameTexture.RefreshAtlasList;
var
  Node: TTreeNode;
  Sprite: PQuadFXSprite;
begin
  cbAtlases.Clear;
  Node := fTextures.TreeList.Items.GetFirstNode;
  while Assigned(Node) do
  begin
    if Node is TAtlasNode then
    begin
      cbAtlases.Items.AddObject(Node.Text, Node);
      if (Params.TextureCount > 0) and (TAtlasNode(Node).Atlas.SpriteByID(Params.Textures[0].ID, Sprite) = S_OK) then
        cbAtlases.ItemIndex := cbAtlases.Items.Count - 1;
    end;

    Node := Node.GetNext;
  end;
end;

procedure TFrameTexture.RefreshSpriteList;
var
  Atlas: TAtlasNode;
  Node: TTreeNode;
  Item: TListItem;
  i: Integer;
begin
  if (cbAtlases.ItemIndex >= 0) and Assigned(cbAtlases.Items.Objects[cbAtlases.ItemIndex]) then
    Atlas := TAtlasNode(cbAtlases.Items.Objects[cbAtlases.ItemIndex]);

  try
    FIsRefresh := True;
    lvList.Items.BeginUpdate;
    lvList.Items.Clear;
    if Assigned(Atlas) then
    begin
      Node := Atlas.getFirstChild;
      while Assigned(Node) do
      begin
        if Node is TSpriteNode then
        begin
          Item := lvList.Items.Add;
          Item.Caption := Node.Text;
          Item.SubItems.Add(Format('%dõ%d', [TSpriteNode(Node).Width, TSpriteNode(Node).Height]));
          Item.ImageIndex := Node.ImageIndex;
          Item.Data := TSpriteNode(Node).Sprite;
          Item.Checked := ExistsEnabledSprite(TSpriteNode(Node).Sprite);
        end;
        Node := Atlas.GetNextChild(Node);
      end;
    end;
    lvList.Items.EndUpdate;
  finally
    FIsRefresh := False;
    lvList.Items.EndUpdate;
  end;
end;

function TFrameTexture.ExistsEnabledSprite(ASprite: PQuadFXSprite): Boolean;
var
  i: Integer;
begin
  for i := 0 to Params.TextureCount - 1 do
    if Params.Textures[i].ID = ASprite.ID then
      Exit(True);
  Result := False;
end;

procedure TFrameTexture.lvListItemChecked(Sender: TObject; Item: TListItem);
var
  i, Count: Integer;
begin
  if FIsRefresh then
    Exit;

  Count := 0;
  for Item in lvList.Items do
    if Item.Checked then
      Inc(Count);

  Params.TextureCount := 0;
  SetLength(Params.Textures, Count);
  if Count > 0 then
  begin
    i := 0;
    for Item in lvList.Items do
      if Item.Checked then
      begin
        Params.Textures[i] := PQuadFXSprite(Item.Data);
        Inc(i);
      end;
    Params.TextureCount := Count;
  end;
end;

procedure TFrameTexture.Refresh;
var
  i: Integer;
  Atlas: TAtlasNode;
  Sprite: TSpriteNode;
  AtlasSize: TVec2f;
begin
  RefreshAtlasList;
  RefreshSpriteList;
  Exit;
  SetLength(Params.Textures, lvList.Items.Count);

  for i := 0 to lvList.Items.Count - 1 do
    if Assigned(lvList.Items[i].Data) then{ and (Frame.lvList.Items[i].Data is TSpriteNode)}
    begin
      Sprite := TSpriteNode(lvList.Items[i].Data);
      if Sprite.IsLocate and Assigned(Sprite.Parent) and (Sprite.Parent is TAtlasNode) then
      begin
        Atlas := TAtlasNode(Sprite.Parent);
        AtlasSize := TVec2f.Create(Atlas.Width, Atlas.Height);
        with Params.Textures[i]^ do
        begin
          Texture := TQuadFXAtlas(Atlas.Atlas).Texture;
          Position := TVec2f.Create(Sprite.Position.X, Sprite.Position.Y);
          Size := TVec2f.Create(Sprite.Width, Sprite.Height);
          UVA := Position / AtlasSize;
          UVB := (Position + Size) / AtlasSize;
         // Data := Sprite;
        end;
      end;
    end;

  Params.TextureCount := lvList.Items.Count;
end;

procedure TFrameTexture.lvListDeletion(Sender: TObject; Item: TListItem);
begin
//  Refresh;
end;

procedure TFrameTexture.lvListEdited(Sender: TObject; Item: TListItem; var S: string);
begin
  if Assigned(Item.Data) then
    TSpriteNode(Item.Data).Text := S;
end;

procedure TFrameTexture.lvListResize(Sender: TObject);
begin
  inherited;

  lvList.Columns.Items[0].Width := Width - 28 - lvList.Columns.Items[1].Width;
  lvList.Columns.Items[1].Width := 100;
end;

end.
