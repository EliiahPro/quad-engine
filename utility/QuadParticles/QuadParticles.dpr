program QuadParticles;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

{$WARNINGS ON}
{$WARN CONSTRUCTING_ABSTRACT ERROR}

uses
  Vcl.Forms,
  Main in 'Main.pas' {fMain},
  RenderPanel in 'RenderPanel.pas',
  Vcl.Themes,
  Vcl.Styles,
  Frame.Custom in 'Frames\Frame.Custom.pas' {CustomParamFrame: TFrame},
  Frame.Value in 'Frames\Frame.Value.pas' {FrameValue: TFrame},
  Frame.Shape in 'Frames\Frame.Shape.pas' {FrameShape: TFrame},
  Frame.Shape.Line in 'Frames\Shape\Frame.Shape.Line.pas' {FrameShapeLine: TFrame},
  Frame.Shape.Circle in 'Frames\Shape\Frame.Shape.Circle.pas' {FrameShapeCircle: TFrame},
  Frame.Shape.Rect in 'Frames\Shape\Frame.Shape.Rect.pas' {FrameShapeRect: TFrame},
  QPTreeNode in 'QPTreeNode.pas',
  Atlas in 'Textures\Atlas.pas',
  CustomTextureNode in 'Textures\CustomTextureNode.pas',
  Sprite in 'Textures\Sprite.pas',
  Textures in 'Textures\Textures.pas' {fTextures},
  IcomList in 'Globals\IcomList.pas' {dmIcomList: TDataModule},
  Frame.Color in 'Frames\Frame.Color.pas' {FrameColor: TFrame},
  Frame.Texture in 'Frames\Frame.Texture.pas' {FrameTexture: TFrame},
  FileAssociationContoller in 'FileAssociationContoller.pas',
  Frame.Position in 'Frames\Frame.Position.pas' {FramePosition: TFrame},
  Frame.DirectionSpread in 'Frames\Frame.DirectionSpread.pas' {FrameDirectionSpread: TFrame},
  Frame.Globals in 'Frames\Frame.Globals.pas' {FrameGlobals: TFrame};

{$R *.res}
{$R 'resources\data.res' 'resources\data.rc'}

begin
  ReportMemoryLeaksOnShutdown := True;
  Randomize;

  if TFileAssociationContoller.Create.IsAssociation then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  //TStyleManager.TrySetStyle('Glossy');
  Application.CreateForm(TdmIcomList, dmIcomList);
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfTextures, fTextures);
  //Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
