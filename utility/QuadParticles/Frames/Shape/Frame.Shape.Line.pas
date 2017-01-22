unit Frame.Shape.Line;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Vcl.StdCtrls, QuadFX,
  Vec2f, FloatSpinEdit, Quad.Diagram, Vcl.ExtCtrls;

type
  TFrameShapeLine = class(TCustomParamFrame)
    pValues: TPanel;
    Panel2: TPanel;
    cbCurve: TCheckBox;
    eAngle: TFloatSpinEdit;
    Label2: TLabel;
    eLength: TFloatSpinEdit;
    Label1: TLabel;
    dDiagram: TQuadDiagram;
    cbDirectionFromCenter: TCheckBox;
    procedure eLengthChange(Sender: TObject);
    procedure eAngleChange(Sender: TObject);
    procedure cbCurveClick(Sender: TObject);
    procedure dDiagramPointChange(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointAdd(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointDelete(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure cbDirectionFromCenterClick(Sender: TObject);
  private

  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
  end;

implementation

uses
  Math;

{$R *.dfm}

Function atan2(y: extended;x : extended): Extended; Assembler;
asm
  fld [y]
  fld [x]
  fpatan
end;

procedure TFrameShapeLine.cbCurveClick(Sender: TObject);
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

procedure TFrameShapeLine.cbDirectionFromCenterClick(Sender: TObject);
begin
  if Params <> nil then
    Params.DirectionFromCenter := cbDirectionFromCenter.Checked;
end;

constructor TFrameShapeLine.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
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

  eLength.Value := Params.Shape.Value[0];
  eAngle.Value := Params.Shape.Value[1];

  if dDiagram.Visible then
  begin
    LoadDiagram(dDiagram.Lines[0], @Params.Shape.Diagram[0]);
    LoadDiagram(dDiagram.Lines[1], @Params.Shape.Diagram[1]);
  end;
end;

procedure TFrameShapeLine.dDiagramPointAdd(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
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

procedure TFrameShapeLine.dDiagramPointChange(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
begin
  Params.Shape.Diagram[ALine.Index].List[APoint.Index].Value := APoint.Y;
  Params.Shape.Diagram[ALine.Index].List[APoint.Index].Life := APoint.X / 100;
end;

procedure TFrameShapeLine.dDiagramPointDelete(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
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

procedure TFrameShapeLine.eLengthChange(Sender: TObject);
begin
  if Params = nil then
    Exit;

  Params.Shape.Value[0] := eLength.Value;
end;

procedure TFrameShapeLine.eAngleChange(Sender: TObject);
//var
//  rad: Single;
begin
  if Params = nil then
    Exit;

  Params.Shape.Value[1] := eAngle.Value;
end;

end.
