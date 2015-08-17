unit QuadFX.EffectParamsList;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.Emitter,
  System.Generics.Collections, System.Classes, System.SysUtils;

type
  TQuadFXEffectParamsList = class(TInterfacedObject, IQuadFXEffectParamsList)
  private
    FEffects: TList<IQuadFXEffectParams>;
    function GetEffectByName(AFilename: PWideChar): IQuadFXEffectParams; stdcall;
    function GetEffect(Index: Integer): IQuadFXEffectParams; stdcall;
    function GetEffectCount: Integer; stdcall;
    procedure LoadEffect(F: TFileStream);
  public
    constructor Create;
    destructor Destroy; override;
    function EffectAdd(AEffect: IQuadFXEffectParams): Integer;
    procedure EffectRemove(AEffect: IQuadFXEffectParams);
    procedure LoadFromFile(AFilename: PWideChar); stdcall;
    procedure SaveToFile(AFilename: PWideChar); stdcall;
  end;

implementation

uses
  QuadFX.EffectParams;

const
  FILE_HEADER: array[0..7] of Char = (#137, #81, #69, #70, #13, #10, #26, #10);
type
  TFileChunkName = array[0..2] of Char;

{
TParams
  1 -- Type




File
  - header (8)
  - texture ????????

  - effects
  [EFT] (3 + 4)
    [EMT] (3 + 4)

    [EMT] (3 + 4)
      [LFT] 3 + 4  -- LifeTime
      [EMS] 3 + 4  -- Emission
        -- TParams

  [END] (3 + 4)
}

{ TQPEffectParams }

constructor TQuadFXEffectParamsList.Create;
begin
  FEffects := TList<IQuadFXEffectParams>.Create;
end;

destructor TQuadFXEffectParamsList.Destroy;
begin
  if Assigned(FEffects) then
    FEffects.Free;
  inherited;
end;

function TQuadFXEffectParamsList.EffectAdd(AEffect: IQuadFXEffectParams): Integer;
begin
  if Assigned(AEffect) then
    Exit(FEffects.Add(AEffect));
  Result := 0;
end;

procedure TQuadFXEffectParamsList.EffectRemove(AEffect: IQuadFXEffectParams);
begin
  FEffects.Remove(AEffect);
end;

function TQuadFXEffectParamsList.GetEffectByName(AFilename: PWideChar): IQuadFXEffectParams; stdcall;
//var
//  i: Integer;
begin
  Result := nil;
  {if GetEffectCount > 0 then
    for i := 0 to GetEffectCount - 1 do
      if TQuadFXEffectParams(FEffects[i]).Name = AFilename then
        Exit(FEffects[i]);   }
end;

function TQuadFXEffectParamsList.GetEffect(Index: Integer): IQuadFXEffectParams; stdcall;
begin
  if Assigned(FEffects) and (Index >= 0) and (Index < FEffects.Count) then
    Result := FEffects[Index]
  else
    Result := nil;
end;

function TQuadFXEffectParamsList.GetEffectCount: Integer; stdcall;
begin
  if Assigned(FEffects) then
    Result := FEffects.Count
  else
    Result := 0;
end;

procedure TQuadFXEffectParamsList.LoadFromFile(AFilename: PWideChar); stdcall;
var
  F: TFileStream;
  Header: array[0..7] of Char;

  ChunkLength: Cardinal;
  ChunkName: TFileChunkName;
begin
  if not FileExists(AFilename) then
    Exit;

  F := TFileStream.Create(AFilename, fmOpenRead);
  try
    F.Seek(0, soBeginning);
    F.Read(Header[0], 8);

    if Header = FILE_HEADER then
    begin
      repeat
        F.Read(ChunkName[0], 3);
        F.Read(ChunkLength, 4);
        if F.Position + ChunkLength > F.Size then
          Break;




      until (ChunkName = 'END');
    end;
  finally
    F.Free;
  end;

end;

procedure TQuadFXEffectParamsList.LoadEffect(F: TFileStream);
//var
//  Effect: TQuadFXEffectParams;
begin
 // Effect := TQuadFXEffectParams.Create();

end;

procedure TQuadFXEffectParamsList.SaveToFile(AFilename: PWideChar); stdcall;
var
  F: TFileStream;
begin
  F := TFileStream.Create(AFilename, fmCreate);
  try
    F.Seek(0, soBeginning);
    F.Write(FILE_HEADER[0], 8);
        {
    if Header = FILE_HEADER then
    begin
      repeat
        F.Read(FILE_HEADER[0], 3);
        F.Read(ChunkLength, 4);
        if F.Position + ChunkLength > F.Size then
          Break;




      until (ChunkName = 'END');
    end;  }
  finally
    F.Free;
  end;
end;

end.
