unit CustomTextureNode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GDIPAPI, GDIPOBJ, GDIPUTIL, Vcl.ComCtrls, Vcl.ImgList,
  System.Json, EncdDecd, IcomList;

type
  TCustomTextureNode = class(TCustomTreeNode)
  strict protected
    FBitmap: TGPBitmap;
    procedure RefreshIcon;
    procedure LoadBitmapFromJson(AJsonObject: TJSONObject);
    procedure SaveBitmapToJson(AJsonObject: TJSONObject);
    function GetWidth: Integer;
    function GetHeight: Integer;
  public
    destructor Destroy; override;

    property Bitmap: TGPBitmap read FBitmap;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
  end;

implementation

uses
  Sprite;

{ TCustomTextureNode }

destructor TCustomTextureNode.Destroy;
begin
  if Assigned(FBitmap) then
    FBitmap.Free;
  inherited;
end;

procedure TCustomTextureNode.RefreshIcon;
var
  Graphics: TGPGraphics;
  Rect: TGPRectF;
  Pen: TGPPen;
  Brush: TGPSolidBrush;
  Icon: TBitmap;
  X, Y: Integer;
begin
  Icon := TBitmap.Create;
  Icon.PixelFormat := pf32bit;
  Icon.Width := dmIcomList.List.Width;
  Icon.Height := dmIcomList.List.Height;

  if not Assigned(Bitmap) then
  begin
    Rect.Width := dmIcomList.List.Width;
    Rect.Height := dmIcomList.List.Height;
  end
  else
    if (Bitmap.GetWidth <= Icon.Width) and (Bitmap.GetHeight <= Icon.Height) then
    begin
      Rect.Width := Bitmap.GetWidth;
      Rect.Height := Bitmap.GetHeight;
    end
    else
      if Bitmap.GetWidth > Bitmap.GetHeight then
      begin
        Rect.Width := Icon.Width;
        Rect.Height := Bitmap.GetHeight / Bitmap.GetWidth * Icon.Height;
      end
      else
      begin
        Rect.Width := Bitmap.GetWidth / Bitmap.GetHeight * Icon.Width;
        Rect.Height := Icon.Height;
      end;

  Rect.X := Icon.Width div 2 - Rect.Width / 2;
  Rect.Y := Icon.Height div 2 - Rect.Height / 2;

  Graphics := TGPGraphics.Create(Icon.Canvas.Handle);
  Graphics.Clear($00FFFFFF);
  Brush := TGPSolidBrush.Create($FFCCCCCC);
  for Y := 0 to Icon.Width div 16 do
    for X := 0 to Icon.Width div 8 do
      Graphics.FillRectangle(Brush, MakeRect(X * 8, (Y * 16) + (X mod 2) * 8, 8, 8));
  Brush.SetColor($FF0000000);
  Graphics.FillRectangle(Brush, MakeRect(0, 0, 32, 32));

  if Assigned(Bitmap) then
    Graphics.DrawImage(FBitmap, Rect);

  if Self is TSpriteNode and not TSpriteNode(Self).IsLocate then
  begin
    Brush.SetColor($FFFF0000);
    Graphics.FillRectangle(Brush, MakeRect(0, Icon.Height - 10, 10, Icon.Height));
  end;
  Brush.Free;

  Pen := TGPPen.Create($FF000000);
  Graphics.DrawRectangle(Pen, 0, 0, Icon.Width - 1, Icon.Height - 1);

  Pen.Free;
  Graphics.Free;

  dmIcomList.List.Replace(ImageIndex, Icon, nil);
  Icon.Free;
end;

procedure TCustomTextureNode.SaveBitmapToJson(AJsonObject: TJSONObject);
var
  Stream: TMemoryStream;
  Encoding: TGUID;
begin
  GetEncoderClsid('image/png', Encoding);
  Stream := TMemoryStream.Create;
  try
    Bitmap.Save(TStreamAdapter.Create(Stream), Encoding);
    AJsonObject.AddPair(TJSONPair.Create('Data', String(EncodeBase64(stream.Memory, stream.Size))));
  finally
    Stream.Free;
  end;
end;

procedure TCustomTextureNode.LoadBitmapFromJson(AJsonObject: TJSONObject);
var
  Width, Height: Integer;
  Bytes: TBytes;
  Stream: TMemoryStream;
begin
  if not Assigned(AJsonObject) then
    Exit;

  if Assigned(AJsonObject.Get('Data')) then
  begin
    Bytes := DecodeBase64(AnsiString((AJsonObject.Get('Data').JsonValue as TJSONString).Value));
    Stream := TMemoryStream.Create;
    try
      if Bytes <> nil then
        Stream.Write(Bytes[0], Length(Bytes));
      FBitmap := TGPBitmap.Create(TStreamAdapter.Create(Stream));
    finally
      Stream.Free;
    end;
  end
  else
  begin
    Width := 0;
    if Assigned(AJsonObject.Get('Width')) then
      Width := (AJsonObject.Get('Width').JsonValue as TJSONNumber).AsInt;
    Height := 0;
    if Assigned(AJsonObject.Get('Height')) then
      Height := (AJsonObject.Get('Height').JsonValue as TJSONNumber).AsInt;
    FBitmap := TGPBitmap.Create(Width, Height);
  end;
end;

function TCustomTextureNode.GetWidth: Integer;
begin
  if Assigned(Bitmap) then
    Result := Bitmap.GetWidth
  else
    Result := 0;
end;

function TCustomTextureNode.GetHeight: Integer;
begin
  if Assigned(Bitmap) then
    Result := Bitmap.GetHeight
  else
    Result := 0;
end;

end.
