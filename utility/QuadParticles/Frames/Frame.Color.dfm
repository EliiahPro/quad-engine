inherited FrameColor: TFrameColor
  Width = 217
  Height = 249
  ExplicitWidth = 217
  ExplicitHeight = 249
  object pCaption: TPanel
    Left = 0
    Top = 0
    Width = 217
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lCaption: TLabel
      Left = 8
      Top = 8
      Width = 38
      Height = 19
      Caption = 'Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object pGradient: TPanel
    Left = 0
    Top = 35
    Width = 217
    Height = 102
    Align = alTop
    AutoSize = True
    BevelOuter = bvLowered
    TabOrder = 1
    object GradientEdit: TQuadGradientEdit
      Left = 1
      Top = 1
      Width = 215
      Height = 100
      Align = alTop
      Colors = <
        item
          Color = clRed
        end
        item
          Color = clGray
          Position = 0.250000000000000000
        end
        item
          Color = clYellow
          Position = 0.280000001192092900
        end
        item
          Color = clGreen
          Position = 0.750000000000000000
        end
        item
          Color = clLime
          Position = 1.000000000000000000
        end>
      OnItemAdd = GradientEditItemAdd
      OnItemDel = GradientEditItemDel
      OnItemChange = GradientEditItemChange
      ExplicitLeft = 0
      ExplicitWidth = 217
    end
  end
end
