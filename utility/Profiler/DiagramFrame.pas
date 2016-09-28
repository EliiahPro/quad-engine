unit DiagramFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Math,
  Vcl.ExtCtrls, Vcl.ComCtrls, DiagramLine, GDIPAPI, GDIPOBJ, QuadEngine.Socket,
  QuadEngine.Profiler, QuadEngine;

type
  TDiagram = class(TPanel)
  private
    const PADDING: TRect = (Left: 8; Top: 8; Right: 32; Bottom: 16);
    const LINE_COLOR: array[0..12] of Cardinal = (
      $00d99593,
      $00538dd4,
      $00948954,
      $00c4d69c,
      $00b1a1c7,
      $0093cddb,
      $00fabe91,
      $0096b4d6,
      $00ff0000,
      $00f59547,
      $00ffff00,
      $00cc3399,
      $0000FF00
    );
  private
    FOnPaint: TNotifyEvent;
    FBitMap: TBitMap;
    FOldTime: TDateTime;

    FIsRepaint: Boolean;
    FIsRemath: Boolean;

    FMaxValue: Single;
    FScaleY: Single;

    FGraphics: TGPGraphics;
    FPen: TGPPen;
    FBrush: TGPSolidBrush;
    FFontFormat: TGPStringFormat;
    FFont: TGPFont;
    FFontFamily: TGPFontFamily;
    procedure ReInit;
    procedure ReMath;
    procedure DrawDiagram;
    procedure SetMaxValue(Value: Single);
  protected
    procedure Paint; override;
    procedure Resize; override;
  public
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property Canvas;
  published
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DoubleBuffered;

    property MaxValue: Single read FMaxValue write SetMaxValue;
  end;

  TfDiagramForm = class(TFrame)
    Panel: TPanel;
    Scroll: TScrollBar;
    pLeft: TPanel;
    List: TListView;
    Log: TListView;
    Splitter1: TSplitter;
    Header: TPanel;
    Caption: TLabel;
    TimerPaint: TTimer;
    procedure ListCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure ListItemChecked(Sender: TObject; Item: TListItem);
    procedure TimerPaintTimer(Sender: TObject);
    procedure LogCreateItemClass(Sender: TCustomListView;
      var ItemClass: TListItemClass);
  private
    class var FScale: Single;
  private
    FGUID: TGUID;
    FClient: TQuadSocket;
    FMemory: TMemoryStream;
    FDiagram: TDiagram;
  public
    constructor Create(AOwner: TComponent; AClient: TQuadSocket; const AGUID: TGUID);
    destructor Destroy; override;
    function FindLineByID(AID: Word): TDiagramLine;
    procedure Write(AMemory: TMemoryStream);
    procedure UpdateInfo(ACode: Word; AMemory: TMemoryStream);

    property Diagram: TDiagram read FDiagram;
    property GUID: TGUID read FGUID;
  end;

implementation

{$R *.dfm}

uses Main, ListLogItem;

{ TDiagram }

constructor TDiagram.Create(AOwner: TComponent);
begin
  inherited;
  FOldTime := 0;
  FMaxValue := 0;
  DoubleBuffered := True;
  FIsRepaint := True;
  FIsRemath := True;
  FBitMap := TBitMap.Create;
  FBitMap.PixelFormat := pf24bit;
  FPen := TGPPen.Create(LINE_COLOR[0], 1);
  FBrush := TGPSolidBrush.Create($FFCCCCCC);
  FFontFamily := TGPFontFamily.Create('Verdana');
  FFont := TGPFont.Create(FFontFamily, 10, FontStyleRegular, UnitPixel);
  FFontFormat := TGPStringFormat.Create;
  FFontFormat.SetAlignment(StringAlignmentNear);

  FBitMap.Canvas.Brush.Color := $00101010;
end;

procedure TDiagram.ReInit;
begin
  if not FIsRepaint then
    Exit;

  if Assigned(FGraphics) then
    FGraphics.Free;
  FGraphics := TGPGraphics.Create(Canvas.Handle);

  FBitMap.SetSize(Width - PADDING.Left - PADDING.Right, Height - PADDING.Top - PADDING.Bottom);
end;

