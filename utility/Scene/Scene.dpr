program Scene;

uses
  Vcl.Forms,
  main in 'main.pas' {mainform},
  CustomScene in 'CustomScene.pas',
  Resources in 'Resources.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.
