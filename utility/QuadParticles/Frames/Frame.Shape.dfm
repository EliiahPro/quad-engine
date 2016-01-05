inherited FrameShape: TFrameShape
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 320
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object cbShapeType: TComboBox
      Left = 3
      Top = 3
      Width = 137
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 0
      Text = 'Line'
      OnChange = cbShapeTypeChange
      Items.Strings = (
        'Point'
        'Line'
        'Circle'
        'Rect')
    end
  end
  object pCaption: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lCaption: TLabel
      Left = 8
      Top = 8
      Width = 43
      Height = 19
      Caption = 'Shape'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
end
