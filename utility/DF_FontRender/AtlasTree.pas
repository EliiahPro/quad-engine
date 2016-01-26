unit AtlasTree;

interface

uses
  System.Types, Winapi.Windows, vcl.Graphics;

type
  PNode = ^TNode;
  TNode = record
    Child: array[0..1] of PNode;
    rc: TRect;
    ID: SmallInt;
  end;

  TAtlasTree = class sealed
  private
    FRootNode: PNode;
    FWidth: Integer;
    FHeight: Integer;
    FAtlas: TBitmap;
  public
    constructor Create(AWidth, AHeight: Integer);
    destructor Destroy;
    procedure Clear;
    function AddNode(aID: Word; AItemWidth, AItemHeight: Integer; AItem: TBitmap): PNode;
    function InsertNode(aID: Word; Node: PNode; AItemWidth, AItemHeight: Integer): PNode;
    procedure Grow;
    property RootNode: PNode read FRootNode;
    property Atlas: TBitmap read FAtlas;
  end;

implementation

constructor TAtlasTree.Create(AWidth, AHeight: Integer);
begin
  New(FRootNode);

  FWidth := AWidth;
  FHeight := AHeight;

  Clear;
end;

destructor TAtlasTree.Destroy;
begin
  FAtlas.Free;
end;

procedure TAtlasTree.Clear;
begin
  if not Assigned(FAtlas) then
    FAtlas := TBitmap.Create;

  FAtlas.PixelFormat := pf32bit;
  FAtlas.Width := FWidth;
  FAtlas.Height := FHeight;
  FAtlas.Canvas.Brush.Color := clBlack;
  FAtlas.Canvas.FillRect(Rect(0, 0, FWidth, FHeight));

  FRootNode.ID := -1;
  FRootNode.Child[0] := nil;
  FRootNode.Child[1] := nil;
  FRootNode.rc := Rect(0, 0, FWidth, FHeight);
end;

function TAtlasTree.AddNode(aID: Word; AItemWidth, AItemHeight: Integer; AItem: TBitmap): PNode;
var
  Node: PNode;
begin
  Node := InsertNode(aID, FRootNode, AItemWidth, AItemHeight);

  if Node = nil then
  begin
    Grow;
    Node := InsertNode(aID, FRootNode, AItemWidth, AItemHeight);
  end;

  Result := Node;
  BitBlt(FAtlas.Canvas.Handle, Node.rc.Left, Node.rc.Top, AItemWidth, AItemHeight, AItem.Canvas.Handle, 0, 0, SRCCOPY);
end;

function TAtlasTree.InsertNode(aID: Word; Node: PNode; AItemWidth, AItemHeight: Integer): PNode;
var
  NewNode: PNode;
  dw, dh: Integer;
begin
  if (Node.Child[0] <> nil) and (Node.Child[1] <> nil) then
  begin
    NewNode := InsertNode(aID, Node.Child[0], AItemWidth, AItemHeight);
    if NewNode <> nil then
      Result := NewNode
    else
      Result := InsertNode(aID, Node.Child[1], AItemWidth, AItemHeight);
    Exit;
  end
  else
  begin
    if Node.ID <> -1 then
      Exit(nil);

    if ((Node.rc.Right - Node.rc.Left) < AItemWidth) or
       ((Node.rc.Bottom - Node.rc.Top) < AItemHeight) then
    begin
      Result := nil;
      Exit;
    end;

    if ((Node.rc.Right - Node.rc.Left) = AItemWidth) and
       ((Node.rc.Bottom - Node.rc.Top) = AItemHeight) then
    begin
      Node.ID := aID;
      Exit(Node);
    end
    else
    begin
      New(Node.Child[0]);
      New(Node.Child[1]);
      Node.Child[0].ID := -1;
      Node.Child[1].ID := -1;
      Node.Child[0].Child[0] := nil;
      Node.Child[0].Child[1] := nil;
      Node.Child[1].Child[0] := nil;
      Node.Child[1].Child[1] := nil;

      dw := Node.rc.Right - Node.rc.Left - AItemWidth;
      dh := Node.rc.Bottom - Node.rc.Top - AItemHeight;

      if dw > dh then
      begin
        Node.Child[0].rc := Rect(Node.rc.left, Node.rc.top, Node.rc.left + AItemWidth, Node.rc.bottom);
        Node.Child[1].rc := Rect(Node.rc.left + AItemWidth + 1, Node.rc.top, Node.rc.right, Node.rc.bottom);
      end
      else
      begin
        Node.Child[0].rc := Rect(Node.rc.left, Node.rc.top, Node.rc.right, Node.rc.top + AItemHeight);
        Node.Child[1].rc := Rect(Node.rc.left, Node.rc.top + AItemHeight + 1, Node.rc.right, Node.rc.bottom);
      end;

      Result := InsertNode(aID, Node.Child[0], AItemWidth, AItemHeight);
    end;
  end;
end;

procedure TAtlasTree.Grow;
var
  Node: PNode;
begin
  Node := FRootNode;

  if FWidth = FHeight then
    FWidth := FWidth * 2
  else
    FHeight := FHeight * 2;

  New(FRootNode);
  FRootNode.ID := 500;
  FRootNode.rc := Rect(0, 0, FWidth, FHeight);

  FRootNode.Child[0] := Node;
  New(FRootNode.Child[1]);
  FRootNode.Child[1].ID := -1;
  FRootNode.Child[1].Child[0] := nil;
  FRootNode.Child[1].Child[1] := nil;
  if FWidth > FHeight then
    FRootNode.Child[1].rc := Rect(FRootNode.Child[0].rc.Right, 0, FWidth, FHeight)
  else
    FRootNode.Child[1].rc := Rect(0, FRootNode.Child[0].rc.Bottom, FWidth, FHeight);

  FAtlas.Width := FWidth;
  FAtlas.Height := FHeight;
end;

end.
