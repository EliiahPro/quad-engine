unit Frame.Value;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Vcl.ComCtrls, Vcl.StdCtrls,
  QuadFX, Vcl.ActnList, Quad.Diagram, Vcl.ExtCtrls, FloatSpinEdit;

type
  TFrameValue = class(TCustomParamFrame)
    dDiagram: TQuadDiagram;
    Panel1: TPanel;
    cbRandom: TCheckBox;
    cbCurve: TCheckBox;
    pCaption: TPanel;
    lCaption: TLabel;
    pValues: TPanel;
    eMinValue: TFloatSpinEdit;
    eMaxValue: TFloatSpinEdit;
    procedure cbRandomClick(Sender: TObject);
    procedure cbCurveClick(Sender: TObject);
    procedure dDiagramPointChange(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointAdd(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure dDiagramPointDelete(ADiagram: TQuadDiagram;
      ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
    procedure eMinValueChange(Sender: TObject);
    procedure eMaxValueChange(Sender: TObject);
  private
    FParams: PQuadFXParams;
    function GetType: TQuadFXParamsType;
  protected
    property Params: PQuadFXParams read FParams;
  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXParams);
    procedure SetLife(ALife: Double); override;
  end;

  TListItemValue = class(TCustomParamListItem)

  end;

  TListItemEmission = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

  TListItemScale = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

  TListItemStartAngle = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

  TListItemSpin = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

  TListItemOpacity = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

  TListItemStartVelocity = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

  TListItemVelocity = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

  TListItemLifeTime = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

  TListItemGravitation = class(TListItemValue)
  public
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
    constructor CreateEx(AOwner: TListItems); override;
  end;

implementation

{$R *.dfm}

{ TListItemValue }

{ TListItemEmission }

constructor TListItemEmission.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Emission';
end;

function TListItemEmission.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Emission);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', count';
  Axis.Format := '0';
  Axis.GridSize := 100;
  Axis.MaxValue := 300;
  Axis.LowMax := 300;
  Axis.HighMax := 5000;
  Axis.MinValue := 0;
  Axis.LowMin := 0;
  Axis.HighMin := 0;
end;

{ TListItemStartAngle }

constructor TListItemStartAngle.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Start Angle';
end;


function TListItemStartAngle.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Particle.StartAngle);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', Grad';
  Axis.Format := '0';
  Axis.GridSize := 45;
  Axis.MaxValue := 360;
  Axis.LowMax := 360;
  Axis.HighMax := 360;
  Axis.MinValue := 0;
  Axis.LowMin := 0;
  Axis.HighMin := 0;
end;

{ TListItemSpin }

constructor TListItemSpin.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Spin';
end;


function TListItemSpin.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Particle.Spin);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', %';
  Axis.Format := '0.00';
  Axis.GridSize := 1;
  Axis.MaxValue := 5;
  Axis.LowMax := 5;
  Axis.HighMax := 40;
  Axis.MinValue := 0;
  Axis.LowMin := 0;
  Axis.HighMin := 0;
end;

{ TListItemOpacity }

constructor TListItemOpacity.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Opacity';
end;


function TListItemOpacity.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Particle.Opacity);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', %';
  Axis.Format := '0.00';
  Axis.GridSize := 0.25;
  Axis.MaxValue := 1;
  Axis.LowMax := 1;
  Axis.HighMax := 1;
  Axis.MinValue := 0;
  Axis.LowMin := 0;
  Axis.HighMin := 0;
end;

{ TListItemScale }

constructor TListItemScale.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Scale';
end;


function TListItemScale.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Particle.Scale);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', %';
  Axis.Format := '0.00';
  Axis.GridSize := 1;
  Axis.MaxValue := 5;
  Axis.LowMax := 5;
  Axis.HighMax := 20;
  Axis.MinValue := 0;
  Axis.LowMin := 0;
  Axis.HighMin := 0;
end;

{ TListItemVelocity }

constructor TListItemVelocity.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Velocity';
end;


function TListItemVelocity.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Particle.Velocity);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', %';
  Axis.Format := '0.00';
  Axis.GridSize := 1;
  Axis.MaxValue := 5;
  Axis.LowMax := 5;
  Axis.HighMax := 20;
  Axis.MinValue := -5;
  Axis.LowMin := -5;
  Axis.HighMin := -20;
end;

{ TListItemStartVelocity }

constructor TListItemStartVelocity.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Start Velocity';
end;


function TListItemStartVelocity.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Particle.StartVelocity);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', px/sec';
  Axis.Format := '0';
  Axis.GridSize := 100;
  Axis.MaxValue := 300;
  Axis.LowMax := 300;
  Axis.HighMax := 2000;
  Axis.MinValue := 0;
  Axis.LowMin := 0;
  Axis.HighMin := 0;
end;

{ TListItemScale }

constructor TListItemLifeTime.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Life Time';
end;


