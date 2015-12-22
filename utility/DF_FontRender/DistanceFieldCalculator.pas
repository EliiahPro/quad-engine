unit DistanceFieldCalculator;

interface

uses
  Windows, Graphics;

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

  TDistanceFieldCalculator = class sealed
  private
    const Coeef = 84;
    const ScaleFactor = 12;
  var
    S: array[0..2047, 0..2047] of Byte;
    mat: _MAT2;
    function RenderChar(Aindex: Word): Integer;
  public
    function Calculate: Integer;
  end;

implementation

function TDistanceFieldCalculator.RenderChar(Aindex: Word): Integer;
var
  gm: _GLYPHMETRICS;
begin
  FillChar(gm, SizeOf(gm), 0);
end;

function TDistanceFieldCalculator.Calculate: Integer;
begin
  FillChar(mat, SizeOf(mat), 0);
  mat.eM11.value := 1;
  mat.eM12.value := 0;
  mat.eM21.value := 0;
  mat.eM22.value := 1;


end;

end.
