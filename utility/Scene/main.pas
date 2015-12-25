unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, QuadEngine, Quadengine.Color, Vec2f,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus, Resources, Vcl.ComCtrls;

type
  Tmainform = class(TForm)
    MainPanel: TPanel;
    ResizeTimer: TTimer;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    About1: TMenuItem;
    Exit1: TMenuItem;
    Project1: TMenuItem;
    Additem1: TMenuItem;
    N1: TMenuItem;
    Options1: TMenuItem;
    Texture1: TMenuItem;
    Animation1: TMenuItem;
    Font1: TMenuItem;
    Shader1: TMenuItem;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    RenderPanel: TPanel;
    New1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    N2: TMenuItem;
    View1: TMenuItem;
    About2: TMenuItem;
    TreeView1: TTreeView;
    OpenDialog1: TOpenDialog;
    procedure ResizeTimerTimer(Sender: TObject);
    procedure RenderPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RenderPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RenderPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RenderPanelResize(Sender: TObject);
    procedure Texture1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AfterConstruction; override;
    { Public declarations }
  end;

var
  mainform: Tmainform;
  OldX: Integer;
  OldY: Integer;
  MouseDrag: Boolean = False;
  tx: IQuadTexture;
  res: TVec2f;
  mat: TMatrix4x4;
  time: Single;
  mymouse: TVec2f;

implementation

uses
  CustomScene;

{$R *.dfm}

{ Tmainform }

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  time := time + delta / 10;
  TGlobals.QuadScene.Process(delta);

  TGlobals.QuadRender.BeginRender;
  TGlobals.QuadRender.Clear(0);
  TGlobals.QuadCamera.Enable;

  TGlobals.QuadScene.Draw;

  TGlobals.QuadRender.SetBlendMode(qbmNone);
  res.X := 1;
  res.Y := 1;
  TGlobals.QuadCamera.GetMatrix(mat);
  mymouse.X := OldY / 600;
  mymouse.Y := OldX / 600;

  TGlobals.QuadCamera.Disable;

  TGlobals.QuadRender.EndRender;
end;

procedure Tmainform.AfterConstruction;
begin
  inherited;

  TGlobals.QuadDevice := CreateQuadDevice;
  TGlobals.QuadDevice.CreateRender(TGlobals.QuadRender);

  TGlobals.QuadRender.Initialize(RenderPanel.Handle, RenderPanel.Width, RenderPanel.Height, False, qsm30);

  TGlobals.QuadDevice.CreateCamera(TGlobals.QuadCamera);

  TGlobals.QuadScene := TCustomScene.Create;

  TGlobals.QuadDevice.CreateAndLoadTexture(0, 'data\cursor.png', TGlobals.Cursor);

  TGlobals.QuadDevice.CreateAndLoadTexture(0, 'data\Bump.jpg', tx);
  tx.LoadFromFile(1, 'data\Bump.jpg');

  TGlobals.QuadRender.SetAutoCalculateTBN(False);
  TGlobals.QuadDevice.CreateTimerEx(TGlobals.QuadTimer, OnTimer, 16, True);
end;

procedure Tmainform.Texture1Click(Sender: TObject);
var
  node: TTreeNode;
begin
  if OpenDialog1.Execute then
  begin
    TGlobals.AddTexture(OpenDialog1.FileName);
    node := TreeView1.Items.AddChild(TreeView1.Items.GetFirstNode(), ExtractFileName(OpenDialog1.FileName));
    node.Data := Pointer(TGlobals.Textures.Count - 1);
  end;
end;

procedure Tmainform.RenderPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDrag := True;
end;

procedure Tmainform.RenderPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if MouseDrag then
    TGlobals.QuadCamera.Translate(TVec2f.Create(OldX - X, OldY - Y));

  OldX := X;
  OldY := Y;
end;

procedure Tmainform.RenderPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDrag := False;
end;

procedure Tmainform.RenderPanelResize(Sender: TObject);
begin
  ResizeTimer.Enabled := True;
  ResizeTimer.Interval := 300;
end;

procedure Tmainform.ResizeTimerTimer(Sender: TObject);
begin
  if Assigned(TGlobals.QuadTimer) then
    TGlobals.QuadRender.ChangeResolution(mainform.RenderPanel.Width, mainform.RenderPanel.Height, False);
  ResizeTimer.Enabled := False;
end;

end.
