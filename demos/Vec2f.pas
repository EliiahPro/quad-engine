unit Vec2f;

interface

type
  TVec2i = record
    class operator Add(const a, b: TVec2i): TVec2i;
    class operator Subtract(const a, b: TVec2i): TVec2i;
    class operator Multiply(const a, b: TVec2i): TVec2i;
    class operator Multiply(const a: TVec2i; X: Single): TVec2i;
    class operator Negative(const X: TVec2i): TVec2i;
    constructor Create(X, Y: Single);
    function Distance(const X: TVec2i): Single; inline;
    function Dot(const X: TVec2i): Single; inline;
    function Lerp(const X: TVec2i; dist: Single): TVec2i; inline;
        // data
    case Integer of
      0: (X, Y: Single);
      1: (U, V: Single);
      2: (a: array[0..1] of Single);
  end;

  TVec2f = packed record
  strict private
    class var FZero: TVec2f;
  public
    class operator Add(const A, B: TVec2f): TVec2f;
    class operator Implicit(const A: TVec2i): TVec2f;
    class operator Subtract(X: Single; const A: TVec2f): TVec2f;
    class operator Subtract(const A: TVec2f; X: Single): TVec2f;
    class operator Subtract(const A, B : TVec2f): TVec2f;
    class operator Multiply(const A, B : TVec2f): TVec2f;
    class operator Multiply(const A: TVec2f; X: Single): TVec2f;
    class operator Divide(const A, b: TVec2f): TVec2f;
    class operator Divide(const A: TVec2f; X: Single): TVec2f;
    class operator Negative(const A: TVec2f): TVec2f;
    class operator Equal(const A, B: TVec2f): Boolean;
    class operator NotEqual(const A, B: TVec2f): Boolean;
    class operator GreaterThan(const A, B: TVec2f): Boolean;
    class operator LessThan(const A, B: TVec2f): Boolean;
    constructor Create(X, Y: Single);
    function Length: Single; inline;
    function Distance(const A: TVec2f): Single; inline;
    function Dot(const A: TVec2f) : Single; inline;
    function Lerp(const A: TVec2f; dist: Single): TVec2f; inline;
    function Normal: TVec2f; inline;
    function Normalize: TVec2f; inline;
    class property Zero: TVec2f read FZero;
        // data
    case Integer of
      0: (X, Y: Single);
      1: (U, V: Single);
      2: (a: array[0..1] of Single);
  end;

  TVec3f = record
    class operator Add(const a, b: TVec3f): TVec3f;
    class operator Subtract(const a, b: TVec3f): TVec3f;
    class operator Multiply(const a, b: TVec3f): TVec3f;
    class operator Multiply(const a: TVec3f; X: Single): TVec3f;
    class operator Negative(const X: TVec3f): TVec3f;
    constructor Create(X, Y, Z: Single);
    function Distance(const X: TVec3f): Single; inline;
    function Dot(const X: TVec3f): Single; inline;
    function Lerp(const X: TVec3f; dist: Single): TVec3f; inline;
        // data
    case Integer of
      0: (X, Y, Z: Single);
      1: (U, V, W: Single);
      2: (R, G, B: Single);
      3: (a: array[0..2] of Single);
  end;

implementation

  {TVec2f}

class operator TVec2f.Add(const A, B: TVec2f): TVec2f;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

class operator TVec2f.Implicit(const A: TVec2i): TVec2f;
begin
  Result.X := A.X;
  Result.Y := A.Y;
end;

class operator TVec2f.Subtract(X: Single; const A: TVec2f): TVec2f;
begin
  Result.X := X - A.X;
  Result.Y := X - A.Y;
end;

class operator TVec2f.Subtract(const A: TVec2f; X: Single): TVec2f;
begin
  Result.X := A.X - X;
  Result.Y := A.Y - X;
end;

class operator TVec2f.Subtract(const A, B: TVec2f): TVec2f;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

class operator TVec2f.Multiply(const A, B: TVec2f): TVec2f;
begin
  Result.X := A.X * B.X;
  Result.Y := A.Y * B.Y;
end;

class operator TVec2f.Multiply(const A: TVec2f; X: Single): TVec2f;
begin
  Result.X := A.X * X;
  Result.Y := A.Y * X;
end;

class operator TVec2f.Divide(const A, B: TVec2f): TVec2f;
begin
  Result.X := A.X / B.X;
  Result.Y := A.Y / B.Y;
end;

class operator TVec2f.Divide(const A: TVec2f; X: Single): TVec2f;
begin
  Result.X := A.X / X;
  Result.Y := A.Y / X;
end;

class operator TVec2f.Negative(const A: TVec2f): TVec2f;
begin
  Result.X := - A.X;
  Result.Y := - A.Y;
end;

class operator TVec2f.Equal(const A, B: TVec2f): Boolean;
begin
  Result := (A.X = B.X) and (A.Y = B.Y);
