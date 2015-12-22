unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, System.Types, VCL.Imaging.pngimage, AtlasTree;

type
  TMain = class(TForm)
    RenderBox: TPaintBox;
    RenderButton: TButton;
    RenderChars: TMemo;
    cxProgressBar1: TProgressBar;
    FontNames: TComboBox;
    IsVisialize: TCheckBox;
    PreRenderBox: TPaintBox;
    cxLabel1: TLabel;
    cxLabel2: TLabel;
    procedure RenderButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FontNamesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TQuadChar = packed record
    Data: TBitmap;
    Xpos: Word;
    YPos: Word;
    id: Word;
    SizeX: Byte;
    SizeY: Byte;
    OriginX: Smallint;
    OriginY: Smallint;
    IncX: Smallint;
    IncY: Smallint;
  end;

  TQuadFontHeader = packed record
    Coeef: Byte;
    ScaleFactor: Byte;
  end;

  TFontData = packed record
    Log: LOGFONT;
    Metric: TEXTMETRIC;
  end;

const
  Coeef = 84;
  ScaleFactor = 12;

var
  QuadChars: array[Word] of TQuadChar;
  Main: TMain;
  chari : Char;
  S: array[0..2047, 0..2047] of Byte;
  QuadFontHeader: TQuadFontHeader;
  FontList: array of TFontData;
  ATree: TAtlasTree;

implementation

uses Math;

{$R *.dfm}

procedure GetChar;
var
  i, j: Integer;
  xOrig, yOrig: Integer;
  MinDist, Dist: Double;
  Side: Boolean;
  isFound: Boolean;
  MaxRadius: Double;
  radius: Integer;
  c, d: Integer;
  X, Y: Integer;
  Value: Double;
  Source: TBitmap;

  PResult: PByteArray;
  Result: TBitmap;

  gm: _GLYPHMETRICS;
  bufsize: Cardinal;
  buf: PByteArray;
  mat: _MAT2;
  rowsize: Cardinal;

  SizeOX: Integer;
  SizeOY: Integer;
  SizeX: Integer;
  SizeY: Integer;
begin
  // очистка
  Main.RenderBox.Canvas.Brush.Color := clBlack;
  Main.RenderBox.Canvas.FillRect(Main.RenderBox.ClientRect);

  //
  FillChar(mat, SizeOf(mat), 0);
  mat.eM11.value := 1;
  mat.eM12.value := 0;
  mat.eM21.value := 0;
  mat.eM22.value := 1;

  Source := TBitmap.Create;
  Source.PixelFormat := pf24bit;

  FillChar(gm, SizeOf(gm), 0);

  Source.Canvas.Font.Handle := CreateFont(512, 0, 0, 0, FontList[Main.FontNames.ItemIndex].Log.lfWeight,
                                          FontList[Main.FontNames.ItemIndex].Log.lfItalic,
                                          0, 0, DEFAULT_CHARSET, 0, 0, NONANTIALIASED_QUALITY, 0,
                                          FontList[Main.FontNames.ItemIndex].Log.lfFaceName);

  bufsize := GetGlyphOutline(Source.Canvas.Handle, ord(chari), GGO_BITMAP, gm, 0, nil, mat);

  SizeOX := gm.gmBlackBoxX + Coeef * 2;
  SizeOY := gm.gmBlackBoxY + Coeef * 2;
  SizeX := SizeOX div ScaleFactor;

  if SizeOX mod ScaleFactor > 0 then
    Inc(SizeX);
  SizeY := SizeOY div ScaleFactor;
  if SizeOY mod ScaleFactor > 0 then
    Inc(SizeY);


  QuadChars[ord(chari)].SizeX := SizeX;
  QuadChars[ord(chari)].SizeY := SizeY;
  QuadChars[ord(chari)].OriginX := gm.gmptGlyphOrigin.X;
  QuadChars[ord(chari)].OriginY := gm.gmptGlyphOrigin.Y;
  QuadChars[ord(chari)].IncX := gm.gmCellIncX;
  QuadChars[ord(chari)].IncY := gm.gmBlackBoxY;
  QuadChars[ord(chari)].id := ord(chari);


  if bufsize = 0 then
    Exit;


  GetMem(buf, bufsize);
  GetGlyphOutline(Source.Canvas.Handle, ord(chari), GGO_BITMAP, gm, bufsize, buf, mat);

  // буква есть, ищем верные размеры

  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.Width := SizeX;
  Result.Height := SizeY;


  FillChar(S, 2048 * 2048, $FF);

  Source.Width := SizeOX;
  Source.Height := SizeOY;
  Source.Canvas.Brush.Color := clBlack;
  Source.Canvas.FillRect(Rect(0, 0, SizeOX, SizeOY));


