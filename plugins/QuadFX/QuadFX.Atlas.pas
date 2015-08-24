unit QuadFX.Atlas;

interface

uses
  QuadFX, QuadFX.Helpers, QuadEngine, QuadEngine.Color, Vec2f,
  System.Generics.Collections, System.Classes, System.Json;

type
  TQuadFXAtlas = class(TInterfacedObject, IQuadFXAtlas)
  private
    FName: WideString;
    FPackName: WideString;
    FSprites: TList<PQuadFXTextureInfo>;
    FTexture: IQuadTexture;
    function GetSprite(Index: Integer): PQuadFXTextureInfo;
    function GetSpriteCount: Integer;
    function GetSize: TVec2f;
  public
    constructor Create;
    destructor Destroy; override;
    function GetName: PWideChar; stdcall;
    function GetPackName: PWideChar; stdcall;
    function SearchSprite(const AID: Integer): PQuadFXTextureInfo;
    function AddSprite(APosition, ASize, AAxis: TVec2f): PQuadFXTextureInfo;

    property Texture: IQuadTexture read FTexture write FTexture;
    property Name: WideString read FName write FName;
    property PackName: WideString read FPackName write FPackName;
  end;

implementation

constructor TQuadFXAtlas.Create;
begin
  FSprites := TList<PQuadFXTextureInfo>.Create;
end;

destructor TQuadFXAtlas.Destroy;
begin
  FSprites.Free;
end;

function TQuadFXAtlas.GetSize: TVec2f;
begin
  Result := TVec2f.Create(FTexture.GetTextureWidth, FTexture.GetTextureHeight);
end;

function TQuadFXAtlas.GetSprite(Index: Integer): PQuadFXTextureInfo;
begin
  Result := FSprites[Index];
end;

function TQuadFXAtlas.GetSpriteCount: Integer;
begin
  Result := FSprites.Count;
end;

function TQuadFXAtlas.SearchSprite(const AID: Integer): PQuadFXTextureInfo;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FSprites.Count - 1 do
    if Assigned(FSprites[i]) and (FSprites[i].ID = AID) then
      Exit(FSprites[i]);
end;

function TQuadFXAtlas.GetName: PWideChar; stdcall;
begin
  Result := PWideChar(FName);
end;

function TQuadFXAtlas.GetPackName: PWideChar; stdcall;
begin
  Result := PWideChar(FPackName);
end;

function TQuadFXAtlas.AddSprite(APosition, ASize, AAxis: TVec2f): PQuadFXTextureInfo;
begin
  new(Result);
  FSprites.Add(Result);
  Result.Texture := nil;
  Result.Position := APosition;
  Result.Size := ASize;
  Result.Axis := AAxis;
  Result.Recalculate(GetSize);
end;

end.
