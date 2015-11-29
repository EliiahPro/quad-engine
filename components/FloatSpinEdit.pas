unit FloatSpinEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TSpinUpDown = class(TUpDown)

  end;

  TFloatSpinEdit = class(TCustomEdit)
  private
    FValue: Extended;
    FIncrement: Extended;
    FUpDown: TUpDown;

    procedure SetValue(const AValue: Extended);
    procedure UpDownChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Integer; Direction: TUpDownDirection);
  protected
    procedure KeyPress(var Key: Char); override;
    procedure Change; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Visible;
    property OnChange;

    property Value: Extended read FValue write SetValue;// default 0;
    property Increment: Extended read FIncrement write FIncrement;// default 0.05;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Quad', [TFloatSpinEdit]);
end;

{ TFloatSpinEdit }

constructor TFloatSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIncrement := 0.05;
  FUpDown := TUpDown.Create(Self);
  FUpDown.Min := -1;
  FUpDown.OnChangingEx := UpDownChangingEx;
  FUpDown.Parent := Self;
  FUpDown.Align := alRight;

  FValue := 0;
  Text := Format('%f', [FValue]);
end;

procedure TFloatSpinEdit.SetParent(AParent: TWinControl);
begin
  inherited;
end;

destructor TFloatSpinEdit.Destroy;
begin
  inherited;
end;

procedure TFloatSpinEdit.UpDownChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Integer; Direction: TUpDownDirection);
var
  Sel: Integer;
begin
  Sel := SelStart;
  AllowChange := False;
  case Direction of
    updUp: FValue := FValue + FIncrement;
    updDown: FValue := FValue - FIncrement;
  end;
  Text := Format('%f', [FValue]);
  SelStart := Sel;
end;

procedure TFloatSpinEdit.SetValue(const AValue: Extended);
begin
  FValue := AValue;
  Text := Format('%f', [FValue]);
end;

procedure TFloatSpinEdit.KeyPress(var Key: Char);
begin
  if CharInSet(Key, [',', '.']) then
    Key := FormatSettings.DecimalSeparator;

  case Key of
    '-':
      if (SelStart <> 0) or (Pos('-', Text) <> 0) then
        key := #0;
    ',', '.':
      if (Text <> '') and (Pos(Key, Text) <> 0) then
        key := #0;
    #1..#31, '0'..'9', {#8, #9, #13, #27,} #127:;
    else key := #0;
  end;
  inherited KeyPress(Key);
end;

procedure TFloatSpinEdit.Change;
begin
  FValue := StrToFloatDef(Text, 13);
  inherited;
end;

end.
