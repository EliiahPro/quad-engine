//=============================================================================
//             ╔═══════════╦═╗
//             ║           ║ ║
//             ║           ║ ║
//             ║ ╔╗ ║║ ╔╗ ╔╣ ║
//             ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
//             ║  ║ engine   ║
//             ║  ║          ║
//             ╚══╩══════════╝
//=============================================================================

unit QuadEngine.Camera;

interface

Uses
  QuadEngine, QuadEngine.Render, Winapi.DXTypes, Math;

type
  TQuadCamera = class(TInterfacedObject, IQuadCamera)
  private
    FRender: TQuadRender;
    FViewMatrix: D3DMATRIX;
    FAngle: Single;
    FScale: Single;
//    FXShear: Single;
//    FYShear: Single;
//    FXShift: Single;
//    FYShift: Single;
    FXTranslation: Single;
    FYTranslation: SIngle;
  public
    constructor Create(AQuadRender: TQuadRender);
    procedure Shift(AXShift, AYShift: Single); stdcall;
    procedure Shear(AXShear, AYShear: Single); stdcall;
    procedure Zoom(AScale: Single); stdcall;
    procedure Rotate(AAngle: Single); stdcall;
    procedure Translate(AXDistance, AYDistance: Single); stdcall;
    procedure Reset; stdcall;
    procedure ApplyTransform; stdcall;
  end;

implementation

uses
  QuadEngine.Device, Winapi.Direct3D9;

{ TQuadCamera }

procedure TQuadCamera.ApplyTransform;
var
  SinA, CosA: Single;
begin
  SinCos(DegToRad(FAngle), SinA, CosA);

  FViewMatrix._11 := 2 / FRender.Width * CosA * FScale;
  FViewMatrix._12 := - 2 / FRender.Height * SinA;
  FViewMatrix._13 := 0;
  FViewMatrix._14 := 0;

  FViewMatrix._21 := 2 / FRender.Width * (- SinA);
  FViewMatrix._22 := -2 / FRender.Height * CosA * FScale;
  FViewMatrix._23 := 0;
  FViewMatrix._24 := 0;

  FViewMatrix._31 := 0  ;
  FViewMatrix._32 := 0;
  FViewMatrix._33 := 1;
  FViewMatrix._34 := 0;

  FViewMatrix._41 := -1 - FXTranslation / FRender.Width;
  FViewMatrix._42 := 1 - FYTranslation / FRender.Height;
  FViewMatrix._43 := 0;
  FViewMatrix._44 := 1;

  Device.LastResultCode := FRender.D3DDevice.SetTransform(D3DTS_PROJECTION, FViewMatrix);
end;

constructor TQuadCamera.Create(AQuadRender: TQuadRender);
begin
  FRender := AQuadRender;
  FScale := 1.0;
  FAngle := 0;
end;

procedure TQuadCamera.Reset;
begin
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

  Device.LastResultCode := FRender.D3DDevice.SetTransform(D3DTS_PROJECTION, FViewMatrix);
end;

procedure TQuadCamera.Rotate(AAngle: Single);
begin
  FAngle := FAngle + AAngle;
end;

procedure TQuadCamera.Shear(AXShear, AYShear: Single);
begin

end;

procedure TQuadCamera.Shift(AXShift, AYShift: Single);
begin

end;

procedure TQuadCamera.Translate(AXDistance, AYDistance: Single);
begin
  FXTranslation := FXTranslation + AXDistance;
  FYTranslation := FYTranslation + AYDistance;
end;

procedure TQuadCamera.Zoom(AScale: Single);
begin
  FScale := AScale;
end;

end.
