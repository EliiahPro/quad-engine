unit Resources;

interface

uses
  QuadEngine, Vec2f, QuadEngine.Color, CustomScene, System.Generics.Collections,
  sysutils, Windows, Classes;

type
  TGlobals = class sealed
  class var
    QuadDevice: IQuadDevice;
    QuadRender: IQuadRender;
    QuadTimer: IQuadTimer;
    QuadCamera: IQuadCamera;
    QuadFont: IQuadFont;
    QuadScene: TCustomScene;
    Cursor: IQuadTexture;
    Textures: TList<IQuadTexture>;
  class procedure AddTexture(const AFilename: string);
  end;

implementation

{ TGlobals }

class procedure TGlobals.AddTexture(const AFilename: string);
var
  Texture: IQuadTexture;
begin
  if FileExists(AFilename) then
  begin
    TGlobals.QuadDevice.CreateTexture(Texture);
    Texture.LoadFromFile(0, PWideChar(AFilename));
    TGlobals.Textures.Add(Texture);
  end;
end;

initialization
  TGlobals.Textures := TList<IQuadTexture>.Create;

finalization
  TGlobals.Textures.Free;

end.
