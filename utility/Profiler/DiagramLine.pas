unit DiagramLine;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, GDIPAPI, GDIPOBJ,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Generics.Collections, System.Math,
  QuadEngine.Socket, Vcl.ComCtrls, QuadEngine.Profiler;

const
  CALL_BLOCK_COUNT = 1000;

type
  PAPICall = ^TAPICall;

  PDiagramLineCall = ^TDiagramLineCall;
  TDiagramLineCall = record
    Call: TAPICall;
    Next: PDiagramLineCall;
    Prev: PDiagramLineCall;
  end;

  TDiagramLine = class(TListItem)
  private
    FID: Word;

    FCall: PDiagramLineCall;
    FCursorCall: PDiagramLineCall;
    FCallBlockList: TList<PDiagramLineCall>;
    FCallCount: Integer;

    FMaxValue: Double;
    function CreateBlockCall: PDiagramLineCall;
    function GetCall: PAPICall;
  public
    constructor Create(AOwner: TListItems); override;
    destructor Destroy; override;
    procedure SetID(AID: Integer);
    procedure Add(const ACall: TAPICall);

    procedure First;
    procedure Next;
    property Call: PAPICall read GetCall;

    property ID: Word read FID;
    property Point: PDiagramLineCall read FCall;
    property PointCount: Integer read FCallCount;
    property MaxValue: Double read FMaxValue;
  end;

implementation

constructor TDiagramLine.Create(AOwner: TListItems);
begin
  inherited;
  FCall := nil;
  FCallBlockList := TList<PDiagramLineCall>.Create;
  FCallCount := 0;
  CreateBlockCall;
  SubItems.Add('0');
  FMaxValue := 0;
  FCursorCall := nil;
end;

destructor TDiagramLine.Destroy;
var
  CallBlock: PDiagramLineCall;
begin
  for CallBlock in FCallBlockList do
    FreeMem(CallBlock);
  FCallBlockList.Free;
  inherited;
end;

function TDiagramLine.CreateBlockCall: PDiagramLineCall;
begin
  GetMem(Result, SizeOf(TDiagramLineCall) * CALL_BLOCK_COUNT);
  FCallBlockList.Add(Result);
end;

procedure TDiagramLine.SetID(AID: Integer);
begin
  FID := AID;
end;

procedure TDiagramLine.Add(const ACall: TAPICall);
var
  Call: PDiagramLineCall;
begin
  if FCallCount mod CALL_BLOCK_COUNT = 0 then
    Call := CreateBlockCall
  else
    Call := Pointer(Integer(FCall) + SizeOf(TDiagramLineCall));

  Call.Next := nil;
  if FCall <> nil then
  begin
    Call.Prev := FCall;
    FCall.Next := Call;
  end
  else
    Call.Prev := nil;

  FCall := Call;
  FCall.Call := ACall;
  Inc(FCallCount);

  if FMaxValue < ACall.Value then
    FMaxValue := ACall.Value;

  SubItems[0] := IntToStr(FCallCount);
end;

procedure TDiagramLine.First;
begin
  FCursorCall := FCall;
end;

procedure TDiagramLine.Next;
begin
  if FCursorCall <> nil then
    FCursorCall := FCursorCall.Prev;
end;

function TDiagramLine.GetCall: PAPICall;
begin
  if FCursorCall <> nil then
    Exit(@FCursorCall.Call);
  Result := nil;
end;

end.
