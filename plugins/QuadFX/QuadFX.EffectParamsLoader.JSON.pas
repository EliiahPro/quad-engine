unit QuadFX.EffectParamsLoader.JSON;

interface

uses
  QuadFX, QuadEngine, Generics.Collections, sysutils, classes, System.Json,
  QuadFX.EffectParamsLoader.CustomFormat;

type
  TQuadFXJSONEffectFormat = class sealed(TQuadFXCustomEffectFormat)
    procedure LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams); override;
    class function CheckSignature(ASignature: TEffectSignature): Boolean; override;
  end;

implementation

uses
  QuadFX.Manager, QuadFX.EffectParams;

{ TQuadFXJSONEffectFormat }

procedure TQuadFXJSONEffectFormat.LoadFromStream(const AEffectName: PWideChar; AStream: TMemoryStream; AEffectParams: IQuadFXEffectParams);
var
  i: Integer;
  JSONObject: TJSONObject;
  JSONEffects: TJSONArray;
  S: TStringList;
  Log: IQuadLog;
  IsLoaded: Boolean;
  Name: String;
begin
  IsLoaded := False;
  if Assigned(Manager.QuadDevice) then
    Manager.QuadDevice.CreateLog(Log);
  S := TStringList.Create;
  S.LoadFromStream(AStream);
  JSONObject := TJSONObject.ParseJSONValue(S.Text) as TJSONObject;
  try

    if Assigned(JSONObject.Get('Effects')) then
    begin
      JSONEffects := JSONObject.Get('Effects').JsonValue as TJSONArray;
      for i := 0 to JSONEffects.Count - 1 do
      begin
        Name := (JSONEffects.Items[i] as TJSONObject).GetValue('Name').Value;
        if Name = AEffectName then
        begin
          TQuadFXEffectParams(AEffectParams).FromJson(JSONEffects.Items[i] as TJSONObject);
          IsLoaded := True;
          Break;
        end;
      end;

      if not IsLoaded and Assigned(Log) then
        Log.Write(PWideChar('QuadFX: Effect "' + AEffectName + '" not found'));
    end;

  finally
    JSONObject.Destroy;
    S.Free;
  end;
end;

class function TQuadFXJSONEffectFormat.CheckSignature(ASignature: TEffectSignature): Boolean;
begin
  Result := Copy(ASignature, 1, 1) = '{';
end;

end.
