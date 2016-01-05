unit Atlas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GDIPAPI, GDIPOBJ, GDIPUTIL, Vcl.ComCtrls, Vcl.ImgList,
  CustomTextureNode, Sprite, System.Generics.Collections, System.Json, QuadEngine, System.Types,
  QuadFX, QuadFX.Atlas, Vec2f, XMLIntf, XMLDoc;

type
  PNode = ^TNode;
  TNode = record
    Child: array[0..1] of PNode;
    Rect: TRect;
  end;

  TAtlasNode = class(TCustomTextureNode)
  strict private
    FList: TList<TSpriteNode>;
    FAtlas: IQuadFXAtlas;
    function InsertNode(ASprite: TSpriteNode; ANode: PNode): Boolean;
  public
    constructor CreateEx;
    destructor Destroy; override;
    procedure Refresh;
    procedure FocusToPosition(const AMousePosition: TPoint);
    procedure LoadTexture;

    function ToJson: TJSONObject;
    function ToXml(AParent: IXMLNode): IXMLNode;
    procedure FromJson(AJsonObject: TJSONObject);

    property Atlas: IQuadFXAtlas read FAtlas write FAtlas;
  end;

implementation

uses
  Main, QuadFX.FileLoader.JSON, QPTreeNode, QuadFX.Helpers, QuadFX.FileLoader.XML;

{ TAtlasNode }

constructor TAtlasNode.CreateEx;
begin
  FList := TList<TSpriteNode>.Create;
  FBitmap := TGPBitmap.Create(256, 256);
  RefreshIcon;
end;

procedure TAtlasNode.FocusToPosition(const AMousePosition: TPoint);
var
  i: Integer;
  Sprite: TSpriteNode;
begin
  for i := 0 to Count - 1 do
  begin
    Sprite := TSpriteNode(Item[i]);
    if (Sprite.Position.X < AMousePosition.X)
      and (Sprite.Position.Y < AMousePosition.Y)
      and (Sprite.Position.X + Sprite.Width > AMousePosition.X)
      and (Sprite.Position.Y + Sprite.Height > AMousePosition.Y) then
    begin
      Sprite.Selected := True;
    end;
  end;
end;

destructor TAtlasNode.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TAtlasNode.Refresh;
  procedure FreeNode(ANode: PNode);
  begin
    if ANode.Child[0] <> nil then
      FreeNode(ANode.Child[0]);
    if ANode.Child[1] <> nil then
      FreeNode(ANode.Child[1]);
    Dispose(ANode);
  end;
var
  Node: PNode;
  i, j: Integer;
  Graphics: TGPGraphics;
  IsFind: Boolean;
begin
  Graphics := TGPGraphics.Create(FBitmap);
  Graphics.Clear($00FFFFFF);

  New(Node);
  Node.Child[0] := nil;
  Node.Child[1] := nil;

  Node.Rect := Rect(0, 0, FBitmap.GetWidth, FBitmap.GetHeight);
  FList.Clear;
  for i := 0 to Count - 1 do
    if (Item[i] is TSpriteNode) then
      if FList.Count > 0 then
      begin
        IsFind := False;
        for j := 0 to FList.Count - 1 do
          if (FList[j].Square <= TSpriteNode(Item[i]).Square)then
          begin
            FList.Insert(j, TSpriteNode(Item[i]));
            IsFind := True;
            Break;
          end;
        if not IsFind then
          FList.Add(TSpriteNode(Item[i]));
      end
      else
        FList.Add(TSpriteNode(Item[i]));

  for i := 0 to FList.Count - 1 do
  begin
    FList[i].IsLocate := InsertNode(FList[i], Node);
    if FList[i].IsLocate then
    begin
      Graphics.DrawImage(FList[i].Bitmap, FList[i].Rect);

      FList[i].Sprite.Position := TVec2f.Create(FList[i].Rect.X, FList[i].Rect.Y);
      FList[i].Sprite.Size := TVec2f.Create(FList[i].Rect.Width, FList[i].Rect.Height);
      FList[i].Sprite.Axis := FList[i].Sprite.Size / 2;
      FList[i].Sprite.Recalculate(Atlas);
    end;
  end;

  FreeNode(Node);
  Graphics.Free;
  RefreshIcon;
  LoadTexture;
end;

function TAtlasNode.InsertNode(ASprite: TSpriteNode; ANode: PNode): Boolean;
var
  dw, dh: Integer;
