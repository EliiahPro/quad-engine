program QuadProfiler;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form4},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TfMainForm, fMainForm);
  Application.Run;
end.
