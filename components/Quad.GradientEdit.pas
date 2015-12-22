unit Quad.GradientEdit;

interface

uses
  Winapi.Windows, Vcl.ExtCtrls, System.Classes, Vcl.Controls, System.Generics.Collections,
  System.SysUtils, System.Variants, Winapi.Messages, Vcl.StdCtrls, Vcl.Dialogs, System.Types,
  Vcl.ComCtrls, Vcl.Forms, Vcl.Graphics, Vcl.Themes, GDIPAPI, GDIPOBJ, Vcl.Menus;

type
  TQuadGradientEdit = class;
  TQuadGradientColorItem = class;
  TQuadGradientColorItemChangeEvent = procedure(Sender: TObject; Color: TQuadGradientColorItem) of object;

  TQuadGradientColorItem = class(TCollectionItem)
  private
    FColor: TColor;
    FPosition: Single;
    FOrder: Integer;
    function GetRGB: Cardinal;
    procedure SetColor(const Value: TColor);
    procedure SetPosition(Value: Single);
    procedure SetRGB(const Value: Cardinal);
    procedure SetOrder(const Value: Integer);
  public
    property RGB: Cardinal read GetRGB write SetRGB;
    property Order: Integer read FOrder write SetOrder;
  published
    property Color: TColor read FColor write SetColor;
    property Position: Single read FPosition write SetPosition;
  end;

  TQuadGradientCollection = class(TOwnedCollection)
  private
    FOwner: TQuadGradientEdit;
    function GetItem(Index: Integer): TQuadGradientColorItem;
    procedure SetItem(Index: Integer; const Value: TQuadGradientColorItem);
  protected
    procedure Update(Item: TCollectionItem); override;
    function GetOwner: TPersistent; override;
  public
    constructor Create(AGradientEdit: TQuadGradientEdit);
    destructor Destroy; override;
    function Add: TQuadGradientColorItem;
    property Items[Index: Integer]: TQuadGradientColorItem read GetItem write SetItem; default;
  end;

  TQuadGradientEdit = class(TCustomControl)
  private
    FBuffer: TBitmap;
    FColors: TQuadGradientCollection;
    FColorDrag: TQuadGradientColorItem;
    FColorMouseMove: TQuadGradientColorItem;
    FColorSelected: TQuadGradientColorItem;
    FColorDragPosition: Integer;

    FColorDialog: TColorDialog;
    FMinu: TPopupMenu;
    FMenuAdd: TMenuItem;
    FMenuEdit: TMenuItem;
    FMenuDel: TMenuItem;

    FOnItemAdd: TQuadGradientColorItemChangeEvent;
    FOnItemDel: TQuadGradientColorItemChangeEvent;
    FOnItemChange: TQuadGradientColorItemChangeEvent;

    FMousePosition: TPoint;
    procedure MouseLeave(var Msg: TMessage); message CM_MouseLeave;
    procedure SetColors(const Value: TQuadGradientCollection);
    procedure SetColorMouseMove(const Value: TQuadGradientColorItem);
    procedure MenuAddClick (Sender: TObject);
    procedure MenuEditClick (Sender: TObject);
    procedure MenuDelClick (Sender: TObject);
    function GetColor(Index: Integer): TQuadGradientColorItem;
    function GetCount: Integer;
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    property ColorMouseMove: TQuadGradientColorItem read FColorMouseMove write SetColorMouseMove;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Color[Index: Integer]: TQuadGradientColorItem read GetColor; default;
    property Count: Integer read GetCount;
  published
    property Visible;
    property Align;
    property Anchors;
    property Colors: TQuadGradientCollection read FColors write SetColors;
    property OnItemAdd: TQuadGradientColorItemChangeEvent read FOnItemAdd write FOnItemAdd;
    property OnItemDel: TQuadGradientColorItemChangeEvent read FOnItemDel write FOnItemDel;
    property OnItemChange: TQuadGradientColorItemChangeEvent read FOnItemChange write FOnItemChange;
  end;

implementation

uses
  Math;

{ TQuadGradientColorItem }

function TQuadGradientColorItem.GetRGB: Cardinal;
begin
  Result := MakeColor(255, GetRValue(Color), GetGValue(Color), GetBValue(Color));
end;

procedure TQuadGradientColorItem.SetRGB(const Value: Cardinal);
begin
  Color := (BYTE(Value shr RedShift) or (BYTE(Value shr GreenShift) shl 8) or (BYTE(Value) shl 16));
end;

procedure TQuadGradientColorItem.SetColor(const Value: TColor);
begin
  if FColor = Value then
    Exit;
  FColor := Value;
  Changed(True);
end;

procedure TQuadGradientColorItem.SetOrder(const Value: Integer);
begin
  FOrder := Value;
end;

