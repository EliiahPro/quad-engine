{==============================================================================

  Quad engine Color

     ╔═══════════╦═╗
     ║           ║ ║
     ║           ║ ║
     ║ ╔╗ ║║ ╔╗ ╔╣ ║
     ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
     ║  ║ engine   ║
     ║  ║          ║
     ╚══╩══════════╝

  For further information please visit:
  http://quad-engine.com

===============================================================================}

unit QuadEngine.Color;

interface

type
  TQuadColor = record
  private
    procedure ClampToMin; inline;
    procedure ClampToMax; inline;
  public
    class operator Implicit(ARGB: Cardinal): TQuadColor;
    class operator Implicit(A: TQuadColor): Cardinal;
    class operator Add(A, B: TQuadColor): TQuadColor;
    class operator Subtract(A, B: TQuadColor): TQuadColor;
    class operator Multiply(A, B: TQuadColor): TQuadColor;
    class operator Multiply(A: TQuadColor; B: Double): TQuadColor;
    class operator Divide(A, B: TQuadColor): TQuadColor;
    class operator Divide(A: TQuadColor; B: Double): TQuadColor;
    constructor Create(R, G, B: Double; A: Double = 1.0); overload;
    constructor Create(R, G, B: Byte; A: Byte = 255); overload;
    constructor Create(ARGB: Cardinal); overload;
    function Lerp(const A: TQuadColor; dist: Single): TQuadColor; inline;
  case integer of
    0: (A, R, G, B: Double);
    1: (comp: array[0..3] of Double);
  end;

  TQuadColorHelper = record helper for TQuadColor
  public
    const White: TQuadColor = (A: 1.0; R: 1.0; G: 1.0; B: 1.0);
    const Black: TQuadColor = (A: 1.0; R: 0.0; G: 0.0; B: 0.0);
    const Red: TQuadColor = (A: 1.0; R: 1.0; G: 0.0; B: 0.0);
    const Lime: TQuadColor = (A: 1.0; R: 0.0; G: 1.0; B: 0.0);
    const Blue: TQuadColor = (A: 1.0; R: 0.0; G: 0.0; B: 1.0);
    const Maroon: TQuadColor = (A: 1.0; R: 128/255; G: 0.0; B: 0.0);
    const Green: TQuadColor = (A: 1.0; R: 0.0; G: 128/255; B: 0.0);
    const Navy: TQuadColor = (A: 1.0; R: 0.0; G: 0.0; B: 128/255);
    const Yellow: TQuadColor = (A: 1.0; R: 1.0; G: 1.0; B: 0.0);
    const Fuchsia: TQuadColor = (A: 1.0; R: 1.0; G: 0.0; B: 1.0);
    const Aqua: TQuadColor = (A: 1.0; R: 0.0; G: 1.0; B: 1.0);
    const Olive: TQuadColor = (A: 1.0; R: 128/255; G: 128/255; B: 0.0);
    const Purple: TQuadColor = (A: 1.0; R: 128/255; G: 0.0; B: 128/255);
    const Teal: TQuadColor = (A: 1.0; R: 0.0; G: 128/255; B: 128/255);
    const Gray: TQuadColor = (A: 1.0; R: 128/255; G: 128/255; B: 128/255);
    const Silver: TQuadColor = (A: 1.0; R: 192/255; G: 192/255; B: 192/255);
    const Orange: TQuadColor = (A: 1.0; R: 1.0; G: 128/255; B: 0.0);
    const Brown: TQuadColor = (A: 1.0; R: 128/255; G: 64/255; B: 0.0);
    const Violet: TQuadColor = (A: 1.0; R: 128/255; G: 0; B: 1.0);
  end;

implementation

{ TQuadColor }

constructor TQuadColor.Create(R, G, B: Double; A: Double = 1.0);
begin
  Self.A := A;
  Self.R := R;
  Self.G := G;
  Self.B := B;
end;

