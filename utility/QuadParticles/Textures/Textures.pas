unit Textures;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GDIPAPI, GDIPOBJ, GDIPUTIL, Sprite, Atlas, CustomTextureNode,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ImgList, Vcl.ExtCtrls, System.Json, System.Types,
  System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ToolWin, QuadFX, QuadFx.Manager, XMLIntf, XMLDoc;

type
  TPreviewBG = (
    pbgNone = 0,
    pbgWhite = 1,
    pbgBlack = 2,
    pbgCustom = 3
  );

  TfTextures = class(TForm)
    RightPanel: TPanel;
    TreeList: TTreeView;
    pmTreeList: TPopupMenu;
    ActionList: TActionList;
    aCreateAtlas: TAction;
    aOpenSprite: TAction;
    aRemove: TAction;
    CreateAtlas1: TMenuItem;
    OpenSprite1: TMenuItem;
    N1: TMenuItem;
    Remove1: TMenuItem;
    OpenDialog: TOpenDialog;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolBar2: TToolBar;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ColorDialog: TColorDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListGetImageIndex(Sender: TObject; Item: TListItem);
    procedure TreeListCreateNodeClass(Sender: TCustomTreeView;
      var NodeClass: TTreeNodeClass);
    procedure TreeListChange(Sender: TObject; Node: TTreeNode);
    procedure BackgroundInit;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure aCreateAtlasExecute(Sender: TObject);
    procedure aOpenSpriteExecute(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure TreeListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure aRemoveExecute(Sender: TObject);
    procedure ToolBarColorClick(Sender: TObject);
  private
    FCustomColor: TColor;
    FBGType: TPreviewBG;
    FBitBuffer: TBitmap;
    FBackGround: TGPBitmap;
    FAtlasSelected: TAtlasNode;
    FSpriteSelected: TSpriteNode;
    FCamera: TPoint;
    FCameraDrag: Boolean;
    FMouseDown: Array[TMouseButton] of Boolean;
    FMouse: TPoint;
    FPosition: TPoint;
   // FOnTextureChange: TTextureChangeEvent;

    function NormalizeSize(int: Integer): Integer;
    function GetAtlasSelected: TAtlasNode;
    function GetSprite(ID: Integer): TSpriteNode;
  public
    procedure Clear;
    function SpriteAdd(AFileName: String): TSpriteNode;
    function ToJson: TJSONObject;
    function ToXml(AParent: IXMLNode): IXMLNode;
    function CreateAtlas: TAtlasNode; overload;
    function CreateAtlas(AAtlas: IQuadFXAtlas): TAtlasNode; overload;
    function CreateAtlas(AAtlas: IQuadFXAtlas; AJsonObject: TJSONObject): TAtlasNode; overload;
    function CreateSprite(AAtlas: TTreeNode): TSpriteNode;
    property AtlasSelected: TAtlasNode read GetAtlasSelected;
    procedure BackgroundDraw(AGraphics: TGPGraphics; AWidth, AHeight: Integer);
    procedure RefreshID;
    property Sprite[ID: Integer]: TSpriteNode read GetSprite;
  end;

var
  fTextures: TfTextures;

function ColorToARGB(AColor: TColor; Alpha: byte = 255): DWORD;

implementation

{$R *.dfm}

uses IcomList, Main;

type
  PNode = ^TNode;
  TNode = record
    Child: array[0..1] of PNode;
    Rect: TRect;
  end;

function ColorToARGB(AColor: TColor; Alpha: byte = 255): DWORD;
begin
  AColor := ColorToRgb(AColor);
  result := MakeColor(Alpha, GetRValue(AColor), GetGValue(AColor), GetBValue(AColor));
end;

procedure TfTextures.RefreshID;
var
  i, Number: Integer;
begin
  Number := 1;
  for i := 0 to TreeList.Items.Count - 1 do
    if (TreeList.Items[i] is TSpriteNode) and Assigned(TSpriteNode(TreeList.Items[i]).Sprite) then
    begin
      TSpriteNode(TreeList.Items[i]).Sprite.ID := Number;
      Inc(Number);
    end;
end;

function TfTextures.GetSprite(ID: Integer): TSpriteNode;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to TreeList.Items.Count - 1 do
    if (TreeList.Items[i] is TSpriteNode) and (TSpriteNode(TreeList.Items[i]).Sprite.ID = ID) then
      Exit(TSpriteNode(TreeList.Items[i]));
end;

function TfTextures.SpriteAdd(AFileName: String): TSpriteNode;
var
  Atlas: TAtlasNode;
begin
  Result := nil;
  if TreeList.Items.GetFirstNode is TAtlasNode then
    Atlas := TAtlasNode(TreeList.Items.GetFirstNode)
  else
    Atlas := CreateAtlas;

  if Assigned(Atlas) then
  begin
    Result := CreateSprite(Atlas);
    Result.CreateEx(AFileName);
    Atlas.Refresh;
  //Atlas.LoadTexture;
  end;
end;

procedure TfTextures.Clear;
begin
 // try
    TreeList.Items.Clear;
 // except
 // end;
end;

function TfTextures.CreateAtlas: TAtlasNode;
begin
  dmIcomList.TreeNodeCreateClass := TAtlasNode;
  Result := TreeList.Items.AddChild(nil, 'Atlas') as TAtlasNode;
  Result.CreateEx;
  TreeList.Select(Result);
end;

function TfTextures.CreateAtlas(AAtlas: IQuadFXAtlas): TAtlasNode;
begin
  Result := CreateAtlas;
  if not Assigned(AAtlas) then
  begin
    Manager.CreateAtlas(AAtlas);
    Result.Text := AAtlas.GetName;
  end;

  Result.Atlas := AAtlas;
end;

function TfTextures.CreateAtlas(AAtlas: IQuadFXAtlas; AJsonObject: TJSONObject): TAtlasNode;
var
  i: Integer;
  Sprite: PQuadFXSprite;
begin
  Result := CreateAtlas(AAtlas);
  Result.FromJson(AJsonObject);

  for i := 0 to AAtlas.GetSpriteCount - 1 do
  begin
    AAtlas.GetSprite(i, Sprite);
    CreateSprite(Result).CreateEx(Sprite);
  end;
end;

function TfTextures.CreateSprite(AAtlas: TTreeNode): TSpriteNode;
begin
  dmIcomList.TreeNodeCreateClass := TSpriteNode;
  Result := (TreeList.Items.AddChild(AAtlas, '') as TSpriteNode);
 // Result.Sprite
  //TAtlasNode(AAtlas).Atlas.CreateSprite(Result.Sprite);
 // QuadFXAtlas.CreateSprite(Sprite);
  AAtlas.Expanded := True;
end;

procedure TfTextures.FormClick(Sender: TObject);
begin                                     {
  if not Assigned(FAtlasSelected) then
    Exit;

  FAtlasSelected.FocusToPosition(Point(FMouse.X - FPosition.X, FMouse.Y - FPosition.Y));
  }
end;

procedure TfTextures.FormCreate(Sender: TObject);
begin
  FBGType := pbgNone;
  FCustomColor := $FFA0A0A0;
  BackgroundInit;
  FCamera.X := 0;
  FCamera.Y := 0;

  FBitBuffer := TBitmap.Create;
                     {
  SpriteAdd('Data\Fire\Fire01.png');
  SpriteAdd('Data\Fire\Fire02.png');
  SpriteAdd('Data\Fire\Fire03.png');
  SpriteAdd('Data\Fire\Fire04.png');
  SpriteAdd('Data\Fire\Fire05.png');
  SpriteAdd('Data\Fire\Fire06.png');    }
end;

procedure TfTextures.FormDestroy(Sender: TObject);
begin
  if Assigned(FBackGround) then
    FBackGround.Free;
  FBitBuffer.Free;
end;

procedure TfTextures.aCreateAtlasExecute(Sender: TObject);
begin
  CreateAtlas(nil).Selected := True;
end;

procedure TfTextures.aOpenSpriteExecute(Sender: TObject);
var
  i: Integer;
begin
  if not OpenDialog.Execute then
    Exit;

  for i := 0 to OpenDialog.Files.Count - 1 do
    CreateSprite(AtlasSelected).CreateEx(OpenDialog.Files.Strings[i]);

 { CreateSprite(FAtlasSelected).CreateEx('stone.png');
  CreateSprite(FAtlasSelected).CreateEx('stone_n.png');
  CreateSprite(FAtlasSelected).CreateEx('stone_s.png');
  CreateSprite(FAtlasSelected).CreateEx('test\ConsoleBg.png');

  CreateSprite(FAtlasSelected).CreateEx('test\test.png');
  CreateSprite(FAtlasSelected).CreateEx('test\test1.png'); }
 // CreateSprite(FAtlasSelected).CreateEx('test\sand.png');

  FAtlasSelected.Refresh;
  Repaint;
end;

procedure TfTextures.aRemoveExecute(Sender: TObject);
begin
  if TreeList.Selected is TSpriteNode then
    FAtlasSelected.Atlas.DeleteSprite(TSpriteNode(TreeList.Selected).Sprite);

  TreeList.Items.Delete(TreeList.Selected);
  if Assigned(FAtlasSelected) then
    FAtlasSelected.Refresh;
  Repaint;
end;

procedure TfTextures.BackgroundDraw(AGraphics: TGPGraphics; AWidth, AHeight: Integer);
var
  X, Y: Integer;
  Brush: TGPSolidBrush;
begin
  Brush := nil;
  case FBGType of
    pbgNone:
      for Y := 0 to AHeight div FBackground.GetHeight + 1 do
        for X := 0 to AWidth div FBackground.GetWidth + 1 do
          AGraphics.DrawImage(FBackground, FBackground.GetWidth * X, FBackground.GetHeight * Y);
    pbgWhite: Brush := TGPSolidBrush.Create($FFFFFFFF);
    pbgBlack: Brush := TGPSolidBrush.Create($FF000000);
    pbgCustom: Brush := TGPSolidBrush.Create(ColorToARGB(FCustomColor));
  end;

  if Assigned(Brush) and (FBGType <> pbgNone) then
  begin
    AGraphics.FillRectangle(Brush, 0, 0, ClientWidth - RightPanel.Width, ClientHeight);
    Brush.Free;
  end;
end;

procedure TfTextures.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown[Button] := True;
end;

procedure TfTextures.FormMouseLeave(Sender: TObject);
var
  Button: TMouseButton;
begin
  for Button := Low(TMouseButton) to High(TMouseButton) do
    FMouseDown[Button] := False;

  FCameraDrag := false;
  if Cursor = crSizeAll then
    Cursor := crDefault;
end;

procedure TfTextures.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FMouseDown[mbLeft] then
  begin
    FCameraDrag := True;
    Cursor := crSizeAll;
    FCamera.X := FCamera.X - FMouse.X + X;
    FCamera.Y := FCamera.Y - FMouse.Y + Y;
    Repaint;
  end;

  FMouse.X := X;
  FMouse.Y := Y;
end;

procedure TfTextures.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if not FCameraDrag then
    begin
      if not Assigned(FAtlasSelected) then
        Exit;

      FAtlasSelected.FocusToPosition(Point(FMouse.X - FPosition.X, FMouse.Y - FPosition.Y));
    end;

    FCameraDrag := false;
    if Cursor = crSizeAll then
      Cursor := crDefault;
  end;
  FMouseDown[Button] := False;
end;

procedure TfTextures.FormPaint(Sender: TObject);
var
  Graphics: TGPGraphics;
  i: Integer;
  Pen: TGPPen;
begin
  if not Assigned(FAtlasSelected) then
    Exit;

  FBitBuffer.Width := ClientWidth - RightPanel.Width;
  FBitBuffer.Height := ClientHeight;

  FPosition.X := FBitBuffer.Width div 2 - FAtlasSelected.Bitmap.GetWidth div 2 + FCamera.X;
  FPosition.Y := FBitBuffer.Height div 2 - FAtlasSelected.Bitmap.GetHeight div 2 + FCamera.Y;

  Graphics := TGPGraphics.Create(FBitBuffer.Canvas.Handle);
  Pen := TGPPen.Create($FF000000);
  BackgroundDraw(Graphics, FBitBuffer.Width, FBitBuffer.Height);

  Graphics.DrawRectangle(Pen, FPosition.X - 2, FPosition.Y - 2, FAtlasSelected.Bitmap.GetWidth + 4, FAtlasSelected.Bitmap.GetHeight + 4);

  Graphics.DrawImage(FAtlasSelected.Bitmap, FPosition.X, FPosition.Y);

  if Assigned(FSpriteSelected) and FSpriteSelected.IsLocate then
  begin
    Pen.SetColor($FF000000);
    Pen.SetWidth(4);
    Graphics.DrawRectangle(Pen,
      FPosition.X + FSpriteSelected.Position.X - 2,
      FPosition.Y + FSpriteSelected.Position.Y - 2,
      FSpriteSelected.Bitmap.GetWidth + 4,
      FSpriteSelected.Bitmap.GetHeight + 4
    );
    Pen.SetColor($FFEEEEEE);
    Pen.SetWidth(2);
    Graphics.DrawRectangle(Pen,
      FPosition.X + FSpriteSelected.Position.X - 2,
      FPosition.Y + FSpriteSelected.Position.Y - 2,
      FSpriteSelected.Bitmap.GetWidth + 4,
      FSpriteSelected.Bitmap.GetHeight + 4
    );
  end;

  Pen.Free;
  Graphics.Free;

  Canvas.Draw(0, 0, FBitBuffer);
end;

procedure TfTextures.FormResize(Sender: TObject);
begin
  Repaint;
end;

procedure TfTextures.ListGetImageIndex(Sender: TObject; Item: TListItem);
begin
  Item.ImageIndex := Item.Index;
end;

procedure TfTextures.TreeListChange(Sender: TObject; Node: TTreeNode);
begin
  if Node is TAtlasNode then
  begin
    FAtlasSelected := TAtlasNode(Node);
    FSpriteSelected := nil;
  end
  else
    if Node is TSpriteNode then
    begin
      FSpriteSelected := TSpriteNode(Node);
      FAtlasSelected := TAtlasNode(Node.Parent);
    end;

  Paint;
end;

procedure TfTextures.TreeListCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := dmIcomList.TreeNodeCreateClass;
end;

procedure TfTextures.TreeListDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Node, DragNode: TTreeNode;
begin
  Node := TreeList.GetNodeAt(X, Y);
  if not Assigned(Node) then
    Exit;
  DragNode := TreeList.Selected;
  if DragNode is TAtlasNode then
  begin
    if Node is TAtlasNode then
      DragNode.MoveTo(Node, naInsert)
    else
      DragNode.MoveTo(Node.Parent, naInsert);
    DragNode.Expand(True);
  end
  else
  begin
    if Node is TAtlasNode then
      DragNode.MoveTo(Node, naAddChild)
    else
      DragNode.MoveTo(Node, naInsert);
  end;

  TreeList.Select(Node);

  FAtlasSelected.Refresh;
  Repaint;
end;

procedure TfTextures.TreeListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = TreeList;
end;

procedure TfTextures.BackgroundInit;
var
  Graphics: TGPGraphics;
  Brush: TGPSolidBrush;
  X, Y: Integer;
begin
  if Assigned(FBackGround) then
    Exit;

  FBackground := TGPBitmap.Create(512, 512);
  Graphics := TGPGraphics.Create(FBackground);
  Graphics.Clear($FFFFFFFF);
  Brush := TGPSolidBrush.Create($FFCCCCCC);
  for Y := 0 to 31 do
    for X := 0 to 63 do
      Graphics.FillRectangle(Brush, MakeRect(X * 8, (Y * 16) + (X mod 2) * 8, 8, 8));
  Brush.Free;
  Graphics.Free;
end;

function TfTextures.NormalizeSize(int: Integer): Integer; assembler;
asm
  bsr ecx, eax
  mov edx, 2
  add eax, eax
  shl edx, cl
  cmp eax, edx
  jne @ne
  shr edx, 1
  @ne :
  mov eax, edx
end;

function TfTextures.ToXml(AParent: IXMLNode): IXMLNode;
var
  i: Integer;
begin
  RefreshID;
  Result := AParent.OwnerDocument.CreateNode('Atlases');

  for i := 0 to TreeList.Items.Count - 1 do
    if TreeList.Items[i] is TAtlasNode then
      TAtlasNode(TreeList.Items[i]).ToXml(Result);

  AParent.ChildNodes.Add(Result);
end;

function TfTextures.ToJson: TJSONObject;
var
  i: Integer;
  Atlases: TJSONArray;
begin
  RefreshID;
  Result := TJSONObject.Create;

  Atlases := TJSONArray.Create;

  for i := 0 to TreeList.Items.Count - 1 do
    if TreeList.Items[i] is TAtlasNode then
      Atlases.Add(TAtlasNode(TreeList.Items[i]).ToJson);

  Result.AddPair('Atlases', Atlases);
end;

procedure TfTextures.ToolBarColorClick(Sender: TObject);
begin
  if not (Sender is TToolButton) then
    Exit;

  FBGType := TPreviewBG(TToolButton(Sender).ImageIndex);
  if (FBGType = pbgCustom) and ColorDialog.Execute then
    FCustomColor := ColorDialog.Color;

  Repaint;
end;

function TfTextures.GetAtlasSelected: TAtlasNode;
begin
  if not Assigned(FAtlasSelected) then
  begin
    if TreeList.Items.GetFirstNode is TAtlasNode then
      FAtlasSelected := TAtlasNode(TreeList.Items.GetFirstNode)
    else
      FAtlasSelected := CreateAtlas(nil);
  end;

  Result := FAtlasSelected;
end;

end.
