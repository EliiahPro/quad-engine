unit QuadIcon;

interface

uses
  Classes, SysUtils, Windows, Graphics, Controls, Messages;

type
  TQuadIconThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    Color1, Color2, BackColor: TColor;
    BackBuffer: TBitmap;
    Image: TBitmap;
    Canvas: TCanvas;
    Animated : PBoolean;
    procedure Blit;
  end;

 TQuadIcon = class(TCustomControl)
  private
    FImage: TBitmap;
    FBackBuffer: TBitmap;
    FHR, FHG, FHB: Byte;
    FNR, FNG, FNB: Byte;
    FCR, FCG, FCB: Byte;
    FThread: TQuadIconThread;
    IsAnimated: Boolean;
    FOnClick: TNotifyEvent;
    function GetClickColor: TColor;
    function GetHoverColor: TColor;
    function GetNormalColor: TColor;
    procedure SetClickColor(const Value: TColor);
    procedure SetHoverColor(const Value: TColor);
    procedure SetNormalColor(const Value: TColor);
    procedure SetImage(const Value: TBitmap);
  protected
    procedure Paint; override;
    procedure CMMouseenter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseleave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X: Integer; Y: Integer); override;

  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  published
    property NormalColor: TColor read GetNormalColor write SetNormalColor;
    property HoverColor: TColor read GetHoverColor write SetHoverColor;
    property ClickColor: TColor read GetClickColor write SetClickColor;
    property ShowHint;
    property Glyph: TBitmap read FImage write SetImage;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

implementation

uses Math;

{ TmyButtonThread }

function Lerp(A, B, T: Byte): Byte;
begin
  Result := Round((B - A) * T / 255 + A);
end;

procedure TQuadIconThread.Blit;
begin
 // Canvas.Lock;
  BitBlt(Canvas.Handle, 0, 0, Image.Width, Image.Height, BackBuffer.Canvas.Handle, 0, 0, SRCCOPY);
//  Canvas.Unlock;
end;

procedure TQuadIconThread.Execute;
var
  p, r: PByteArray;
  i, j: Integer;
  ar, ag, ab : Byte;
  br, bg, bb : Byte;
  time: Integer;
  PF: Int64;
  PC, PC2: Int64;
  wait: Smallint;
begin
  inherited;

 // Priority := tpTimeCritical;
  QueryPerformanceFrequency(PF);

  if not Assigned(BackBuffer) then
    Exit;

  for time := 0 to 31 do
  begin
    QueryPerformanceCounter(PC);
    BackBuffer.Canvas.Lock;
    Image.Canvas.Lock;

    br := GetRValue(BackColor);
    bb := GetBValue(BackColor);
    bg := GetGValue(BackColor);

    ar := Lerp(GetRValue(Color1), GetRValue(Color2), time * 8);
    ab := Lerp(GetBValue(Color1), GetBValue(Color2), time * 8);
    ag := Lerp(GetGValue(Color1), GetGValue(Color2), time * 8);

    for i := Image.Height - 1 downto 0 do
    begin
      p := Image.ScanLine[i];
      r := BackBuffer.ScanLine[i];
      for j := 0 to Image.Width * 3 - 3 do
      begin
        begin
          r[j * 3 + 0] := Lerp(bb, ab, p[j * 3 + 0]);
          r[j * 3 + 1] := Lerp(bg, ag, p[j * 3 + 1]);
          r[j * 3 + 2] := Lerp(br, ar, p[j * 3 + 2]);
        end;
      end;
    end;
    Image.Canvas.Unlock;
    BackBuffer.Canvas.Unlock;

    Synchronize(Blit);

    QueryPerformanceCounter(PC2);
    wait := Max(0, 5 - trunc((PC2 - PC) / PF * 1000));
    if wait > 0 then
      WaitForSingleObject(Handle, wait);
  end;
end;

{ TMyImage }

procedure TQuadIcon.AfterConstruction;
begin
  inherited;

  FImage := TBitmap.Create;
  FBackBuffer := TBitmap.Create;

  DoubleBuffered := True;
  IsAnimated := False;
  NormalColor := clGray;
  ClickColor := clWhite;
  HoverColor := clSkyBlue;
end;

procedure TQuadIcon.BeforeDestruction;
begin
  inherited;
  FImage.Free;
  FBackBuffer.Free;
end;

