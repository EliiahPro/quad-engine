program Scene;

uses
  Vcl.Forms,
  main in 'main.pas' {MainForm},
  CustomScene in 'CustomScene.pas',
  Resources in 'Resources.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
