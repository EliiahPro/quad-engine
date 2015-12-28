unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stdctrls, ExtCtrls, StrUtils, QuadIcon, QuadMemo, ComCtrls, QuadEngine,
  CustomDialogForm;

type
  TForm1 = class(TForm)
    ToolbarPanel: TPanel;
    QuadIcon1: TQuadIcon;
    QuadIcon2: TQuadIcon;
    QuadIcon3: TQuadIcon;
    OpenDialog1: TOpenDialog;
    QuadIcon4: TQuadIcon;
    QuadIcon5: TQuadIcon;
    QuadIcon6: TQuadIcon;
    QuadIcon7: TQuadIcon;
    QuadIcon8: TQuadIcon;
    MessagePanel: TPanel;
    Splitter1: TSplitter;
    ToolsPanel: TPanel;
    Splitter2: TSplitter;
    SaveDialog1: TSaveDialog;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    QuadMemo1: TQuadMemo;
    RenderPanel: TPanel;
    FPSLabel: TLabel;
    CPULabel: TLabel;
    Panel1: TPanel;
    Splitter3: TSplitter;
    procedure QuadIcon1Click(Sender: TObject);
    procedure QuadIcon2Click(Sender: TObject);
    procedure QuadIcon7Click(Sender: TObject);
    procedure QuadIcon4Click(Sender: TObject);
    procedure QuadIcon5Click(Sender: TObject);
    procedure QuadIcon6Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure QuadIcon3Click(Sender: TObject);
    procedure QuadIcon8Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RenderPanelResize(Sender: TObject);
  private

  public
    procedure AfterConstruction; override;
    { Public declarations }
  end;

var
  Form1: TForm1;
  QD: IQuadDevice;
  QR: IQuadRender;
  QT: IQuadTimer;
  Jet: IQuadTexture;

implementation

uses Unit2, Vec2f;

{$R *.dfm}

procedure TForm1.QuadIcon1Click(Sender: TObject);
begin
  QuadMemo1.Clear;
end;

procedure TForm1.QuadIcon2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    QuadMemo1.LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm1.QuadIcon7Click(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.QuadIcon4Click(Sender: TObject);
begin
  QuadMemo1.TextCut;  
end;

procedure TForm1.QuadIcon5Click(Sender: TObject);
begin
  QuadMemo1.TextCopy;
end;

procedure TForm1.QuadIcon6Click(Sender: TObject);
begin
  QuadMemo1.TextPaste;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if QuadMemo1.IsChanged then
  begin
    if TDialogForm.Execute('Quit', 'File not saved. Proceed to quit?', mtConfirmation) = mrCancel then
      CanClose := False;
  end;
end;

procedure TForm1.QuadIcon3Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    QuadMemo1.Lines.SaveToFile(SaveDialog1.FileName);
end;

function GetCUIText(lpCmdLine: String): String; stdcall;
const
	ReadBuffer = 65536; //64k
var
	Buffer: PAnsiChar;
	dwRead: Cardinal;
	dwExit: Cardinal;
	si: TStartUpInfo;
	sa: TSecurityAttributes;
	sd: TSecurityDescriptor;
	pi: TProcessInformation;
	newstdout, read_stdout: THandle;
	osv: TOSVersionInfo;
  cmd: string;
begin
  cmd := lpCmdLine;
  UniqueString(cmd);
	newstdout := 0;
	read_stdout := 0;
	si.cb := SizeOf(si);
	FillChar(si, SizeOf(si), 0);
	sa.nlength := SizeOf(TSecurityAttributes);
//	sd := nil;

  osv.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
	GetVersionEx(osv);

	if (osv.dwPlatformId = VER_PLATFORM_WIN32_NT) then
	begin
		InitializeSecurityDescriptor(@sd, SECURITY_DESCRIPTOR_REVISION);
		SetSecurityDescriptorDacl(@sd, True, nil, False);
		sa.lpSecurityDescriptor := @sd;
	end
	else
    sa.lpSecurityDescriptor := nil;

	sa.bInheritHandle := True;

	// Create pipe
	if not (CreatePipe(read_stdout, newstdout, @sa, 0)) then
	begin
    Result := '';
		Exit;
	end;

	GetStartupInfo(si);
	si.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
	si.wShowWindow := SW_HIDE;
	si.hStdOutput := newstdout;
	si.hStdInput := read_stdout;
	si.hStdError := newstdout;

	// Create Process
	if not (CreateProcess(nil, PChar(cmd), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, si, pi)) then
	begin
		CloseHandle(newstdout);
		CloseHandle(read_stdout);
    Result := '';
		Exit;
	end;

	Buffer := AllocMem(ReadBuffer + 1);
	dwRead := 1;
	dwExit := STILL_ACTIVE;

	while ((dwExit = STILL_ACTIVE) or (dwRead > 0) ) do
	begin
		PeekNamedPipe(read_stdout, nil, 0, nil, @dwRead, nil);

		if (dwRead > 0 ) then
		begin
			ReadFile(read_stdout, Buffer[0], ReadBuffer, dwRead, nil);
			Buffer[dwRead] := #0;
      Result := Result + String(Buffer);
		end
		else
      Sleep(100);

		GetExitCodeProcess(pi.hProcess, dwExit);

		// Make sure we have no data before killing getting out of the loop
		if (dwExit <> STILL_ACTIVE) then
			PeekNamedPipe(read_stdout, nil, 0, nil, @dwRead, nil);
	end;

	FreeMem(Buffer);
	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);
	CloseHandle(read_stdout);
	CloseHandle(newstdout);
