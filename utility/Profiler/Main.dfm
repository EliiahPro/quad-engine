object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'fMain'
  ClientHeight = 572
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 794
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 392
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
    end
  end
  object PanelGroup: TCategoryPanelGroup
    Left = 0
    Top = 33
    Width = 794
    Height = 458
    VertScrollBar.Tracking = True
    Align = alClient
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -11
    HeaderFont.Name = 'Tahoma'
    HeaderFont.Style = []
    TabOrder = 1
    ExplicitHeight = 215
  end
  object ListBox1: TListBox
    Left = 0
    Top = 491
    Width = 794
    Height = 81
    Align = alBottom
    ItemHeight = 13
    TabOrder = 2
    ExplicitTop = 248
  end
  object Timer: TTimer
    Interval = 16
    OnTimer = TimerTimer
    Left = 344
    Top = 225
  end
end
