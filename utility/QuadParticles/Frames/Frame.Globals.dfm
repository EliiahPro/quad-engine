inherited FrameGlobals: TFrameGlobals
  Width = 333
  Height = 317
  ExplicitWidth = 333
  ExplicitHeight = 317
  object lTimeFrom: TLabel
    Left = 16
    Top = 43
    Width = 51
    Height = 13
    Caption = 'Time from:'
  end
  object lTimeTo: TLabel
    Left = 16
    Top = 83
    Width = 39
    Height = 13
    Caption = 'Time to:'
  end
  object lCaption: TLabel
    Left = 8
    Top = 8
    Width = 52
    Height = 19
    Caption = 'Globals'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lMaxParticles: TLabel
    Left = 16
    Top = 123
    Width = 67
    Height = 13
    Caption = 'Max particles:'
  end
  object lBlendMode: TLabel
    Left = 16
    Top = 187
    Width = 59
    Height = 13
    Caption = 'Blend mode:'
  end
  object cbLoop: TCheckBox
    Left = 16
    Top = 152
    Width = 51
    Height = 17
    Caption = 'Loop'
    TabOrder = 0
    OnClick = cbLoopClick
  end
  object seTimeFrom: TFloatSpinEdit
    Left = 88
    Top = 40
    Width = 121
    Height = 21
    OnChange = seTimeFromChange
    Increment = 0.050000000000000000
  end
  object seTimeTo: TFloatSpinEdit
    Left = 88
    Top = 80
    Width = 121
    Height = 21
    OnChange = seTimeToChange
    Increment = 0.050000000000000000
  end
  object seMaxParticles: TFloatSpinEdit
    Left = 88
    Top = 120
    Width = 121
    Height = 21
    OnChange = seMaxParticlesChange
    Increment = 10.000000000000000000
  end
  object cbBlendMode: TComboBox
    Left = 88
    Top = 184
    Width = 121
    Height = 21
    Style = csDropDownList
    DropDownCount = 12
    TabOrder = 4
    OnChange = cbBlendModeChange
  end
end
