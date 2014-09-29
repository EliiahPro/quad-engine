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
  Winapi.Windows, Winapi.PSApi;

type
  TCPUExtensions = record
    CPUName : array[0..95] of AnsiChar;
    MMX, SSE, SSE2, SSE3, HT: Boolean;
  end;

  function GetAppMemoryUsed: Cardinal;
  function GetMemoryStatus: _MEMORYSTATUS;
  function NormalizeSize(int: Integer): Integer; assembler;
  function IsSingleIn(AValue, Amin, Amax: Single): Boolean; inline;
  function GetCPUInfo: TCPUExtensions;

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
function IsSingleIn(AValue, Amin, Amax: Single): Boolean;
begin
  Result := (AValue > Amin) and (AValue < Amax);
end;

//=============================================================================
//
//=============================================================================
function GetCPUInfo: TCPUExtensions;
begin

end;

end.
