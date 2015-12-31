unit DiagramLine;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, GDIPAPI, GDIPOBJ,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Generics.Collections, System.Math,
  QuadEngine.Socket, Vcl.ComCtrls, QuadEngine.Profiler;

type
  PAPICall = ^TAPICall;

  TDiagramLine = class(TListItem)
  private
    FID: Word;
    FValues: TList<TAPICall>;
    FMaxValue: Double;
    FBeginIndex: Integer;
    FEndIndex: Integer;
    function GetValue(Index: Integer): TAPICall;
    function GetValueCount: Integer;
    function GetTime: TDateTime;
  public
    constructor Create(AOwner: TListItems); override;
    destructor Destroy; override;
    procedure SetID(AID: Integer);
    procedure Add(const ACall: TAPICall);

    property ID: Word read FID;
    property Values[Index: Integer]: TAPICall read GetValue; default;
    property ValueCount: Integer read GetValueCount;
    property MaxValue: Double read FMaxValue;
    property Time: TDateTime read GetTime;
    property BeginIndex: Integer read FBeginIndex;
    property EndIndex: Integer read FEndIndex;
  end;

implementation

constructor TDiagramLine.Create(AOwner: TListItems);
begin
  inherited;

  FValues := TList<TAPICall>.Create;
  SubItems.Add('0');
  FMaxValue := 0;
  FBeginIndex := 0;
  FEndIndex := 0;
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

  if FMaxValue < ACall.Value then
    FMaxValue := ACall.Value;

  SubItems[0] := IntToStr(FValues.Count);
end;

function TDiagramLine.GetValue(Index: Integer): TAPICall;
begin
  Result := FValues[Index];
end;

function TDiagramLine.GetValueCount: Integer;
begin
  Result := FValues.Count;
end;

function TDiagramLine.GetTime: TDateTime;
begin
  Result := FValues[FValues.Count - 1].Time;
end;

end.
