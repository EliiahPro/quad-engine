unit Frame.Shape.Rect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Quad.Diagram,
  Vcl.StdCtrls, FloatSpinEdit, Vcl.ExtCtrls, QuadFX;

type
  TFrameShapeRect = class(TCustomParamFrame)
    Panel2: TPanel;
    cbCurve: TCheckBox;
    pValues: TPanel;
    Label2: TLabel;
    Label1: TLabel;
    eHeight: TFloatSpinEdit;
    eWidth: TFloatSpinEdit;
    dDiagram: TQuadDiagram;
    eAngle: TFloatSpinEdit;
    Label3: TLabel;
    cbDirectionFromCenter: TCheckBox;
    procedure eWidthChange(Sender: TObject);
    procedure eHeightChange(Sender: TObject);
    procedure eAngleChange(Sender: TObject);
    procedure dDiagramPointChange(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure cbCurveClick(Sender: TObject);
    procedure dDiagramPointAdd(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointDelete(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure cbDirectionFromCenterClick(Sender: TObject);
  private

  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
  end;

var
  FrameShapeRect: TFrameShapeRect;

implementation

uses
  Math;

{$R *.dfm}

procedure TFrameShapeRect.cbCurveClick(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  pValues.Visible := not cbCurve.Checked;
  dDiagram.Visible := cbCurve.Checked;

  if cbCurve.Checked then
  begin
    Params.Shape.ParamType := qpptCurve;
    for i := 0 to 2 do
      if Params.Shape.Diagram[i].Count = 0 then
      begin
        Params.Shape.Diagram[i].Count := 1;
        SetLength(Params.Shape.Diagram[i].List, 1);
      end;
  end
  else
    Params.Shape.ParamType := qpptValue;
end;

procedure TFrameShapeRect.cbDirectionFromCenterClick(Sender: TObject);
begin
  if Params <> nil then
    Params.DirectionFromCenter := cbDirectionFromCenter.Checked;
end;

constructor TFrameShapeRect.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
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

  eWidth.Value := Params.Shape.Value[0];
  eHeight.Value := Params.Shape.Value[1];
  eAngle.Value := RadToDeg(Params.Shape.Value[2]);

  if dDiagram.Visible then
  begin
    LoadDiagram(dDiagram.Lines[0], @Params.Shape.Diagram[0]);
    LoadDiagram(dDiagram.Lines[1], @Params.Shape.Diagram[1]);
    LoadDiagram(dDiagram.Lines[2], @Params.Shape.Diagram[2]);
  end;
end;

procedure TFrameShapeRect.dDiagramPointAdd(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  Diagram := @Params.Shape.Diagram[ALine.Index];
  Count := Diagram.Count + 1;
  SetLength(Diagram.List, Count);
  for i := Count - 2 downto APoint.Index do
    Diagram.List[i + 1] := Diagram.List[i];

  Diagram.List[APoint.Index].Value := APoint.Y;
  Diagram.List[APoint.Index].Life := APoint.X / 100;
  Diagram.Count := Count;
end;

procedure TFrameShapeRect.dDiagramPointChange(ADiagram: TQuadDiagram;
  ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
begin
  inherited;
  Params.Shape.Diagram[ALine.Index].List[APoint.Index].Life := APoint.X / 100;

  if ALine.Index = 2 then
    Params.Shape.Diagram[ALine.Index].List[APoint.Index].Value := DegToRad(APoint.Y)
  else
    Params.Shape.Diagram[ALine.Index].List[APoint.Index].Value := APoint.Y;
end;

procedure TFrameShapeRect.dDiagramPointDelete(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
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

procedure TFrameShapeRect.eAngleChange(Sender: TObject);
begin
  inherited;
  Params.Shape.Value[2] := DegToRad(eAngle.Value);
end;

procedure TFrameShapeRect.eHeightChange(Sender: TObject);
begin
  inherited;
  Params.Shape.Value[1] := eHeight.Value;
end;

procedure TFrameShapeRect.eWidthChange(Sender: TObject);
begin
  inherited;
  Params.Shape.Value[0] := eWidth.Value;
end;

end.
