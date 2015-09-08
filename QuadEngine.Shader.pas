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

unit QuadEngine.Shader;

interface

uses
  windows, direct3d9, QuadEngine.Render, QuadEngine.Utils, QuadEngine, System.SysUtils;

type
  TBindedVariable = packed record
    Variable: Pointer;
    RegisterIndex: Byte;
    Size: Byte;
    IsVS: Boolean;
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
    procedure LoadFromResource(AResourceName: PWideChar; AIsPixelShader: Boolean = True);

    procedure BindVariableToVS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    procedure BindVariableToPS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    function GetVertexShader(out Shader: IDirect3DVertexShader9): HResult; stdcall;
    function GetPixelShader(out Shader: IDirect3DPixelShader9): HResult; stdcall;
    procedure LoadVertexShader(AVertexShaderFilename: PWideChar); stdcall;
    procedure LoadPixelShader(APixelShaderFilename: PWideChar); stdcall;
    procedure LoadComplexShader(AVertexShaderFilename, APixelShaderFilename: PWideChar); stdcall;
    procedure SetShaderState(AIsEnabled: Boolean); stdcall;
  class var
    DistanceField: TQuadShader;
    CircleShader: TQuadShader;
    MRTShader: TQuadShader;
    DeferredShading: TQuadShader;
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
var
  i: Integer;
begin
  for i := 0 to FBindedVariableCount - 1 do
    if FBindedVariables[i].IsVS and (FBindedVariables[i].RegisterIndex = ARegister) then
      if (FBindedVariables[i].Variable <> AVariable) then
      begin
        FBindedVariables[i].Variable := AVariable;
        FBindedVariables[i].Size := ASize;
        Exit;
      end
      else
        Exit;

  FBindedVariableCount := FBindedVariableCount + 1;
  SetLength(FBindedVariables, FBindedVariableCount);

  with FBindedVariables[FBindedVariableCount - 1] do
  begin
    RegisterIndex := ARegister;
    Variable := AVariable;
    Size := ASize;
    isVS := True;
  end;
end;

//=============================================================================
// bind variable to pixel shader
//=============================================================================
procedure TQuadShader.BindVariableToPS(ARegister: Byte; AVariable: Pointer;
  ASize: Byte);
var
  i: Integer;
begin
  for i := 0 to FBindedVariableCount - 1 do
    if not FBindedVariables[i].IsVS and (FBindedVariables[i].RegisterIndex = ARegister) then
      if (FBindedVariables[i].Variable <> AVariable) then
      begin
        FBindedVariables[i].Variable := AVariable;
        FBindedVariables[i].Size := ASize;
        Exit;
      end
      else
        Exit;


  FBindedVariableCount := FBindedVariableCount + 1;
  SetLength(FBindedVariables, FBindedVariableCount);

  with FBindedVariables[FBindedVariableCount - 1] do
  begin
    RegisterIndex := ARegister;
    Variable := AVariable;
    Size := ASize;
    isVS := False;
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
procedure TQuadShader.LoadComplexShader(AVertexShaderFilename, APixelShaderFilename: PWidechar);
begin
  LoadVertexShader(AVertexShaderFilename);
  LoadPixelShader(APixelShaderFilename);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadShader.LoadFromResource(AResourceName: PWideChar; AIsPixelShader: Boolean = True);
var
  hFind, hRes: THandle;
  size: Cardinal;
  Data: Pointer;
begin
  hFind := FindResource(HInstance, AResourceName, RT_RCDATA);
  if hFind <> 0 then
  begin
    hRes := LoadResource(HInstance, hFind);
    if hRes <> 0  then
    begin
      size := SizeofResource(HInstance, hFind);
      if size > 0 then
      begin
        Data := LockResource(hRes);
        if AIsPixelShader then
          Device.LastResultCode := FQuadRender.D3DDevice.CreatePixelShader(Data, Fps)
        else
          Device.LastResultCode := FQuadRender.D3DDevice.CreateVertexShader(Data, Fvs);
        UnlockResource(hRes);
      end;
    end;
  end;
  FreeResource(hFind);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadShader.LoadPixelShader(APixelShaderFilename: PWideChar);
var
  dwpPS: PDWORD;
  filePS: THandle;
  mapPS: THandle;
begin
  if Assigned(Device.Log) then
  begin
    Device.Log.Write(PWideChar('Loading shader "' + APixelShaderFilename + '"'));

    if not FileExists(APixelShaderFilename) then
    begin
      Device.Log.Write(PWideChar('Shader "' + APixelShaderFilename + '" not found!'));
      Exit;
    end;
  end;

  filePS := CreateFile(APixelShaderFilename, GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  mapPS := CreateFileMapping(filePS, nil, PAGE_READONLY, 0, 0, nil);

  dwpPS := MapViewOfFile(mapPS, FILE_MAP_READ, 0, 0, 0);

  //  todo:
  {
  if Assigned(dwpPS) then
  begin
    Version := Word(dwpPS^);
    if ((Version and $FF) = 2) and Device.Render.ShaderModel <> qsm20 then
    Device.Log.Write(PWideChar('Shader "' + APixelShaderFilename + '" have is ps_2_0 shader model'));

  end;
   }
  Device.LastResultCode := FQuadRender.D3DDevice.CreatePixelShader(dwpPS, Fps);

  UnmapViewOfFile(dwpPS);
  CloseHandle(mapPS);
  CloseHandle(filePS);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadShader.LoadVertexShader(AVertexShaderFilename: PWideChar);
var
  dwpVS: PDWORD;
  fileVS: THandle;
  mapVS: THandle;
begin
  if Assigned(Device.Log) then
  begin
    Device.Log.Write(PWideChar('Loading shader "' + AVertexShaderFilename + '"'));

    if not FileExists(AVertexShaderFilename) then
    begin
      Device.Log.Write(PWideChar('Shader "' + AVertexShaderFilename + '" not found!'));
      Exit;
    end;
  end;

  fileVS := CreateFile(AVertexShaderFilename, GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  mapVS := CreateFileMapping(fileVS, nil, PAGE_READONLY, 0, 0, nil);

  dwpVS := MapViewOfFile(mapVS, FILE_MAP_READ, 0, 0, 0);

  Device.LastResultCode := FQuadRender.D3DDevice.CreateVertexShader(dwpVS, Fvs);

  UnmapViewOfFile(dwpVS);
  CloseHandle(mapVS);
  CloseHandle(fileVS);
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
        Device.LastResultCode := FQuadRender.D3DDevice.SetVertexShaderConstantF(FBindedVariables[i].RegisterIndex, FBindedVariables[i].Variable, FBindedVariables[i].Size)
      else
        Device.LastResultCode := FQuadRender.D3DDevice.SetPixelShaderConstantF(FBindedVariables[i].RegisterIndex, FBindedVariables[i].Variable, FBindedVariables[i].Size);
    end;
  end
  else
  begin
    Device.LastResultCode := FQuadRender.D3DDevice.SetVertexShader(nil);
    Device.LastResultCode := FQuadRender.D3DDevice.SetPixelShader(nil);
  end;
end;

end.
