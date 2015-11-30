program DFFontRender;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Main},
  DistanceFieldCalculator in 'DistanceFieldCalculator.pas',
  AtlasTree in 'AtlasTree.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
