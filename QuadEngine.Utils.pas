{//=============================================================================
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
//=============================================================================}

unit QuadEngine.Utils;

interface

uses
  Winapi.Windows, Winapi.PSApi, System.SysUtils;

type
  TCPUExtensions = record
    CPUName : array[0..95] of AnsiChar;
    MMX, SSE, SSE2, SSE3, HT: Boolean;
  end;

  function GetAppMemoryUsed: Cardinal;
  function GetMemoryStatus: _MEMORYSTATUS;
  function NormalizeSize(int: Integer): Integer; assembler;
  function IsSingleIn(const AValue, Amin, Amax: Single): Boolean; inline;
  function GetCPUInfo: TCPUExtensions;
  procedure FastSinCos(Angle : Single; var Asin, Acos: Single); inline;
  function GetFilePath: string;

implementation

//=============================================================================
//
//=============================================================================
Function GetAppMemoryUsed : Cardinal;
var
  pmc: TProcessMemoryCounters;
begin
  Result := 0;
  pmc.cb := SizeOf(pmc);
  if GetProcessMemoryInfo(GetCurrentProcess, @pmc, SizeOf(pmc)) then
    Result := pmc.WorkingSetSize;
end;

//=============================================================================
//
//=============================================================================
Function GetMemoryStatus: _MEMORYSTATUS;
begin
  GlobalMemoryStatus(Result);
end;

//=============================================================================
// Next or this value in power of two
//=============================================================================
function NormalizeSize(int: Integer): Integer; assembler;
asm
  bsr ecx, eax
  mov edx, 2
  add eax, eax
  shl edx, cl
  cmp eax, edx
  jne @ne
  shr edx, 1
  @ne :
  mov eax, edx
end;

//=============================================================================
//
//=============================================================================
function IsSingleIn(const AValue, Amin, Amax: Single): Boolean;
begin
  Result := (AValue > Amin) and (AValue < Amax);
end;

//=============================================================================
//
//=============================================================================
function GetCPUInfo: TCPUExtensions;
begin

end;

//=============================================================================
//
//=============================================================================
procedure FastSinCos(Angle : Single; var Asin, Acos: Single); inline;
begin
  //always wrap input angle to -PI..PI
  repeat
    if Angle < -Pi then
      Angle := Angle + Pi * 2
    else
      if Angle > Pi then
        Angle := Angle - Pi * 2;
  until IsSingleIn(Angle, -Pi, Pi);

  //compute sine
  if Angle < 0 then
  begin
    Asin := 1.27323954 * Angle + 0.405284735 * Angle * Angle;

    if Asin < 0 then
      Asin := 0.225 * (Asin * -Asin - Asin) + Asin
    else
      Asin := 0.225 * (Asin * Asin - Asin) + Asin;
  end
  else
  begin
    Asin := 1.27323954 * Angle - 0.405284735 * Angle * Angle;

    if Asin < 0 then
      Asin := 0.225 * (Asin * -Asin - Asin) + Asin
    else
      Asin := 0.225 * (Asin * Asin - Asin) + Asin;
  end;

  //compute cosine: sin(x + PI/2) = cos(x)
  Angle := Angle + Pi / 2;
  if Angle > Pi then
    Angle := Angle - 2 * Pi;

  if Angle < 0 then
  begin
      Acos := 1.27323954 * Angle + 0.405284735 * Angle * Angle;

      if Acos < 0 then
          Acos := 0.225 * (Acos * -Acos - Acos) + Acos
      else
          Acos := 0.225 * (Acos * Acos - Acos) + Acos;
  end
  else
  begin
      Acos := 1.27323954 * Angle - 0.405284735 * Angle * Angle;

      if Acos < 0 then
        Acos := 0.225 * (Acos * -Acos - Acos) + Acos
      else
        Acos := 0.225 * (Acos * Acos - Acos) + Acos;
  end;
end;

//=============================================================================
//
//=============================================================================

function GetFilePath: string;
var
  buffer: array [0..MAX_PATH] of WideChar;
begin
  GetModuleFileNameW(Hinstance, buffer, MAX_PATH);
  Result := ExtractFilePath(buffer);
end;

end.
