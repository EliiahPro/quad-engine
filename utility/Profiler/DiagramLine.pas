unit DiagramLine;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, GDIPAPI, GDIPOBJ,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Generics.Collections, System.Math,
  QuadEngine.Socket, Vcl.ComCtrls;

type
  TAPICall = record
    Time: TDateTime;
    Value: Double;
    Cound: Integer;
    MaxValue: Double;
    MinValue: Double;
  end;

  TDiagramLine = class(TListItem)
  private
    FID: Word;
    FValues: TList<TAPICall>;
    MaxValue: Double;
    MinValue: Double;
  public
    constructor Create(AOwner: TListItems); override;
    destructor Destroy; override;
    procedure SetID(AID: Integer);
    procedure Add(const ACall: TAPICall);

    property ID: Word read FID;
  end;

implementation

constructor TDiagramLine.Create(AOwner: TListItems);
begin
  inherited;
  FValues := TList<TAPICall>.Create;
  SubItems.Add('0');
end;

destructor TDiagramLine.Destroy;
begin
  FValues.Free;
  inherited;
end;

procedure TDiagramLine.SetID(AID: Integer);
begin
  FID := AID;
end;

procedure TDiagramLine.Add(const ACall: TAPICall);
begin
  FValues.Add(ACall);
  SubItems[0] := FValues.Count.ToString;
end;

end.