// заполняем массив

  for i := 0 to gm.gmBlackBoxY - 1 do
  begin
    rowsize := gm.gmBlackBoxX div 32;
    if gm.gmBlackBoxX mod 32 > 0 then
      Inc(rowsize);
    rowsize := rowsize * 4;

    for j := 0 to gm.gmBlackBoxX - 1 do
      if (buf[(j div 8)] shr (7 - j mod 8)) and $1 = 1 then
        S[j + Coeef, i + Coeef] := $00
      else
        S[j + Coeef, i + Coeef] := $FF;
    Inc(Cardinal(buf), rowsize);
  end;


  // ищем distance field
  MaxRadius := Max(Coeef, ScaleFactor * 1.5);

  for j := 0 to SizeY - 1 do
  begin
    PResult := Result.ScanLine[j];
    for i := 0 to SizeX - 1 do
    begin
      xOrig := i * ScaleFactor;
      yOrig := j * ScaleFactor;
      Side := S[xOrig, YOrig] = 0;

      MinDist := 512;
      isFound := False;
      radius := 1;
      X := 0;
      Y := 0;
      repeat
        for c := 0 to radius * 2 - 1 do
          for d := 0 to 3 do
          begin
            case d of
            0:
              begin
                X := xOrig - radius + c;
                Y := yOrig - radius;
              end;
            1:
              begin
                X := xorig + radius;
                Y := yorig - radius + c;
              end;
            2:
              begin
                X := xorig + radius - c;
                Y := yorig + radius;
              end;
            3:
              begin
                X := xorig - radius;
                Y := yorig + radius - c;
              end;
            end;

            X := min(max(X, 0), SizeOX - 1);
            Y := min(max(Y, 0), SizeOY - 1);

            if (S[X, Y] = 0) <> Side then
            begin
              isFound := True;
              Dist := sqrt((X - xOrig) * (X - xOrig) + (Y - yOrig) * (Y - yOrig));
              if Dist < MinDist then
              begin
                MinDist := Dist;
                if Main.IsVisialize.Checked then
                  Main.RenderBox.Canvas.Pixels[X, Y] := $FFFFFF;
              end;
            end;
          end;


        Inc(radius);

        if (radius >= MinDist) then
          Break;
      until radius >= MaxRadius;

      if Main.IsVisialize.Checked then
      begin
        Main.RenderBox.Canvas.Brush.Color := Trunc(MinDist) shl 16 + Trunc(MinDist) shl 8;
        Main.RenderBox.Canvas.FillRect(Rect(xOrig, yOrig, xOrig + ScaleFactor, yOrig + ScaleFactor));
      end;

      Value := 0;
      if isFound then
        Value := 0.5 - minDist / Coeef / 2;

      if Side then
        Value := 1 - Value;

      Value := Min(Max(Value * 255, 0), 255);

      PResult[i * 3] := Round(Value);
      PResult[i * 3 + 1] := Round(Value);
      PResult[i * 3 + 2] := Round(Value);
    end;
  end;

//


  QuadChars[ord(chari)].Data := TBitmap.Create;
  QuadChars[ord(chari)].Data.PixelFormat := pf24bit;
  QuadChars[ord(chari)].Data.Width := SizeX;
  QuadChars[ord(chari)].Data.Height := SizeY;

  BitBlt(QuadChars[ord(chari)].Data.Canvas.Handle, 0, 0, SizeX, SizeY, Result.Canvas.Handle, 0, 0, SRCCOPY);

  BitBlt(Main.PreRenderBox.Canvas.Handle, 0, 0, SizeX, SizeY, Result.Canvas.Handle, 0, 0, SRCCOPY);
  Result.Free;
end;

procedure TMain.RenderButtonClick(Sender: TObject);
type
  Tpairs = array [0..1024 * 6 - 1] of tagKERNINGPAIR;
var
  i, j: Integer;
  Node: PNode;
  c: TQuadChar;
  f: file;
  Size: Cardinal;
  pairs: Tpairs;
  pairsCount: Cardinal;
  W, H: Integer;
  p1, p2: pByteArray;
  Result: TPngImage;
