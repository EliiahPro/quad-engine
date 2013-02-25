unit Vec2f;

interface

uses
  Windows;

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

  TVec2f = record
    class operator Add(const a, b: TVec2f): TVec2f;
    class operator Implicit(const X: TVec2i): TVec2f;
    class operator Subtract(X: Single; const a: TVec2f): TVec2f;
    class operator Subtract(const a, b : TVec2f): TVec2f;
    class operator Multiply(const a, b : TVec2f): TVec2f;
    class operator Multiply(const a: TVec2f; X: Single): TVec2f;
    class operator Divide(const a, b: TVec2f): TVec2f;
    class operator Divide(const a: TVec2f; X: Single): TVec2f;
    class operator Negative(const X: TVec2f): TVec2f;
    constructor Create(X, Y: Single);
    function Distance(const X: TVec2f) : Single; inline;
    function Dot(const X: TVec2f) : Single; inline;
    function Lerp(const X: TVec2f; dist: Single): TVec2f; inline;
    function Normal: TVec2f; inline;
    function Normalize: TVec2f; inline;
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

class operator TVec2f.Add(const a, b: TVec2f): TVec2f;
begin
  Result.X := a.X + b.X;
  Result.Y := a.Y + b.Y;
end;

class operator TVec2f.Implicit(const X: TVec2i): TVec2f;
begin
  Result.X := X.X;
  Result.Y := X.Y;
end;

class operator TVec2f.Subtract(X: Single; const a: TVec2f): TVec2f;
begin
  Result.X := X - a.X;
  Result.Y := X - a.Y;
end;

class operator TVec2f.Subtract(const a, b: TVec2f): TVec2f;
begin
  Result.X := a.X - b.X;
  Result.Y := a.Y - b.Y;
end;

class operator TVec2f.Multiply(const a, b: TVec2f): TVec2f;
begin
  Result.X := a.X * b.X;
  Result.Y := a.Y * b.Y;
end;

class operator TVec2f.Multiply(const a: TVec2f; X: Single): TVec2f;
begin
  Result.X := a.X * X;
  Result.Y := a.Y * X;
end;

class operator TVec2f.Divide(const a, b: TVec2f): TVec2f;
begin
  Result.X := a.X / b.X;
  Result.Y := a.Y / b.Y;
end;

class operator TVec2f.Divide(const a: TVec2f; X: Single): TVec2f;
begin
  Result.X := a.X / X;
  Result.Y := a.Y / X;
end;

class operator TVec2f.Negative(const X: TVec2f): TVec2f;
begin
  Result.X := - X.X;
  Result.Y := - X.Y;
end;

function TVec2f.Normal: TVec2f;
begin
  Result.X := Self.X - Self.Y;
  Result.Y := Self.Y - Self.X;
end;

function TVec2f.Normalize: TVec2f;
var
  d: Double;
begin
  d := Distance(TVec2f.Create(0, 0));
  Result.X := Self.X / d;
  Result.Y := Self.Y / d;
end;

function TVec2f.Distance(const X: TVec2f): Single;
begin
  Result := Sqrt(Sqr(X.X - Self.X) + Sqr(X.Y - Self.Y));
end;

function TVec2f.Dot(const X: TVec2f): Single;
begin
  Result := X.X * Self.X + X.Y * Self.Y;
end;

constructor TVec2f.Create(X, Y: Single);
begin
  Self.X := X;
  Self.Y := Y;
end;

function TVec2f.Lerp(const X: TVec2f; dist: Single): TVec2f;
begin
  Result := (X - Self) * dist + Self;
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

