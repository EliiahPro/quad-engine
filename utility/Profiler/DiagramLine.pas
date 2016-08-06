unit DiagramLine;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, GDIPAPI, GDIPOBJ,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Generics.Collections, System.Math,
  QuadEngine.Socket, Vcl.ComCtrls, QuadEngine.Profiler;

const
  CALL_BLOCK_COUNT = 10000;

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
var
  Call: PDiagramLineCall;
  Size: Integer;
  i: Integer;
begin
  Size := SizeOf(TDiagramLineCall);
  GetMem(Result, Size * CALL_BLOCK_COUNT);
  Call := Result;
  for i := 0 to CALL_BLOCK_COUNT - 1 do
  begin
    if i > 0 then
      Call.Prev := Pointer(Integer(Call) - Size)
    else
      Call.Prev := nil;

    if i < CALL_BLOCK_COUNT - 1 then
      Call.Next := Pointer(Integer(Call) + Size)
    else
      Call.Next := nil;
    Inc(Call);
  end;

  if FCallBlockList.Count > 0 then
  begin
    Call := Pointer(Integer(FCallBlockList[FCallBlockList.Count - 1]) + Size * (CALL_BLOCK_COUNT - 1));
    Result.Prev := Call;
    Call.Next := Result;
  end;
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
  if FCall = nil then
    FCall := FCallBlockList[0];

  if FCall.Next = nil then
    CreateBlockCall;

  if FCallCount > 0 then
    FCall := FCall.Next;
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