procedure TDiagram.ReMath;
begin
  if not FIsRemath then
    Exit;

  if MaxValue > 0 then
    FScaleY := (Height - PADDING.Top - PADDING.Bottom) / Max(MaxValue, 0.0001)
  else
    FScaleY := 0;
end;

destructor TDiagram.Destroy;
begin
  FPen.Free;
  if Assigned(FGraphics) then
    FGraphics.Free;
  FBitMap.Free;
  inherited;
end;

procedure TDiagram.Resize;
begin
  FIsRepaint := True;
  inherited;
end;

procedure TDiagram.Paint;
var
  Str: string;
begin
  ReInit;
  ReMath;
  DrawDiagram;
  FGraphics.Clear($FF191919);

  FPen.SetColor($FF555555);
  FGraphics.DrawRectangle(FPen, MakeRect(
    PADDING.Left - 1, PADDING.Top - 1,
    Width - PADDING.Left - PADDING.Right + 1, Height - PADDING.Top - PADDING.Bottom + 1
  ));

  Str := Format('%f', [MaxValue]);
  FGraphics.DrawString(Str, Length(Str), FFont, MakePoint(Width - PADDING.Right, PADDING.Top - 6.0), FFontFormat, FBrush);
  Str := '0';
  FGraphics.DrawString(Str, Length(Str), FFont, MakePoint(Width - PADDING.Right, Height - 6.0 - PADDING.Bottom), FFontFormat, FBrush);

  BitBlt(Canvas.Handle, PADDING.Left, PADDING.Top, FBitMap.Width, FBitMap.Height, FBitMap.Canvas.Handle, 0, 0, SRCCOPY);
  FIsRepaint := False;
  FIsRemath := False;
end;

procedure TDiagram.DrawDiagram;
var
  i, k, Count: Integer;
  Line: TDiagramLine;
  Points: array of TPoint;
begin
  if not FIsRepaint then
  begin
    BitBlt(FBitMap.Canvas.Handle, -1, 0, FBitMap.Width, FBitMap.Height, FBitMap.Canvas.Handle, 0, 0, SRCCOPY);
    SelectClipRgn(FBitMap.Canvas.Handle, CreateRectRgn(FBitMap.Width - 1, 0, FBitMap.Width, FBitMap.Height));
  end;
  FBitMap.Canvas.FillRect(Canvas.ClipRect);

  for i := 0 to TfDiagramForm(Owner).List.Items.Count - 1 do
    if TfDiagramForm(Owner).List.Items[i].Checked then
    begin
      Line := TDiagramLine(TfDiagramForm(Owner).List.Items[i]);
      FBitMap.Canvas.Pen.Color := LINE_COLOR[i mod Length(LINE_COLOR)];
      FBitMap.Canvas.Pen.Width := 1;

      if FIsRepaint then
      begin
        Count := min(Line.PointCount, FBitMap.Width);
        SetLength(Points, Count);
        Line.First;
        if Line.Call <> nil then
          FOldTime := Line.Call.Time;
        for k := 0 to Count - 1 do
        begin
          if Line.Call = nil then
            Break;
          Points[k].X := FBitMap.Width - k{ (MaxTime - Line.Call.Time) * 24 * 60 * 60 * 40 } {* FScale};
          Points[k].Y := Round(FBitMap.Height - Line.Call.Value * FScaleY);
          Line.Next;
        end;

        FBitMap.Canvas.Polyline(Points);
        SetLength(Points, 0);
      end
      else
      begin
        Line.First;
        if Line.Call <> nil then
        begin
          FBitMap.Canvas.MoveTo(FBitMap.Width - 1, Round(FBitMap.Height - Line.Call.Value * FScaleY + 2));
          FBitMap.Canvas.LineTo(FBitMap.Width - 1, Round(FBitMap.Height - Line.Call.Value * FScaleY));
        end;
      end;
    end;

  if not FIsRepaint then
    SelectClipRgn(FBitMap.Canvas.Handle, HRGN(nil));
end;

procedure TDiagram.SetMaxValue(Value: Single);
begin
  FMaxValue := Value;
  FIsRemath := True;
end;

{ TfDiagramFrame }

