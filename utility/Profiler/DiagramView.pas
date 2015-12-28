unit DiagramView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Generics.Collections, System.Math,
  QuadEngine.Socket, DiagramLine, DiagramFrame;

type
  TProfilerInfo = packed record
    DateTime: Double;
    TagsCount: Byte;
  end;

  TDiagramView = class(TCategoryPanel)
  private
    class var FScale: Single;
  private
    FGUID: TGUID;
    FDiagram: TDiagram;
    FMaxValue: Double;
    FAddress: PQuadSocketAddressItem;
    FFrame: TfDiagramFrame;
  public
    class procedure SetScale(AScale: Single);
    constructor Create(APanelGroup: TCategoryPanelGroup; AAddress: PQuadSocketAddressItem; const AGUID: TGUID);
    destructor Destroy; override;
    procedure Write(AMemory: TMemoryStream);
    procedure UpdateInfo(ACode: Word; AMemory: TMemoryStream);
    procedure Repaint;

    property GUID: TGUID read FGUID;
  end;


implementation

{ TDiagramPanel }

uses Main;

{ TDiagramView }

class procedure TDiagramView.SetScale(AScale: Single);
begin
  FScale := AScale;
end;

constructor TDiagramView.Create(APanelGroup: TCategoryPanelGroup; AAddress: PQuadSocketAddressItem; const AGUID: TGUID);
begin
  inherited Create(APanelGroup.Parent);
  FFrame := TfDiagramFrame.Create(Self);
  FFrame.Parent := Self;

  PanelGroup := APanelGroup;
  Height := 150;
  FGUID := AGUID;
  Text := FGUID.ToString;
  FMaxValue := 0;
  FAddress := AAddress;

  FFrame.Diagram := TDiagram.Create(FFrame);
  FFrame.Diagram.Parent := FFrame.Panel;
  FFrame.Diagram.Align := alClient;
  FFrame.Diagram.Caption := '11';

  fMain.Socket.Clear;
  fMain.Socket.SetCode(2);
  fMain.Socket.Send(FAddress);
  //FDiagram.DoubleBuffered := True;
  //FImg.Frequency := 16;
end;

procedure TDiagramView.Write(AMemory: TMemoryStream);
var
  Time: Double;
  TagsCount: Word;
  i: Integer;
  ID, Code: Word;
  Line: TDiagramLine;
  Call: TAPICall;
begin
  if not Assigned(AMemory) then
    Exit;

  AMemory.Read(TagsCount, SizeOf(TagsCount));
  for i := 0 to TagsCount - 1 do
  begin
    AMemory.Read(ID, SizeOf(ID));
    AMemory.Read(Call, SizeOf(Call));
    Line := FFrame.FindLineByID(ID);
    if not Assigned(Line) then
    begin
      Line := FFrame.List.Items.Add as TDiagramLine;
      Line.Checked := True;
      Line.SetID(ID);
      fMain.Socket.Clear;
      fMain.Socket.SetCode(3);
      fMain.Socket.Write(ID, SizeOf(ID));
      fMain.Socket.Send(FAddress);
    end;
    Line.Add(Call);
  end;
end;

procedure TDiagramView.UpdateInfo(ACode: Word; AMemory: TMemoryStream);
var
  Str: WideString;
  StrLen: Byte;
  ID: Word;
  Line: TDiagramLine;
begin
  case ACode of
    2:
      begin
        AMemory.Read(StrLen, SizeOf(StrLen));
        SetLength(Str, StrLen);
        AMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));
        Caption := Str;
      end;
    3:
      begin
        AMemory.Read(ID, SizeOf(ID));
        Line := FFrame.FindLineByID(ID);
        if Assigned(Line) then
        begin
          AMemory.Read(StrLen, SizeOf(StrLen));
          SetLength(Str, StrLen);
          AMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));
          Line.Caption := Str;
        end;
      end;
  end;
end;

destructor TDiagramView.Destroy;
begin

  inherited;
end;

procedure TDiagramView.Repaint;
begin
//  FFrame.Diagram.Repaint;
  FFrame.Draw;
 // FFrame.Draw(FFrame.Diagram);
end;

(*
procedure TDiagramView.DiagramPaint(Sender: TObject);
var
  i, j: Integer;
  Points: array of TGPPointF;
  Count: Integer;
  ScaleY: Double;
  Time: Double;
  Ruler: Single;
  Graphics: TGPGraphics;
  Pen: TGPPen;
begin
  Ruler := Max(Ceil(FMaxValue * 10) / 10, 0.1);
  if FMaxValue > 0 then
    ScaleY := (FDiagram.Height - 10) / Ruler
  else
    ScaleY := 0;
         {
  if FCells.Count > 0 then
  begin
    Graphics := TGPGraphics.Create(FDiagram.Canvas.Handle);
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);

    Graphics.Clear($FF333333);
    Time := FCells[FCells.Count - 1].Time;
    Count := 0;
    for i := FCells.Count - 1 downto 0 do
      if (Time - FCells[i].Time) * FScale > FDiagram.Width then
      begin
        Count := FCells.Count - i;
        Break;
      end;

    if Count = 0 then
      Count := FCells.Count;

    SetLength(Points, Count);

    j := FCells.Count - 1;
    for i := 0 to Count - 1 do
    begin
      Points[i].X := FDiagram.Width - 32 - (Time - FCells[j].Time) * FScale;
      Points[i].Y := FDiagram.Height - 5 - FCells[j].Time * ScaleY;
      Dec(j);
    end;

    Pen := TGPPen.Create($FFAA4444, 2);
    try
      Graphics.DrawLines(Pen, PGPPointF(@Points[0]), Count);
    finally
      Pen.Free;
    end;
    Graphics.Free;
    {
    Canvas.Pen.Color := $00AA4444;
    Canvas.Pen.Width := 2;
    Canvas.Polyline(Points);    }
   // Canvas.Polygon(Points);
  end;
             {
  Rect.Width := 32;
  Rect.Height := 16;
  Rect.Left := FDiagram.Width - 30;
  Rect.Top := 5;
  Canvas.Fill.Color := TAlphaColorRec.Black;
  Canvas.FillText(Rect, Format('%f', [Ruler]), True, 255, [], TTextAlign.taLeading,TTextAlign.Leading);

  Rect.Top := FDiagram.Height - 21;
  Canvas.FillText(Rect, '0', True, 255, [], TTextAlign.taLeading,TTextAlign.Leading);
          }
end;
*)
initialization
  TDiagramView.SetScale(100);

end.
