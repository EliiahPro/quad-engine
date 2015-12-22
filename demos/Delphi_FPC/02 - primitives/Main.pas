unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, QuadEngine, QuadEngine.Color, Vec2f;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  QuadDevice: IQuadDevice;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;

  Xpos, Ypos: Integer;

implementation

{$R *.dfm}

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadRender.BeginRender;
  QuadRender.Clear(0);

  QuadRender.Rectangle(TVec2f.Create(100, 100), TVec2f.Create(400, 400), TQuadColor.Blue);
  QuadRender.Rectangle(TVec2f.Create(200, 200), TVec2f.Create(500, 500), TQuadColor.Lime.Lerp(TQuadColor.Red, Xpos/800));

  QuadRender.SetBlendMode(qbmSrcAlpha);
  QuadRender.DrawCircle(TVec2f.Create(400, 400), 100, 95, TQuadColor.Blue);
  QuadRender.DrawCircle(TVec2f.Create(Xpos, Ypos), 30, 27, TQuadColor.Aqua);

  QuadRender.DrawQuadLine(TVec2f.Create(400, 400), TVec2f.Create(Xpos, Ypos), 5, 5, TQuadColor.Blue, TQuadColor.Aqua);

  QuadRender.EndRender;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.ClientWidth := 800;
  Self.ClientHeight := 600;

  Randomize;

  QuadDevice := CreateQuadDevice;

  // create render
  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(Self.Handle, 800, 600, False);

  // create and start timer
  QuadDevice.CreateTimer(QuadTimer);
  QuadTimer.SetInterval(16);
  QuadTimer.SetCallBack(OnTimer);
  QuadTimer.SetState(True);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // turn off timer and ensure that timer's thread already stopped
  QuadTimer.SetState(False);
  Sleep(200);

  // free resources
  QuadTimer := nil;
  QuadRender := nil;
  QuadDevice := nil;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Xpos := X;
  Ypos := Y;
end;

end.
