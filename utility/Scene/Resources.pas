unit Resources;

interface

uses
  QuadEngine, Vec2f, QuadEngine.Color, CustomScene, System.Generics.Collections;

type
  TGlobals = class sealed
  class var
    QuadDevice: IQuadDevice;
    QuadRender: IQuadRender;
    QuadTimer: IQuadTimer;
    QuadCamera: IQuadCamera;
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
  QuadDevice.CreateTexture(Texture);
  Texture.LoadFromFile(0, PWideChar(AFileName));
  Self.Textures.Add(Texture);
end;

initialization
  TGlobals.Textures := TList<IQuadTexture>.Create;

finalization
  TGlobals.Textures.Free;

end.