begin
  ATree.Clear;

  cxProgressBar1.Max := Length(RenderChars.Text);
  cxProgressBar1.Position := 0;
  for i:= 0 to MAXWORD do
  if Pos(Chr(i), RenderChars.Text) > 0 then
  begin
    cxProgressBar1.Position := cxProgressBar1.Position + 1;
    chari := char(i);
    getchar;
  end;

  for i:= 0 to MAXWORD - 1 do
  if Pos(Chr(i), RenderChars.Text) > 0 then
  for j:= i + 1 to MAXWORD do
  if Pos(Chr(j), RenderChars.Text) > 0 then
  begin
    if (QuadChars[i].SizeX * QuadChars[i].SizeY) < (QuadChars[j].SizeX * QuadChars[j].SizeY) then
    begin
      c:= QuadChars[j];
      QuadChars[j] := QuadChars[i];
      QuadChars[i] := c;
    end;
  end;


  for i:= 0 to MAXWORD do
  if Pos(Chr(i), RenderChars.Text) > 0 then
  begin
    if QuadChars[i].Data <> nil then
    begin
      Node := ATree.AddNode(i, QuadChars[i].SizeX, QuadChars[i].SizeY, QuadChars[i].Data);
      QuadChars[i].Xpos := Node.rc.Left;
      QuadChars[i].Ypos := Node.rc.Top;
    end;
    BitBlt(RenderBox.Canvas.Handle, 0, 0, 512, 512, ATree.Atlas.Canvas.Handle, 0, 0, SRCCOPY);
  end;

  Canvas.Font.Handle := CreateFont(512, 0, 0, 0, FontList[FontNames.ItemIndex].Log.lfWeight,
                                   FontList[FontNames.ItemIndex].Log.lfItalic, 0, 0,
                                   DEFAULT_CHARSET, 0, 0, NONANTIALIASED_QUALITY, 0,
                                   FontList[FontNames.ItemIndex].Log.lfFaceName);

  pairsCount := GetKerningPairs(Canvas.Handle, 1024 * 6 - 1, pairs);



  AssignFile(f, 'map.qef');
  Rewrite(f, 1);

  QuadFontHeader.Coeef := Coeef;
  QuadFontHeader.ScaleFactor := ScaleFactor;

  // header
  BlockWrite(f, 'QEF2', 8);
  Size := SizeOf(TQuadFontHeader);
  BlockWrite(f, Size, 4);
  BlockWrite(f, QuadFontHeader, Size);

  // chardata
  BlockWrite(f, 'CHRS', 8);
  Size := 0;
  for i := 0 to MAXWORD do
    if Assigned(QuadChars[i].Data) then
      Size := Size + SizeOf(TQuadChar);
  BlockWrite(f, Size, 4);

  for i := 0 to MAXWORD do
    if Assigned(QuadChars[i].Data) then
      BlockWrite(f, QuadChars[i], SizeOf(TQuadChar));

  // kerning pairs
  BlockWrite(f, 'KRNG', 8);
  size := pairsCount * SizeOf(tagKERNINGPAIR);
  BlockWrite(f, Size, 4);
  BlockWrite(f, pairs[0], Size);
  CloseFile(f);



  ATree.Atlas.Transparent := True;

  Result := TPngImage.Create;
  Result.Assign(ATree.Atlas);
  Result.CreateAlpha;

  for i := 0 to ATree.Atlas.Height - 1 do
  begin
    p1 := Result.Scanline[i];
    p2 := Result.AlphaScanline[i];
    for j := 0 to Result.Width - 1 do
    begin
      p2[j] := p1[j * 3];
      p1[j * 3 + 0] := 255;
      p1[j * 3 + 1] := 255;
      p1[j * 3 + 2] := 255;
    end;
  end;

  Result.SaveToFile('atlas.png');
end;

function lerp(a, b: Byte; t: Single): Byte;
begin
  Result := Round((b - a) * t + a);
end;

function EnumFontFamProc(const ALogFont: LOGFONT; const TextMetric: TEXTMETRIC;
  FontType: Cardinal; lParam: Integer): Integer; stdcall;
var
  N: string;
begin
  if FontType = TRUETYPE_FONTTYPE then
  begin
    SetLength(FontList, Length(FontList) + 1);
    FontList[High(FontList)].Log := ALogFont;
    FontList[High(FontList)].Metric := TextMetric;

    N := ALogFont.lfFaceName;

    Main.FontNames.Items.Add(N);
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Screen.Fonts.Count - 1 do
    EnumFontFamilies(Self.Canvas.Handle, PWideChar(Screen.Fonts[i]), @EnumFontFamProc, 0);

  ATree := TAtlasTree.Create(512, 512);
end;

procedure TMain.FontNamesDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  ACanvas: TCanvas;
  ARect: TRect;
  AText: string;
begin
  ACanvas := FontNames.Canvas;

  ACanvas.Font.Name := FontNames.Items[Index];
  ACanvas.Font.size := 16;

  if FontList[Index].Log.lfItalic > 0 then
    ACanvas.Font.Style := ACanvas.Font.Style + [fsItalic];

  if FontList[Index].Log.lfWeight > 400 then
    ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];

  ARect := Rect;
  ARect.Right := ARect.Right - 32;
  AText := FontNames.Items[Index];

  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Color := clBlack;
  ACanvas.TextRect(ARect, AText, []);
end;

end.

