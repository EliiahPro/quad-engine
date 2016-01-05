inherited FramePosition: TFramePosition
  object FramePosition: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lCaption: TLabel
      Left = 8
      Top = 8
      Width = 56
      Height = 19
      Caption = 'Position'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 320
    Height = 21
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
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
  object pValues: TPanel
    Left = 0
    Top = 56
    Width = 320
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object lX: TLabel
      Left = 14
      Top = 9
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object lY: TLabel
      Left = 14
      Top = 36
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object eXMinValue: TFloatSpinEdit
      Left = 24
      Top = 6
      Width = 94
      Height = 21
      OnChange = eXMinValueChange
      Increment = 0.050000000000000000
    end
    object eXMaxValue: TFloatSpinEdit
      Left = 141
      Top = 6
      Width = 94
      Height = 21
      Visible = False
      OnChange = eXMaxValueChange
      Increment = 0.050000000000000000
    end
    object eYMaxValue: TFloatSpinEdit
      Left = 141
      Top = 33
      Width = 94
      Height = 21
      Visible = False
      OnChange = eYMaxValueChange
      Increment = 0.050000000000000000
    end
    object eYMinValue: TFloatSpinEdit
      Left = 24
      Top = 33
      Width = 94
      Height = 21
      OnChange = eYMinValueChange
      Increment = 0.050000000000000000
    end
  end
  object dDiagram: TQuadDiagram
    Left = 0
    Top = 112
    Width = 320
    Height = 128
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
    AxisV.Name = 'Position, px'
    AxisV.Format = '0'
    AxisV.MinValue = -200.000000000000000000
    AxisV.MaxValue = 200.000000000000000000
    AxisV.GridSize = 100.000000000000000000
    AxisV.LowMin = -100.000000000000000000
    AxisV.LowMax = 100.000000000000000000
    AxisV.HighMin = -1000.000000000000000000
    AxisV.HighMax = 1000.000000000000000000
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
end
