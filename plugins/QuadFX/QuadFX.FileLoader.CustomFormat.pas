unit QuadFX.FileLoader.CustomFormat;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes;

type
  TEffectSignature = array[0..31] of AnsiChar;

  TQuadFXCustomFileFormatClass = class of TQuadFXCustomFileFormat;

  TQuadFXCustomFileFormat = class abstract
  private
    FEffectParams: IQuadFXEffectParams;
    FAtlas: IQuadFXAtlas;
  protected
    FPackName: WideString;
    property EffectParams: IQuadFXEffectParams read FEffectParams;
  public
    class function CheckSignature(ASignature: TEffectSignature): Boolean; virtual; abstract;
    constructor Create;
    procedure SetEffectParams(AEffectParams: IQuadFXEffectParams);
    procedure SetAtlas(AAtlas: IQuadFXAtlas);
    procedure EffectLoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams); virtual;
    procedure AtlasLoadFromStream(const AAtlasName: PWideChar; AStream: TMemoryStream; AAtlas: IQuadFXAtlas); virtual;
  end;

implementation

constructor TQuadFXCustomFileFormat.Create;
begin
  FPackName := '';
  FEffectParams := nil;
  FAtlas := nil;
end;

procedure TQuadFXCustomFileFormat.EffectLoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
begin
  FEffectParams := AEffectParams;
end;

procedure TQuadFXCustomFileFormat.AtlasLoadFromStream(const AAtlasName: PWideChar; AStream: TMemoryStream; AAtlas: IQuadFXAtlas);
begin
  FAtlas := AAtlas;
end;

procedure TQuadFXCustomFileFormat.SetEffectParams(AEffectParams: IQuadFXEffectParams);
begin
  FEffectParams := AEffectParams;
end;

procedure TQuadFXCustomFileFormat.SetAtlas(AAtlas: IQuadFXAtlas);
begin
  FAtlas := AAtlas;
end;
end.