procedure TQuadGradientColorItem.SetPosition(Value: Single);
begin
  if Value < 0 then
    Value := 0
  else
    if Value > 1 then
      Value := 1;

  if FPosition = Value then
    Exit;
  FPosition := Value;
  Changed(True);
end;

{ TQuadGradientCollection }

constructor TQuadGradientCollection.Create(AGradientEdit: TQuadGradientEdit);
begin
  inherited Create(AGradientEdit, TQuadGradientColorItem);
  FOwner := AGradientEdit;
end;

destructor TQuadGradientCollection.Destroy;
var
  i: Integer;
begin
  for i := Count - 1 to 0 do
    if Assigned(Items[i]) then
      Items[i].Free;
  inherited;
end;

function TQuadGradientCollection.Add: TQuadGradientColorItem;
begin
  Result := TQuadGradientColorItem(inherited Add);
end;

function TQuadGradientCollection.GetItem(Index: Integer): TQuadGradientColorItem;
begin
  Result := TQuadGradientColorItem(inherited Items[index]);
end;

function TQuadGradientCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TQuadGradientCollection.SetItem(Index: Integer; const Value: TQuadGradientColorItem);
begin
  Items[index].Assign(Value);
end;


procedure TQuadGradientCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  FOwner.Height := 20 * Count;
  FOwner.Invalidate;
end;

{ TQuadGradientEdit }

constructor TQuadGradientEdit.Create(AOwner: TComponent);
begin
  inherited;
  DoubleBuffered := True;
  FColorMouseMove := nil;
  FColorDrag := nil;
  FBuffer := TBitmap.Create;
  FColors := TQuadGradientCollection.Create(Self);
  FColorDialog := TColorDialog.Create(Self);


  FMinu := TPopupMenu.Create(Self);
  PopupMenu := FMinu;

  FMenuAdd := TMenuItem.Create(FMinu);
  FMenuAdd.Caption := 'Add';
  FMenuAdd.Tag := 0;
  FMenuAdd.OnClick := MenuAddClick;
  FMinu.Items.Add(FMenuAdd);
  FMenuEdit := TMenuItem.Create(FMinu);
  FMenuEdit.Caption := 'Edit';
  FMenuEdit.Tag := 1;
  FMenuEdit.OnClick := MenuEditClick;
  FMinu.Items.Add(FMenuEdit);
  FMenuDel := TMenuItem.Create(FMinu);
  FMenuDel.Caption := 'Delete';
  FMenuDel.Tag := 2;
  FMenuDel.OnClick := MenuDelClick;
  FMinu.Items.Add(FMenuDel);
end;

destructor TQuadGradientEdit.Destroy;
begin
  FColorMouseMove := nil;
  FColorDrag := nil;
  FColorDialog.Free;
  FColors.Free;
  FBuffer.Free;
  inherited;
end;

function TQuadGradientEdit.GetColor(Index: Integer): TQuadGradientColorItem;
begin
  Result := FColors[Index];
end;

function TQuadGradientEdit.GetCount: Integer;
begin
  Result := FColors.Count;
end;

procedure TQuadGradientEdit.MenuAddClick(Sender: TObject);
var
  Item: TQuadGradientColorItem;
begin
  FColors.BeginUpdate;
  Item := FColors.Add;
  Height := 20 * FColors.Count;
  Item.Position := FMousePosition.X / (Width - 20);
  Item.Color := clWhite;
  if Assigned(FOnItemAdd) then
    FOnItemAdd(Self, Item);
  FColors.EndUpdate;
end;

procedure TQuadGradientEdit.MenuEditClick(Sender: TObject);
begin
  if Assigned(FColorSelected) and FColorDialog.Execute then
    FColorSelected.Color := FColorDialog.Color;
end;

procedure TQuadGradientEdit.MenuDelClick(Sender: TObject);
begin
  if Assigned(FColorSelected) then
  begin
    if Assigned(FOnItemDel) then
      FOnItemDel(Self, FColorSelected);
    FColors.Delete(FColorSelected.Index);
    Height := 20 * FColors.Count;
  end;
end;

procedure TQuadGradientEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    TMouseButton.mbLeft:
      if Assigned(FColorMouseMove) then
      begin
        FColorDragPosition := X - Round(FColorMouseMove.Position * (Width - 20));
        FColorDrag := FColorMouseMove;
      end;
    TMouseButton.mbRight:
      FColorSelected := FColorMouseMove;
  end;

  inherited;
end;

procedure TQuadGradientEdit.MouseLeave(var Msg: TMessage);
begin
  FColorMouseMove := nil;
  FColorDrag := nil;
end;

procedure TQuadGradientEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  Rect: TGPRect;
  MoveItem: TQuadGradientColorItem;