constructor TfDiagramForm.Create(AOwner: TComponent; AClient: TQuadSocket; const AGUID: TGUID);
begin
  inherited Create(AOwner);
  FClient := AClient;
  FGUID := AGUID;

  FDiagram := TDiagram.Create(Self);
  FDiagram.Parent := Panel;
  FDiagram.Align := alClient;
end;

destructor TfDiagramForm.Destroy;
begin
  inherited;
end;

function TfDiagramForm.FindLineByID(AID: Word): TDiagramLine;
var
  i: Integer;
begin
  for i := 0 to List.Items.Count - 1 do
    if TDiagramLine(List.Items[i]).ID = AID then
      Exit(TDiagramLine(List.Items[i]));
  Result := nil;
end;

procedure TfDiagramForm.ListCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TDiagramLine;
end;

procedure TfDiagramForm.ListItemChecked(Sender: TObject; Item: TListItem);
begin
  TimerPaint.Enabled := True;
end;

procedure TfDiagramForm.LogCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TLogListItem;
end;

procedure TfDiagramForm.TimerPaintTimer(Sender: TObject);
begin
  TimerPaint.Enabled := False;
  Diagram.Repaint;
end;

procedure TfDiagramForm.Write(AMemory: TMemoryStream);
var
  TagsCount: Word;
  i: Integer;
  ID, Code: Word;
  Line: TDiagramLine;
  Call: TAPICall;
begin
  if not Assigned(AMemory) then
    Exit;

  Code := 3;
  AMemory.Read(TagsCount, SizeOf(TagsCount));
  for i := 0 to TagsCount - 1 do
  begin
    AMemory.Read(ID, SizeOf(ID));
    AMemory.Read(Call, SizeOf(Call));
    Line := FindLineByID(ID);
    if Assigned(Line) then
      Line.Add(Call);
           {
    begin
      Line := FFrame.List.Items.Add as TDiagramLine;
      Line.Checked := True;
      Line.SetID(ID);
      FMemory.Clear;
      FMemory.Write(Code, SizeOf(Code));
      FMemory.Write(ID, SizeOf(ID));
      FClient.SendStream(FMemory);
      //fMain.Log.Items.Add(Format('Send: %d - %d', [Code, ID]));
    end;
            }
    if Diagram.MaxValue < Line.MaxValue then
      Diagram.MaxValue := Line.MaxValue;
  end;
  TimerPaint.Enabled := True;
end;

procedure TfDiagramForm.UpdateInfo(ACode: Word; AMemory: TMemoryStream);
var
  Str: WideString;
  StrLen: Byte;
  ID: Word;
  Line: TDiagramLine;
  MsgType: TQuadProfilerMessageType;
  DateTime: TDateTime;
  LogItem: TLogListItem;
begin
  case ACode of
    2:
      begin
        AMemory.Read(StrLen, SizeOf(StrLen));
        SetLength(Str, StrLen);
        AMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));
        Caption.Caption := Str;
        ACode := 4;
        FClient.SendBuf(ACode, SizeOf(ACode));
      end;
    3:
      begin
        AMemory.Read(ID, SizeOf(ID));
        Line := List.Items.Add as TDiagramLine;
        Line.Checked := True;
        Line.SetID(ID);

        AMemory.Read(StrLen, SizeOf(StrLen));
        SetLength(Str, StrLen);
        AMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));
        Line.Caption := Str;
      end;
    4:
      begin
        AMemory.Read(ID, SizeOf(ID));
        AMemory.Read(DateTime, SizeOf(DateTime));
        AMemory.Read(MsgType, SizeOf(MsgType));
        AMemory.Read(StrLen, SizeOf(StrLen));
        SetLength(Str, StrLen);
        AMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));

        LogItem := Log.Items.Add as TLogListItem;
        LogItem.Caption := '';
        LogItem.SubItems.Add('DateTime');
        LogItem.SubItems.Add(Str);

        if ID > 0 then
        begin
          Line := FindLineByID(ID);
          LogItem.SubItems.Add(Line.Caption);
        end
        else
          LogItem.SubItems.Add('');
      end;
  end;
  TimerPaint.Enabled := True;
end;

end.
