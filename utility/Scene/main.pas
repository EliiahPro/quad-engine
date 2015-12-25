unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, QuadEngine, Quadengine.Color, Vec2f,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus, Resources, Vcl.ComCtrls,
  System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan;

type
  TMainForm = class(TForm)
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
    TimeLinePanel: TPanel;
    RenderPanel: TPanel;
    New1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    N2: TMenuItem;
    View1: TMenuItem;
    About2: TMenuItem;
    TreeView1: TTreeView;
    OpenTextureDialog: TOpenDialog;
    ActionManager1: TActionManager;
    Action1: TAction;
    Button1: TButton;
    procedure ResizeTimerTimer(Sender: TObject);
    procedure RenderPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RenderPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RenderPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RenderPanelResize(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  public
    procedure AfterConstruction; override;
  end;

var
  MainForm: TMainForm;
  OldX: Integer;
  OldY: Integer;
  MouseDrag: Boolean = False;
  time: Single;

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
  TGlobals.QuadCamera.Disable;

  TGlobals.QuadRender.SetBlendMode(qbmSrcAlpha);
  TGlobals.QuadFont.SetKerning(2);
  TGlobals.QuadFont.TextOut(TVec2f.Create(2, 10), 0.25, 'DSFDSFDS', TQuadColor.Gray);
  TGlobals.QuadRender.EndRender;
end;

procedure TMainForm.Action1Execute(Sender: TObject);
var
  node: TTreeNode;
begin
  if OpenTextureDialog.Execute then
  begin
    TGlobals.AddTexture(OpenTextureDialog.FileName);
    node := TreeView1.Items.AddChild(TreeView1.Items.GetFirstNode(), ExtractFileName(OpenTextureDialog.FileName));
    node.Data := Pointer(TGlobals.Textures.Count - 1);
  end;
end;

procedure TMainForm.AfterConstruction;
begin
  inherited;

  TGlobals.QuadDevice := CreateQuadDevice;
  TGlobals.QuadDevice.CreateRender(TGlobals.QuadRender);

  TGlobals.QuadRender.Initialize(RenderPanel.Handle, RenderPanel.Width, RenderPanel.Height, False, qsm30);

  TGlobals.QuadDevice.CreateCamera(TGlobals.QuadCamera);

  TGlobals.QuadScene := TCustomScene.Create;

  TGlobals.QuadDevice.CreateAndLoadTexture(0, 'data\cursor.png', TGlobals.Cursor);
  TGlobals.QuadDevice.CreateAndLoadFont('data\font.png', 'data\font.qef', TGlobals.QuadFont);


  TGlobals.QuadRender.SetAutoCalculateTBN(True);
  TGlobals.QuadDevice.CreateTimerEx(TGlobals.QuadTimer, OnTimer, 16, True);
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  TGlobals.AddTexture(OpenTextureDialog.FileName);
  //TGlobals.QuadDevice.CreateAndLoadTexture(0, 'C:\Users\IProkhodtsev\Desktop\medal_steam.png', TGlobals.Cursor);
end;

procedure TMainForm.RenderPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDrag := (Button = TMouseButton.mbRight);
end;

procedure TMainForm.RenderPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if MouseDrag then
    TGlobals.QuadCamera.Translate(TVec2f.Create(OldX - X, OldY - Y));

  OldX := X;
  OldY := Y;
end;

procedure TMainForm.RenderPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDrag := False;
end;

procedure TMainForm.RenderPanelResize(Sender: TObject);
begin
  ResizeTimer.Enabled := True;
  ResizeTimer.Interval := 300;
end;

procedure TMainForm.ResizeTimerTimer(Sender: TObject);
begin
  if Assigned(TGlobals.QuadTimer) then
    TGlobals.QuadRender.ChangeResolution(MainForm.RenderPanel.Width, MainForm.RenderPanel.Height, False);
  ResizeTimer.Enabled := False;
end;

end.
