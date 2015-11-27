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
    R_HEIGHT = 3;
  private
    FBuffer: IQuadTexture;
    FDiffuseMap: IQuadTexture;
    FNormalMap: IQuadTexture;
    FSpecularMap: IQuadTexture;
    FHeightMap: IQuadTexture;
    FQuadRender: TQuadRender;
    FCamera: TQuadCamera;
  public
    constructor Create(AQuadRender: TQuadRender); reintroduce;
    function DiffuseMap: IQuadTexture; stdcall;
    function NormalMap: IQuadTexture; stdcall;
    function SpecularMap: IQuadTexture; stdcall;
    function HeightMap: IQuadTexture; stdcall;
    function Buffer: IQuadTexture; stdcall;
    procedure DrawLight(const APos: TVec3f; ARadius: Single; AColor: Cardinal); stdcall;
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

  if FQuadRender.NumSimultaneousRTs < 4 then
    Device.Log.Write('Error: Videocard does not support 4 Simultaneous Render Targets.');

  Device.CreateRenderTarget(FQuadRender.Width, FQuadRender.Height, FBuffer, R_DIFFUSE);
  Device.CreateRenderTarget(FQuadRender.Width, FQuadRender.Height, FBuffer, R_NORMAL);
  Device.CreateRenderTarget(FQuadRender.Width, FQuadRender.Height, FBuffer, R_SCPECULAR);
  Device.CreateRenderTarget(FQuadRender.Width, FQuadRender.Height, FBuffer, R_HEIGHT);

  FDiffuseMap := TQuadTexture.Create(FQuadRender);
  FNormalMap := TQuadTexture.Create(FQuadRender);
  FSpecularMap := TQuadTexture.Create(FQuadRender);
  FHeightMap := TQuadTexture.Create(FQuadRender);

  FDiffuseMap.AssignTexture(FBuffer, R_DIFFUSE, 0);
  FNormalMap.AssignTexture(FBuffer, R_NORMAL, 0);
  FSpecularMap.AssignTexture(FBuffer, R_SCPECULAR, 0);
  FHeightMap.AssignTexture(FBuffer, R_HEIGHT, 0);

  FDiffuseMap.SetIsLoaded(FQuadRender.Width, FQuadRender.Height);
  FNormalMap.SetIsLoaded(FQuadRender.Width, FQuadRender.Height);
  FSpecularMap.SetIsLoaded(FQuadRender.Width, FQuadRender.Height);
  FHeightMap.SetIsLoaded(FQuadRender.Width, FQuadRender.Height);
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.DiffuseMap: IQuadTexture;
begin
  Result := FDiffuseMap;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadGBuffer.DrawLight(const APos: TVec3f; ARadius: Single;
  AColor: Cardinal);
var
  LightPos: TVec3f;
  LightUV: array[0..3] of Single;
  ScreenRatio: Single;
  Position: TVec2f;
begin
  ScreenRatio := FBuffer.GetTextureWidth / FBuffer.GetTextureHeight;

  Position := TVec2f.Create(APos.X, APos.Y);

  if Assigned(FCamera) then
  begin
    Aradius := Aradius * FCamera.GetScale;
    Position := FCamera.GetTransformed(Position);
  end;

  TQuadShader.DeferredShading.BindVariableToPS(5, @LightUV[0], 1);
  TQuadShader.DeferredShading.BindVariableToPS(6, @ScreenRatio, 1);

  Device.Render.SetBlendMode(qbmSrcAlphaAdd);

  lightUV[0] := Position.X / FBuffer.GetTextureWidth;
  lightUV[1] := Position.Y / FBuffer.GetTextureHeight;
  lightUV[2] := APos.Z / 100;
  lightUV[3] := Aradius / FBuffer.GetTextureWidth;

  TQuadShader.DeferredShading.SetShaderState(True);

  FBuffer.DrawMap(TVec2f.Create(Position.X - Aradius, Position.Y - Aradius),
                  TVec2f.Create(Position.X + Aradius, Position.Y + Aradius),
                  TVec2f.Create((Position.X - Aradius) / FBuffer.GetTextureWidth, (Position.Y - Aradius) / FBuffer.GetTextureHeight),
                  TVec2f.Create((Position.X + Aradius) / FBuffer.GetTextureWidth, (Position.Y + Aradius) / FBuffer.GetTextureHeight),
                  AColor);

  TQuadShader.DeferredShading.SetShaderState(False);
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.NormalMap: IQuadTexture;
begin
  Result := FNormalMap;
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.SpecularMap: IQuadTexture;
begin
  Result := FSpecularMap;
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.HeightMap: IQuadTexture;
begin
  Result := FHeightMap;
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.Buffer: IQuadTexture; stdcall;
begin
  Result := FBuffer;
end;

end.
