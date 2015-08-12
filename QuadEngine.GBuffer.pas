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
  windows, direct3d9, QuadEngine.Render, QuadEngine.Utils, QuadEngine, System.SysUtils;

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
  public
    constructor Create(AQuadRender: TQuadRender); reintroduce;
    function DiffuseMap: IQuadTexture; stdcall;
    function NormalMap: IQuadTexture; stdcall;
    function SpecularMap: IQuadTexture; stdcall;
    function HeightMap: IQuadTexture; stdcall;
    function Buffer: IQuadTexture; stdcall;
  end;

implementation

uses
  QuadEngine.Device;

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
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.DiffuseMap: IQuadTexture;
begin
  Device.CreateTexture(Result);
  Result.AssignTexture(FBuffer, 0, R_DIFFUSE);
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.NormalMap: IQuadTexture;
begin
  Device.CreateTexture(Result);
  Result.AssignTexture(FBuffer, 0, R_NORMAL);
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.SpecularMap: IQuadTexture;
begin
  Device.CreateTexture(Result);
  Result.AssignTexture(FBuffer, 0, R_SCPECULAR);
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.HeightMap: IQuadTexture;
begin
  Device.CreateTexture(Result);
  Result.AssignTexture(FBuffer, 0, R_HEIGHT);
end;

//=============================================================================
//
//=============================================================================
function TQuadGBuffer.Buffer: IQuadTexture; stdcall;
begin
  Result := FBuffer;
end;

end.
