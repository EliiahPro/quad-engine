object fMain: TfMain
  Left = 0
  Top = 200
  Caption = 'QuadProfiler (beta)'
  ClientHeight = 441
  ClientWidth = 796
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 796
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 624
      Top = 2
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 33
    Width = 796
    Height = 408
    Align = alClient
    TabOrder = 1
  end
  object Timer: TTimer
    Enabled = False
    Interval = 16
    OnTimer = TimerTimer
    Left = 232
    Top = 145
  end
end
