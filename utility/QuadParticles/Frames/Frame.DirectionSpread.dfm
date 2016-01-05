inherited FrameDirectionSpread: TFrameDirectionSpread
  Width = 329
  Height = 343
  ExplicitWidth = 329
  ExplicitHeight = 343
  object FramePosition: TPanel
    Left = 0
    Top = 0
    Width = 329
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lCaption: TLabel
      Left = 8
      Top = 8
      Width = 148
      Height = 19
      Caption = 'Direction and Spread'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object pValues: TPanel
    Left = 0
    Top = 56
    Width = 329
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lDirection: TLabel
      Left = 14
      Top = 9
      Width = 46
      Height = 13
      Caption = 'Direction:'
    end
    object lSpread: TLabel
      Left = 14
      Top = 36
      Width = 38
      Height = 13
      Caption = 'Spread:'
    end
    object eDirectionMinValue: TFloatSpinEdit
      Left = 65
      Top = 5
      Width = 94
      Height = 21
      OnChange = eDirectionMinValueChange
      Increment = 0.050000000000000000
    end
    object eSpreadMinValue: TFloatSpinEdit
      Left = 65
      Top = 32
      Width = 94
      Height = 21
      OnChange = eSpreadMinValueChange
      Increment = 0.050000000000000000
    end
    object eSpreadMaxValue: TFloatSpinEdit
      Left = 182
      Top = 32
      Width = 94
      Height = 21
      Visible = False
      OnChange = eSpreadMaxValueChange
      Increment = 0.050000000000000000
    end
    object eDirectionMaxValue: TFloatSpinEdit
      Left = 182
      Top = 5
      Width = 94
      Height = 21
      Visible = False
      OnChange = eDirectionMaxValueChange
      Increment = 0.050000000000000000
    end
  end
  object dDiagram: TQuadDiagram
    Left = 0
    Top = 112
    Width = 329
    Height = 231
    Visible = False
    Align = alClient
    Style.Background1 = clBtnFace
    Style.Background2 = clBtnFace
    Style.GridLine = clWindowText
    Style.Axis = clWindowText
    Style.AxisTitle = clWindowText
    Style.Gradient = LinearGradientModeVertical
    Style.LegendVisible = False
    Style.LegendColumns = 0
    Lines = <
      item
        Color = clRed
        Points = <
          item
            Color = clBlack
          end>
        Width = 2
        Style = DashStyleSolid
        Enabled = True
      end
      item
        Color = clGreen
        Points = <
          item
            Color = clBlack
          end>
        Width = 2
        Style = DashStyleSolid
        Enabled = True
      end>
    Position = -1.000000000000000000
    AxisV.Name = 'Angle, px'
    AxisV.Format = '0'
    AxisV.MinValue = -360.000000000000000000
    AxisV.MaxValue = 360.000000000000000000
    AxisV.GridSize = 90.000000000000000000
    AxisV.LowMin = -360.000000000000000000
    AxisV.LowMax = 360.000000000000000000
    AxisV.HighMin = -1080.000000000000000000
    AxisV.HighMax = 1080.000000000000000000
    AxisH.Name = 'Life, %'
    AxisH.Format = '0'
    AxisH.MaxValue = 100.000000000000000000
    AxisH.GridSize = 20.000000000000000000
    AxisH.LowMin = 100.000000000000000000
    AxisH.LowMax = 100.000000000000000000
    AxisH.HighMax = 100.000000000000000000
    OnPointChange = dDiagramPointChange
    OnPointAdd = dDiagramPointAdd
    OnPointDelete = dDiagramPointDelete
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 329
    Height = 21
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object cbRandom: TCheckBox
      Left = 120
      Top = 3
      Width = 97
      Height = 17
      Caption = 'Random'
      TabOrder = 0
      OnClick = cbRandomClick
    end
    object cbCurve: TCheckBox
      Left = 3
      Top = 4
      Width = 94
      Height = 17
      Caption = 'Curve'
      TabOrder = 1
      OnClick = cbCurveClick
    end
  end
end
