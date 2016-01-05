unit Frame.Globals;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Vcl.StdCtrls, Vcl.ComCtrls,
  FloatSpinEdit, QuadFX, TypInfo, QuadEngine;

type
  TFrameGlobals = class(TCustomParamFrame)
    cbLoop: TCheckBox;
    seTimeFrom: TFloatSpinEdit;
    seTimeTo: TFloatSpinEdit;
    lTimeFrom: TLabel;
    lTimeTo: TLabel;
    lCaption: TLabel;
    seMaxParticles: TFloatSpinEdit;
    lMaxParticles: TLabel;
    lBlendMode: TLabel;
    cbBlendMode: TComboBox;
    procedure cbLoopClick(Sender: TObject);
    procedure seTimeFromChange(Sender: TObject);
    procedure seTimeToChange(Sender: TObject);
    procedure seMaxParticlesChange(Sender: TObject);
    procedure cbBlendModeChange(Sender: TObject);
  private

  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
    property Params;
  end;

  TListItemGlobals = class(TCustomParamListItem)
  public
    constructor CreateEx(AOwner: TListItems);
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
  end;

implementation

{$R *.dfm}

uses Main;

{ TListItemGlobals }

constructor TListItemGlobals.CreateEx(AOwner: TListItems);
begin
  inherited CreateEx(AOwner);
  Caption := 'Globals';
end;

function TListItemGlobals.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
begin
  Result := TFrameGlobals.CreateEx(AOwner, AParams);
end;


{ TFrameGlobals }

procedure TFrameGlobals.cbBlendModeChange(Sender: TObject);
begin
  if Params = nil then
    Exit;

  Params.BlendMode := TQuadBlendMode(cbBlendMode.ItemIndex + 1);
end;

procedure TFrameGlobals.cbLoopClick(Sender: TObject);
begin
  if Params = nil then
    Exit;

  Params.IsLoop := cbLoop.Checked;
  fMain.EmitterSelected.TimeLine.Loop := cbLoop.Checked;
end;

constructor TFrameGlobals.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
var
  BlendMode: TQuadBlendMode;
begin
  inherited;
  if Params = nil then
    Exit;

  cbBlendMode.Clear;
  for BlendMode := Low(TQuadBlendMode) to High(TQuadBlendMode) do
    if BlendMode <> qbmInvalid then
      cbBlendMode.Items.Add(GetEnumName(TypeInfo(TQuadBlendMode), Integer(BlendMode)));

  cbLoop.Checked := Params.IsLoop;
  seTimeFrom.Value := Params.BeginTime;
  seTimeTo.Value := Params.EndTime;
  seMaxParticles.Value := Params.MaxParticles;
  cbBlendMode.ItemIndex := Integer(Params.BlendMode) - 1;
end;

procedure TFrameGlobals.seMaxParticlesChange(Sender: TObject);
begin
  if Params = nil then
    Exit;

  Params.MaxParticles := Round(seMaxParticles.Value);
end;

procedure TFrameGlobals.seTimeFromChange(Sender: TObject);
begin
  if Params = nil then
    Exit;

  Params.BeginTime := seTimeFrom.Value;
  fMain.EmitterSelected.TimeLine.TimeFrom := seTimeFrom.Value;
end;

procedure TFrameGlobals.seTimeToChange(Sender: TObject);
begin
  if Params = nil then
    Exit;

  Params.EndTime := seTimeTo.Value;
  fMain.EmitterSelected.TimeLine.TimeTo := seTimeTo.Value;
end;

end.


