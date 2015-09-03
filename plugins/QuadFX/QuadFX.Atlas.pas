unit QuadFX.Atlas;

interface

uses
  QuadFX, QuadFX.Helpers, QuadEngine, QuadEngine.Color, Vec2f, System.SysUtils,
  System.Generics.Collections, System.Classes, System.Json;

type
  TQuadFXAtlas = class(TInterfacedObject, IQuadFXAtlas)
  private
    FName: WideString;
    FPackName: WideString;
    FSprites: TList<PQuadFXSprite>;
    FTexture: IQuadTexture;
    FLoadFromFile: Boolean;
    function GetSprite(Index: Integer): PQuadFXSprite;
    function GetSpriteCount: Integer;
    function GetSize: TVec2f;
  public
    constructor Create;
    destructor Destroy; override;
    function GetName: PWideChar; stdcall;
    function GetPackName: PWideChar; stdcall;
    procedure LoadFromFile(AAtlasName, AFileName: PWideChar); stdcall;
    procedure LoadFromStream(AAtlasName: PWideChar; AStream: Pointer; AStreamSize: Integer); stdcall;
    procedure FindSprite(const AID: Integer; out ASprite: PQuadFXSprite); stdcall;
    procedure CreateSprite(out ASprite: PQuadFXSprite); stdcall;

    property Texture: IQuadTexture read FTexture write FTexture;
    property Name: WideString read FName write FName;
    property PackName: WideString read FPackName write FPackName;
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

function TQuadFXAtlas.GetSize: TVec2f;
begin
  Result := TVec2f.Create(FTexture.GetTextureWidth, FTexture.GetTextureHeight);
end;

function TQuadFXAtlas.GetSprite(Index: Integer): PQuadFXSprite;
begin
  Result := FSprites[Index];
end;

function TQuadFXAtlas.GetSpriteCount: Integer;
begin
  Result := FSprites.Count;
end;

procedure TQuadFXAtlas.FindSprite(const AID: Integer; out ASprite: PQuadFXSprite); stdcall;
var
  i: Integer;
begin
  ASprite := nil;
  for i := 0 to FSprites.Count - 1 do
    if Assigned(FSprites[i]) and (FSprites[i].ID = AID) then
    begin
      ASprite := FSprites[i];
      Exit;
    end;
end;

function TQuadFXAtlas.GetName: PWideChar; stdcall;
begin
  Result := PWideChar(FName);
end;

function TQuadFXAtlas.GetPackName: PWideChar; stdcall;
begin
  Result := PWideChar(FPackName);
end;

procedure TQuadFXAtlas.CreateSprite(out ASprite: PQuadFXSprite); stdcall;
begin
  new(ASprite);
  FSprites.Add(ASprite);
  ASprite.Texture := FTexture;
  ASprite.Position := TVec2f.Zero;
  ASprite.Size := GetSize;
  ASprite.Axis := GetSize / 2;
  ASprite.Recalculate(ASprite.Size);
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
