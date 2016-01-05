inherited FrameShapeLine: TFrameShapeLine
  Width = 451
  Height = 304
  Align = alClient
  ExplicitWidth = 451
  ExplicitHeight = 305
  object pValues: TPanel
    Left = 0
    Top = 21
    Width = 451
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label2: TLabel
      Left = 3
      Top = 53
      Width = 31
      Height = 13
      Caption = 'Angle:'
    end
    object Label1: TLabel
      Left = 3
      Top = 7
      Width = 37
      Height = 13
      Caption = 'Length:'
    end
    object eAngle: TFloatSpinEdit
      Left = 3
      Top = 72
      Width = 121
      Height = 21
      OnChange = eAngleChange
      Increment = 0.500000000000000000
    end
    object eLength: TFloatSpinEdit
      Left = 3
      Top = 26
      Width = 121
      Height = 21
      OnChange = eLengthChange
      Increment = 1.000000000000000000
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 451
    Height = 21
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
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
  object dDiagram: TQuadDiagram
    Left = 0
    Top = 121
    Width = 451
    Height = 184
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
  end
end
