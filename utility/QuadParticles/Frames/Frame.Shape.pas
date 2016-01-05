unit Frame.Shape;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frame.Custom, Vcl.StdCtrls, Vcl.ActnList,
  QuadFX, Vcl.ComCtrls, Vec2f, Frame.Shape.Line,
  Vcl.ExtCtrls, Frame.Shape.Circle, Frame.Shape.Rect;

type
  TFrameShape = class(TCustomParamFrame)
    Panel1: TPanel;
    cbShapeType: TComboBox;
    pCaption: TPanel;
    lCaption: TLabel;
    procedure cbShapeTypeChange(Sender: TObject);
  private
    FFrame: TFrame;
    procedure ChangeType;
  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
  end;

  TListItemShape = class(TCustomParamListItem)
  private
  public
    constructor CreateEx(AOwner: TListItems);
    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; override;
  end;

implementation

uses
  Math;

{$R *.dfm}

{ TListItemShape }

constructor TListItemShape.CreateEx(AOwner: TListItems);
begin
  inherited CreateEx(AOwner);
  Caption := 'Shape';
end;

function TListItemShape.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
begin
  Result := TFrameShape.CreateEx(AOwner, AParams);
end;

{ TFrameShape }

constructor TFrameShape.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
begin
  inherited;
  cbShapeType.ItemIndex := Integer(AParams.Shape.ShapeType);

  ChangeType;
end;

procedure TFrameShape.ChangeType;
begin
 if Params = nil then
    Exit;

  if Assigned(FFrame) then
    FFrame.Free;

  Params.Shape.ShapeType := TQuadFXEmitterShapeType(cbShapeType.ItemIndex);

  case Params.Shape.ShapeType of
    qeftPoint: ;
    qeftLine:
      begin
        FFrame := TFrameShapeLine.CreateEx(Self, Params);
      end;
    qeftCircle:
      begin
        FFrame := TFrameShapeCircle.CreateEx(Self, Params);
      end;
    qeftRect:
      begin
        FFrame := TFrameShapeRect.CreateEx(Self, Params);
      end;
  end;
end;

procedure TFrameShape.cbShapeTypeChange(Sender: TObject);
begin
  inherited;
  if Params = nil then
    Exit;

  if Params.Shape.ShapeType <> TQuadFXEmitterShapeType(cbShapeType.ItemIndex) then
    ChangeType;
end;

end.
