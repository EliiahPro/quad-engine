unit Frame.Color;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Vcl.StdCtrls, Vcl.ActnList,
  QuadFX, Vcl.ComCtrls, Vcl.ExtCtrls, Quad.GradientEdit, System.Generics.Collections;

type
  TFrameColor = class(TCustomParamFrame)
    pCaption: TPanel;
    lCaption: TLabel;
    pGradient: TPanel;
    GradientEdit: TQuadGradientEdit;
    procedure GradientEditItemChange(Sender: TObject;
      Color: TQuadGradientColorItem);
    procedure GradientEditItemDel(Sender: TObject;
      Color: TQuadGradientColorItem);
    procedure GradientEditItemAdd(Sender: TObject;
      Color: TQuadGradientColorItem);
  private
    FColorList: TList<TQuadGradientColorItem>;
  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
    destructor Destroy; override;
  end;

  TListItemColor = class(TCustomParamListItem)
  private
  public
    constructor CreateEx(AOwner: TListItems);
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
  end;

implementation

{$R *.dfm}

{ TListItemTextures }

constructor TListItemColor.CreateEx(AOwner: TListItems);
begin
  inherited CreateEx(AOwner);
  Caption := 'Color';
end;

function TListItemColor.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
begin
  Result := TFrameColor.CreateEx(AOwner, AParams);
end;

{ TFrameTextures }

constructor TFrameColor.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
var
  i: Integer;
begin
  FColorList := TList<TQuadGradientColorItem>.Create;
  inherited;
  GradientEdit.Colors.BeginUpdate;
  GradientEdit.Colors.Clear;

  for i := 0 to AParams.Particle.Color.Count - 1 do
    with GradientEdit.Colors.Add do
    begin
      Position := AParams.Particle.Color.List[i].Life;
      RGB := AParams.Particle.Color.List[i].Value;
    end;
  GradientEdit.Colors.EndUpdate;
end;

destructor TFrameColor.Destroy;
begin
  FColorList.Free;
  inherited;
end;

procedure TFrameColor.GradientEditItemAdd(Sender: TObject; Color: TQuadGradientColorItem);
begin
  if Length(Params.Particle.Color.List) = Params.Particle.Color.Count then
  begin
    SetLength(Params.Particle.Color.List, Params.Particle.Color.Count + 1);
    Params.Particle.Color.Count := Params.Particle.Color.Count + 1;
  end
  else
    Params.Particle.Color.Count := Params.Particle.Color.Count + 1;
  GradientEditItemChange(Sender, Color);
end;

procedure TFrameColor.GradientEditItemChange(Sender: TObject; Color: TQuadGradientColorItem);
var
  i, j: Integer;
  IsFind: Boolean;
begin
  FColorList.Clear;
  for i := 0 to GradientEdit.Count - 1 do
  begin
    IsFind := False;
    for j := 0 to FColorList.Count - 1 do
      if FColorList[j].Position > GradientEdit[i].Position then
      begin
        FColorList.Insert(j, GradientEdit[i]);
        IsFind := True;
        Break;
      end;
    if not IsFind then
      FColorList.Add(GradientEdit[i]);
  end;

  for i := 0 to FColorList.Count - 1 do
  begin
    Params.Particle.Color.List[i].Life := FColorList[i].Position;
    Params.Particle.Color.List[i].Value := FColorList[i].RGB;
  end;
end;

procedure TFrameColor.GradientEditItemDel(Sender: TObject; Color: TQuadGradientColorItem);
begin
  Params.Particle.Color.Count := Params.Particle.Color.Count - 1;
  GradientEditItemChange(Sender, Color);
end;

end.
