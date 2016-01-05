inherited FrameShapeCircle: TFrameShapeCircle
  Width = 451
  Height = 304
  Align = alClient
  ExplicitWidth = 451
  ExplicitHeight = 305
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 451
    Height = 22
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object cbCurve: TCheckBox
      Left = 3
      Top = 3
      Width = 94
      Height = 17
      Caption = 'Curve'
      TabOrder = 0
      OnClick = cbCurveClick
    end
    object cbDirectionFromCenter: TCheckBox
      Left = 112
      Top = 3
      Width = 121
      Height = 17
      Caption = 'Direction from center'
      TabOrder = 1
      OnClick = cbDirectionFromCenterClick
    end
  end
  object pValues: TPanel
    Left = 0
    Top = 22
    Width = 451
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 21
    object Label2: TLabel
      Left = 3
      Top = 53
      Width = 63
      Height = 13
      Caption = 'Small Radius:'
    end
    object Label1: TLabel
      Left = 3
      Top = 7
      Width = 36
      Height = 13
      Caption = 'Radius:'
    end
    object eSmallRadius: TFloatSpinEdit
      Left = 3
      Top = 72
      Width = 121
      Height = 21
      OnChange = eSmallRadiusChange
      Increment = 0.500000000000000000
    end
    object eRadius: TFloatSpinEdit
      Left = 3
      Top = 26
      Width = 121
      Height = 21
      OnChange = eRadiusChange
      Increment = 1.000000000000000000
    end
  end
  object dDiagram: TQuadDiagram
    Left = 0
    Top = 122
    Width = 451
    Height = 183
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
            Point.Y = 10.000000000000000000
            Color = clBlack
          end>
        Width = 2
        Style = DashStyleSolid
        Enabled = True
        Caption = 'Length'
      end
      item
        Color = clLime
        Points = <
          item
            Point.Y = 20.000000000000000000
            Color = clBlack
          end>
        Width = 2
        Style = DashStyleSolid
        Enabled = True
        Caption = 'Angle'
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
    ExplicitTop = 121
    ExplicitHeight = 184
  end
end
