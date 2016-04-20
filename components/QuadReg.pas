unit QuadReg;

interface

uses Classes;

procedure Register;

implementation

uses
  FloatSpinEdit,
  Quad.Diagram,
  Quad.EffectTimeLine,
  Quad.GradientEdit,
  QuadIcon,
  QuadMemo,
  QuadPageControl,
  Quad.ObjectInspector;

procedure Register;
begin
  RegisterComponents('Quad', [TFloatSpinEdit]);
  RegisterComponents('Quad', [TQuadDiagram]);
  RegisterComponents('Quad', [TEffectTimeLine]);
  RegisterComponents('Quad', [TQuadGradientEdit]);
  RegisterComponents('Quad', [TQuadIcon]);
  RegisterComponents('Quad', [TQuadMemo]);
  RegisterComponents('Quad', [TQuadObjectInspector]);
end;

end.
