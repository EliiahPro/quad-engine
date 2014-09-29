//=============================================================================
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
//=============================================================================

unit QuadEngine.Camera;

interface

Uses
  QuadEngine, QuadEngine.Render, Winapi.DXTypes, Math, Vec2f;

type
  TQuadCamera = class(TInterfacedObject, IQuadCamera)
  private
    FRender: TQuadRender;
    FViewMatrix: D3DMATRIX;
    FAngle: Single;
    FScale: Single;
    FXTranslation: Single;
    FYTranslation: Single;
  public
    constructor Create(AQuadRender: TQuadRender);
    procedure Scale(AScale: Single); stdcall;
    procedure Rotate(AAngle: Single); stdcall;
    procedure Translate(const ADistance: TVec2f); stdcall;
    procedure Reset; stdcall;
    procedure Enable; stdcall;
    procedure Disable; stdcall;
    function GetPosition: TVec2f; stdcall;
    function GetAngle: Single; stdcall;
    function GetScale: Single; stdcall;
  end;

implementation

uses
  QuadEngine.Device, Winapi.Direct3D9;

{ TQuadCamera }

function MultiplyMatrix(const A, B: D3DMATRIX): D3DMATRIX;
var
  i, j: Integer;
  r: Integer;
begin
  for i := 0 to 3 do
  for j := 0 to 3 do
  begin
    Result.m[i, j] := 0;
    for r := 0 to 3 do
      Result.m[i, j] := Result.m[i, j] + A.m[i, r] * B.m[r, j];
  end;
end;

procedure TQuadCamera.Enable;
var
  SinA, CosA: Single;
  Rotate: D3DMATRIX;
  Translate: D3DMATRIX;
begin
  FRender.FlushBuffer;

  SinCos(DegToRad(FAngle), SinA, CosA);

  // translate
  Translate._11 := 1;
  Translate._12 := 0;
  Translate._13 := 0;
  Translate._14 := 0;

  Translate._21 := 0;
  Translate._22 := 1;
  Translate._23 := 0;
  Translate._24 := 0;

  Translate._31 := 0;
  Translate._32 := 0;
  Translate._33 := 1;
  Translate._34 := 0;

  Translate._41 := -(FRender.Width / 2);
  Translate._42 := -(FRender.Height / 2);
  Translate._43 := 0;
  Translate._44 := 1;

  // scale & rorate
  Rotate._11 := 2 / FRender.Width * CosA * FScale;
  Rotate._12 := - 2 / FRender.Height * SinA;
  Rotate._13 := 0;
  Rotate._14 := 0;

  Rotate._21 := 2 / FRender.Width * (- SinA);
  Rotate._22 := -2 / FRender.Height * CosA * FScale;
  Rotate._23 := 0;
  Rotate._24 := 0;

  Rotate._31 := 0;
  Rotate._32 := 0;
  Rotate._33 := 1;
  Rotate._34 := 0;

  Rotate._41 := 0;
  Rotate._42 := 0;
  Rotate._43 := 0;
  Rotate._44 := 1;

  FViewMatrix := MultiplyMatrix(Translate, Rotate);

  // translate backward
  Translate._11 := 1;
  Translate._12 := 0;
  Translate._13 := 0;
  Translate._14 := 0;

  Translate._21 := 0;
  Translate._22 := 1;
  Translate._23 := 0;
  Translate._24 := 0;

  Translate._31 := 0;
  Translate._32 := 0;
  Translate._33 := 1;
  Translate._34 := 0;

  Translate._41 := -(FXTranslation * 2) / FRender.Width * FSCale;
  Translate._42 := (FYTranslation * 2) / FRender.Height * FSCale;
  Translate._43 := 0;
  Translate._44 := 1;

  FViewMatrix := MultiplyMatrix(FViewMatrix, Translate);

  Device.LastResultCode := FRender.D3DDevice.SetTransform(D3DTS_PROJECTION, FViewMatrix);
  FRender.ViewMatrix := FViewMatrix;
end;

constructor TQuadCamera.Create(AQuadRender: TQuadRender);
begin
  FRender := AQuadRender;
  FScale := 1.0;
  FAngle := 0;
end;

procedure TQuadCamera.Reset;
begin
  FRender.FlushBuffer;

  FViewMatrix._11 := 2 / FRender.Width;
  FViewMatrix._12 := 0;
  FViewMatrix._13 := 0;
  FViewMatrix._14 := 0;

  FViewMatrix._21 := 0;
  FViewMatrix._22 := -2 / FRender.Height;
  FViewMatrix._23 := 0;
  FViewMatrix._24 := 0;

  FViewMatrix._31 := 0;
  FViewMatrix._32 := 0;
  FViewMatrix._33 := 1;
  FViewMatrix._34 := 0;

  FViewMatrix._41 := -1;
  FViewMatrix._42 := 1;
  FViewMatrix._43 := 0;
  FViewMatrix._44 := 1;

  FXTranslation := 0;
  FYTranslation := 0;
  FAngle := 0;
  FScale := 1.0;

  Device.LastResultCode := FRender.D3DDevice.SetTransform(D3DTS_PROJECTION, FViewMatrix);
end;

procedure TQuadCamera.Rotate(AAngle: Single);
begin
  FAngle := FAngle + AAngle;
end;

procedure TQuadCamera.Translate(const ADistance: TVec2f);
begin
  FXTranslation := FXTranslation + ADistance.X;
  FYTranslation := FYTranslation + ADistance.Y;
end;

procedure TQuadCamera.Scale(AScale: Single);
begin
  FScale := AScale;
end;

procedure TQuadCamera.Disable;
begin
  FRender.ChangeResolution(FRender.Width, FRender.Height);
end;

function TQuadCamera.GetPosition: TVec2f;
begin
  Result.Create(FXTranslation, FYTranslation);
end;

function TQuadCamera.GetAngle: Single;
begin
  Result := FAngle;
end;

function TQuadCamera.GetScale: Single;
begin
  Result := FScale;
end;


end.
