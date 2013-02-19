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

unit QuadEngine.Shader;

interface

uses
  windows, direct3d9, QuadEngine.Render, QuadEngine.Utils, QuadEngine;

type
  TBindedVariable = packed record
    variable : Pointer;
    register : Byte;
    Size : Byte;
    IsVS : Boolean;
  end;

  TQuadShader = class(TInterfacedObject, IQuadShader)
  private
    Fvs: IDirect3DVertexShader9;
    Fps: IDirect3DPixelShader9;
    FQuadRender: TQuadRender;
    FBindedVariables: array of TBindedVariable;
    FBindedVariableCount: Byte;
  public
    constructor Create(AQuadRender: TQuadRender); reintroduce;

    procedure BindVariableToVS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    procedure BindVariableToPS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    function GetVertexShader(out Shader: IDirect3DVertexShader9): HResult; stdcall;
    function GetPixelShader(out Shader: IDirect3DPixelShader9): HResult; stdcall;
    procedure LoadVertexShader(AVertexShaderFilename: PAnsiChar); stdcall;
    procedure LoadVertexShaderW(AVertexShaderFilename: PWideChar); stdcall;
    procedure LoadPixelShader(APixelShaderFilename: PAnsiChar); stdcall;
    procedure LoadPixelShaderW(APixelShaderFilename: PWideChar); stdcall;
    procedure LoadComplexShader(AVertexShaderFilename, APixelShaderFilename: PAnsiChar); stdcall;
    procedure LoadComplexShaderW(AVertexShaderFilename, APixelShaderFilename: PWideChar); stdcall;
    procedure SetShaderState(AIsEnabled: Boolean); stdcall;
  end;

implementation

uses
  QuadEngine.Device;

{ TQuadShader }

//=============================================================================
// bind variable to vertex shader
//=============================================================================
procedure TQuadShader.BindVariableToVS(ARegister: Byte; AVariable: Pointer;
  ASize: Byte);
begin
  FBindedVariableCount := FBindedVariableCount + 1;
  SetLength(FBindedVariables, FBindedVariableCount);

  with FBindedVariables[FBindedVariableCount - 1] do
  begin
    register := aRegister;
    variable := aVariable;
    Size     := aSize;
    isVS     := True;
  end;
end;

//=============================================================================
// bind variable to pixel shader
//=============================================================================
procedure TQuadShader.BindVariableToPS(ARegister: Byte; AVariable: Pointer;
  ASize: Byte);
begin
  FBindedVariableCount := FBindedVariableCount + 1;
  SetLength(FBindedVariables, FBindedVariableCount);

  with FBindedVariables[FBindedVariableCount - 1] do
  begin
    register := aRegister;
    variable := aVariable;
    Size     := aSize;
    isVS     := False;
  end;

end;

//=============================================================================
//
//=============================================================================
constructor TQuadShader.Create(AQuadRender : TQuadRender);
begin
  FQuadRender := AQuadRender;

  FBindedVariableCount := 0;
  SetLength(FBindedVariables, FBindedVariableCount);
end;

//=============================================================================
//
//=============================================================================
function TQuadShader.GetPixelShader(out Shader: IDirect3DPixelShader9): HResult;
begin
  Shader := Fps;
  Result := D3D_OK;  
end;

//=============================================================================
//
//=============================================================================
function TQuadShader.GetVertexShader(out Shader: IDirect3DVertexShader9): HResult; stdcall;
begin
  Shader := Fvs;
  Result := D3D_OK;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadShader.LoadComplexShader(AVertexShaderFilename, APixelShaderFilename: PAnsiChar);
begin
  LoadVertexShader(AVertexShaderFilename);
  LoadPixelShader(APixelShaderFilename);
end;

procedure TQuadShader.LoadComplexShaderW(AVertexShaderFilename,
  APixelShaderFilename: PWideChar);
begin
  LoadComplexShader(PAnsiChar(AnsiString(AVertexShaderFilename)), PAnsiChar(AnsiString(APixelShaderFilename)));
end;

//=============================================================================
//
//=============================================================================
procedure TQuadShader.LoadPixelShader(APixelShaderFilename: PAnsiChar);
var
  dwpPS : PDWORD;
  filePS: THandle;
  mapPS : THandle;
begin
  filePS := CreateFileA(APixelShaderFilename, GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  mapPS := CreateFileMapping(filePS, nil, PAGE_READONLY, 0, 0, nil);

  dwpPS := MapViewOfFile(mapPS, FILE_MAP_READ, 0, 0, 0);

  Device.LastResultCode := FQuadRender.D3DDevice.CreatePixelShader(dwpPS, Fps);

  UnmapViewOfFile(dwpPS);
  CloseHandle(mapPS);
  CloseHandle(filePS);
end;

procedure TQuadShader.LoadPixelShaderW(APixelShaderFilename: PWideChar);
begin
  LoadPixelShader(PAnsiChar(AnsiString(APixelShaderFilename)));
end;

//=============================================================================
//
//=============================================================================
procedure TQuadShader.LoadVertexShader(AVertexShaderFilename: PAnsiChar);
var
  dwpVS: PDWORD;
  fileVS: THandle;
  mapVS: THandle;
begin
  fileVS := CreateFileA(AVertexShaderFilename, GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  mapVS := CreateFileMapping(fileVS, nil, PAGE_READONLY, 0, 0, nil);

  dwpVS := MapViewOfFile(mapVS, FILE_MAP_READ, 0, 0, 0);

  Device.LastResultCode := FQuadRender.D3DDevice.CreateVertexShader(dwpVS, Fvs);

  UnmapViewOfFile(dwpVS);
  CloseHandle(mapVS);
  CloseHandle(fileVS);
end;

procedure TQuadShader.LoadVertexShaderW(AVertexShaderFilename: PWideChar);
begin
  LoadVertexShader(PAnsiChar(AnsiString(AVertexShaderFilename)));
end;

//=============================================================================
//
//=============================================================================
procedure TQuadShader.SetShaderState(AIsEnabled: Boolean);
var
  i: Integer;
begin
  FQuadRender.FlushBuffer;
  if AIsEnabled then
  begin
    Device.LastResultCode := FQuadRender.D3DDevice.SetVertexShader(Fvs);
    Device.LastResultCode := FQuadRender.D3DDevice.SetPixelShader(Fps);

    // bind variables
    for i := 0 to FBindedVariableCount - 1 do
    begin
      if FBindedVariables[i].isVS then
        Device.LastResultCode := FQuadRender.D3DDevice.SetVertexShaderConstantF(FBindedVariables[i].register, FBindedVariables[i].variable, FBindedVariables[i].Size)
      else
        Device.LastResultCode := FQuadRender.D3DDevice.SetPixelShaderConstantF(FBindedVariables[i].register, FBindedVariables[i].variable, FBindedVariables[i].Size);
    end;
  end
  else
  begin
    Device.LastResultCode := FQuadRender.D3DDevice.SetVertexShader(nil);
    Device.LastResultCode := FQuadRender.D3DDevice.SetPixelShader(nil);
  end;
end;

end.
