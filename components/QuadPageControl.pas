unit QuadPageControl;

interface

uses
  Classes, SysUtils, Windows, Graphics, Controls, ExtCtrls, Messages;

type
  TQuadPage = class
  private
    FCaption: String;
    FHint: String;
    FOnSelect: TNotifyEvent;
  public
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
  end;

  TQuadPageControl = class(TCustomPanel)
  public
    constructor Create(AOwner: TComponent); override;
    
  end;

implementation

{ TQuadPageControl }

constructor TQuadPageControl.Create(AOwner: TComponent);
begin
  inherited;
  Align := alTop;
  Caption := '';
  BevelOuter := bvNone;
  Color := $00353535;
  Height := 93;
  Font.Name := 'Segoe UI';
end;

end.
 