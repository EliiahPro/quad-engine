unit CustomDialogForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ImgList, Menus;

type
  TDialogForm = class(TForm)
    ButtonOk: TButton;
    ButtonCancel: TButton;
    DialogCaption: TLabel;
    DialogText: TLabel;
    ButtonYes: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    class function Execute(const ACaption, AText: String; AMessageType: TMsgDlgType = mtCustom;
      const AButtonOkCaption: String = 'OK'; const AButtonCancelCaption: String = 'Cancel'): TModalResult;
    class function ExecuteYesNoCancel(const ACaption, AText: String;
      const AButtonYesCaption: String = 'Да'; const AButtonNoCaption: String = 'Нет'; const AButtonCancelCaption: String = 'Отмена'): TModalResult;
  end;

implementation

{$R *.dfm}

class function TDialogForm.Execute(const ACaption, AText: String; AMessageType: TMsgDlgType = mtCustom;
  const AButtonOkCaption: String = 'OK'; const AButtonCancelCaption: String = 'Cancel'): TModalResult;
var
  Dialog: TDialogForm;
begin
  Dialog := TDialogForm.Create(nil);

  try
    Dialog.DialogCaption.Caption := ACaption;
    Dialog.Caption := ACaption;
    Dialog.DialogText.Caption := AText;
    Dialog.ButtonOk.Caption := AButtonOkCaption;
    Dialog.ButtonCancel.Caption := AButtonCancelCaption;

    if (AMessageType <> mtConfirmation) and (AMessageType <> mtCustom) then
    begin
      Dialog.ButtonOk.Visible := False;
      Dialog.ButtonCancel.Caption := 'OK';
    end;

    Dialog.ClientHeight := 125 + Dialog.DialogText.Height;
    Dialog.ClientWidth := Dialog.ClientWidth + Dialog.DialogText.Width - 390;
    Dialog.Width := Screen.Width;
    Dialog.Panel2.Width := (Screen.Width - Dialog.Panel1.Width) div 2;

    Result := Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

class function TDialogForm.ExecuteYesNoCancel(const ACaption, AText: String;
  const AButtonYesCaption: String = 'Да'; const AButtonNoCaption: String = 'Нет'; const AButtonCancelCaption: String = 'Отмена'): TModalResult;
var
  Dialog: TDialogForm;
begin
  Dialog := TDialogForm.Create(nil);

  try
    Dialog.DialogCaption.Caption := ACaption;
    Dialog.Caption := ACaption;
    Dialog.DialogText.Caption := AText;
    Dialog.ButtonYes.Caption := AButtonYesCaption;
    Dialog.ButtonOk.Caption := AButtonNoCaption;
    Dialog.ButtonCancel.Caption := AButtonCancelCaption;

    Dialog.ButtonYes.Visible := True;
    Dialog.ButtonOk.ModalResult := mrNo;              // в диалоге с тремя кнопками это кнопка 'Нет'

    Dialog.ClientHeight := 125 + Dialog.DialogText.Height;
    Dialog.ClientWidth := Dialog.ClientWidth + Dialog.DialogText.Width - 390;

    Result := Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

procedure TDialogForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    ModalResult := mrCancel;
end;

end.
