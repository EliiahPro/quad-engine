unit CustomScene;

interface

uses
  Vec2f, QuadEngine, QuadEngine.Color;

type
  TSceneProperties = packed record
    Width: Integer;
    Height: Integer;
    Background: TQuadColor;
    Foreground: TQuadColor;
    GridColor: TQuadColor;
  end;

  TCustomScene = class
  const
    FADESIZE = 512;
  private
    FProperties: TSceneProperties;
    FIsDrawGrid: Boolean;
  public
    constructor Create;
    procedure Draw;
    procedure Process(ADelta: Double);
    property IsDrawGrid: Boolean read FIsDrawGrid write FIsDrawGrid;
  end;

implementation

uses
  Resources;

{ TScene }

constructor TCustomScene.Create;
begin
  inherited;

  FProperties.Width := 800;
  FProperties.Height := 600;

  FProperties.Foreground := $FF132328;
  FProperties.Background := $FF000000;
  FProperties.GridColor := FProperties.Background + TQuadColor.Create(0.05, 0.05, 0.05, 0.05);

  FIsDrawGrid := True;
end;

procedure TCustomScene.Draw;
var
  i: Integer;
begin
  TGlobals.QuadRender.Clear(FProperties.Foreground);

  {$REGION 'Grid'}
  if FIsDrawGrid then
  begin
    TGlobals.QuadRender.SetBlendMode(qbmNone);

    TGlobals.QuadRender.Rectangle(TVec2f.Create(0, 0), TVec2f.Create(FProperties.Width, FProperties.Height), FProperties.Background);

    TGlobals.QuadRender.RectangleEx(TVec2f.Create(-FADESIZE, 0), TVec2f.Create(0, FProperties.Height), FProperties.Foreground, FProperties.Background, FProperties.Foreground, FProperties.Background);
    TGlobals.QuadRender.RectangleEx(TVec2f.Create(FProperties.Width, 0), TVec2f.Create(FProperties.Width + FADESIZE, FProperties.Height), FProperties.Background, FProperties.Foreground, FProperties.Background, FProperties.Foreground);
    TGlobals.QuadRender.RectangleEx(TVec2f.Create(0, -FADESIZE), TVec2f.Create(FProperties.Width, 0), FProperties.Foreground, FProperties.Foreground, FProperties.Background, FProperties.Background);
    TGlobals.QuadRender.RectangleEx(TVec2f.Create(0, FProperties.Height), TVec2f.Create(FProperties.Width, FProperties.Height + FADESIZE), FProperties.Background, FProperties.Background, FProperties.Foreground, FProperties.Foreground);

    TGlobals.QuadRender.RectangleEx(TVec2f.Create(-FADESIZE, -FADESIZE), TVec2f.Create(0, 0), FProperties.Foreground, FProperties.Foreground, FProperties.Foreground, FProperties.Background);
    TGlobals.QuadRender.RectangleEx(TVec2f.Create(-FADESIZE, FProperties.Height), TVec2f.Create(0, FProperties.Height + FADESIZE), FProperties.Foreground, FProperties.Background, FProperties.Foreground, FProperties.Foreground);
    TGlobals.QuadRender.RectangleEx(TVec2f.Create(FProperties.Width, -FADESIZE), TVec2f.Create(FProperties.Width + FADESIZE, 0), FProperties.Foreground, FProperties.Foreground, FProperties.Background, FProperties.Foreground);
    TGlobals.QuadRender.RectangleEx(TVec2f.Create(FProperties.Width, FProperties.Height), TVec2f.Create(FProperties.Width + FADESIZE, FProperties.Height + FADESIZE), FProperties.Background, FProperties.Foreground, FProperties.Foreground, FProperties.Foreground);

    for i := 0 to FProperties.Width div 10 do
      TGlobals.QuadRender.DrawQuadLine(TVec2f.Create(i * 10, 0), TVec2f.Create(i * 10, FProperties.Height), 1, 1, FProperties.GridColor, FProperties.GridColor);

    for i := 0 to FProperties.Height div 10 do
      TGlobals.QuadRender.DrawQuadLine(TVec2f.Create(0, i * 10), TVec2f.Create(FProperties.Width, i * 10), 1, 1, FProperties.GridColor, FProperties.GridColor);
  end;
  {$ENDREGION}
end;

procedure TCustomScene.Process(ADelta: Double);
begin

end;

end.
