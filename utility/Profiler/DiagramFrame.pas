unit DiagramFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Math,
  Vcl.ExtCtrls, Vcl.ComCtrls, DiagramLine, GDIPAPI, GDIPOBJ;

type
  TDiagram = class(TPanel)
  private
    FOnPaint: TNotifyEvent;
  protected
    procedure Paint; override;
  public
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property Canvas;
  published
    property DoubleBuffered;
  end;

  TfDiagramFrame = class(TFrame)
    Panel: TPanel;
    Scroll: TScrollBar;
    pLeft: TPanel;
    List: TListView;
    procedure ListCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
  private
  public
    Diagram: TDiagram;
    procedure Draw;
    function FindLineByID(AID: Word): TDiagramLine;
  end;

implementation

const
  LINE_COLOR: array[0..12] of Cardinal = (
    $FF948954,
    $FF538dd4,
    $FFd99593,
    $FFc4d69c,
    $FFb1a1c7,
    $FF93cddb,
    $FFfabe91,
    $FF96b4d6,
    $FFff0000,
    $FFf59547,
    $FFffff00,
    $FFcc3399,
    $FF00FF00
  );

{$R *.dfm}

{ TDiagram }

procedure TDiagram.Paint;
begin
  inherited;
end;

{ TfDiagramFrame }

function TfDiagramFrame.FindLineByID(AID: Word): TDiagramLine;
var
  i: Integer;
begin
  for i := 0 to List.Items.Count - 1 do
    if TDiagramLine(List.Items[i]).ID = AID then
      Exit(TDiagramLine(List.Items[i]));
  Result := nil;
end;

procedure TfDiagramFrame.ListCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TDiagramLine;
end;

procedure TfDiagramFrame.Draw;
var
  DC: HDC;
  memDC: HDC;
  hBMP : HBITMAP;
  i, j, k, count: Integer;
  Points: array of TGPPointF;
  ScaleY, MaxTime, MaxValue: Double;
  Ruler: Single;
  Graphics: TGPGraphics;
  Pen: TGPPen;
  Line: TDiagramLine;
begin
  if List.Items.Count = 0 then
    Exit;

  MaxValue := 0;
  MaxTime := 0;
  for i := 0 to List.Items.Count - 1 do
    if List.Items[i].Checked then
    begin
      MaxValue := Max(MaxValue, TDiagramLine(List.Items[i]).MaxValue);
      MaxTime := Max(MaxTime, TDiagramLine(List.Items[i]).Time);
    end;

  Ruler := Max({Ceil(}MaxValue {* 1000) / 1000}, 0.0001);
  if Ruler > 0 then
    ScaleY := (Diagram.Height - 10) / Ruler
  else
    ScaleY := 0;

  memDC := CreateCompatibleDC(Diagram.Canvas.Handle);
  hBMP := CreateCompatibleBitmap(Diagram.Canvas.Handle, Diagram.Width, Diagram.Height);
  SelectObject(memDC, hBMP);

  Graphics := TGPGraphics.Create(memDC);

  Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
  Graphics.Clear($FF171717);
  Pen := TGPPen.Create($FF000000, 1);
  try
    for i := 0 to List.Items.Count - 1 do
      if List.Items[i].Checked then
      begin
        Line := TDiagramLine(List.Items[i]);

        Pen.SetColor(LINE_COLOR[i]);
        if Line.Selected then
          Pen.SetWidth(2)
        else
          Pen.SetWidth(1);

        SetLength(Points, Line.ValueCount);

        j := Line.ValueCount - 1;
        for k := 0 to Line.ValueCount - 1 do
        begin
          Points[k].X := Diagram.Width - 32 - (MaxTime - Line[j].Time) * 24 * 60 * 60 * 20  {* FScale};
          Points[k].Y := Diagram.Height - 5 - Line[j].Value * ScaleY;
         // Graphics.DrawLine(Pen, 0, 0, Points[k].X, Points[k].Y);
          Dec(j);
        end;
        Graphics.DrawLines(Pen, PGPPointF(@Points[0]), Line.ValueCount);
      end;
  finally
    Pen.Free;
    Graphics.free;
    BitBlt(Diagram.Canvas.Handle, 0, 0, Diagram.Width, Diagram.Height, memDC, 0, 0, SRCCOPY);
    DeleteObject(hBMP);
  end;
end;

end.
