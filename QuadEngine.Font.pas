{﻿//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//
// For license see COPYING
//=============================================================================}

unit QuadEngine.Font;

interface

uses
  windows, direct3d9, QuadEngine.Render, QuadEngine.Texture, QuadEngine.Log,
  QuadEngine, QuadEngine.Shader, Vec2f, System.Classes;

type
  TLetterUV = record
    id            : Word;     { Letter uniq ID }
    U1, V1, U2, V2: Double;   { Texture UV coords }
    X, Y          : Word;     { X, Y position }
    H, W          : Byte;     { Height and width }
  end;

  TQuadChar = packed record
    Reserved: Cardinal;
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

  TInternalDistanceFieldParams = packed record
    Edges: array[0..3] of Single;
    OuterColor: array[0..3] of Single;
    Params: array[0..3] of Single;
    procedure SetColor(AColor: Cardinal); inline;
  end;

  TQuadFont = class(TInterfacedObject, IQuadFont)
    const CHAR_SPACE = 32;
  strict private
    FColors: array[Word] of Cardinal;
    FDistanceFieldParams: TInternalDistanceFieldParams;
    FHeight: Word;
    FIsSmartColoring: Boolean;
    FKerning: Single;
    FSpacing: Single;
    FLetters: array[Word] of TLetterUV;
    FQuadRender: IQuadRender;
    FTexture: IQuadTexture;
    FWidth: Word;
    FFontHeight: Integer;

    //v2.0
    FIsDistanceField: Boolean;
    FQuadFontHeader: TQuadFontHeader;
    FQuadChars: array [Word] of TQuadChar;

    FKerningPairs: array of tagKERNINGPAIR;
    function TextWidthEx(AText: PWideChar; AScale: Single = 1.0; IsIncludeSpaces: Boolean = True): Single;
  public
    constructor Create(AQuadRender : TQuadRender);
    destructor Destroy; override;

    function GetIsLoaded: Boolean; stdcall;
    function GetKerning: Single; stdcall;
    procedure SetKerning(AValue: Single); stdcall;
    function GetSpacing: Single; stdcall;
    procedure SetSpacing(AValue: Single); stdcall;
    procedure LoadFromFile(ATextureFilename, AUVFilename: PWideChar); stdcall;
    procedure LoadFromStream(AStream: Pointer; AStreamSize: Integer; ATexture: IQuadTexture); stdcall;
    procedure SetSmartColor(AColorChar: WideChar; AColor: Cardinal); stdcall;
    procedure SetDistanceFieldParams(const ADistanceFieldParams: TDistanceFieldParams); stdcall;
    procedure SetIsSmartColoring(Value: Boolean); stdcall;
    function TextHeight(AText: PWideChar; AScale: Single = 1.0): Single; stdcall;
    function TextWidth(AText: PWideChar; AScale: Single = 1.0): Single; stdcall;
    procedure TextOut(const Position: TVec2f; AScale: Single; AText: PWideChar; AColor: Cardinal = $FFFFFFFF; AAlign : TqfAlign = qfaLeft); stdcall;
  end;

implementation

uses
  QuadEngine.Device, SysUtils;

{ TQuadFont }

//=============================================================================
//
//=============================================================================
constructor TQuadFont.Create(AQuadRender: TQuadRender);
var
  i: Integer;
begin
  FQuadRender := AQuadRender;
  FKerning := 0.0;

  for i := 0 to High(FColors) do
    FColors[i] := $00FFFFFF;

//  Now set up predefined colors:
  SetSmartColor('W', $00FFFFFF);  // white
  SetSmartColor('Z', $00000000);  // black (zero)
  SetSmartColor('R', $00FF0000);  // red
  SetSmartColor('L', $0000FF00);  // lime
  SetSmartColor('B', $000000FF);  // blue
  SetSmartColor('M', $00800000);  // maroon
  SetSmartColor('G', $00008000);  // green
  SetSmartColor('N', $00000080);  // Navy
  SetSmartColor('Y', $00FFFF00);  // yellow
  SetSmartColor('F', $00FF00FF);  // fuchsia
  SetSmartColor('A', $0000FFFF);  // aqua
  SetSmartColor('O', $00808000);  // olive
  SetSmartColor('P', $00800080);  // purple
  SetSmartColor('T', $00008080);  // teal
  SetSmartColor('D', $00808080);  // gray (dark)
  SetSmartColor('S', $00C0C0C0);  // silver

  FDistanceFieldParams.Edges[0] := 0.35;
  FDistanceFieldParams.Edges[1] := 0.45;
  FDistanceFieldParams.Edges[2] := 0.0;
  FDistanceFieldParams.Edges[3] := 0.0;
  FDistanceFieldParams.Params[0] := 1.0;
  FDistanceFieldParams.Params[1] := 0.0;
  FDistanceFieldParams.SetColor($FFFFFFFF);

end;

//=============================================================================
//
//=============================================================================
destructor TQuadFont.destroy;
begin
  FTexture := nil;
  FQuadRender := nil;
  inherited;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadFont.SetKerning(AValue : Single); stdcall;
begin
  FKerning := AValue;
end;

//=============================================================================
//
//=============================================================================
function TQuadFont.GetKerning: Single; stdcall;
begin
  Result := FKerning;
end;

//=============================================================================
//
//=============================================================================
function TQuadFont.GetSpacing: Single;
begin
  Result := FSpacing;
end;

//=============================================================================
//
//=============================================================================
function TQuadFont.GetIsLoaded: Boolean;
begin
  Result := not (FTexture = nil);
end;

//=============================================================================
// Load font from file and calculate UV for texture
//=============================================================================

procedure TQuadFont.LoadFromFile(ATextureFilename, aUVFilename: PWideChar);
var
  Stream: TMemoryStream;
begin
  Device.Log.Write(PWideChar('Loading font "' + aUVFilename + '"'));

  if not FileExists(aUVFilename) then
  begin
    Device.Log.Write(PWideChar('Texture "' + aUVFilename + '" not found!'));
    Exit;
  end;

  if GetIsLoaded then
    FTexture := nil;

  Device.CreateAndLoadTexture(0, ATextureFilename, FTexture);

  Stream := TMemoryStream.Create;
  Stream.LoadFromFile(aUVFilename);

  LoadFromStream(Stream.Memory, Stream.Size, FTexture);

  FreeAndNil(Stream);
end;

procedure TQuadFont.LoadFromStream(AStream: Pointer; AStreamSize: Integer; ATexture: IQuadTexture);
var
  Stream: TMemoryStream;
  TempUV: TLetterUV;
  c: array[0..3] of Char;
  Size: Cardinal;
  i, j: Integer;
  idx: Word;
  FQuadChars2: array of TQuadChar;
  CharSize: Cardinal;
begin
  if not Assigned(ATexture) then
  begin
    Device.Log.Write(PWideChar('Texture to font not found!'));
    Exit;
  end;

  Device.Log.Write(PWideChar('Loading font from stream'));

  FWidth := ATexture.GetTextureWidth;
  FHeight := ATexture.GetTextureHeight;
  FTexture := ATexture;

  Stream := TMemoryStream.Create;
  Stream.WriteBuffer((AStream)^, AStreamSize);
  Stream.Seek(0, soBeginning);

  Stream.Read(c, 8);
  Stream.Seek(0, soBeginning);

  if c = 'QEF2' then
  begin  // v2.0
    FIsDistanceField := True;
    // header
    Stream.Read(c, 8);
    Stream.Read(Size, 4);
    Stream.Read(FQuadFontHeader, Size);

    // chardata
    Stream.Read(c, 8);
    Stream.Read(CharSize, 4);
    SetLength(FQuadChars2, CharSize div SizeOf(TQuadChar));
    Stream.Read(FQuadChars2[0], CharSize);

    // kerning pairs
    Stream.Read(c, 8);
    Stream.Read(Size, 4);
    SetLength(FKerningPairs, Size div SizeOf(tagKERNINGPAIR));
    Stream.Read(FKerningPairs[0], Size);

    FFontHeight := 0;
    for i := 0 to CharSize div SizeOf(TQuadChar) do
    begin
      if FQuadChars2[i].IncY > FFontHeight then
        FFontHeight := FQuadChars2[i].IncY;

      idx := FQuadChars2[i].id;
      FQuadChars[idx] := FQuadChars2[i];
    end;
    FQuadChars[CHAR_SPACE] := FQuadChars2[CHAR_SPACE];
    Device.Log.Write(PWideChar(String('Distance field font loaded. Char count: ' + IntToStr(CharSize div SizeOf(TQuadChar)))));
  end
  else
  begin  // v1.0
    FIsDistanceField := False;
    i := 0;
    repeat
      Stream.Read(TempUV.id, SizeOf(Word));
      Stream.Read(TempUV.X, SizeOf(Word));
      Stream.Read(TempUV.Y, Sizeof(Word));
      Stream.Read(TempUV.W, SizeOf(Byte));
      Stream.Read(TempUV.H, SizeOf(Byte));

      TempUV.U1 := TempUV.X / FWidth;
      TempUV.V1 := TempUV.Y / FHeight;

      TempUV.U2 := (TempUV.X + TempUV.W) / FWidth;
      TempUV.V2 := (TempUV.Y + TempUV.H) / FHeight;

      FLetters[TempUV.id] := TempUV;
      Inc(i);
    until Stream.Position >= Stream.Size;
    Device.Log.Write(PWideChar(String('Font loaded. Char count: ' + IntToStr(i))));
  end;

  FreeAndNil(Stream);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadFont.SetSmartColor(AColorChar: WideChar; AColor: Cardinal);
begin
  FColors[Ord(AColorChar)] := AColor;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadFont.SetSpacing(AValue: Single);
begin
  FSpacing := AValue;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadFont.SetDistanceFieldParams(
  const ADistanceFieldParams: TDistanceFieldParams);
begin
  Device.Render.FlushBuffer;

  FDistanceFieldParams.SetColor(ADistanceFieldParams.OuterColor);
  FDistanceFieldParams.Edges[0] := ADistanceFieldParams.Edge1X;
  FDistanceFieldParams.Edges[1] := ADistanceFieldParams.Edge1Y;
  FDistanceFieldParams.Edges[2] := ADistanceFieldParams.Edge2X;
  FDistanceFieldParams.Edges[3] := ADistanceFieldParams.Edge2Y;

  if ADistanceFieldParams.FirstEdge then
    FDistanceFieldParams.Params[0] := 1.0
  else
    FDistanceFieldParams.Params[0] := 0.0;

  if ADistanceFieldParams.SecondEdge then
    FDistanceFieldParams.Params[1] := 1.0
  else
    FDistanceFieldParams.Params[1] := 0.0;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadFont.SetIsSmartColoring(Value: Boolean); stdcall;
begin
  FIsSmartColoring := Value;
end;

//=============================================================================
// Draws aligned text with scaling and kerning
//=============================================================================
procedure TQuadFont.TextOut(const Position: TVec2f; AScale: Single; AText: PWideChar;
  AColor: Cardinal; AAlign: TqfAlign);
var
  i: Integer;
  startX: Single;
  sx: Single;
  ypos: Single;
//  width: Single;
  l, c, j: Word;
  CurrentColor: Cardinal;
  CurrentAlpha: Cardinal;
begin
  if AText[0] = #0 then
    Exit;

  CurrentColor := AColor;
  CurrentAlpha := AColor and $FF000000;
  ypos := Position.Y;

  case AAlign of
    qfaLeft   : sx := Position.X;
    qfaRight  : sx := Position.X - Trunc(TextWidth(AText, AScale));
    qfaCenter : sx := Position.X - Trunc(TextWidth(AText, AScale) / 2);
    qfaJustify: begin
                  sx := Position.X;
//                  width := TextWidth(AText, AScale);
                end;
  else
    sx := 0;
  end;

  if FIsDistanceField then
  begin
    TQuadShader.DistanceField.BindVariableToPS(0, @FDistanceFieldParams.Edges, 1);
    TQuadShader.DistanceField.BindVariableToPS(1, @FDistanceFieldParams.OuterColor, 1);
    TQuadShader.DistanceField.BindVariableToPS(2, @FDistanceFieldParams.Params, 1);
  end;

  startX := sx;
  ypos := Position.Y;

  i := 0;
  repeat
    if (FIsSmartColoring) and (AText[i] = '^') and (AText[i + 1] = '$') then
    begin
      Inc(I, 2);
      if (AText[i]='!') then
        CurrentColor := AColor
      else
        if (AText[i]='#') then

        else
          CurrentColor := FColors[Ord(AText[i])] or CurrentAlpha;
      Inc(i);
    end;

    l := Ord(AText[i]);

    if l = Ord(#13) then
    begin
      if not FIsDistanceField then
        ypos := ypos + FLetters[CHAR_SPACE].H * AScale + FSpacing
      else
        ypos := ypos + (FQuadChars[Ord('M')].IncY / FQuadFontHeader.ScaleFactor) * AScale + FSpacing;

      sx := startX;
    end
    else
    begin
      if FIsDistanceField then
      begin
        TQuadShader.DistanceField.SetShaderState(True);

        if l <> CHAR_SPACE then
        FTexture.DrawMap(
                   TVec2f.Create((FQuadChars[l].OriginX / FQuadFontHeader.ScaleFactor) * AScale + sx - (FQuadFontHeader.Coeef / FQuadFontHeader.ScaleFactor) * AScale,
                   (-FQuadChars[l].OriginY / FQuadFontHeader.ScaleFactor) * AScale - (FQuadFontHeader.Coeef / FQuadFontHeader.ScaleFactor) * AScale + ypos),
                   TVec2f.Create((FQuadChars[l].OriginX / FQuadFontHeader.ScaleFactor + FQuadChars[l].SizeX) * AScale + sx - (FQuadFontHeader.Coeef/ FQuadFontHeader.ScaleFactor) * AScale,
                   (-FQuadChars[l].OriginY / FQuadFontHeader.ScaleFactor + FQuadChars[l].SizeY) * AScale - (FQuadFontHeader.Coeef / FQuadFontHeader.ScaleFactor) * AScale + ypos),
                   TVec2f.Create(FQuadChars[l].Xpos / FWidth,
                   FQuadChars[l].YPos / FHeight),
                   TVec2f.Create(FQuadChars[l].Xpos / FWidth + FQuadChars[l].SizeX / FWidth,
                   FQuadChars[l].YPos / FHeight + FQuadChars[l].SizeY / FHeight),
                   CurrentColor);

        sx := sx + (FQuadChars[l].IncX / FQuadFontHeader.ScaleFactor) * AScale + FKerning;// - (QuadChars[c].IncX - QuadChars[c].SizeX) / 2 / QuadFontHeader.ScaleFactor * scale;

        TQuadShader.DistanceField.SetShaderState(False);
      end
      else
      begin
        FTexture.DrawMap(TVec2f.Create(sx, ypos), TVec2f.Create(sx + FLetters[l].W * AScale, ypos + FLetters[l].H * AScale),
                         TVec2f.Create(FLetters[l].U1, FLetters[l].V1), TVec2f.Create(FLetters[l].U2, FLetters[l].V2),
                         CurrentColor);
        sx := sx + FLetters[l].W * AScale + FKerning;
      end;
    end;

    Inc(i);
  until AText[i] = #0;
end;

//=============================================================================
// Calculate text height with scaling and kerning
//=============================================================================
function TQuadFont.TextHeight(AText: PWideChar; AScale: Single = 1.0): Single;
var
  i: Integer;
begin
  if FIsDistanceField then
  begin
    Result := FFontHeight / FQuadFontHeader.ScaleFactor * AScale + FKerning;
  end
  else
  begin
    Result := (FLetters[CHAR_SPACE].V2 - FLetters[CHAR_SPACE].V1) * FHeight * AScale;
    if AText[0] = #0 then
      Exit;

    i := 0;
    repeat
      if AText[i] = #13 then
        Result := Result + (FLetters[CHAR_SPACE].V2 - FLetters[CHAR_SPACE].V1) * FHeight * AScale;

      Inc(i);
    until AText[i] = #0;
  end;
end;

//=============================================================================
// Calculate text width with scaling and kerning
//=============================================================================
function TQuadFont.TextWidth(AText: PWideChar; AScale: Single = 1.0): Single;
begin
  Result := TextWidthEx(AText, AScale);
end;

function TQuadFont.TextWidthEx(AText: PWideChar; AScale: Single;
  IsIncludeSpaces: Boolean): Single;
var
  i, j: Integer;
  l, c: Word;
  max: Single;
begin
  Result := 0.0;
  if AText[0] = #0 then
    Exit;

  max := 0;
  i := 0;
  repeat
    if (FIsSmartColoring) and (AText[i] = '^') and (AText[i + 1] = '$') then
      Inc(i, 3);

    l := Ord(AText[i]);
    if IsIncludeSpaces or (l <> CHAR_SPACE) then
    begin
      if FIsDistanceField then
      begin
        c := l;
        Result := Result + (FQuadChars[c].IncX / FQuadFontHeader.ScaleFactor) * AScale + FKerning
      end
      else
        Result := Result + (FLetters[l].U2 - FLetters[l].U1) * FWidth * AScale + FKerning;
    end;

    if l = Ord(#13) then
    begin
      if Result > max then
        max := Result;
      Result := 0;
    end;
    Inc(i);
  until AText[i] = #0;

  if Result < max then
    Result := max;
end;

{ TInternalDistanceFieldParams }

procedure TInternalDistanceFieldParams.SetColor(AColor: Cardinal);
begin
  Self.OuterColor[0] := (AColor and $00FF0000 shr 16) / 255;
  Self.OuterColor[1] := (AColor and $0000FF00 shr 8) / 255;
  Self.OuterColor[2] := (AColor and $000000FF) / 255;
  Self.OuterColor[3] := (AColor and $FF000000 shr 24) / 255;
end;

end.
