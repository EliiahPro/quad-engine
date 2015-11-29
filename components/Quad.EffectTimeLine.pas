unit Quad.EffectTimeLine;

interface

uses
  Winapi.Windows, Vcl.ExtCtrls, System.Classes, Vcl.Controls, System.Generics.Collections,
  System.SysUtils, System.Variants, Winapi.Messages, Vcl.StdCtrls, Vcl.Dialogs, System.Types,
  Vcl.ComCtrls, Vcl.Forms, Vcl.Graphics, Vcl.Themes, GDIPAPI, GDIPOBJ, Vcl.Menus;

type
  TEffectTimeLineItem = class;
  TEffectTimeLine = class;

  TTimeLineItemChange = procedure(ATimeFrom, ATimeTo: Single) of object;

  TTimeLineItemMoveType = (
    imtLeft = 0,
    imtNone = 1,
    imtRight = 2
  );

  TEffectTimeLineItem = class(TCollectionItem)
  private
    FIsUpdate: Boolean;
    FName: String;
    FTimeFrom: Single;
    FTimeTo: Single;
    FLoop: Boolean;

    FOnChange: TTimeLineItemChange;
    procedure SetTimeFrom(const Value: Single);
    procedure SetTimeTo(const Value: Single);
    procedure SetName(const Value: String);
    procedure SetLoop(const Value: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    procedure BeginUpdate;
    procedure EndUpdate;
  published
    property Name: String read FName write SetName;
    property TimeFrom: Single read FTimeFrom write SetTimeFrom;
    property TimeTo: Single read FTimeTo write SetTimeTo;
    property Loop: Boolean read FLoop write SetLoop;

    property OnChange: TTimeLineItemChange read FOnChange write FOnChange;
  end;

  TEffectTimeLineCollection = class(TOwnedCollection)
  private
    FOwner: TEffectTimeLine;
    function GetItem(Index: Integer): TEffectTimeLineItem;
    procedure SetItem(Index: Integer; const Value: TEffectTimeLineItem);
  protected
    procedure Update(Item: TCollectionItem); override;
    function GetOwner: TPersistent; override;
  public
    constructor Create(AEffectTimeLine: TEffectTimeLine);
    destructor Destroy; override;
    function Add: TEffectTimeLineItem;
    property Items[Index: Integer]: TEffectTimeLineItem read GetItem write SetItem; default;
  end;

  TEffectTimeLine = class(TCustomControl)
  private
    FMousePosition: TPoint;
    FScale: Integer;
    FHeightLine: Integer;
    FLines: TEffectTimeLineCollection;
    FPosition: Single;


    FMoveItem: TEffectTimeLineItem;
    FDragItem: TEffectTimeLineItem;
    FDrawPosition: Integer;
    FDragType: TTimeLineItemMoveType;
    FScrollV, FScrollH: TScrollBar;
    procedure SetLines(const Value: TEffectTimeLineCollection);
    function PointToRect(const Point: TPoint; const Rect: TRect): Boolean;
    procedure SetPosition(const Value: Single);
    procedure SetScale(const Value: Integer);
    procedure SetScrollBarV(const Value: TScrollBar);
    procedure SetScrollBarH(const Value: TScrollBar);
    function GetLineLeft: Integer;
    function MaxValue: Single;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;

    procedure Click; override;

    procedure ScrollChange(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;

  published
    property Visible;
    property Align;
    property Anchors;
    property HeightLine: Integer read FHeightLine write FHeightLine;
    property Scale: Integer read FScale write SetScale;

    property Lines: TEffectTimeLineCollection read FLines write SetLines;
    property Position: Single read FPosition write SetPosition;
    property ScrollBarV: TScrollBar read FScrollV write SetScrollBarV;
    property ScrollBarH: TScrollBar read FScrollH write SetScrollBarH;
  end;

procedure Register;

implementation

uses
  Math;

procedure Register;
begin
  RegisterComponents('Quad', [TEffectTimeLine]);
end;

{ TEffectTimeLineItem }

constructor TEffectTimeLineItem.Create(Collection: TCollection);
begin
  inherited;
  FLoop := False;
  FIsUpdate := False;
end;

procedure TEffectTimeLineItem.SetLoop(const Value: Boolean);
begin
  Floop := Value;
  if FIsUpdate then
    Exit;
  Changed(True);
end;

procedure TEffectTimeLineItem.SetName(const Value: String);
begin
  FName := Value;
  if FIsUpdate then
    Exit;
  Changed(True);
end;

procedure TEffectTimeLineItem.SetTimeFrom(const Value: Single);
begin
  FTimeFrom := Value;
  if FIsUpdate then
    Exit;
  if Assigned(OnChange) then
    OnChange(TimeFrom, TimeTo);
  Changed(True);
end;

procedure TEffectTimeLineItem.SetTimeTo(const Value: Single);
begin
  FTimeTo := Value;
  if FIsUpdate then
    Exit;
  if Assigned(OnChange) then
    OnChange(TimeFrom, TimeTo);
  Changed(True);
end;

procedure TEffectTimeLineItem.BeginUpdate;
begin
  FIsUpdate := True;
end;

procedure TEffectTimeLineItem.EndUpdate;
begin
  FIsUpdate := False;
  Changed(True);
end;

{ TEffectTimeLineCollection }

constructor TEffectTimeLineCollection.Create(AEffectTimeLine: TEffectTimeLine);
begin
  inherited Create(AEffectTimeLine, TEffectTimeLineItem);
  FOwner := AEffectTimeLine;
end;

destructor TEffectTimeLineCollection.Destroy;
var
  i: Integer;
begin
  for i := Count - 1 to 0 do
    if Assigned(Items[i]) then
      Items[i].Free;
  inherited;
end;

function TEffectTimeLineCollection.Add: TEffectTimeLineItem;
begin
  Result := TEffectTimeLineItem(inherited Add);
end;

function TEffectTimeLineCollection.GetItem(Index: Integer): TEffectTimeLineItem;
begin
  Result := TEffectTimeLineItem(inherited Items[index]);
end;

function TEffectTimeLineCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TEffectTimeLineCollection.SetItem(Index: Integer; const Value: TEffectTimeLineItem);
begin
  Items[index].Assign(Value);
end;

procedure TEffectTimeLineCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  FOwner.Invalidate;
end;

{ TEffectTimeLine }

constructor TEffectTimeLine.Create(AOwner: TComponent);
begin
  inherited;
  FPosition := 0;
  FDragItem := nil;
  FHeightLine := 21;
  FScale := 256;

  DoubleBuffered := True;
  FLines := TEffectTimeLineCollection.Create(Self);
end;

destructor TEffectTimeLine.Destroy;
begin
  FLines.Free;
  inherited;
end;

function TEffectTimeLine.GetLineLeft: Integer;
begin
  if Assigned(FScrollH) then
    Result := 128 - FScrollH.Position
  else
    Result := 128;
end;

function TEffectTimeLine.MaxValue: Single;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Lines.Count - 1 do
    if Lines[i].TimeTo * FScale > Result then
      Result := Lines[i].TimeTo;
end;

procedure TEffectTimeLine.Clear;
var
  i: Integer;
begin
  for i := FLines.Count - 1 downto 0 do
    FLines[i].Free;
  FLines.Clear;
end;

procedure TEffectTimeLine.SetPosition(const Value: Single);
begin
  if FPosition <> Value then
  begin
    FPosition := Value;
    Repaint;
  end;
end;

procedure TEffectTimeLine.ScrollChange(Sender: TObject);
begin
  Repaint;
end;

procedure TEffectTimeLine.Click;
begin
  if Lines.Count > 0 then
  begin


  end;

  inherited;
end;

procedure TEffectTimeLine.MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragItem := FMoveItem;
  end;
end;

procedure TEffectTimeLine.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
begin
  if Button = mbLeft then
    FDragItem := nil;
end;

procedure TEffectTimeLine.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);
var
  i: Integer;
  Rect: TRect;
  Len: Single;
begin
  FMousePosition := Point(X, Y);
  FMoveItem := nil;
  if not Assigned(FDragItem) then
  begin
    for i := 0 to Lines.Count - 1 do
    begin
      Rect.Left := GetLineLeft + Round(Scale * Lines[i].TimeFrom);
      Rect.Top := HeightLine + i * HeightLine;
      Rect.Right := GetLineLeft + Round(Scale * Lines[i].TimeTo);
      Rect.Bottom := Rect.Top + HeightLine;
      if PointToRect(FMousePosition, Rect) and (X >= 128) then
      begin
        FMoveItem := Lines[i];
        if X < Rect.Left + 8 then
        begin
          FDragType := imtLeft;
          Cursor := crHSplit;
          FDrawPosition := Rect.Left - X;
        end
        else
          if X > Rect.Right - 8 then
          begin
            FDragType := imtRight;
            Cursor := crHSplit;
            FDrawPosition := Rect.Right - X;
          end
          else
          begin
            FDragType := imtNone;
            Cursor := crSizeWE;
            FDrawPosition := Rect.Left - X;
          end;
        Break;
      end;
      if not Assigned(FMoveItem) then
        Cursor := crDefault;
    end;
  end
  else
  begin
    case FDragType of
      imtNone:
        begin
          Len :=  FDragItem.TimeTo - FDragItem.TimeFrom;
          FDragItem.TimeFrom := max(0, ((X + FDrawPosition) - GetLineLeft) / Scale);
          FDragItem.TimeTo := FDragItem.TimeFrom + Len;
        end;

      imtLeft:
        if (X + FDrawPosition - GetLineLeft) / Scale > FDragItem.FTimeTo then
        begin
          FDragItem.TimeFrom := FDragItem.TimeTo;
          FDragType := imtRight;
        end
        else
          FDragItem.TimeFrom := Min(FDragItem.FTimeTo, Max(0, ((X + FDrawPosition) - GetLineLeft) / Scale));

      imtRight:
        if (X + FDrawPosition - GetLineLeft) / Scale < FDragItem.TimeFrom then
        begin
          FDragItem.TimeTo := FDragItem.TimeFrom;
          FDragType := imtLeft;
        end
        else
          FDragItem.TimeTo := Max(FDragItem.FTimeFrom, ((X + FDrawPosition) - GetLineLeft) / Scale);
    end;
    if Assigned(FScrollH) then
    begin
      FScrollH.Max := Round(MaxValue * Scale) + 1000;
      FScrollH.PageSize := Round(FScrollH.Max / (Width - 128));
    end;
    Repaint;
  end;

  inherited;
end;

procedure TEffectTimeLine.Paint;
var
  i, j, Position, W: Integer;
  Graphics: TGPGraphics;
  Pen: TGPPen;
  Brush: TGPSolidBrush;
  Font: TGPFont;
  FontFamily: TGPFontFamily;
  Rect: TRect;
  sh: Single;

  Str: String;
  StartLine: Integer;
  StartValue: Integer;
begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  Pen := TGPPen.Create($FF000000);
  Brush := TGPSolidBrush.Create($FFE0E0E0);

  if Scale < 50 then
    sh := Scale
  else
  if Scale < 100 then
    sh := Scale / 2
  else
  if Scale < 500 then
    sh := Scale / 10
  else
    sh := Scale / 20;

  FontFamily := TGPFontFamily.Create('Verdana');
  Font := TGPFont.Create(FontFamily, 8, FontStyleRegular, UnitPixel);
  StartLine := 0;
  StartValue := 0;
  if Assigned(FScrollH) then
  begin
    StartLine := FScrollH.Position mod Round(sh);
    StartValue := FScrollH.Position div Round(sh);
  end;

  Graphics.FillRectangle(Brush, 0, 0, Width, HeightLine);
  Brush.SetColor($FF000000);
  for i := 0 to round((Width - 128) / sh) do
  begin
    Position := Round(sh * i) + 128 - StartLine;
   // if Position >= 128 then
    begin
      if StartValue mod 10 = 0 then
      begin
        Graphics.DrawLine(Pen, Position, 0, Position, HeightLine * 0.75);
        Str := FormatFloat('0.0', sh * StartValue / Scale);
        Graphics.DrawString(Str, Length(Str), Font, MakePoint(Position + 2, 9.0), Brush);
      end
      else
        if StartValue mod 10 = 5 then
        begin
          Graphics.DrawLine(Pen, Position, 0, Position, HeightLine div 2);
          Str := FormatFloat('0.0', sh * StartValue / Scale);
          Graphics.DrawString(Str, Length(Str), Font, MakePoint(Position + 2, 2.0), Brush);
        end
        else
          Graphics.DrawLine(Pen, Position, 0, Position, HeightLine * 0.1);
    end;
    Inc(StartValue);
  end;

  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := 128;
  Rect.Bottom := HeightLine;
  with TStyleManager.ActiveStyle do
    DrawElement(Canvas.Handle, GetElementDetails(TThemedComboBox.tcReadOnlyNormal), Rect);

  for i := 0 to Lines.Count - 1 do
  begin
    Rect.Left := GetLineLeft - 10;
    Rect.Top := HeightLine + i * HeightLine;
    Rect.Right := Width + 10;
    Rect.Bottom := Rect.Top + HeightLine;

    with TStyleManager.ActiveStyle do
      DrawElement(Canvas.Handle, GetElementDetails(TThemedGrid.tgFixedCellPressed  {TThemedProgress.tpBar}), Rect);

    Rect.Left := GetLineLeft + Round(Scale * Lines[i].TimeFrom);
    Rect.Top := HeightLine + i * HeightLine;
    Rect.Right := GetLineLeft + Round(Scale * Lines[i].TimeTo);
    Rect.Bottom := Rect.Top + HeightLine;

    with TStyleManager.ActiveStyle do
      DrawElement(Canvas.Handle, GetElementDetails(TThemedGrid.tgEllipsisButtonPressed {TThemedProgress.tpFill}), Rect);

    if Lines[i].Loop then
    begin
      W := Round(Rect.Right - Rect.Left);
      with TStyleManager.ActiveStyle do
        for j := 0 to Round((Width - Rect.Right) / W) do
        begin
          Rect.Left := Rect.Left + W;
          Rect.Right := Rect.Right + W;
          DrawElement(Canvas.Handle, GetElementDetails(TThemedGrid.tgEllipsisButtonNormal  {TThemedToolBar.ttbButtonHot}), Rect);
        end;
    end;

    Rect.Left := 0;
    Rect.Top := HeightLine + i * HeightLine;
    Rect.Right := 128;
    Rect.Bottom := Rect.Top + HeightLine;

    with TStyleManager.ActiveStyle do
    begin
      DrawElement(Canvas.Handle, GetElementDetails(TThemedComboBox.tcReadOnlyNormal), Rect);
      Rect.Right := Rect.Right - 4;
      DrawText(Canvas.Handle, GetElementDetails(TThemedComboBox.tcReadOnlyNormal), Lines[i].Name, Rect, [tfRight, tfSingleLine, tfVerticalCenter] ) ;
    end;
  end;

  Pen.SetColor($FFFF0000);
  Position := Round(FPosition * Scale + GetLineLeft);
  if Position >= 128 then
    Graphics.DrawLine(Pen, Position, 0, Position, Lines.Count * HeightLine + HeightLine);

  Font.Free;
  FontFamily.Free;
  Brush.Free;
  Pen.Free;
  Graphics.Free;
end;

procedure TEffectTimeLine.SetLines(const Value: TEffectTimeLineCollection);
begin
  FLines.Assign(Value);
end;

function TEffectTimeLine.PointToRect(const Point: TPoint; const Rect: TRect): Boolean;
begin
  Result := (Point.X > Rect.Left) and (Point.Y > Rect.Top) and (Point.X < Rect.Right) and (Point.Y < Rect.Bottom);
end;

procedure TEffectTimeLine.SetScale(const Value: Integer);
begin
  if FScale <> Value then
  begin
    FScale := Value;
    Repaint;
  end;
end;

procedure TEffectTimeLine.SetScrollBarV(const Value: TScrollBar);
begin
  FScrollV := Value;
  if Assigned(FScrollV) then
  begin
    FScrollV.OnChange := ScrollChange;
  end;
end;

procedure TEffectTimeLine.SetScrollBarH(const Value: TScrollBar);
begin
  FScrollH := Value;
  if Assigned(FScrollH) then
  begin
    FScrollH.OnChange := ScrollChange;
    FScrollH.Max := Round(MaxValue * Scale) + 1000;
    FScrollH.PageSize := Round(FScrollH.Max / (Width - 128));
  end;
end;

end.