constructor TQuadColor.Create(R, G, B: Byte; A: Byte = 255);
begin
  Self.A := A / 255;
  Self.R := R / 255;
  Self.G := G / 255;
  Self.B := B / 255;
end;

constructor TQuadColor.Create(ARGB: Cardinal);
begin
  Self.A := (ARGB and $FF000000) shr 24 / 255;
  Self.R := (ARGB and $00FF0000) shr 16 / 255;
  Self.G := (ARGB and $0000FF00) shr 8 / 255;
  Self.B := (ARGB and $000000FF) / 255;
end;

class operator TQuadColor.Divide(A: TQuadColor; B: Double): TQuadColor;
begin
  if B = 0 then
    Exit(TQuadColor.Create(1.0, 1.0, 1.0, 1.0));

  Result.A := A.A / B;
  Result.R := A.R / B;
  Result.G := A.G / B;
  Result.B := A.B / B;
end;

class operator TQuadColor.Add(A, B: TQuadColor): TQuadColor;
begin
  Result.A := A.A + B.A;
  Result.R := A.R + B.R;
  Result.G := A.G + B.G;
  Result.B := A.B + B.B;

  Result.ClampToMax;
end;

procedure TQuadColor.ClampToMax;
begin
  if Self.A > 1.0 then
    Self.A := 1.0;
  if Self.R > 1.0 then
    Self.R := 1.0;
  if Self.G > 1.0 then
    Self.G := 1.0;
  if Self.B > 1.0 then
    Self.B := 1.0;
end;

procedure TQuadColor.ClampToMin;
begin
  if Self.A < 0.0 then
    Self.A := 0.0;
  if Self.R < 0.0 then
    Self.R := 0.0;
  if Self.G < 0.0 then
    Self.G := 0.0;
  if Self.B < 0.0 then
    Self.B := 0.0;
end;

class operator TQuadColor.Divide(A, B: TQuadColor): TQuadColor;
begin
  if B.A = 0 then
    Result.A := 1.0
  else
    Result.A := A.A / B.A;

  if B.R = 0 then
    Result.R := 1.0
  else
    Result.R := A.R / B.R;

  if B.G = 0 then
    Result.G := 1.0
  else
    Result.G := A.G / B.G;

  if B.B = 0 then
    Result.B := 1.0
  else
    Result.B := A.B / B.B;
end;

class operator TQuadColor.Implicit(A: TQuadColor): Cardinal;
begin
  Result := Trunc(A.A * 255) shl 24 +
            Trunc(A.R * 255) shl 16 +
            Trunc(A.G * 255) shl 8 +
            Trunc(A.B * 255);
end;

class operator TQuadColor.Implicit(ARGB: Cardinal): TQuadColor;
begin
  Result := TQuadColor.create(ARGB);
end;

function TQuadColor.Lerp(const A: TQuadColor; dist: Single): TQuadColor;
begin
  Result.A := (A.A - Self.A) * dist + Self.A;
  Result.R := (A.R - Self.R) * dist + Self.R;
  Result.G := (A.G - Self.G) * dist + Self.G;
  Result.B := (A.B - Self.B) * dist + Self.B;
  Result.ClampToMin;
  Result.ClampToMax;
end;

class operator TQuadColor.Multiply(A: TQuadColor; B: Double): TQuadColor;
begin
  Result.A := A.A * B;
  Result.R := A.R * B;
  Result.G := A.G * B;
  Result.B := A.B * B;
  Result.ClampToMax;
end;

class operator TQuadColor.Multiply(A, B: TQuadColor): TQuadColor;
begin
  Result.A := A.A * B.A;
  Result.R := A.R * B.R;
  Result.G := A.G * B.G;
  Result.B := A.B * B.B;
  Result.ClampToMax;
end;

class operator TQuadColor.Subtract(A, B: TQuadColor): TQuadColor;
begin
  Result.A := A.A - B.A;
  Result.R := A.R - B.R;
  Result.G := A.G - B.G;
  Result.B := A.B - B.B;
  Result.ClampToMin;
end;

end.
