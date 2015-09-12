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

unit QuadEngine.Input;

interface

uses
  windows,
  messages,
  QuadEngine,
  Vec2f;

type
  TQuadInput = class(TInterfacedObject, IQuadInput)
  private
    FIsKeysDown: array[0..255] of Boolean;
    FIsKeysPress: array[0..255] of Boolean;
    FIsKeysCanPress: array[0..255] of Boolean;

    FOldMousePosition: TVec2f;
    FMousePosition: TVec2f;
    FMouseCanPosition: TVec2f;
    FMouseVector: TVec2f;

    FIsMouseDown: array[TMouseButtons] of Boolean;
    FIsMouseClick: array[TMouseButtons] of Boolean;
    FIsMouseCanClick: array[TMouseButtons] of Boolean;

    FMouseWheel: TVec2f;
    FMouseCanWheel: TVec2f;

  public
    constructor Create;
    function IsKeyDown(const AKey: Byte): Boolean; stdcall;
    function IsKeyPress(const AKey: Byte): Boolean; stdcall;

    function GetMousePosition: TVec2f; stdcall;
    function GetMouseVector: TVec2f; stdcall;

    function IsMouseDown(const AButton: TMouseButtons): Boolean; stdcall;
    function IsMouseClick(const AButton: TMouseButtons): Boolean; stdcall;
    function GetMouseWheel: TVec2f; stdcall;

    procedure Update; stdcall;

    procedure SetKeyState(const AKey: Word; const AState: Boolean);
    procedure SetMouseButtonState(const AButton: TMouseButtons; const AState: Boolean);
    procedure SetMousePosition(const APosition: TVec2i);
    procedure SetMouseWheel(const AVector: TVec2i);
  end;

implementation

constructor TQuadInput.Create;
begin
  FillChar(FIsKeysDown, SizeOf(FIsKeysDown), 0);
  FillChar(FIsKeysPress, SizeOf(FIsKeysDown), 0);
  FillChar(FIsKeysCanPress, SizeOf(FIsKeysDown), 0);

  FillChar(FIsMouseDown, Length(FIsMouseDown), 0);
  FillChar(FIsMouseClick, Length(FIsMouseClick), 0);
  FillChar(FIsMouseCanClick, Length(FIsMouseCanClick), 0);

  FOldMousePosition := TVec2f.Zero;
  FMousePosition := TVec2f.Zero;
  FMouseCanPosition := TVec2f.Zero;
  FMouseVector := TVec2f.Zero;

  FMouseWheel := TVec2f.Zero;
  FMouseCanWheel := TVec2f.Zero;
end;

procedure TQuadInput.SetKeyState(const AKey: Word; const AState: Boolean);
begin
  if AState and not FIsKeysDown[AKey] then
    FIsKeysCanPress[AKey] := True;
  FIsKeysDown[AKey] := AState;
end;

procedure TQuadInput.SetMouseButtonState(const AButton: TMouseButtons; const AState: Boolean);
begin
  if AState and not FIsMouseDown[AButton] then
    FIsMouseCanClick[AButton] := True;

  FIsMouseDown[AButton] := AState;
end;

procedure TQuadInput.SetMousePosition(const APosition: TVec2i);
begin
  FMouseCanPosition := APosition;
end;

procedure TQuadInput.SetMouseWheel(const AVector: TVec2i);
begin
  FMouseCanWheel := FMouseCanWheel + AVector;
end;

procedure TQuadInput.Update; stdcall;
begin
  Move(FIsKeysCanPress, FIsKeysPress, 256);
  FillChar(FIsKeysCanPress, SizeOf(FIsKeysDown), 0);

  Move(FIsMouseCanClick, FIsMouseClick, Length(FIsMouseCanClick));
  FillChar(FIsMouseCanClick, Length(FIsMouseCanClick), 0);

  FMousePosition := FMouseCanPosition;
  FMouseVector := FMousePosition - FOldMousePosition;
  FOldMousePosition := FMousePosition;

  FMouseWheel := FMouseCanWheel;
  FMouseCanWheel := TVec2f.Zero;
end;

function TQuadInput.IsKeyDown(const AKey: Byte): Boolean; stdcall;
begin
  Result := FIsKeysDown[AKey];
end;

function TQuadInput.IsKeyPress(const AKey: Byte): Boolean; stdcall;
begin
  Result := FIsKeysPress[AKey];
end;

function TQuadInput.GetMousePosition: TVec2f; stdcall;
begin
  Result := FMousePosition;
end;

function TQuadInput.GetMouseVector: TVec2f; stdcall;
begin
  Result := FMouseVector;
end;

function TQuadInput.IsMouseDown(const AButton: TMouseButtons): Boolean; stdcall;
begin
  Result := FIsMouseDown[AButton];
end;

function TQuadInput.IsMouseClick(const AButton: TMouseButtons): Boolean; stdcall;
begin
  Result := FIsMouseClick[AButton];
end;

function TQuadInput.GetMouseWheel: TVec2f; stdcall;
begin
  Result := FMouseWheel;
end;

end.