begin
  FMousePosition := Point(X, Y);

  if Assigned(FColorDrag) then
  begin
    FColorDrag.Position := (X - FColorDragPosition) / (Width - 20);
    if Assigned(FOnItemChange) then
      FOnItemChange(Self, FColorDrag);
  end
  else
  begin
    Rect.Width := 16;
    Rect.Height := 16;
    MoveItem := nil;
    for i := 0 to Count - 1 do
    begin
      Rect.Y := i * 20 + 2;
      Rect.X := Round(Color[i].Position * (Width - 20) + 2);
      if (Rect.X < X) and (Rect.Y < Y) and (Rect.X + Rect.Width > X) and (Rect.Y + Rect.Height > Y) then
      begin
        MoveItem := FColors[i];
        Break;
      end;
    end;
    ColorMouseMove := MoveItem;
  end;
  inherited;
end;

procedure TQuadGradientEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    FColorDrag := nil;

  inherited;
end;

procedure TQuadGradientEdit.Paint;
var
  i, j: Integer;
  Graphics: TGPGraphics;
  Pen: TGPPen;
  Brush: TGPSolidBrush;
  Gradient: TGPLinearGradientBrush;
  Rect: TGPRect;
  GradientWidth: Integer;
  ColorList: TList<TQuadGradientColorItem>;
  IsFind: Boolean;
begin
  //inherited;
  if FColors.Count = 0 then
    Exit;

  FBuffer.Width := Width;
  FBuffer.Height := Height;
  Graphics := TGPGraphics.Create(Canvas.Handle);
  GradientWidth := Width - 20;
  Pen := TGPPen.Create($FF000000);
  Brush := TGPSolidBrush.Create($FF000000);

  if FColors.Count > 1 then
  begin
    ColorList := TList<TQuadGradientColorItem>.Create;
    for i := 0 to Count - 1 do
    begin
      IsFind := False;
      for j := 0 to ColorList.Count - 1 do
        if ColorList[j].Position > FColors[i].Position then
        begin
          ColorList.Insert(j, FColors[i]);
          IsFind := True;
          Break;
        end;

      if not IsFind then
        ColorList.Add(FColors[i]);
    end;

    Rect.Y := 0;
    Rect.Height := Height;

    Brush.SetColor(ColorList[0].RGB);
    Graphics.FillRectangle(Brush, 0, 0, Floor(ColorList[0].Position * GradientWidth + 10), Height);

    Brush.SetColor(ColorList[ColorList.Count - 1].RGB);
    Graphics.FillRectangle(Brush, Floor(ColorList[0].Position * GradientWidth + 10), 0, Width- Floor(ColorList[0].Position * GradientWidth + 10), Height);


    for i := 0 to ColorList.Count - 2 do
    begin
      Rect.X := Floor(ColorList[i].Position * GradientWidth + 10) - 1;
      Rect.Width := Ceil(ColorList[i + 1].Position * GradientWidth - Rect.X + 10) + 2;
      Gradient := TGPLinearGradientBrush.Create(
        MakeRect(Rect.X - 1, Rect.Y, Rect.Width + 2, Rect.Height),
        ColorList[i].RGB, ColorList[i + 1].RGB,
        TLinearGradientMode.LinearGradientModeHorizontal
      );
      Graphics.FillRectangle(Gradient, Rect);
      Gradient.Free;
    end;
    ColorList.Free;
  end
  else
  begin
    Brush.SetColor(FColors[0].RGB);
    Graphics.FillRectangle(Brush, 0, 0, Width, Height);
  end;

  Rect.Width := 16;
  Rect.Height := 16;
  Brush.SetColor(FColors[0].RGB);
  for i := 0 to FColors.Count - 1 do
  begin
    Brush.SetColor(FColors[i].RGB);
    Rect.Y := i * 20 + 2;
    Rect.X := Floor(FColors[i].Position * GradientWidth + 2);
    Graphics.FillRectangle(Brush, Rect);

    if (FColors[i] = FColorDrag) then
      Pen.SetColor($FFFF0000)
    else
      if (FColors[i] = FColorMouseMove) then
        Pen.SetColor($FFFFFFFF)
      else
        Pen.SetColor($FF000000);
    Graphics.DrawRectangle(Pen, Rect);

  end;
  Brush.Free;
  Pen.Free;
  Graphics.Free;

 // Canvas.Draw(0, 0, FBuffer);
end;

procedure TQuadGradientEdit.SetColorMouseMove(const Value: TQuadGradientColorItem);
begin
  if FColorMouseMove <> Value then
  begin
    FColorMouseMove := Value;
    Repaint;
  end;
end;

procedure TQuadGradientEdit.SetColors(const Value: TQuadGradientCollection);
begin
  FColors.Assign(Value);
end;

end.
