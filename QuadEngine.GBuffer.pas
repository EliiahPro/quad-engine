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

unit QuadEngine.GBuffer;

interface

uses
  windows, direct3d9, QuadEngine.Render, QuadEngine.Utils, QuadEngine,
  System.SysUtils, Vec2f, QuadEngine.Camera;

type
  TQuadGBuffer = class(TInterfacedObject, IQuadGBuffer)
  const
    R_DIFFUSE = 0;
    R_NORMAL = 1;
    R_SCPECULAR = 2;
  private
    FBuffer: IQuadTexture;
    FDiffuseMap: IQuadTexture;
    FNormalMap: IQuadTexture;
    FSpecularMap: IQuadTexture;
    FQuadRender: TQuadRender;
    FCamera: TQuadCamera;
  public
    constructor Create(AQuadRender: TQuadRender); reintroduce;
    procedure GetDiffuseMap(out ADiffuseMap: IQuadTexture); stdcall;
    procedure GetNormalMap(out ANormalMap: IQuadTexture); stdcall;
    procedure GetSpecularMap(out ASpecularMap: IQuadTexture); stdcall;
    procedure GetBuffer(out ABuffer: IQuadTexture); stdcall;
    procedure DrawLight(const APos: TVec2f; AHeight: Single; ARadius: Single; AColor: Cardinal); stdcall;
    property Camera: TQuadCamera read FCamera write FCamera;
  end;

implementation

uses
  QuadEngine.Device, QuadEngine.Texture, QuadEngine.Shader;

{ TQuadGBuffer }

//=============================================================================
//
//=============================================================================
constructor TQuadGBuffer.Create(AQuadRender: TQuadRender);
begin
  FQuadRender := AQuadRender;

  if FQuadRender.NumSimultaneousRTs < 3 then
    Device.Log.Write('Error: Videocard does not support 3 Simultaneous Render Targets.');

  Device.CreateRenderTarget(FQuadRender.Width, FQuadRender.Height, FBuffer, R_DIFFUSE);
  Device.CreateRenderTarget(FQuadRender.Width, FQuadRender.Height, FBuffer, R_NORMAL);
  Device.CreateRenderTarget(FQuadRender.Width, FQuadRender.Height, FBuffer, R_SCPECULAR);

  Device.CreateTexture(FDiffuseMap);
  Device.CreateTexture(FNormalMap);
  Device.CreateTexture(FSpecularMap);
           {
  FDiffuseMap.AssignTexture(FBuffer, R_DIFFUSE, 0);
  FNormalMap.AssignTexture(FBuffer, R_NORMAL, 0);
  FSpecularMap.AssignTexture(FBuffer, R_SCPECULAR, 0);

  FDiffuseMap._Release;
  FNormalMap._Release;
  FSpecularMap._Release;  }

  FDiffuseMap.SetIsLoaded(FQuadRender.Width, FQuadRender.Height);
  FNormalMap.SetIsLoaded(FQuadRender.Width, FQuadRender.Height);
  FSpecularMap.SetIsLoaded(FQuadRender.Width, FQuadRender.Height);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadGBuffer.GetDiffuseMap(out ADiffuseMap: IQuadTexture);
begin
  ADiffuseMap := FDiffuseMap;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadGBuffer.DrawLight(const APos: TVec2f; AHeight: Single;
  ARadius: Single; AColor: Cardinal);
var
  LightPos: TVec3f;
  LightUV: array[0..3] of Single;
  ScreenRatio: Single;
  Position, CameraPosition: TVec2f;
begin
  if Device.Render.IsDeviceLost then
    Exit;

  ScreenRatio := FBuffer.GetTextureWidth / FBuffer.GetTextureHeight;

  Position := TVec2f.Create(APos.X, APos.Y);

  if Assigned(FCamera) then
  begin
    Aradius := Aradius * FCamera.GetScale;
    FCamera.Project(Position, CameraPosition);
  end;

  TQuadShader.DeferredShading.BindVariableToPS(5, @LightUV[0], 1);
  TQuadShader.DeferredShading.BindVariableToPS(6, @ScreenRatio, 1);

  Device.Render.SetBlendMode(qbmSrcAlphaAdd);

  lightUV[0] := CameraPosition.X / FBuffer.GetTextureWidth;
  lightUV[1] := CameraPosition.Y / FBuffer.GetTextureHeight;
  lightUV[2] := AHeight / 100;
  lightUV[3] := Aradius / FBuffer.GetTextureWidth;

  TQuadShader.DeferredShading.SetShaderState(True);

  FBuffer.DrawMap(TVec2f.Create(CameraPosition.X - Aradius, CameraPosition.Y - Aradius),
                  TVec2f.Create(CameraPosition.X + Aradius, CameraPosition.Y + Aradius),
                  TVec2f.Create((CameraPosition.X - Aradius) / FBuffer.GetTextureWidth, (CameraPosition.Y - Aradius) / FBuffer.GetTextureHeight),
                  TVec2f.Create((CameraPosition.X + Aradius) / FBuffer.GetTextureWidth, (CameraPosition.Y + Aradius) / FBuffer.GetTextureHeight),
                  AColor);

  TQuadShader.DeferredShading.SetShaderState(False);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadGBuffer.GetNormalMap(out ANormalMap: IQuadTexture); stdcall;
begin
  ANormalMap := FNormalMap;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadGBuffer.GetSpecularMap(out ASpecularMap: IQuadTexture); stdcall;
begin
  ASpecularMap := FSpecularMap;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadGBuffer.GetBuffer(out ABuffer: IQuadTexture); stdcall;
begin
  ABuffer := FBuffer;
end;

end.