end;

procedure TForm1.QuadIcon8Click(Sender: TObject);
var
  S: String;
  Aline, AChar: Integer;
begin
  Memo1.Clear;
  QuadMemo1.Lines.SaveToFile('!temp.fx');
  S := GetCUIText('fxc.exe /O1 /T vs_2_0 /E std_VS /nologo /Fo vs_temp.bin !temp.fx');

  if (Pos('error', S) > 0) and (Pos('!temp.fx', S) > 0) then
  begin
    S := Copy(S, Pos('!temp.fx', S) + 8, Length(S));
    ALine := StrToIntDef(Copy(S, 2, Pos(',', S) - 2), -1) - 1;
    AChar := StrToIntDef(Copy(S, Pos(',', S) + 1, Pos(')', S) - Pos(',', S) - 1), -1) - 1;
    QuadMemo1.SetErrorWarning(Aline, AChar);
    TDialogForm.Execute('Compile error', S, mtError);
  end;

  Memo1.Lines.Add(S);




  Memo1.Lines.Add(GetCUIText('fxc.exe /O1 /T ps_2_0 /E std_PS /nologo /Fo ps_temp.bin !temp.fx'));
  if (Pos('error', S) > 0) and (Pos('!temp.fx', S) > 0) then
  begin
    S := Copy(S, Pos('!temp.fx', S) + 8, Length(S));
    ALine := StrToIntDef(Copy(S, 2, Pos(',', S) - 2), -1) - 1;
    AChar := StrToIntDef(Copy(S, Pos(',', S) + 1, Pos(')', S) - Pos(',', S) - 1), -1) - 1;
    QuadMemo1.SetErrorWarning(Aline, AChar);
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  QuadMemo1.SetFocus;
end;

procedure OnTimer(var delta: Double);
begin
  QR.BeginRender;
  QR.Clear($00424242);
//      QR.Rectangle(10, 10, 100, 100, $FFFFFFFF);
  QR.SetBlendMode(qbmSrcAlpha);
  Jet.Draw(TVec2F.Create(0, 0), $FFFFFFFF);
//      QR.Rectangle(0, 0, 640, 480, $FF000000);
  QR.EndRender;

  Form1.FPSLabel.Caption := 'FPS: ' + FormatFloat('00.00', QT.GetFPS);
  Form1.CPULabel.Caption := 'CPU: ' + FormatFloat('00.00', QT.GetCPUload);
end;

procedure TForm1.AfterConstruction;
begin
  inherited;
  QD := CreateQuadDevice;

  QD.CreateRender(QR);
  QR.Initialize(RenderPanel.Handle, 640, 480, False);

  QD.CreateAndLoadTexture(0, 'fighterjet.png', Jet);

  QD.CreateTimer(QT);
  QT.SetCallBack(@OnTimer);
  QT.SetInterval(30);
 // QT.SetState(True);
end;

procedure TForm1.RenderPanelResize(Sender: TObject);
begin
  RenderPanel.Height := RenderPanel.Width div 4 * 3;

  if QR = nil then
    Exit;

 // QR.ChangeResolution(RenderPanel.Width, RenderPanel.Height);
end;

end.

