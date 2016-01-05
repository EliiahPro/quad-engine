unit Frame.Custom;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  QuadFX, Vcl.ActnList, Quad.Diagram;

type
  TCustomParamFrame = class(TFrame)
  private
    FParams: PQuadFXEmitterParams;
  protected
    function ValueConvert(AValue: Single): Single; virtual;
  public
    constructor CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
    procedure LoadDiagram(ALine: TQuadDiagramLineItem; APoints: PQuadFXSingleDiagram);
    property Params: PQuadFXEmitterParams read FParams;
  end;

  TCustomParamListItem = class(TListItem)
  public
    constructor CreateEx(AOwner: TListItems); virtual;
    destructor Destroy; override;

    function CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame; virtual;
  end;

implementation

{$R *.dfm}

{ TCustomParamListItem }

constructor TCustomParamListItem.CreateEx(AOwner: TListItems);
begin
  inherited Create(AOwner);
  AOwner.AddItem(Self);
  ImageIndex := -1;
  StateIndex := -1;
end;

destructor TCustomParamListItem.Destroy;
begin
  inherited;
end;

function TCustomParamListItem.CreateFrame(AOwner: TComponent; AParams: PQuadFXEmitterParams): TCustomParamFrame;
begin
  Result := nil;
end;

{ TCustomParamFrame }

constructor TCustomParamFrame.CreateEx(AOwner: TComponent; AParams: PQuadFXEmitterParams);
begin
  inherited Create(AOwner);
  FParams := AParams;
  Align := alClient;
end;

function TCustomParamFrame.ValueConvert(AValue: Single): Single;
begin
  Result := AValue;
end;

procedure TCustomParamFrame.LoadDiagram(ALine: TQuadDiagramLineItem; APoints: PQuadFXSingleDiagram);
var
  i: Integer;
begin
  if not Assigned(ALine) or (APoints = nil) then
    Exit;

  ALine.Points.Clear;
  for i := 0 to APoints.Count - 1 do
    with ALine.Points.Add do
    begin
      Point.X := APoints.List[i].Life * 100;
      Point.Y := ValueConvert(APoints.List[i].Value);
    end;
end;

end.
