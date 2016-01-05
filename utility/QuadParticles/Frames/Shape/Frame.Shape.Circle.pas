unit Frame.Shape.Circle;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Quad.Diagram, QuadFX,
  Vcl.StdCtrls, FloatSpinEdit, Vcl.ExtCtrls;

type
  TFrameShapeCircle = class(TCustomParamFrame)
    Panel2: TPanel;
    cbCurve: TCheckBox;
    pValues: TPanel;
    Label2: TLabel;
    Label1: TLabel;
    eSmallRadius: TFloatSpinEdit;
    eRadius: TFloatSpinEdit;
    dDiagram: TQuadDiagram;
    cbDirectionFromCenter: TCheckBox;
    procedure eRadiusChange(Sender: TObject);
    procedure eSmallRadiusChange(Sender: TObject);
    procedure cbCurveClick(Sender: TObject);
    procedure dDiagramPointAdd(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointChange(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointDelete(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure cbDirectionFromCenterClick(Sender: TObject);
  private

  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
  end;

var
  FrameShapeCircle: TFrameShapeCircle;

implementation

{$R *.dfm}

procedure TFrameShapeCircle.cbDirectionFromCenterClick(Sender: TObject);
begin
  if Params <> nil then
    Params.DirectionFromCenter := cbDirectionFromCenter.Checked;
end;

constructor TFrameShapeCircle.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
begin
  inherited;
  Parent := TWinControl(AOwner);
  dDiagram.Style.RefreshSystemStyle;

  if Params = nil then
    Exit;

  cbCurve.Checked := Params.Shape.ParamType = qpptCurve;
  cbDirectionFromCenter.Checked := Params.DirectionFromCenter;

  pValues.Visible := not cbCurve.Checked;
  dDiagram.Visible := cbCurve.Checked;

  eRadius.Value := Params.Shape.Value[0];
  eSmallRadius.Value := Params.Shape.Value[1];

  if dDiagram.Visible then
  begin
    LoadDiagram(dDiagram.Lines[0], @Params.Shape.Diagram[0]);
    LoadDiagram(dDiagram.Lines[1], @Params.Shape.Diagram[1]);
  end;
end;

procedure TFrameShapeCircle.dDiagramPointAdd(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  Diagram := @Params.Shape.Diagram[ALine.Index];
  Count := Diagram.Count + 1;
  SetLength(Diagram.List, Count);
  for i := Count - 2 downto APoint.Index do
    Diagram.List[i + 1] := Diagram.List[i];

  Diagram.List[APoint.Index].Value := APoint.Point.Y;
  Diagram.List[APoint.Index].Life := APoint.Point.X / 100;
  Diagram.Count := Count;
end;

procedure TFrameShapeCircle.dDiagramPointChange(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
begin
  Params.Shape.Diagram[ALine.Index].List[APoint.Index].Value := APoint.Point.Y;
  Params.Shape.Diagram[ALine.Index].List[APoint.Index].Life := APoint.Point.X / 100;
end;

procedure TFrameShapeCircle.dDiagramPointDelete(ADiagram: TQuadDiagram;
  ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  Diagram := @Params.Shape.Diagram[ALine.Index];
  Count := Diagram.Count - 1;
  for i := APoint.Index to Count - 2 do
    Diagram.List[i] := Diagram.List[i + 1];

  SetLength(Diagram.List, Count);
  Diagram.Count := Count;
end;

procedure TFrameShapeCircle.cbCurveClick(Sender: TObject);
var
  i: Integer;
begin
  pValues.Visible := not cbCurve.Checked;
  dDiagram.Visible := cbCurve.Checked;

  if cbCurve.Checked then
  begin
    Params.Shape.ParamType := qpptCurve;
    for i := 0 to 1 do
      if Params.Shape.Diagram[i].Count = 0 then
      begin
        Params.Shape.Diagram[i].Count := 1;
        SetLength(Params.Shape.Diagram[i].List, 1);
      end;
  end
  else
    Params.Shape.ParamType := qpptValue;
end;

procedure TFrameShapeCircle.eRadiusChange(Sender: TObject);
begin
  inherited;
  Params.Shape.Value[0] := eRadius.Value;
end;

procedure TFrameShapeCircle.eSmallRadiusChange(Sender: TObject);
begin
  inherited;
  Params.Shape.Value[1] := eSmallRadius.Value;
end;

end.
