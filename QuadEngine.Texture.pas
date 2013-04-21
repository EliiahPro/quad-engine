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

unit QuadEngine.Texture;

interface

uses
  QuadEngine.Render, graphics, VCL.Imaging.pngimage, VCL.Imaging.JPEG, direct3d9,
  TGAReader, QuadEngine.Log, QuadEngine, System.SyncObjs, Vec2f;

type
  TQuadTextureItem = record
    Texture: IDirect3DTexture9;
    Reg: Byte;
  end;

  TQuadTexture =  class(TInterfacedObject, IQuadTexture)
  private
    FQuadRender: TQuadRender;
    FTextures: array of TQuadTextureItem;
    FTexturesCount: Byte;
    FWidth: Integer;
    FHeight: Integer;
    FFrameWidth: Integer;
    FFrameHeight: Integer;
    FPatternWidth: Integer;
    FPatternHeight: Integer;
    FPatternSize: TVec2f;
    FIsLoaded: Boolean;
    FSync: TCriticalSection;
    procedure LoadBMPTexture(const aFilename: String; var Texture: IDirect3DTexture9; ColorKey: Integer = -1);
    procedure LoadDDSTexture(const aFilename: String; var Texture: IDirect3DTexture9);
    procedure LoadJPGTexture(const aFilename: String; var Texture: IDirect3DTexture9);
    procedure LoadTGATexture(const aFilename: String; var Texture: IDirect3DTexture9);
    procedure LoadPNGTexture(const aFilename: String; var Texture: IDirect3DTexture9);
    procedure CreateFromRenderTarget(RenderTargetIndex: Byte; aRegister: Byte = 0);
    procedure SetTextureStages;
  public
    constructor Create(QuadRender: TQuadRender);
    destructor Destroy; override;

    function GetIsLoaded: Boolean; stdcall;
    function GetPatternCount: Integer; stdcall;
    function GetPatternHeight: Word; stdcall;
    function GetPatternWidth: Word; stdcall;
    function GetPixelColor(x, y: Integer; ARegister: byte = 0): Cardinal; stdcall;
    function GetSpriteHeight: Word; stdcall;
    function GetSpriteWidth: Word; stdcall;
    function GetTexture(i: Byte): IDirect3DTexture9; stdcall;
    function GetTextureHeight: Word; stdcall;
    function GetTextureWidth: Word; stdcall;
    procedure AddTexture(ARegister: Byte; ATexture: IDirect3DTexture9); stdcall;
    procedure Draw(const Position: Tvec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawFrame(const Position: Tvec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMap(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMapRotAxis(const PointA, PointB, UVA, UVB, Axis: TVec2f; Angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRot(const Center: TVec2f; angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotFrame(const Center: TVec2f; angle, Scale: Double; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxis(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxisFrame(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure LoadFromFile(ARegister: Byte; AFilename: PWideChar; APatternWidth: Integer = 0;
      APatternHeight: Integer = 0; AColorKey: Integer = -1); stdcall;
    procedure LoadFromRAW(ARegister: Byte; AData: Pointer; AWidth, AHeight: Integer); stdcall;
    procedure SetIsLoaded(AWidth, AHeight: Word); stdcall;

    property Texture[i: Byte]: IDirect3DTexture9 read GetTexture;
    property TextureWidth: Integer read FWidth;
    property TextureHeight: Integer read FHeight;
    property FrameWidth: Integer read FFrameWidth;
    property FrameHeight: Integer read FFrameHeight;
    property PatternWidth: Integer read FPatternWidth;
    property PatternHeight: Integer read FPatternHeight;
    property PatternsCount: Integer read GetPatternCount;
    property TexturesCount: Byte read FTexturesCount;
    property IsLoaded: Boolean read FIsLoaded;
  end;


implementation

uses
  QuadEngine.Utils, QuadEngine.Device, System.SysUtils;

{ TQuadTexture }

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.AddTexture(ARegister: Byte; ATexture: IDirect3DTexture9);
begin
  FSync.Enter;

  Inc(FTexturesCount);
  SetLength(FTextures, FTexturesCount);
  FTextures[FTexturesCount - 1].Reg := ARegister;
  FTextures[FTexturesCount - 1].Texture := ATexture;

  FSync.Leave;
end;

//=============================================================================
//
//=============================================================================
constructor TQuadTexture.Create(QuadRender: TQuadRender);
begin
  FQuadRender := QuadRender;
  FTexturesCount := 0;
  FIsLoaded := False;
  FPatternWidth := 0;
  FPatternHeight := 0;
  FPatternSize := TVec2f.Zero;
  FSync := TCriticalSection.Create;
end;

//=============================================================================
// Create sprite from rendertarget
//=============================================================================
procedure TQuadTexture.CreateFromRenderTarget(RenderTargetIndex,
  aRegister: Byte);
begin
  FIsLoaded := False;
  FWidth := FQuadRender.Width;
  FHeight := FQuadRender.Height;
  FFrameWidth := FQuadRender.Width;
  FFrameHeight := FQuadRender.Height;
  FIsLoaded := True;
end;

//=============================================================================
// Draws sprite with [X, Y] position
//=============================================================================
procedure TQuadTexture.Draw(const Position: Tvec2f; Color: Cardinal);
begin
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

  for i := 0 to FTexturesCount - 1 do
    FTextures[i].Texture := nil;

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
  SetTextureStages;
                                                        {todo: todo what?}
  px := (Pattern mod (FFrameWidth div FPatternWidth)) * FPatternWidth;
  py := (Pattern div (FFrameWidth div FPatternWidth)) * FPatternHeight;
  px2 := px + FPatternWidth;
  py2 := py + FPatternHeight;

  FQuadRender.Drawrect(Position - 0.5, Position - 0.5 + TVec2f.Create(FPatternWidth, FPatternHeight),
                       TVec2f.Create(px / FWidth, py / FHeight), TVec2f.Create(px2 / FWidth, py2 / FHeight), Color);
end;

//=============================================================================
// Draws sprite with specify all 4 vertexes in free positions
//=============================================================================
procedure TQuadTexture.DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double;
  Color: Cardinal);
begin
  SetTextureStages;

  FQuadRender.DrawDistort(x1 - 0.5, y1 - 0.5, x2 - 0.5, y2 - 0.5, x3 - 0.5, y3 - 0.5, x4 - 0.5, y4 - 0.5,
                          0, 0, FFrameWidth / FWidth, FFrameHeight / FHeight, Color);
end;

//=============================================================================
// Draws sprite with [X, Y, X2, Y2] vertex pos, and [U1, V1, U2, V2] tex coods
//=============================================================================
procedure TQuadTexture.DrawMap(const PointA, PointB, UVA, UVB: TVec2f; Color : Cardinal);
begin
  SetTextureStages;

  FQuadRender.Drawrect(PointA -0.5, PointB - 0.5, UVA, UVB, Color);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.DrawMapRotAxis(const PointA, PointB, UVA, UVB, Axis: TVec2f;
  angle, Scale: Double; Color: Cardinal); stdcall;
begin
  SetTextureStages;

  FQuadRender.DrawRectRotAxis(PointA - 0.5, PointB - 0.5, angle, Scale, Axis,
                              UVA, UVB, Color);
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
  SetTextureStages;

  FQuadRender.DrawRectRotAxis(Position - 0.5, Position - 0.5 + TVec2f.Create(FPatternWidth, FPatternHeight),
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
  SetTextureStages;

  FQuadRender.Drawrectrot(Center - 0.5, Center - 0.5 +TVec2f.Create(FFrameWidth, FFrameHeight),
                          angle, Scale, TVec2f.Zero, TVec2f.Create(FFrameWidth / FWidth, FFrameHeight / FHeight), Color);
end;

//=============================================================================
// Returns pattern count
//=============================================================================
function TQuadTexture.GetPatternCount: Integer;
begin
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
  Result := FTextures[i].Texture;
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
function TQuadTexture.GetPixelColor(x, y: Integer; ARegister: byte): Cardinal; stdcall;
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
procedure TQuadTexture.LoadBMPTexture(const aFilename: String; var Texture: IDirect3DTexture9; ColorKey: Integer);
var
  bmp : TBitmap;
  i, j : Integer;
  p : Pointer;
  aData : TD3DLockedRect;
begin
  bmp := TBitmap.Create;
  bmp.LoadFromFile(aFilename);
  if (bmp.PixelFormat <> pf24bit) and (bmp.PixelFormat <> pf32bit) then
    bmp.PixelFormat := pf24bit;

  FWidth := NormalizeSize(bmp.Width);
  FHeight := NormalizeSize(bmp.Height);

  FFrameWidth := bmp.Width;
  FFrameHeight := bmp.Height;

  Device.LastResultCode := FQuadRender.D3DDevice.CreateTexture(FWidth, FHeight, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil);
  Device.LastResultCode := Texture.LockRect(0, aData, nil, 0);

  for I := 0 to FFrameHeight - 1 do
  begin
    p := bmp.ScanLine[i];
    for j := 0 to FFrameWidth - 1 do
    begin

      if bmp.PixelFormat = pf24bit then
      begin
        Move(p^, aData.pBits^, 3);

        Cardinal(aData.pBits^) := Cardinal(aData.pBits^) ;//and $FF000000 + $00FFFFFF;

        Inc(NativeInt(aData.pBits), 3);

        if ColorKey <> -1 then
        begin

          if (Byte(p^) = (ColorKey shr 16) and $FF) and
             (Byte(Pointer(Integer(p) + 1)^) = (ColorKey shr 8) and $FF) and
             (Byte(Pointer(Integer(p) + 2)^) = ColorKey and $FF) then
            Byte(aData.pBits^) := 0
          else
            Byte(aData.pBits^) := 255;
        end;

        Inc(NativeInt(aData.pBits), 1);

        Inc(NativeInt(p), 3);
      end else
      if bmp.PixelFormat = pf32bit then
      begin
        Move(p^, aData.pBits^, 4);

        Cardinal(aData.pBits^) := Cardinal(aData.pBits^) and $FF000000 + $00FFFFFF;

        Inc(NativeInt(aData.pBits), 4);

        Inc(NativeInt(p), 4);
      end;
    end;
    Inc(NativeInt(aData.pBits), 4 * (FWidth - FFrameWidth));
  end;

  bmp.Free;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadDDSTexture(const aFilename: String; var Texture: IDirect3DTexture9);
type
  DDSHEADER = packed record
    dwSize             : Cardinal;
    dwFlags            : Cardinal;
    dwHeight           : Cardinal;
    dwWidth            : Cardinal;
    dwPitchOrLinearSize: Cardinal;
    dwDepth            : Cardinal;
    dwMipMapCount      : Cardinal;
    dwReserved1        : array [0..10] of Cardinal;
    ddspf              : Cardinal;
    dwCaps             : Cardinal;
    dwCaps2            : Cardinal;
    dwCaps3            : Cardinal;
    dwCaps4            : Cardinal;
    dwReserved2        : Cardinal;
  end;

var
  f : file;
  header : DDSHEADER;
  head : array[0..3] of Ansichar;
  buf : PAnsiChar;
begin
  AssignFile(f, aFilename);
  Reset(f, 1);

  BlockRead(f, head[0], 4);
  BlockRead(f, header, SizeOf(header));
  GetMem(buf, header.dwPitchOrLinearSize);
  BlockRead(f, buf, SizeOf(header.dwPitchOrLinearSize));
 //  Move(buf^, aData.pBits^, header.dwPitchOrLinearSize);
   {todo : требует дебага}
  CloseFile(f);
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadFromFile(ARegister: Byte; AFilename: PWideChar;
  APatternWidth, APatternHeight: Integer; AColorKey: Integer);
var
  Texture : IDirect3DTexture9;
begin
  FIsLoaded := False;

                           {todo : size FWIDTH, FHEIGHT}
//  if not (copy(UpperCase(aFilename), length(aFilename) - 3, 4) = '.DDS') then
//  FQuadRender.LastResultCode := FQuadRender.D3DDevice.CreateTexture(NormalizeSize(aWidth), NormalizeSize(aHeight), 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil)
//  else
//  FQuadRender.LastResultCode := FQuadRender.D3DDevice.CreateTexture(NormalizeSize(aWidth), NormalizeSize(aHeight), 0, 0, D3DFMT_DXT1, D3DPOOL_MANAGED, Texture, nil);


//  if copy(UpperCase(aFilename), length(aFilename) - 3, 4) = '.DDS' then
//  LoadDDSTexture(aFilename, rect);
  if copy(UpperCase(AFilename), length(AFilename) - 3, 4) = '.BMP' then
    LoadBMPTexture(AFilename, Texture, AColorKey);
  if copy(UpperCase(AFilename), length(AFilename) - 3, 4) = '.JPG' then
    LoadJPGTexture(AFilename, Texture);
  if copy(UpperCase(AFilename), length(AFilename) - 3, 4) = '.TGA' then
    LoadTGATexture(AFilename, Texture);
  if copy(UpperCase(AFilename), length(AFilename) - 3, 4) = '.PNG' then
    LoadPNGTexture(AFilename, Texture);

  Device.LastResultCode := Texture.UnlockRect(0);

  AddTexture(ARegister, Texture);

  FIsLoaded := True;

  if (APatternWidth = 0) or (APatternHeight = 0)
  then
  begin
    FPatternWidth := FFrameWidth;
    FPatternHeight := FFrameHeight;
  end
  else
  begin
    FPatternWidth := APatternWidth;
    FPatternHeight := APatternHeight;
  end;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadFromRAW(ARegister: Byte; AData: Pointer; AWidth, AHeight: Integer);
var
  Texture: IDirect3DTexture9;
  i, j: Integer;
  LockedRect: TD3DLockedRect;
begin
  FIsLoaded := False;

  FWidth := NormalizeSize(AWidth);
  FHeight := NormalizeSize(AHeight);

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
      Move(AData^, LockedRect.pBits^, 4);
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
procedure TQuadTexture.SetIsLoaded(AWidth, AHeight: Word); stdcall;
begin
  FWidth := AWidth;
  FHeight := AHeight;
  FFrameWidth := AWidth;
  FFrameHeight := AHeight;
  FIsLoaded := True;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadJPGTexture(const aFilename: String; var Texture: IDirect3DTexture9);
var
  bmp : TBitmap;
  jpg : TJPEGImage;
  i, j : Integer;
  p : Pointer;
  aData : TD3DLockedRect;
begin
  bmp := TBitmap.Create;
  jpg := TJPEGImage.Create;
  jpg.LoadFromFile(aFilename);
  bmp.Assign(jpg);
  jpg.Free;

  FWidth := NormalizeSize(bmp.Width);
  FHeight := NormalizeSize(bmp.Height);

  FFrameWidth := bmp.Width;
  FFrameHeight := bmp.Height;

  Device.LastResultCode := FQuadRender.D3DDevice.CreateTexture(FWidth, FHeight, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil);
  Device.LastResultCode := Texture.LockRect(0, aData, nil, 0);

  for I := 0 to FFrameHeight - 1 do
  begin
    p:= bmp.ScanLine[i];
    for j:= 0 to FFrameWidth - 1 do
    begin
      Move(p^, aData.pBits^, 3);

      Inc(NativeInt(aData.pBits), 3);

//      if Byte(p^) + Byte(Pointer(Integer(p) + 1)^) + Byte(Pointer(Integer(p) + 2)^) < 128 then
//      Byte(aData.pBits^) := 0 else
      Byte(aData.pBits^) := 255;

      Inc(NativeInt(aData.pBits), 1);

      Inc(NativeInt(p), 3);
    end;
    Inc(NativeInt(aData.pBits), 4 * (FWidth - FFrameWidth));
  end;

  bmp.Free;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadPNGTexture(const aFilename: String; var Texture: IDirect3DTexture9);
var
  bmp : TPNGObject;
  i, j : Integer;
  p, pa : Pointer;
  aData : TD3DLockedRect;
begin
  bmp := TPNGObject.Create;
  bmp.LoadFromFile(aFilename);

  FWidth := NormalizeSize(bmp.Width);
  FHeight := NormalizeSize(bmp.Height);

  FFrameWidth := bmp.Width;
  FFrameHeight := bmp.Height;

  Device.LastResultCode := FQuadRender.D3DDevice.CreateTexture(FWidth, FHeight, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil);
  Device.LastResultCode := Texture.LockRect(0, aData, nil, 0);

  for I := 0 to FFrameHeight - 1 do
  begin
    p := bmp.ScanLine[i];
    pa := bmp.AlphaScanline[i];
    for j:= 0 to FFrameWidth - 1 do
    begin
      Move(p^, aData.pBits^, 3);
      Inc(NativeInt(aData.pBits), 3);
      Inc(NativeInt(p), 3);

      if pa <> nil then
      begin
        Move(pa^, aData.pBits^, 1);
        Inc(NativeInt(pa), 1);
      end;
      Inc(NativeInt(aData.pBits), 1);

    end;
    Inc(NativeInt(aData.pBits), 4 * (FWidth - FFrameWidth));
  end;

  bmp.Free;
end;

//=============================================================================
//
//=============================================================================
procedure TQuadTexture.LoadTGATexture(const aFilename: String; var Texture: IDirect3DTexture9);
var
  bmp: TBitmapEx;
  i, j: Integer;
  p: Pointer;
  aData: TD3DLockedRect;
begin
  bmp := TBitmapEx.Create;
  bmp.LoadFromFile(aFilename);

  FWidth := NormalizeSize(bmp.Width);
  FHeight := NormalizeSize(bmp.Height);

  FFrameWidth := bmp.Width;
  FFrameHeight := bmp.Height;

  Device.LastResultCode := FQuadRender.D3DDevice.CreateTexture(FWidth, FHeight, 0, D3DUSAGE_AUTOGENMIPMAP, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil);
  Device.LastResultCode := Texture.LockRect(0, aData, nil, 0);

  for I := 0 to FFrameHeight - 1 do
  begin
    p:= bmp.ScanLine[i];
    for j:= 0 to FFrameWidth - 1 do
    begin
      Move(p^, aData.pBits^, 4);

      Inc(NativeInt(aData.pBits), 4);

  {    if Byte(p^) + Byte(Pointer(Integer(p) + 1)^) + Byte(Pointer(Integer(p) + 2)^) < 128 then
      Byte(aData.pBits^) := 0 else
      Byte(aData.pBits^) := 255;
                                    }

      Inc(NativeInt(p), 4);
    end;
    Inc(NativeInt(aData.pBits), 4 * (FWidth - FFrameWidth));
  end;

  bmp.Free;
end;

procedure TQuadTexture.SetTextureStages;
var
  i: Integer;
begin
  for i := 0 to FTexturesCount - 1 do
    FQuadRender.SetTexture(FTextures[i].Reg, FTextures[i].Texture);

  for i := FTexturesCount to FQuadRender.MaxTextureStages - 1 do
    FQuadRender.SetTexture(i, nil);
end;

end.
