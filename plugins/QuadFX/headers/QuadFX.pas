unit QuadFX;

interface

uses
  Winapi.Windows, QuadEngine, Vec2f, QuadEngine.Color;

const
  QuadFXLibraryName: PChar = 'qeiFX.dll';
  QuadFXMinorVersion: Byte = 0;
  QuadFXMajorVersion: Byte = 8;
  QuadFXReleaseVersion: Byte = 0;

type
  PVertexes = ^TVertexes;
  TVertexes = array[0..5] of TVertex;

  PQuadFXParticle = ^TQuadFXParticle;
  PQuadFXEmitterParams = ^TQuadFXEmitterParams;
  PQuadFXParams = ^TQuadFXParams;
  PQuadFXParticleValue = ^TQuadFXParticleValue;
  PQuadFXSprite = ^TQuadFXSprite;
  PQuadFXEmitterShape = ^TQuadFXEmitterShape;
  IQuadFXEmitter = interface;

  TQuadFXEmitterDrawEvent = procedure(AEmitter: IQuadFXEmitter; AParticles: PQuadFXParticle; AParticleCount: Integer) of object; stdcall;

  TQuadFXParticleValue = record
  public
    Index: array[0..1] of Integer;
    Rand: Single;
    Params: PQuadFXParams;
    Value: Single;
  end;

  TQuadFXParticle = record
    Vertexes: PVertexes;
    Time: Double;
    Life: Double;
    Position: TVec2f;
    TextureIndex: Integer;
    Angle: Single;

    LifeTime: Double;

    StartVelocity: TVec2f;
    Velocity: TQuadFXParticleValue;

    Gravitation: TQuadFXParticleValue;

    Color: TQuadColor;
    ColorIndex: integer;

    Opacity: TQuadFXParticleValue;

    StartScale: Single;
    Scale: TQuadFXParticleValue;

    StartAngle: Single;
    Spin: TQuadFXParticleValue;
  end;

  PQuadFXSingleDiagramValue = ^TQuadFXSingleDiagramValue;
  TQuadFXSingleDiagramValue = packed record
    Life: Single;
    Value: Single;
  end;

  PQuadFXSingleDiagram = ^TQuadFXSingleDiagram;
  TQuadFXSingleDiagram = record
    List: array of TQuadFXSingleDiagramValue;
    Count: Integer;
  end;

  PQuadFXColorDiagramValue = ^TQuadFXColorDiagramValue;
  TQuadFXColorDiagramValue = record
    Life: Single;
    Value: TQuadColor;
  end;

  PQuadFXColorDiagram = ^TQuadFXColorDiagram;
  TQuadFXColorDiagram = record
    List: array of TQuadFXColorDiagramValue;
    Count: Integer;
  end;

  TQuadFXSingleStartValue = record
    Min: Single;
    Max: Single;
  end;

  TQuadFXEmitterShapeType = (
    qeftPoint = 0,
    qeftLine = 1,
    qeftCircle = 2,
    qeftRect = 3
  );

  TQuadFXParamsType = (
    qpptValue = 0,
    qpptRandomValue = 1,
    qpptCurve = 2,
    qpptRandomCurve = 3
  );

  TQuadFXEmitterShape = record
    ShapeType: TQuadFXEmitterShapeType;
    ParamType: TQuadFXParamsType;
    Value: array[0..2] of Single;
    Diagram: array[0..2] of TQuadFXSingleDiagram;
  end;

  TQuadFXParams = record
    ParamsType: TQuadFXParamsType;
    Value: array[0..1] of Single;
    Diagram: array[0..1] of TQuadFXSingleDiagram;
  end;

  TQuadFXSprite = record
    ID: Integer;
    Texture: IQuadTexture;
    Position: TVec2f;
    Size: TVec2f;
    Axis: TVec2f;
    UVA, UVB: TVec2f;
  end;

  TQuadFXEmitterParams = record
    Name: WideString;

    Textures: array of PQuadFXSprite;
    TextureCount: Integer;

    BlendMode: TQuadBlendMode;
    EndTime: Single;
    BeginTime: Single;
    IsLoop: Boolean;
    MaxParticles: Cardinal;

    Position: record
      X: TQuadFXParams;
      Y: TQuadFXParams;
    end;

    Shape: TQuadFXEmitterShape;

    Emission: TQuadFXParams;

    Direction: TQuadFXParams;
    DirectionFromCenter: Boolean;
    Spread: TQuadFXParams;

    Particle: record
      LifeTime: TQuadFXParams;
      StartVelocity: TQuadFXParams;
      Velocity: TQuadFXParams;
      Gravitation: TQuadFXParams;

      Color: TQuadFXColorDiagram;

      Opacity: TQuadFXParams;
      Scale: TQuadFXParams;
      StartAngle: TQuadFXParams;
      Spin: TQuadFXParams;
    end;
  end;

  IQuadFXEffectParams = interface;

  IQuadFXAtlas = interface(IUnknown)
  ['{5277308B-9D5E-4B5A-B554-97D19552B899}']
    function GetSprite(Index: Integer; out ASprite: PQuadFXSprite): HResult; stdcall;
    function GetSpriteCount: Integer; stdcall;
    function GetSize: TVec2f; stdcall;
    function GetName: PWideChar; stdcall;
    function GetPackName: PWideChar; stdcall;
    function SpriteByID(const AID: Integer; out ASprite: PQuadFXSprite): HResult; stdcall;
    procedure LoadFromFile(AEffectName, AFileName: PWideChar); stdcall;
    procedure LoadFromStream(AEffectName: PWideChar; AStream: Pointer; AStreamSize: Integer); stdcall;
    function CreateSprite(out ASprite: PQuadFXSprite): HResult; stdcall;
    function DeleteSprite(ASprite: PQuadFXSprite): HResult; stdcall;
    procedure SetTexture(ATesture: IQuadTexture); stdcall;
  end;

  IQuadFXEmitter = interface(IUnknown)
    ['{2F2841E6-88FF-4F1E-8261-3C9197EA89AE}']
    procedure Update(ADelta: Double); stdcall;
    procedure Draw; stdcall;
    function GetEmitterParams(out AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
    function GetParticleCount: integer; stdcall;
    function GetActive: Boolean; stdcall;
  end;

  IQuadFXEffectParams = interface(IUnknown)
    ['{8036DBA9-BFDA-4D57-8E8E-E2709930D706}']
    function CreateEmitterParams(out AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
    procedure LoadFromFile(AEffectName, AFileName: PWideChar); stdcall;
    procedure LoadFromStream(AEffectName: PWideChar; AStream: Pointer; AStreamSize: Integer); stdcall;
    function GetEmitterParams(Index: Integer; out AEmitterParams: PQuadFXEmitterParams): HResult; stdcall;
    function GetEmitterParamsCount: integer; stdcall;
    function GetLifeTime: Single; stdcall;
  end;

  IQuadFXEffect = interface(IUnknown)
    ['{2A368A2E-ECAD-46F4-8F38-25CFFAE27A18}']
    procedure Update(const ADelta: Double); stdcall;
    procedure Draw; stdcall;

    function GetEmitter(Index: Integer; out AEmitter: IQuadFXEmitter): HResult; stdcall;
    function GetEmitterCount: integer; stdcall;
    function GetParticleCount: integer; stdcall;
    function GetEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
    function GetPosition: TVec2f; stdcall;
    function GetLife: Single; stdcall;
    function GetAngle: Single; stdcall;
    function GetScale: Single; stdcall;
    function GetSpawnWithLerp: Boolean; stdcall;

    procedure SetPosition(APosition: TVec2f); stdcall;
    procedure SetAngle(AAngle: Single); stdcall;
    procedure SetScal(AScale: Single); stdcall;
    procedure SetSpawnWithLerp(ASpawnWithLerp: Boolean); stdcall;
  end;

  IQuadFXLayer = interface(IUnknown)
    ['{9574A3EF-D5DE-4E42-B5E8-F08E869EC53F}']
    procedure Clear; stdcall;
    procedure Draw; stdcall;
    procedure Update(const ADelta: Double); stdcall;
    function CreateEffect(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; AAngle: Single = 0; AScale: Single = 1): HResult; stdcall;
    function CreateEffectEx(AEffectParams: IQuadFXEffectParams; APosition: TVec2f; out AEffect: IQuadFXEffect; AAngle: Single = 0; AScale: Single = 1): HResult; stdcall;
    procedure SetOnDraw(AOnDraw: TQuadFXEmitterDrawEvent);
    procedure SetOnDebugDraw(AOnDebugDraw: TQuadFXEmitterDrawEvent);
    procedure SetGravitation(Avector: TVec2f); stdcall;
    function GetEffectCount: Integer; stdcall;
    function GetEffect(AIndex: Integer; out AEffect: IQuadFXEffect): HResult; stdcall;
    function GetParticleCount: Integer; stdcall;
    function GetGravitation: TVec2f; stdcall;
  end;

  IQuadFXManager = interface(IUnknown)
    ['{E8E26D13-A480-4763-87B0-B381A8221C4E}']
    function CreateEffectParams(out AEffect: IQuadFXEffectParams): HResult; stdcall;
    function CreateLayer(out ALayer: IQuadFXLayer): HResult; stdcall;
    function CreateAtlas(out AAtlas: IQuadFXAtlas): HResult; stdcall;
  end;

  TCreateQuadFXManager    = function(AQuadDevice: IQuadDevice; out AQuadFXManager: IQuadFXManager): HResult; stdcall;
  TCheckQuadFXLibraryVersion = function(ARelease, AMajor, AMinor: Byte): Boolean; stdcall;

  function CreateQuadFXManager(AQuadDevice: IQuadDevice): IQuadFXManager;

implementation

// Creating of main QuadFX interface object
function CreateQuadFXManager(AQuadDevice: IQuadDevice): IQuadFXManager;
var
  h: THandle;
  Creator: TCreateQuadFXManager;
  CheckQuadLibrary: TCheckLibraryVersion;
  CheckLibrary: TCheckQuadFXLibraryVersion;
begin
  h := LoadLibrary(QuadFXLibraryName);
  if h <> 0 then
  begin
    CheckLibrary := TCheckQuadFXLibraryVersion(GetProcAddress(h, 'IsSameVersion'));
    CheckQuadLibrary := TCheckQuadFXLibraryVersion(GetProcAddress(h, 'IsSameQuadVersion'));
    if CheckLibrary(QuadFXReleaseVersion, QuadFXMajorVersion, QuadFXMinorVersion) and
       CheckQuadLibrary(QuadEngineReleaseVersion, QuadEngineMajorVersion, QuadEngineMinorVersion) then
    begin
      Creator := TCreateQuadFXManager(GetProcAddress(h, 'CreateQuadFXManager'));
      if Assigned(Creator) then
        Creator(AQuadDevice, Result);
    end;
  end;
end;

end.
