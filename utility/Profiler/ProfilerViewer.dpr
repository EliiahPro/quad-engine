program ProfilerViewer;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  Vcl.Forms,
  Main in 'Main.pas' {fMain},
  Vcl.Themes,
  Vcl.Styles,
  DiagramLine in 'DiagramLine.pas',
  DiagramFrame in 'DiagramFrame.pas' {fDiagramForm: TFrame},
  ListLogItem in 'ListLogItem.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