procedure TQuadIcon.CMMouseenter(var Message: TMessage);
begin
  if Assigned(FThread) then
    FThread.Free;

  FThread := TQuadIconThread.Create(True);

  begin
    FThread.BackColor := Parent.Brush.Color;
    FThread.Color1 := NormalColor;
    FThread.Color2 := HoverColor;
    FThread.BackBuffer := FBackBuffer;
    FThread.Image := FImage;
    FThread.Canvas := Self.Canvas;
    FThread.Animated := @IsAnimated;
    FThread.Resume;
  end;

  Message.Result := 0;
end;

procedure TQuadIcon.CMMouseleave(var Message: TMessage);
begin
  if Assigned(FThread) then
    FThread.Free;

  FThread := TQuadIconThread.Create(True);

  begin
    FThread.BackColor := Parent.Brush.Color;
    FThread.Color1 := Self.HoverColor;
    FThread.Color2 := Self.NormalColor;
    FThread.BackBuffer := Self.FBackBuffer;
    FThread.Image := Self.FImage;
    FThread.Canvas := Self.Canvas;
    FThread.Animated := @Self.IsAnimated;
    FThread.Resume;
  end;

  Message.Result := 0;
end;

function TQuadIcon.GetClickColor: TColor;
begin
  Result := RGB(FCR, FCG, FCB);
end;

function TQuadIcon.GetHoverColor: TColor;
begin
  Result := RGB(FHR, FHG, FHB);
end;

function TQuadIcon.GetNormalColor: TColor;
begin
  Result := RGB(FNR, FNG, FNB);
end;

procedure TQuadIcon.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

  if Assigned(FThread) then
    FThread.Free;

  FThread := TQuadIconThread.Create(True);

  begin
    FThread.BackColor := Parent.Brush.Color;
    FThread.Color1 := Self.ClickColor;
    FThread.Color2 := Self.HoverColor;
    FThread.BackBuffer := Self.FBackBuffer;
    FThread.Image := Self.FImage;
    FThread.Canvas := Self.Canvas;
    FThread.Animated := @Self.IsAnimated;
    FThread.Resume;
  end;

  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TQuadIcon.Paint;
var
  p, r: PByteArray;
  i, j: Integer;
  ar, ag, ab : Byte;
  br, bg, bb : Byte;
begin
  inherited;

  FBackBuffer.PixelFormat := pf24bit;
  FBackBuffer.Width := FImage.Width;
  FBackBuffer.Height := FImage.Height;

  FBackBuffer.Canvas.Brush.Color := Parent.Brush.Color;
  FBackBuffer.Canvas.FillRect(FBackBuffer.Canvas.ClipRect);

  br := GetRValue(FBackBuffer.Canvas.Brush.Color);
  bb := GetBValue(FBackBuffer.Canvas.Brush.Color);
  bg := GetGValue(FBackBuffer.Canvas.Brush.Color);

  ar := FNR; //GetRValue(FColor);
  ab := FNB; //GetBValue(FColor);
  ag := FNG; //GetGValue(FColor);

  FImage.Canvas.Lock;
  FBackBuffer.Canvas.Lock;
  for i := FImage.Height - 1 downto 0 do
  begin
    p := FImage.ScanLine[i];
    r := FBackBuffer.ScanLine[i];
    for j := 0 to FImage.Width * 3 do
    begin
      begin
        r[j*3+3] := Lerp(bb, ab, p[j*3+3]);
        r[j*3+1] := Lerp(bg, ag, p[j*3+1]);
        r[j*3+2] := Lerp(br, ar, p[j*3+2]);
      end;
    end;
  end;
  FImage.Canvas.Unlock;
  FBackBuffer.Canvas.Unlock;

  BitBlt(Canvas.Handle, 0, 0, FImage.Width, FImage.Height, FBackBuffer.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TQuadIcon.SetClickColor(const Value: TColor);
begin
  FCR := GetRValue(Value);
  FCG := GetGValue(Value);
  FCB := GetBValue(Value);
end;

procedure TQuadIcon.SetHoverColor(const Value: TColor);
begin
  FHR := GetRValue(Value);
  FHG := GetGValue(Value);
  FHB := GetBValue(Value);
end;

procedure TQuadIcon.SetImage(const Value: TBitmap);
begin
  FImage.Assign(Value);

  Width := FImage.Width;
  Height := FImage.Height;
end;

procedure TQuadIcon.SetNormalColor(const Value: TColor);
begin
  FNR := GetRValue(Value);
  FNG := GetGValue(Value);
  FNB := GetBValue(Value);
end;

end.
