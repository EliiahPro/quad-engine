unit QuadShadeProject;

interface

type
  TqsProjectOptions = record
    Name             : String;
    PSprofile        : String;
    VSprofile        : String;
    OptimizationLevel: Byte;
    PSOutputPath     : String;
    VSOutputPath     : String;
    SourcePath       : String;
    PSsRegister      : array[0..7] of String;
  end;

  TQuadShadeProject = class

  end;

implementation

end.
 