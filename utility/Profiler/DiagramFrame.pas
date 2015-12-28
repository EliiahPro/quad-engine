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
    tbScale: TTrackBar;
    procedure ListCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
  private
  public
    Diagram: TDiagram;
    procedure Draw;
    function FindLineByID(AID: Word): TDiagramLine;
  end;

implementation

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
  i, j, k: Integer;
  Points: array of TGPPointF;
  ScaleY, MaxValue: Double;
  MaxTime: TDateTime;
  Ruler: Single;
  Graphics: TGPGraphics;
  Pen: TGPPen;
  Line: TDiagramLine;
begin
  if List.Items.Count = 0 then
    Exit;

  MaxTime := 0;
  MaxValue := 0;
  for i := 0 to List.Items.Count - 1 do
    if List.Items[i].Checked then
    begin
      MaxTime := Max(MaxTime, TDiagramLine(List.Items[i]).Time);
      MaxValue := Max(MaxValue, TDiagramLine(List.Items[i]).MaxValue);
    end;

  Ruler := Max(Ceil(MaxValue * 10) / 10, 0.1);
  if Ruler > 0 then
    ScaleY := (Diagram.Height - 10) / Ruler
  else
    ScaleY := 0;

  Graphics := TGPGraphics.Create(Diagram.Canvas.Handle);
  Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
  Graphics.Clear($FFFFFFFF);
  Pen := TGPPen.Create($FF000000, 2);
  try
    for i := 0 to List.Items.Count - 1 do
      if List.Items[i].Checked then
      begin
        Line := TDiagramLine(List.Items[i]);

        SetLength(Points, Line.ValueCount);

        j := Line.ValueCount - 1;
        for k := 0 to Line.ValueCount - 1 do
        begin
          Points[k].X := Diagram.Width - 32 - k{ (MaxTime - Line.Values[j].Time) * FScale};
          Points[k].Y := Diagram.Height - 5 - Line.Values[j].Value * ScaleY;
          Dec(j);
        end;
        Graphics.DrawLines(Pen, PGPPointF(@Points[0]), Line.ValueCount);
      end;
  finally
      Pen.Free;
    Graphics.free;
  end;
end;

end.
