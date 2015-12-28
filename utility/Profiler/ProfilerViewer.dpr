program ProfilerViewer;

uses
  Vcl.Forms,
  Main in 'Main.pas' {fMain},
  Vcl.Themes,
  Vcl.Styles,
  DiagramView in 'DiagramView.pas',
  DiagramLine in 'DiagramLine.pas',
  DiagramFrame in 'DiagramFrame.pas' {fDiagramFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