function TListItemLifeTime.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Particle.LifeTime);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', second';
  Axis.Format := '0.00';
  Axis.GridSize := 1;
  Axis.MaxValue := 5;
  Axis.LowMax := 5;
  Axis.HighMax := 20;
  Axis.MinValue := 0;
  Axis.LowMin := 0;
  Axis.HighMin := 0;
end;

{ TListItemGravitation }

constructor TListItemGravitation.CreateEx(AOwner: TListItems);
begin
  inherited;
  Caption := 'Gravitation';
end;

function TListItemGravitation.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
var
  Axis: TQuadDiagramAxis;
begin
  Result := TFrameValue.CreateEx(AOwner, @AParams.Particle.Gravitation);
  TFrameValue(Result).lCaption.Caption := Caption;
  Axis := TFrameValue(Result).dDiagram.AxisV;
  Axis.Name := Caption + ', px/sec';
  Axis.Format := '0';
  Axis.GridSize := 100;
  Axis.MaxValue := 300;
  Axis.LowMax := 300;
  Axis.HighMax := 2000;
  Axis.MinValue := 0;
  Axis.LowMin := 0;
  Axis.HighMin := 0;
end;

{ TFrameValue }

constructor TFrameValue.CreateEx(AOwner: TComponent; AParams: PQuadFXParams);
begin
  inherited CreateEx(AOwner, nil);
  FParams := AParams;

  if FParams = nil then
    Exit;

  case FParams.ParamsType of
    qpptValue: ;
    qpptRandomValue:
      begin
        cbRandom.Checked := True;
        eMaxValue.Visible := True;
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

  eMinValue.Value := FParams.Value[0];
  eMaxValue.Value := FParams.Value[1];

  dDiagram.Style.RefreshSystemStyle;

  if FParams.ParamsType in [qpptCurve, qpptRandomCurve] then
    LoadDiagram(dDiagram.Lines[0], @FParams.Diagram[0]);

  if FParams.ParamsType = qpptRandomCurve then
  begin
    with dDiagram.Lines.Add do
    begin
      Width := 2;
      Color := clGreen;
    end;
    LoadDiagram(dDiagram.Lines[1], @FParams.Diagram[1]);
  end;
end;

procedure TFrameValue.SetLife(ALife: Double);
var
  Position: Double;
begin
  Position := ALife * 100;
  if (Position >= 0) or (Position <= 100) then
    dDiagram.Position := Position
  else
    dDiagram.Position := -1;
end;

procedure TFrameValue.dDiagramPointAdd(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  Diagram := @FParams.Diagram[ALine.Index];
  Count := Diagram.Count + 1;
  SetLength(Diagram.List, Count);
  for i := Count - 2 downto APoint.Index do
    Diagram.List[i + 1] := Diagram.List[i];

  Diagram.List[APoint.Index].Value := APoint.Y;
  Diagram.List[APoint.Index].Life := APoint.X / 100;
  Diagram.Count := Count;
end;

procedure TFrameValue.dDiagramPointChange(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
begin
  FParams.Diagram[ALine.Index].List[APoint.Index].Value := APoint.Y;
  FParams.Diagram[ALine.Index].List[APoint.Index].Life := APoint.X / 100;
end;

procedure TFrameValue.dDiagramPointDelete(ADiagram: TQuadDiagram; ALine: TQuadDiagramLineItem; APoint: TQuadDiagramLinePointItem);
var
  i, Count: Integer;
  Diagram: PQuadFXSingleDiagram;
begin
  Diagram := @FParams.Diagram[ALine.Index];
  Count := Diagram.Count - 1;
  for i := APoint.Index to Count - 2 do
    Diagram.List[i] := Diagram.List[i + 1];

  SetLength(Diagram.List, Count);
  Diagram.Count := Count;
end;

function TFrameValue.GetType: TQuadFXParamsType;
begin
  Result := qpptValue;
  if FParams = nil then
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

procedure TFrameValue.eMaxValueChange(Sender: TObject);
begin
  if FParams <> nil then
    FParams.Value[1] := eMaxValue.Value;
end;

procedure TFrameValue.eMinValueChange(Sender: TObject);
begin
  if FParams <> nil then
    FParams.Value[0] := eMinValue.Value;
end;

procedure TFrameValue.cbCurveClick(Sender: TObject);
begin
  inherited;
  pValues.Visible := not cbCurve.Checked;
  dDiagram.Visible := cbCurve.Checked;

  if Params.Diagram[0].Count = 0 then
  begin
    Params.Diagram[0].Count := 1;
    SetLength(Params.Diagram[0].List, 1);
    Params.Diagram[0].List[0].Value := eMinValue.Value;
  end;
  Params.ParamsType := GetType;
end;

procedure TFrameValue.cbRandomClick(Sender: TObject);
begin
  eMaxValue.Visible := cbRandom.Checked;
  eMaxValue.Value := eMinValue.Value;
  Params.ParamsType := GetType;
end;

end.