end;

class operator TVec2f.GreaterThan(const A, B: TVec2f): Boolean;
begin
  Result := A.Length > B.Length;
end;

class operator TVec2f.NotEqual(const A, B: TVec2f): Boolean;
begin
  Result := (A.X <> B.X) or (A.Y <> B.Y);
end;

function TVec2f.Normal: TVec2f;
begin
  Result.X := Self.Y;
  Result.Y := - Self.X;
end;

function TVec2f.Normalize: TVec2f;
var
  d: Double;
begin
  d := Distance(TVec2f.Create(0, 0));
  if d > 0 then
  begin
    Result.X := Self.X / d;
    Result.Y := Self.Y / d;
  end
  else
  begin
    Result.Create(0, 0);
  end;
end;

function TVec2f.Distance(const A: TVec2f): Single;
begin
  Result := (Self - A).Length;
end;

function TVec2f.Dot(const A: TVec2f): Single;
begin
  Result := A.X * Self.X + A.Y * Self.Y;
end;

constructor TVec2f.Create(X, Y: Single);
begin
  Self.X := X;
  Self.Y := Y;
end;

function TVec2f.Length: Single;
begin
  Result := Sqrt(Self.X * Self.X + Self.Y * Self.Y);
end;

function TVec2f.Lerp(const A: TVec2f; dist: Single): TVec2f;
begin
  Result := (A - Self) * dist + Self;
end;

class operator TVec2f.LessThan(const A, B: TVec2f): Boolean;
begin
  Result := A.Length < B.Length;
end;

{TVec2i}

class operator TVec2i.Add(const a, b: TVec2i): TVec2i;
begin
  Result.X := a.X + b.X;
  Result.Y := a.Y + b.Y;
end;

class operator TVec2i.Subtract(const a, b: TVec2i): TVec2i;
begin
  Result.X := a.X - b.X;
  Result.Y := a.Y - b.Y;
end;

class operator TVec2i.Multiply(const a, b : TVec2i): TVec2i;
begin
  Result.X := a.X * b.X;
  Result.Y := a.Y * b.Y;
end;

class operator TVec2i.Multiply(const a: TVec2i; X: Single): TVec2i;
begin
  Result.X := a.X * X;
  Result.Y := a.Y * X;
end;

class operator TVec2i.Negative(const X: TVec2i): TVec2i;
begin
  Result.X := - X.X;
  Result.Y := - X.Y;
end;

function TVec2i.Distance(const X: TVec2i): Single;
begin
  Result := Sqrt(Sqr(X.X - Self.X) + Sqr(X.Y - Self.Y));
end;

function TVec2i.Dot(const X: TVec2i): Single;
begin
  Result := X.X * Self.X + X.Y * Self.Y;
end;

constructor TVec2i.Create(X, Y: Single);
begin
  Self.X := X;
  Self.Y := Y;
end;

function TVec2i.Lerp(const X: TVec2i; dist: Single): TVec2i;
begin
  Result := (X - Self) * dist + Self;
end;

 {TVec3f}

class operator TVec3f.Add(const a, b: TVec3f): TVec3f;
begin
  Result.X := a.X + b.X;
  Result.Y := a.Y + b.Y;
  Result.Z := a.Z + b.Z;
end;

class operator TVec3f.Subtract(const a, b: TVec3f): TVec3f;
begin
  Result.X := a.X - b.X;
  Result.Y := a.Y - b.Y;
  Result.Z := a.Z - b.Z;
end;

class operator TVec3f.Multiply(const a, b: TVec3f): TVec3f;
begin
  Result.X := a.X * b.X;
  Result.Y := a.Y * b.Y;
  Result.Z := a.Z * b.Z;
end;

class operator TVec3f.Multiply(const a: TVec3f; X: Single): TVec3f;
begin
  Result.X := a.X * X;
  Result.Y := a.Y * X;
  Result.Z := a.Z * X;
end;

class operator TVec3f.Negative(const X: TVec3f): TVec3f;
begin
  Result.X := - X.X;
  Result.Y := - X.Y;
  Result.Z := - X.Z;
end;

function TVec3f.Distance(const X: TVec3f): Single;
begin
  Result := Sqrt(Sqr(X.X - Self.X) + Sqr(X.Y - Self.Y) + Sqr(X.Z - Self.Z));
end;

function TVec3f.Dot(const X: TVec3f): Single;
begin
  Result := X.X * Self.X + X.Y * Self.Y + X.Z * Self.Z;
end;

constructor TVec3f.Create(X, Y, Z: Single);
begin
  Self.X:= X;
  Self.Y:= Y;
  Self.Z:= Z;
end;

function TVec3f.Lerp(const X: TVec3f; dist: Single): TVec3f;
begin
  Result := (X - Self) * dist + Self;     
end;

end.

