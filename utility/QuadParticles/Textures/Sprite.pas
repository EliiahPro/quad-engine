unit Sprite;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GDIPAPI, GDIPOBJ, GDIPUTIL, Vcl.ComCtrls, Vcl.ImgList,
  CustomTextureNode, System.Json, System.Types, QuadFX, QuadFX.Helpers,
  Vec2f;

type
  TSpriteNode = class(TCustomTextureNode)
  strict private
    FIsLocate: Boolean;
    FPadding: Integer;
    FSprite: PQuadFXSprite;
    function GetRect: TGPRectF;
    function GetSquare: Integer;
    procedure SetIsLocate(AValue: Boolean);
    function GetPosition: TPoint;
    procedure SetPosition(const Value: TPoint);
    function GetAxis: TPoint;
    procedure SetAxis(const Value: TPoint);
  public
    constructor CreateEx(const AFileName: WideString); overload;
    constructor CreateEx(ASprite: PQuadFXSprite); overload;
    destructor Destroy; override;
    function ToJson: TJSONObject;

    property Position: TPoint read GetPosition write SetPosition;
    property Axis: TPoint read GetAxis write SetAxis;
    property Rect: TGPRectF read GetRect;
    property Padding: Integer read FPadding write FPadding;
    property IsLocate: Boolean read FIsLocate write SetIsLocate;
    property Square: Integer read GetSquare;
    property Sprite: PQuadFXSprite read FSprite;
  published
    property Parent;
  end;

implementation

{ TSpriteNode }

uses Atlas;

procedure TSpriteNode.SetIsLocate(AValue: Boolean);
var
  Ref: Boolean;
begin
  Ref := FIsLocate <> AValue;
  FIsLocate := AValue;
  if Ref then
    RefreshIcon;
end;

function TSpriteNode.GetRect: TGPRectF;
begin
  Result := MakeRect(Position.X, Position.Y, FSprite.Size.X, FSprite.Size.Y);
end;

function TSpriteNode.GetSquare: Integer;
begin
  Result := FBitmap.GetWidth * FBitmap.GetHeight;
end;

function TSpriteNode.GetPosition: TPoint;
begin
  if Assigned(FSprite) then
    Result := Point(Round(FSprite.Position.X), Round(FSprite.Position.Y))
  else
    Result := Point(0, 0);
end;

procedure TSpriteNode.SetPosition(const Value: TPoint);
begin
  if Assigned(FSprite) then
    FSprite.Position := TVec2f.Create(Value.X, Value.Y);
end;

function TSpriteNode.GetAxis: TPoint;
begin
  if Assigned(FSprite) then
    Result := Point(Round(FSprite.Axis.X), Round(FSprite.Axis.Y))
  else
    Result := Point(0, 0);
end;

procedure TSpriteNode.SetAxis(const Value: TPoint);
begin
  if Assigned(FSprite) then
    FSprite.Axis := TVec2f.Create(Value.X, Value.Y);
end;

constructor TSpriteNode.CreateEx(const AFileName: WideString);
begin
  FPadding := 0;
  FIsLocate := True;
  FBitmap := TGPBitmap.Create(AFileName);
  TAtlasNode(Parent).Atlas.CreateSprite(FSprite);
  FSprite.Position := TVec2f.Create(0, 0);
  FSprite.Size := TVec2f.Create(FBitmap.GetWidth, FBitmap.GetHeight);
  FSprite.Axis := FSprite.Size / 2;
  Text := ExtractFileName(AFileName);

// CreateEx(FSprite);
  RefreshIcon;
end;

destructor TSpriteNode.Destroy;
begin

  inherited;
end;

function TSpriteNode.ToJson: TJSONObject;
begin
  //Result := FTextureInfo.ToJson;
  if not IsLocate then
    SaveBitmapToJson(Result);
end;

constructor TSpriteNode.CreateEx(ASprite: PQuadFXSprite);
var
  Graphics: TGPGraphics;
begin
  FPadding := 0;
  FIsLocate := true;
  //FTextureInfo.FromJson(AJsonObject);
  //LoadBitmapFromJson(AJsonObject);
  FSprite := ASprite;
  FBitmap := TGPBitmap.Create(Integer(Round(ASprite.Size.X)), Integer(Round(ASprite.Size.Y)));
  Axis := Point(FBitmap.GetWidth div 2, FBitmap.GetHeight div 2);
  Position := Point(Round(ASprite.Position.X), Round(ASprite.Position.Y));

  if Parent is TCustomTextureNode then
  begin
    Graphics := TGPGraphics.Create(FBitmap);
    Graphics.DrawImage(TCustomTextureNode(Parent).Bitmap, MakePoint(-Position.X, -Position.Y));
    Graphics.Free;
  end;

  Text := 'Sprite ' + IntToStr(ASprite.ID);
  //Text := IntToStr(Position.X) + 'x' + IntToStr(Position.Y);
  Text := IntToStr(FBitmap.GetWidth) + 'x' + IntToStr(FBitmap.GetHeight);

    {
  if Assigned(AJsonObject.Get('Name')) then
    Text := (AJsonObject.Get('Name').JsonValue as TJSONString).Value
  else
    Text := 'Sprite ' + IntToStr(Index);  }
  RefreshIcon;
end;

end.
