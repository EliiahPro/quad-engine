unit Frame.DirectionSpread;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Vcl.StdCtrls, Vcl.ComCtrls,
  Quad.Diagram, FloatSpinEdit, Vcl.ExtCtrls, QuadFX;

type
  TFrameDirectionSpread = class(TCustomParamFrame)
    FramePosition: TPanel;
    lCaption: TLabel;
    pValues: TPanel;
    lDirection: TLabel;
    lSpread: TLabel;
    dDiagram: TQuadDiagram;
    Panel1: TPanel;
    cbRandom: TCheckBox;
    cbCurve: TCheckBox;
    eDirectionMinValue: TFloatSpinEdit;
    eSpreadMinValue: TFloatSpinEdit;
    eSpreadMaxValue: TFloatSpinEdit;
    eDirectionMaxValue: TFloatSpinEdit;
    procedure cbCurveClick(Sender: TObject);
    procedure cbRandomClick(Sender: TObject);
    procedure eDirectionMinValueChange(Sender: TObject);
    procedure eDirectionMaxValueChange(Sender: TObject);
    procedure eSpreadMinValueChange(Sender: TObject);
    procedure eSpreadMaxValueChange(Sender: TObject);
    procedure dDiagramPointChange(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointAdd(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointDelete(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
  private
    function GetType: TQuadFXParamsType;
    function ValueConvert(AValue: Single): Single; override;
  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
  end;

  TListItemDirectionSpread = class(TCustomParamListItem)
  public
    constructor CreateEx(AOwner: TListItems);
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
  end;

implementation

uses
  Math;

{$R *.dfm}

{ TListItemDirectionSpread }

constructor TListItemDirectionSpread.CreateEx(AOwner: TListItems);
begin
  inherited CreateEx(AOwner);
  Caption := 'Direction and Spread';
end;

function TListItemDirectionSpread.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
begin
  Result := TFrameDirectionSpread.CreateEx(AOwner, AParams);
end;

{ TFrameDirectionSpread }

function TFrameDirectionSpread.ValueConvert(AValue: Single): Single;
begin
  Result := RadToDeg(AValue);
end;

procedure TFrameDirectionSpread.cbRandomClick(Sender: TObject);
begin
  eDirectionMaxValue.Visible := cbRandom.Checked;
  eSpreadMaxValue.Visible := cbRandom.Checked;
end;

constructor TFrameDirectionSpread.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
begin
  inherited;
  if Params = nil then
    Exit;

  case Params.Direction.ParamsType of
    qpptValue: ;
    qpptRandomValue:
      begin
        cbRandom.Checked := True;
        eDirectionMaxValue.Visible := True;
        eSpreadMaxValue.Visible := True;
      end;
    qpptCurve:
      begin
        cbCurve.Checked := True;
        pValues.Visible := False;
        dDiagram.Visible := True;
      end;
    qpptRandomCurve:
      begin
        cbCurve.Checked := True;
        cbRandom.Checked := True;
        pValues.Visible := False;
        dDiagram.Visible := True;
      end;
  end;

  eDirectionMinValue.Value := RadToDeg(Params.Direction.Value[0]);
  eDirectionMaxValue.Value := RadToDeg(Params.Direction.Value[1]);
  eSpreadMinValue.Value := RadToDeg(Params.Spread.Value[0]);
  eSpreadMaxValue.Value := RadToDeg(Params.Spread.Value[1]);

  dDiagram.Style.RefreshSystemStyle;

  if Params.Direction.ParamsType in [qpptCurve, qpptRandomCurve] then
  begin
    LoadDiagram(dDiagram.Lines[0], @Params.Direction.Diagram[0]);
    LoadDiagram(dDiagram.Lines[1], @Params.Spread.Diagram[0]);
  end;
end;

procedure TFrameDirectionSpread.dDiagramPointAdd(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  case ALine.Index of
    0: Diagram := @Params.Direction.Diagram[0];
    1: Diagram := @Params.Spread.Diagram[0];
  end;
  Count := Diagram.Count + 1;
  SetLength(Diagram.List, Count);
  for i := Count - 2 downto APoint.Index do
    Diagram.List[i + 1] := Diagram.List[i];

  Diagram.List[APoint.Index].Value := APoint.Point.Y;
  Diagram.List[APoint.Index].Life := APoint.Point.X / 100;
  Diagram.Count := Count;
end;

procedure TFrameDirectionSpread.dDiagramPointChange(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  param: PQuadFXParams;
begin
  case ALine.Index of
    0: param := @Params.Direction;
    1: param := @Params.Spread;
  end;
  param.Diagram[0].List[APoint.Index].Value := DegToRad(APoint.Point.Y);
  param.Diagram[0].List[APoint.Index].Life := APoint.Point.X / 100;
end;

procedure TFrameDirectionSpread.dDiagramPointDelete(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  case ALine.Index of
    0: Diagram := @Params.Direction.Diagram[0];
    1: Diagram := @Params.Spread.Diagram[0];
  end;
  Count := Diagram.Count - 1;
  for i := APoint.Index to Count - 2 do
    Diagram.List[i] := Diagram.List[i + 1];

  SetLength(Diagram.List, Count);
  Diagram.Count := Count;
end;

function TFrameDirectionSpread.GetType: TQuadFXParamsType;
begin
  Result := qpptValue;
  if Params = nil then
    Exit;

  if cbCurve.Checked and cbRandom.Checked then
    Result := qpptRandomCurve
  else
    if cbCurve.Checked then
      Result := qpptCurve
    else
      if cbRandom.Checked then
        Result := qpptRandomValue;
end;

procedure TFrameDirectionSpread.eDirectionMaxValueChange(Sender: TObject);
begin
  if Params <> nil then
    Params.Direction.Value[1] := DegToRad(eDirectionMaxValue.Value);
end;

procedure TFrameDirectionSpread.eDirectionMinValueChange(Sender: TObject);
begin
  if Params <> nil then
    Params.Direction.Value[0] := DegToRad(eDirectionMinValue.Value);
end;

procedure TFrameDirectionSpread.eSpreadMaxValueChange(Sender: TObject);
begin
  if Params <> nil then
    Params.Spread.Value[1] := DegToRad(eSpreadMaxValue.Value);
end;

procedure TFrameDirectionSpread.eSpreadMinValueChange(Sender: TObject);
begin
  if Params <> nil then
    Params.Spread.Value[0] := DegToRad(eSpreadMinValue.Value);
end;

procedure TFrameDirectionSpread.cbCurveClick(Sender: TObject);
begin
  Params.Direction.ParamsType := GetType;
  Params.Spread.ParamsType := GetType;

  pValues.Visible := not cbCurve.Checked;
  dDiagram.Visible := cbCurve.Checked;

  if Params.Direction.Diagram[0].Count = 0 then
  begin
    Params.Direction.Diagram[0].Count := 1;
    SetLength(Params.Direction.Diagram[0].List, 1);
  end;

  if Params.Spread.Diagram[0].Count = 0 then
  begin
    Params.Spread.Diagram[0].Count := 1;
    SetLength(Params.Spread.Diagram[0].List, 1);
  end;
end;

end.
