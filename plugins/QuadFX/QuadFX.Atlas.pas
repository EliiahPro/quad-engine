unit QuadFX.Atlas;

interface

uses
  QuadFX, QuadFX.Helpers, QuadEngine, QuadEngine.Color, Vec2f, System.SysUtils,
  System.Generics.Collections, System.Classes, System.Json, Windows;

type
  TQuadFXAtlas = class(TInterfacedObject, IQuadFXAtlas)
  private
    FName: WideString;
    FPackName: WideString;
    FGUID: TGUID;
    FSprites: TList<PQuadFXSprite>;
    FTexture: IQuadTexture;
    FLoadFromFile: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function GetName: PWideChar; stdcall;
    function GetPackName: PWideChar; stdcall;
    procedure GetGUID(out AGUID: TGUID); stdcall;
    function GetSprite(Index: Integer; out ASprite: PQuadFXSprite): HResult; stdcall;
    function GetSpriteCount: Integer; stdcall;
    procedure GetSize(out ASize: TVec2f); stdcall;
    function GetWidth: Integer; stdcall;
    function GetHeight: Integer; stdcall;
    function SpriteByID(const AID: Integer; out ASprite: PQuadFXSprite): HResult; stdcall;
    procedure LoadFromFile(AAtlasName, AFileName: PWideChar); stdcall;
    procedure LoadFromStream(AAtlasName: PWideChar; AStream: Pointer; AStreamSize: Integer); stdcall;
    function CreateSprite(out ASprite: PQuadFXSprite): HResult; stdcall;
    function DeleteSprite(ASprite: PQuadFXSprite): HResult; stdcall;
    procedure SetTexture(const ATexture: IQuadTexture); stdcall;

    property Texture: IQuadTexture read FTexture write SetTexture;
    property Name: WideString read FName write FName;
    property PackName: WideString read FPackName write FPackName;
    property GUID: TGUID read FGUID write FGUID;
  end;

implementation

uses QuadFX.Manager, QuadFX.FileLoader;

constructor TQuadFXAtlas.Create;
begin
  FLoadFromFile := False;
  FSprites := TList<PQuadFXSprite>.Create;
end;

destructor TQuadFXAtlas.Destroy;
var
  i: Integer;
begin
  for i := FSprites.count - 1 downto 0 do
    if Assigned(FSprites[i]) then
      Dispose(FSprites[i]);

  FSprites.Free;
end;

procedure TQuadFXAtlas.SetTexture(const ATexture: IQuadTexture); stdcall;
begin
  FTexture := ATexture;
end;

procedure TQuadFXAtlas.GetSize(out ASize: TVec2f); stdcall;
begin
  if Assigned(FTexture) then
    ASize := TVec2f.Create(FTexture.GetTextureWidth, FTexture.GetTextureHeight)
  else
    ASize := TVec2f.Zero;
end;

function TQuadFXAtlas.GetWidth: Integer; stdcall;
begin
  Result := FTexture.GetTextureWidth;
end;

function TQuadFXAtlas.GetHeight: Integer; stdcall;
begin
  Result := FTexture.GetTextureHeight;
end;

function TQuadFXAtlas.GetSprite(Index: Integer; out ASprite: PQuadFXSprite): HResult; stdcall;
begin
  ASprite := FSprites[Index];
  if Assigned(ASprite) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadFXAtlas.GetSpriteCount: Integer; stdcall;
begin
  Result := FSprites.Count;
end;

function TQuadFXAtlas.SpriteByID(const AID: Integer; out ASprite: PQuadFXSprite): HResult; stdcall;
var
  Sprite: PQuadFXSprite;
begin
  for Sprite in FSprites do
    if Assigned(Sprite) and (Sprite.ID = AID) then
    begin
      ASprite := Sprite;
      Exit(S_OK);
    end;
  ASprite := nil;
  Result := E_FAIL;
end;

function TQuadFXAtlas.GetName: PWideChar; stdcall;
begin
  Result := PWideChar(FName);
end;

function TQuadFXAtlas.GetPackName: PWideChar; stdcall;
begin
  Result := PWideChar(FPackName);
end;

procedure TQuadFXAtlas.GetGUID(out AGUID: TGUID); stdcall;
begin
  AGUID := FGUID;
end;

function TQuadFXAtlas.CreateSprite(out ASprite: PQuadFXSprite): HResult; stdcall;
begin
  new(ASprite);
  FSprites.Add(ASprite);
  ASprite.Texture := FTexture;
  ASprite.Position := TVec2f.Zero;
  GetSize(ASprite.Size);
  ASprite.Axis := ASprite.Size / 2;
  ASprite.Recalculate(nil);
  Result := S_OK
end;

function TQuadFXAtlas.DeleteSprite(ASprite: PQuadFXSprite): HResult; stdcall;
begin
  if Assigned(ASprite) then
  begin
    FSprites.Remove(ASprite);
    Dispose(ASprite);
    Result := S_OK;
  end
  else
    Result := E_FAIL;
end;

procedure TQuadFXAtlas.LoadFromFile(AAtlasName, AFileName: PWideChar); stdcall;
var
  Stream: TMemoryStream;
begin
  FLoadFromFile := True;
  Manager.AddLog(PWideChar('QuadFX: Loading atlas "' + AAtlasName + '" from file "' + AFileName + '"'));

  if not FileExists(AFileName) then
  begin
    Manager.AddLog(PWideChar('QuadFX: File "' + AFileName + '" not found!'));
    Exit;
  end;

  Stream := TMemoryStream.Create;
  Stream.LoadFromFile(AFileName);
  LoadFromStream(AAtlasName, Stream.Memory, Stream.Size);
  FreeAndNil(Stream);
end;

procedure TQuadFXAtlas.LoadFromStream(AAtlasName: PWideChar; AStream: Pointer; AStreamSize: Integer); stdcall;
var
  Stream: TMemoryStream;
begin
  if not FLoadFromFile then
    Manager.AddLog(PWideChar('QuadFX: Loading atlas "' + AAtlasName + '" from stream'));
  FLoadFromFile := False;

  Stream := TMemoryStream.Create;
  Stream.WriteBuffer((AStream)^, AStreamSize);
  Stream.Seek(0, soFromBeginning);
  try
    TQuadFXFileLoader.AtlasLoadFromStream(AAtlasName, Stream, Self);
  except
    Manager.AddLog(PWideChar('QuadFX: Error loading atlas'));
  end;
  Stream.Free;
end;

end.
