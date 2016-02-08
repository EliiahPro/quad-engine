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

unit QuadEngine.Texture;

interface

uses
  QuadEngine.Render, direct3d9, classes, QuadEngine.Log,
  QuadEngine, System.SyncObjs, Vec2f, QuadEngine.TextureLoader;

type
  TQuadTexture =  class(TInterfacedObject, IQuadTexture)
  private
    FQuadRender: TQuadRender;
    FTextures: array of IDirect3DTexture9;
    FWidth: Integer;
    FHeight: Integer;
    FFrameWidth: Integer;
    FFrameHeight: Integer;
    FPatternWidth: Integer;
    FPatternHeight: Integer;
    FPatternSize: TVec2f;
    FIsLoaded: Boolean;
    FSync: TCriticalSection;
    FIsLoadFromFile: Boolean;
    procedure SetTextureStages;
  public
    constructor Create(QuadRender: TQuadRender);
    destructor Destroy; override;

    function GetIsLoaded: Boolean; stdcall;
    function GetPatternCount: Integer; stdcall;
    function GetPatternHeight: Word; stdcall;
    function GetPatternWidth: Word; stdcall;
    function GetPixelColor(x, y: Integer; ARegister: Byte = 0): Cardinal; stdcall;
    function GetSpriteHeight: Word; stdcall;
    function GetSpriteWidth: Word; stdcall;
    function GetTexture(i: Byte): IDirect3DTexture9; stdcall;
    function GetTextureHeight: Word; stdcall;
    function GetTextureWidth: Word; stdcall;
    procedure AddTexture(ARegister: Byte; ATexture: IDirect3DTexture9); stdcall;
    procedure AssignTexture(AQuadTexture: IQuadTexture; ASourceRegister, ATargetRegister: Byte); stdcall;
    procedure Draw(const Position: Tvec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawFrame(const Position: Tvec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMap(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMapRotAxis(const PointA, PointB, UVA, UVB, Axis: TVec2f; Angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawPart(const Position: TVec2f; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawPartRot(const Center: TVec2f; angle, Scale: Double; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawPartRotAxis(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRot(const Center: TVec2f; angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotFrame(const Center: TVec2f; angle, Scale: Double; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxis(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxisFrame(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure LoadFromFile(ARegister: Byte; AFilename: PWideChar; APatternWidth: Integer = 0;
      APatternHeight: Integer = 0; AColorKey: Integer = -1); stdcall;
    procedure LoadFromStream(ARegister: Byte; AStream: Pointer; AStreamSize: Integer; APatternWidth: Integer = 0;
      APatternHeight: Integer = 0; AColorKey: Integer = -1); stdcall;
    procedure LoadFromRAW(ARegister: Byte; AData: Pointer; AWidth, AHeight: Integer; ASourceFormat: TRAWDataFormat = rdfARGB8); stdcall;
    procedure SetIsLoaded(AWidth, AHeight: Word); stdcall;

    property Texture[i: Byte]: IDirect3DTexture9 read GetTexture;
    property TextureWidth: Integer read FWidth;
    property TextureHeight: Integer read FHeight;
    property FrameWidth: Integer read FFrameWidth;
    property FrameHeight: Integer read FFrameHeight;
    property PatternWidth: Integer read FPatternWidth;
    property PatternHeight: Integer read FPatternHeight;
    property PatternsCount: Integer read GetPatternCount;
    property IsLoaded: Boolean read FIsLoaded;
  end;


implementation

uses
  QuadEngine.Utils, QuadEngine.Device, System.SysUtils, Math;

{ TQuadTexture }

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.AddTexture(ARegister: Byte; ATexture: IDirect3DTexture9);
begin
  FSync.Enter;

  FTextures[ARegister] := ATexture;

  FSync.Leave;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.AssignTexture(AQuadTexture: IQuadTexture; ASourceRegister, ATargetRegister: Byte);
begin
  AddTexture(ATargetRegister, AQuadTexture.GetTexture(ASourceRegister));
end;

//=============================================================================
//
//=============================================================================
constructor TQuadTexture.Create(QuadRender: TQuadRender);
begin
  FQuadRender := QuadRender;
  FIsLoaded := False;
  FPatternWidth := 0;
  FPatternHeight := 0;
  FPatternSize := TVec2f.Zero;
  FSync := TCriticalSection.Create;
  SetLength(FTextures, FQuadRender.MaxTextureStages);
  FIsLoadFromFile := False;
end;

//=============================================================================
// Draws sprite with [X, Y] position
//=============================================================================
procedure TQuadTexture.Draw(const Position: Tvec2f; Color: Cardinal);
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  FQuadRender.Drawrect(Position - 0.5, Position - 0.5 + TVec2f.Create(FFrameWidth, FFrameHeight),
                       TVec2f.Zero, TVec2f.Create(FFrameWidth / FWidth, FFrameHeight / FHeight),
                       Color);
end;

//=============================================================================
//
//=============================================================================
destructor TQuadTexture.Destroy;
var
  i: Integer;
begin
  FSync.Free;

  for i := 0 to High(FTextures) do
    FTextures[i] := nil;

  inherited;
end;

//=============================================================================
// Draws sprite with [X, Y] position and pattern
//=============================================================================
procedure TQuadTexture.DrawFrame(const Position: Tvec2f; Pattern: Word; Color: Cardinal);
var
  px, py : Integer;
  px2, py2 : Integer;
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  px := (Pattern mod (FFrameWidth div FPatternWidth)) * FPatternWidth;
  py := (Pattern div (FFrameWidth div FPatternWidth)) * FPatternHeight;
  px2 := px + FPatternWidth;
  py2 := py + FPatternHeight;

  FQuadRender.Drawrect(Position - 0.5, Position - 0.5 + TVec2f.Create(FPatternWidth, FPatternHeight),
                       TVec2f.Create(px / FWidth, py / FHeight), TVec2f.Create(px2 / FWidth, py2 / FHeight), Color);
end;

//=============================================================================
// Draws sprite with [X, Y, X2, Y2] vertex pos, and [U1, V1, U2, V2] tex coods
//=============================================================================
procedure TQuadTexture.DrawMap(const PointA, PointB, UVA, UVB: TVec2f; Color : Cardinal);
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  FQuadRender.Drawrect(PointA -0.5, PointB - 0.5, UVA, UVB, Color);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.DrawMapRotAxis(const PointA, PointB, UVA, UVB, Axis: TVec2f;
  angle, Scale: Double; Color: Cardinal); stdcall;
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  FQuadRender.DrawRectRotAxis(PointA - 0.5, PointB - 0.5, angle, Scale, Axis,
                              UVA, UVB, Color);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.DrawPart(const Position: TVec2f; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  FQuadRender.Drawrect(Position - 0.5, Position - 0.5 + RightBottom - LeftTop,
                       TVec2f.Create(LeftTop.X / FWidth, LeftTop.Y / FHeight) , TVec2f.Create(RightBottom.X / FWidth, RightBottom.Y / FHeight),
                       Color);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.DrawPartRot(const Center: TVec2f; angle, Scale: Double; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  FQuadRender.DrawRectRot(Center - 0.5, Center - 0.5 + RightBottom - LeftTop, angle, Scale,
                          TVec2f.Create(LeftTop.X / FWidth, LeftTop.Y / FHeight) , TVec2f.Create(RightBottom.X / FWidth, RightBottom.Y / FHeight),
                          Color);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.DrawPartRotAxis(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; LeftTop, RightBottom: TVec2i; Color: Cardinal = $FFFFFFFF); stdcall;
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  FQuadRender.DrawRectRotAxis(Position - 0.5, Position - 0.5 + RightBottom - LeftTop, angle, Scale, Axis,
                              TVec2f.Create(LeftTop.X / FWidth, LeftTop.Y / FHeight) , TVec2f.Create(RightBottom.X / FWidth, RightBottom.Y / FHeight),
                              Color);
end;

//=============================================================================
// Draws sprite with [X, Y] center pos, angle, scale and pattern
//=============================================================================
procedure TQuadTexture.DrawRotFrame(const Center: TVec2f; angle, Scale: Double; Pattern: Word;
  Color: Cardinal);
var
  px, py : Integer;
  px2, py2 : Integer;
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  px := (Pattern mod (FFrameWidth div FPatternWidth)) * FPatternWidth;
  py := (Pattern div (FFrameWidth div FPatternWidth)) * FPatternHeight;
  px2 := px + FPatternWidth;
  py2 := py + FPatternHeight;

  FQuadRender.Drawrectrot(Center - 0.5, Center - 0.5 + TVec2f.Create(FPatternWidth, FPatternHeight),
                          angle, Scale, TVec2f.Create(px / FWidth, py / FHeight),
                          TVec2f.Create(px2 / FWidth, py2 / FHeight), Color);
end;

//=============================================================================
// Draws sprite with [X, Y] center pos, angle from [xA, yA] and scale
//=============================================================================
procedure TQuadTexture.DrawRotAxis(const Position: TVec2f; angle, Scale: Double;
  const Axis: TVec2f; Color: Cardinal);
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  FQuadRender.DrawRectRotAxis(Position - 0.5, Position - 0.5 + TVec2f.Create(FFrameWidth, FFrameHeight),
                              angle, Scale, Axis, TVec2f.Zero, TVec2f.Create(FFrameWidth / FWidth, FFrameHeight / FHeight), Color);
end;

//=============================================================================
// Draws sprite with [X, Y] center pos, angle from [xA, yA], scale and pattern
//=============================================================================
procedure TQuadTexture.DrawRotAxisFrame(const Position: TVec2f; angle, Scale: Double;
  const Axis: TVec2f; Pattern: Word; Color: Cardinal);
var
  px, py : Integer;
  px2, py2 : Integer;
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  px := (Pattern mod (FFrameWidth div FPatternWidth)) * FPatternWidth;
  py := (Pattern div (FFrameWidth div FPatternWidth)) * FPatternHeight;
  px2 := px + FPatternWidth;
  py2 := py + FPatternHeight;

  FQuadRender.DrawRectRotAxis(Position - 0.5, Position - 0.5 + TVec2f.Create(FPatternWidth, FPatternHeight),
                              angle, Scale, Axis, TVec2f.Create(px / FWidth, py / FHeight), TVec2f.Create(px2 / FWidth, py2 / FHeight), Color);
end;

//=============================================================================
// Draws sprite with [X, Y] center pos, angle and scale
//=============================================================================
procedure TQuadTexture.DrawRot(const Center: TVec2f; angle, Scale: Double; Color : Cardinal);
begin
  if not FIsLoaded then
    Exit;

  SetTextureStages;

  FQuadRender.Drawrectrot(Center - 0.5, Center - 0.5 + TVec2f.Create(FFrameWidth, FFrameHeight),
                          angle, Scale, TVec2f.Zero, TVec2f.Create(FFrameWidth / FWidth, FFrameHeight / FHeight), Color);
end;

//=============================================================================
// Returns pattern count
//=============================================================================
function TQuadTexture.GetPatternCount: Integer;
begin
  if not FIsLoaded then
    Exit;

  Result := (FFrameWidth div FPatternWidth) * (FFrameHeight div FPatternHeight);
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetIsLoaded: Boolean;
begin
  Result := FIsLoaded;
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetTexture(i: Byte): IDirect3DTexture9;
begin
  Result := FTextures[i];
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetTextureWidth : Word;
begin
  Result := FWidth;
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetSpriteWidth : Word;
begin
  Result := FFrameWidth;
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetPatternWidth : Word;
begin
  Result := FPatternWidth;
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetPixelColor(x, y: Integer; ARegister: Byte): Cardinal; stdcall;
var
  aData : TD3DLockedRect;
begin
  Result := 0;
  if (x > FWidth) or (y > FHeight) then
    Exit;

  Device.LastResultCode := Texture[ARegister].LockRect(0, aData, nil, D3DLOCK_READONLY);
  Inc(NativeInt(aData.pBits), 4 * (y * FWidth + x));
  Result := Cardinal(aData.pBits^);
  Device.LastResultCode := Texture[ARegister].UnlockRect(0);
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetTextureHeight : Word;
begin
  Result := FHeight;
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetSpriteHeight : Word;
begin
  Result := FFrameHeight;
end;

//=============================================================================
//
//=============================================================================
function TQuadTexture.GetPatternHeight : Word;
begin
  Result := FPatternHeight;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadFromFile(ARegister: Byte; AFilename: PWideChar;
  APatternWidth, APatternHeight: Integer; AColorKey: Integer);
var
  Stream: TMemoryStream;
begin
  FIsLoadFromFile := True;

  if Assigned(Device.Log) then
  begin
    Device.Log.Write(PWideChar('Loading texture "' + AFilename + '"'));
  end;

  if not FileExists(AFilename) then
  begin
    Device.Log.Write(PWideChar('Texture "' + AFilename + '" not found!'));
    Exit;
  end;

  Stream := TMemoryStream.Create;
  Stream.LoadFromFile(AFilename);

  LoadFromStream(ARegister, Stream.Memory, Stream.Size, APatternWidth, APatternHeight, AColorKey);

  FreeAndNil(Stream);
  FIsLoadFromFile := False;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadFromRAW(ARegister: Byte; AData: Pointer; AWidth, AHeight: Integer; ASourceFormat: TRAWDataFormat);
var
  Texture: IDirect3DTexture9;
  i, j: Integer;
  LockedRect: TD3DLockedRect;
  PixelData: Cardinal;
  a, r, g, b: Byte;
begin
  FIsLoaded := False;

  if FQuadRender.IsSupportedNonPow2 then
  begin
    FWidth := Ceil(AWidth / 4) * 4;
    FHeight := Ceil(AHeight / 4) * 4;
  end
  else
  begin
    FWidth := NormalizeSize(AWidth);
    FHeight := NormalizeSize(AHeight);
  end;

  FFrameWidth := AWidth;
  FFrameHeight := AHeight;

  FPatternWidth := AWidth;
  FPatternHeight := AHeight;

  Device.LastResultCode := FQuadRender.D3DDevice.CreateTexture(FWidth, FHeight, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil);
  Device.LastResultCode := Texture.LockRect(0, LockedRect, nil, 0);

  for I := 0 to FFrameHeight - 1 do
  begin
    for j := 0 to FFrameWidth - 1 do
    begin
      case ASourceFormat of
        rdfARGB8: Move(AData^, LockedRect.pBits^, 4);
        rdfRGBA8: begin
                    PixelData := Cardinal(AData^);
                    a := PixelData and $FF000000 shr 24;
                    r := PixelData and $FF0000 shr 16;
                    g := PixelData and $FF00 shr 8;
                    b := PixelData and $FF;
                    PixelData := a shl 24 + r shl 16 + g shl 8 + b;
                    Move(PixelData, LockedRect.pBits^, 4);
                  end;
        rdfABGR8: begin
                    PixelData := Cardinal(AData^);
                    a := PixelData and $FF000000 shr 24;
                    b := PixelData and $FF0000 shr 16;
                    g := PixelData and $FF00 shr 8;
                    r := PixelData and $FF;
                    PixelData := a shl 24 + r shl 16 + g shl 8 + b;
                    Move(PixelData, LockedRect.pBits^, 4);
                  end;
      end;
      Inc(NativeInt(LockedRect.pBits), 4);
      Inc(NativeInt(AData), 4);
    end;
    Inc(NativeInt(LockedRect.pBits), 4 * (FWidth - FFrameWidth));
  end;

  Device.LastResultCode := Texture.UnlockRect(0);

  AddTexture(aRegister, Texture);

  FIsLoaded := True;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadFromStream(ARegister: Byte; AStream: Pointer; AStreamSize: Integer;
  APatternWidth, APatternHeight, AColorKey: Integer); stdcall;
var
  TextureResult: TTextureResult;
  Stream: TMemoryStream;
begin
  FIsLoaded := False;

  if Assigned(Device.Log) and not FIsLoadFromFile then
  begin
    Device.Log.Write(PWideChar('Loading texture from stream'));
  end;

  Stream := TMemoryStream.Create;
  Stream.WriteBuffer((AStream)^, AStreamSize);
  Stream.Position := 0;

  try
    TextureResult := TQuadTextureLoader.LoadFromStream(Stream);

    AddTexture(ARegister, TextureResult.Texture);
    FWidth := TextureResult.Width;
    FHeight := TextureResult.Height;
    FFrameWidth := TextureResult.FrameWidth;
    FFrameHeight := TextureResult.FrameHeight;
  except
    if Assigned(Device.Log) then
      Device.Log.Write(PWideChar('Error loading texture'));
    Exit;
  end;

  if (APatternWidth = 0) or (APatternHeight = 0) then
  begin
    FPatternWidth := FFrameWidth;
    FPatternHeight := FFrameHeight;
  end
  else
  begin
    FPatternWidth := APatternWidth;
    FPatternHeight := APatternHeight;
  end;

  FIsLoaded := True;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.SetIsLoaded(AWidth, AHeight: Word); stdcall;
begin
  FWidth := AWidth;
  FHeight := AHeight;
  FFrameWidth := AWidth;
  FFrameHeight := AHeight;
  FIsLoaded := True;
end;

procedure TQuadTexture.SetTextureStages;
var
  i: Integer;
begin
  for i := 0 to FQuadRender.MaxTextureStages - 1 do
    FQuadRender.SetTexture(i, FTextures[i]);
end;

end.
