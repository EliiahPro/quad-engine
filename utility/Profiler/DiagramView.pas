unit DiagramView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Generics.Collections, System.Math,
  QuadEngine.Socket, DiagramLine, DiagramFrame, QuadEngine.Profiler, QuadEngine;

type
  TProfilerInfo = packed record
    DateTime: Double;
    TagsCount: Byte;
  end;

  TDiagramView = class(TCategoryPanel)
  private
    class var FScale: Single;
  private
    FGUID: TGUID;
    FMaxValue: Double;
    FClient: TQuadSocket;
    FFrame: TfDiagramFrame;
    FMemory: TMemoryStream;
  public
    class procedure SetScale(AScale: Single);
    constructor Create(APanelGroup: TCategoryPanelGroup; AClient: TQuadSocket; const AGUID: TGUID);
    destructor Destroy; override;
    procedure Write(AMemory: TMemoryStream);
    procedure UpdateInfo(ACode: Word; AMemory: TMemoryStream);
    procedure Repaint;

    property GUID: TGUID read FGUID;
  end;


implementation

{ TDiagramPanel }

uses Main, ListLogItem;

{ TDiagramView }

class procedure TDiagramView.SetScale(AScale: Single);
begin
  FScale := AScale;
end;

constructor TDiagramView.Create(APanelGroup: TCategoryPanelGroup; AClient: TQuadSocket; const AGUID: TGUID);
var
  Code: Word;
begin
  inherited Create(APanelGroup.Parent);
  FFrame := TfDiagramFrame.Create(Self);
  FFrame.Parent := Self;
  FMemory := TMemoryStream.Create;
  PanelGroup := APanelGroup;
  Height := 256;
  FGUID := AGUID;
  Text := FGUID.ToString;
  FMaxValue := 0;
  FClient := AClient;

  FFrame.Diagram := TDiagram.Create(FFrame);
  FFrame.Diagram.Parent := FFrame.Panel;
  FFrame.Diagram.Align := alClient;
  FFrame.Diagram.OnPaint := FFrame.Draw;

  Code := 2;
  AClient.SendBuf(Code, SizeOf(Code));
end;

destructor TDiagramView.Destroy;
begin
  FMemory.Free;
  inherited;
end;

procedure TDiagramView.Write(AMemory: TMemoryStream);
var
  TagsCount: Word;
  i: Integer;
  ID, Code: Word;
  Line: TDiagramLine;
  Call: TAPICall;
begin
  if not Assigned(AMemory) then
    Exit;

  Code := 3;
  AMemory.Read(TagsCount, SizeOf(TagsCount));
  for i := 0 to TagsCount - 1 do
  begin
    AMemory.Read(ID, SizeOf(ID));
    AMemory.Read(Call, SizeOf(Call));
    Line := FFrame.FindLineByID(ID);
    if not Assigned(Line) then
    begin
      Line := FFrame.List.Items.Add as TDiagramLine;
      Line.Checked := True;
      Line.SetID(ID);
      FMemory.Clear;
      FMemory.Write(Code, SizeOf(Code));
      FMemory.Write(ID, SizeOf(ID));
      FClient.SendStream(FMemory);
    end;
    Line.Add(Call);
  end;
end;

procedure TDiagramView.UpdateInfo(ACode: Word; AMemory: TMemoryStream);
var
  Str: WideString;
  StrLen: Byte;
  ID: Word;
  Line: TDiagramLine;
  MsgType: TQuadProfilerMessageType;
  DateTime: TDateTime;
  LogItem: TLogListItem;
begin
  case ACode of
    2:
      begin
        AMemory.Read(StrLen, SizeOf(StrLen));
        SetLength(Str, StrLen);
        AMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));
        Caption := Str;
      end;
    3:
      begin
        AMemory.Read(ID, SizeOf(ID));
        Line := FFrame.FindLineByID(ID);
        if Assigned(Line) then
        begin
          AMemory.Read(StrLen, SizeOf(StrLen));
          SetLength(Str, StrLen);
          AMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));
          Line.Caption := Str;
        end;
      end;
    4:
      begin
        AMemory.Read(ID, SizeOf(ID));
        AMemory.Read(DateTime, SizeOf(DateTime));
        AMemory.Read(MsgType, SizeOf(MsgType));
        AMemory.Read(StrLen, SizeOf(StrLen));
        SetLength(Str, StrLen);
        AMemory.Read(Pointer(Str)^, StrLen * SizeOf(WideChar));

        LogItem := fMain.lvLog.Items.Add as TLogListItem;
        LogItem.Caption := '';
        LogItem.SubItems.Add('DateTime');
        LogItem.SubItems.Add(Str);
        LogItem.SubItems.Add(Caption);

        if ID > 0 then
        begin
          Line := FFrame.FindLineByID(ID);
          LogItem.SubItems.Add(Line.Caption);
        end
        else
          LogItem.SubItems.Add('');
      end;
  end;
end;

procedure TDiagramView.Repaint;
begin
  FFrame.Draw(nil);
end;

initialization
  TDiagramView.SetScale(100);

end.
