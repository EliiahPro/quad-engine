unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, QuadEngine;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
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

implementation

{$R *.dfm}

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
begin
  QuadRender.BeginRender;
  QuadRender.Clear(Random($FFFFFFFF));

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
  QuadTimer.SetInterval(200);
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

end.
