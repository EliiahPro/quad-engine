inherited FrameValue: TFrameValue
  object dDiagram: TQuadDiagram
    Left = 0
    Top = 92
    Width = 320
    Height = 148
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
      end>
    Position = -1.000000000000000000
    AxisV.Name = 'Emission, el/s'
    AxisV.Format = '0'
    AxisV.MaxValue = 300.000000000000000000
    AxisV.GridSize = 100.000000000000000000
    AxisV.LowMin = 300.000000000000000000
    AxisV.LowMax = 1000.000000000000000000
    AxisH.Name = 'Life, %'
    AxisH.Format = '0'
    AxisH.MaxValue = 100.000000000000000000
    AxisH.GridSize = 20.000000000000000000
    AxisH.LowMin = 100.000000000000000000
    AxisH.LowMax = 100.000000000000000000
    OnPointChange = dDiagramPointChange
    OnPointAdd = dDiagramPointAdd
    OnPointDelete = dDiagramPointDelete
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
  object pCaption: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object lCaption: TLabel
      Left = 8
      Top = 8
      Width = 41
      Height = 19
      Caption = 'Name'
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
    Width = 320
    Height = 36
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object eMinValue: TFloatSpinEdit
      Left = 3
      Top = 6
      Width = 94
      Height = 21
      OnChange = eMinValueChange
      Increment = 0.050000000000000000
    end
    object eMaxValue: TFloatSpinEdit
      Left = 120
      Top = 6
      Width = 94
      Height = 21
      Visible = False
      OnChange = eMaxValueChange
      Increment = 0.050000000000000000
    end
  end
end