begin
  if ANode = nil then
    Exit(False);

  if (ANode.Child[0] <> nil) and (ANode.Child[1] <> nil) then
  begin
    Result := insertNode(ASprite, ANode.Child[0]);
    if not Result then
      Result := insertNode(ASprite, ANode.Child[1]);
  end
  else
  begin
    dw := ANode.Rect.Width - ASprite.Width + ASprite.Padding * 2;
    dh := ANode.Rect.Height - ASprite.Height + ASprite.Padding * 2;

    if (dw < 0) or (dh < 0) then
      Exit(False);

    ASprite.Position := Point(ANode.Rect.Left + ASprite.Padding, ANode.Rect.Top + ASprite.Padding);

    New(ANode.Child[0]);
    ANode.Child[0].Child[0] := nil;
    ANode.Child[0].Child[1] := nil;

    New(ANode.Child[1]);
    ANode.Child[1].Child[0] := nil;
    ANode.Child[1].Child[1] := nil;

    if dw > dh then
    begin
      ANode.Child[0].Rect := Rect(ANode.Rect.left, ANode.Rect.top + ASprite.Height + ASprite.Padding * 2, ANode.Rect.left + ASprite.Width + ASprite.Padding * 2, ANode.Rect.bottom);
      ANode.Child[1].Rect := Rect(ANode.Rect.left + ASprite.Width + ASprite.Padding * 2, ANode.Rect.top, ANode.Rect.right, ANode.Rect.bottom);
    end
    else
    begin
      ANode.Child[0].Rect := Rect(ANode.Rect.left + ASprite.Width + ASprite.Padding * 2, ANode.Rect.top, ANode.Rect.right, ANode.Rect.top + ASprite.Height + ASprite.Padding * 2);
      ANode.Child[1].Rect := Rect(ANode.Rect.left, ANode.Rect.top + ASprite.Height + ASprite.Padding * 2, ANode.Rect.right, ANode.Rect.bottom);
    end;

    Result := True;
  end;
end;

procedure TAtlasNode.LoadTexture;
var
  i: Integer;
  Stream: TMemoryStream;
  Encoding: TGUID;
  QuadTexture: IQuadTexture;
  Sprite: PQuadFXSprite;
begin
  if not Assigned(fMain) then
    Exit;

  GetEncoderClsid('image/png', Encoding);
  Stream := TMemoryStream.Create;
  try
    Bitmap.Save(TStreamAdapter.Create(Stream), Encoding);
    fMain.RenderPreview.QuadDevice.CreateTexture(QuadTexture);
    if QuadTexture <> nil then
      QuadTexture.LoadFromStream(0, Stream.Memory, Stream.Size);
    FAtlas.SetTexture(QuadTexture);
  finally
    Stream.Free;
  end;

  for i := 0 to Atlas.GetSpriteCount - 1 do
  begin
    Atlas.GetSprite(i, Sprite);
    Sprite.Texture := QuadTexture;
    Sprite.Recalculate(Atlas);
  end;

end;

function TAtlasNode.ToXml(AParent: IXMLNode): IXMLNode;
var
  i: Integer;
  Sprite: PQuadFXSprite;
  FileFormat: TQuadFXXMLFileFormat;
begin
  Result := AParent.OwnerDocument.CreateNode('Atlas');

  Result.Attributes['Name'] := Text;
  Result.Attributes['Width'] := Width;
  Result.Attributes['Height'] := Height;

  FileFormat := TQuadFXXMLFileFormat.Create;
  try
    for i := 0 to FAtlas.GetSpriteCount - 1 do
    begin
      FAtlas.GetSprite(i, Sprite);
      FileFormat.SaveSprite(Result, Sprite);
    end;
  finally
    FileFormat.Free;
  end;

  AParent.ChildNodes.Add(Result);
end;

function TAtlasNode.ToJson: TJSONObject;
var
  i: Integer;
  Sprites: TJSONArray;
  Sprite: PQuadFXSprite;
  FileFormat: TQuadFXJSONFileFormat;
begin
  Result := TJSONObject.Create;

  //Result.AddPair(TJSONPair.Create('ID', TJSONNumber.Create(ImageIndex)));
  Result.AddPair(TJSONPair.Create('Name', Text));
  Result.AddPair(TJSONPair.Create('Width', TJSONNumber.Create(Width)));
  Result.AddPair(TJSONPair.Create('Height', TJSONNumber.Create(Height)));

  Sprites := TJSONArray.Create;

  FileFormat := TQuadFXJSONFileFormat.Create;
  try
    for i := 0 to FAtlas.GetSpriteCount - 1 do
    begin
      FAtlas.GetSprite(i, Sprite);
      Sprites.Add(FileFormat.SaveSprite(Sprite));
    end;
  finally
    FileFormat.Free;
  end;

  Result.AddPair(TJSONPair.Create('Sprites', Sprites));
  SaveBitmapToJson(Result);
end;

procedure TAtlasNode.FromJson(AJsonObject: TJSONObject);
begin
  LoadBitmapFromJson(AJsonObject);
  RefreshIcon;
end;

end.
