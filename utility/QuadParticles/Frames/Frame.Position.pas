unit Frame.Position;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Quad.Diagram, Vcl.ComCtrls,
  Vcl.StdCtrls, FloatSpinEdit, Vcl.ExtCtrls, QuadFX;

type
  TFramePosition = class(TCustomParamFrame)
    FramePosition: TPanel;
    lCaption: TLabel;
    Panel1: TPanel;
    cbRandom: TCheckBox;
    cbCurve: TCheckBox;
    pValues: TPanel;
    lX: TLabel;
    lY: TLabel;
    eXMinValue: TFloatSpinEdit;
    eXMaxValue: TFloatSpinEdit;
    eYMaxValue: TFloatSpinEdit;
    eYMinValue: TFloatSpinEdit;
    dDiagram: TQuadDiagram;
    procedure cbRandomClick(Sender: TObject);
    procedure cbCurveClick(Sender: TObject);
    procedure eXMinValueChange(Sender: TObject);
    procedure eYMinValueChange(Sender: TObject);
    procedure eXMaxValueChange(Sender: TObject);
    procedure eYMaxValueChange(Sender: TObject);
    procedure dDiagramPointChange(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointAdd(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointDelete(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
  private
    function GetType: TQuadFXParamsType;
  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
  end;

  TListItemPosition = class(TCustomParamListItem)
  public
    constructor CreateEx(AOwner: TListItems);
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
  end;

implementation

{$R *.dfm}

{ TListItemPosition }

constructor TListItemPosition.CreateEx(AOwner: TListItems);
begin
  inherited CreateEx(AOwner);
  Caption := 'Position';
end;

function TListItemPosition.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
begin
  Result := TFramePosition.CreateEx(AOwner, AParams);
end;

{ TFramePosition }

constructor TFramePosition.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
begin
  inherited;
  if Params = nil then
    Exit;

  case Params.Position.X.ParamsType of
    qpptValue: ;
    qpptRandomValue:
      begin
        cbRandom.Checked := True;
        eXMaxValue.Visible := True;
        eYMaxValue.Visible := True;
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

  eXMinValue.Value := Params.Position.X.Value[0];
  eXMaxValue.Value := Params.Position.X.Value[1];
  eYMinValue.Value := Params.Position.Y.Value[0];
  eYMaxValue.Value := Params.Position.Y.Value[1];

  dDiagram.Style.RefreshSystemStyle;

  if Params.Position.X.ParamsType in [qpptCurve, qpptRandomCurve] then
  begin
    LoadDiagram(dDiagram.Lines[0], @Params.Position.X.Diagram[0]);
    LoadDiagram(dDiagram.Lines[1], @Params.Position.Y.Diagram[0]);
  end;
end;

procedure TFramePosition.dDiagramPointAdd(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  case ALine.Index of
    0: Diagram := @Params.Position.X.Diagram[0];
    1: Diagram := @Params.Position.Y.Diagram[0];
  end;
  Count := Diagram.Count + 1;
  SetLength(Diagram.List, Count);
  for i := Count - 2 downto APoint.Index do
    Diagram.List[i + 1] := Diagram.List[i];

  Diagram.List[APoint.Index].Value := APoint.Y;
  Diagram.List[APoint.Index].Life := APoint.X / 100;
  Diagram.Count := Count;
end;

procedure TFramePosition.dDiagramPointChange(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  param: PQuadFXParams;
begin
  case ALine.Index of
    0: param := @Params.Position.X;
    1: param := @Params.Position.Y;
  end;
  param.Diagram[0].List[APoint.Index].Value := APoint.Y;
  param.Diagram[0].List[APoint.Index].Life := APoint.X / 100;
end;

procedure TFramePosition.dDiagramPointDelete(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  case ALine.Index of
    0: Diagram := @Params.Position.X.Diagram[0];
    1: Diagram := @Params.Position.Y.Diagram[0];
  end;
  Count := Diagram.Count - 1;
  for i := APoint.Index to Count - 2 do
    Diagram.List[i] := Diagram.List[i + 1];

  SetLength(Diagram.List, Count);
  Diagram.Count := Count;
end;

procedure TFramePosition.eXMaxValueChange(Sender: TObject);
begin
  if Params <> nil then
    Params.Position.X.Value[1] := eXMaxValue.Value;
end;

procedure TFramePosition.eXMinValueChange(Sender: TObject);
begin
  if Params <> nil then
    Params.Position.X.Value[0] := eXMinValue.Value;
end;

procedure TFramePosition.eYMaxValueChange(Sender: TObject);
begin
  if Params <> nil then
    Params.Position.Y.Value[1] := eYMaxValue.Value;
end;

procedure TFramePosition.eYMinValueChange(Sender: TObject);
begin
  if Params <> nil then
    Params.Position.Y.Value[0] := eYMinValue.Value;
end;

function TFramePosition.GetType: TQuadFXParamsType;
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

procedure TFramePosition.cbCurveClick(Sender: TObject);
begin
  inherited;
  Params.Position.X.ParamsType := GetType;
  Params.Position.Y.ParamsType := GetType;

  pValues.Visible := not cbCurve.Checked;
  dDiagram.Visible := cbCurve.Checked;

  if Params.Position.X.Diagram[0].Count = 0 then
  begin
    Params.Position.X.Diagram[0].Count := 1;
    SetLength(Params.Position.X.Diagram[0].List, 1);
  end;

  if Params.Position.Y.Diagram[0].Count = 0 then
  begin
    Params.Position.Y.Diagram[0].Count := 1;
    SetLength(Params.Position.Y.Diagram[0].List, 1);
  end;
end;

procedure TFramePosition.cbRandomClick(Sender: TObject);
begin
  inherited;
  eXMaxValue.Visible := cbRandom.Checked;
  eYMaxValue.Visible := cbRandom.Checked;
end;

end.
