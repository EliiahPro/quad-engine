using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using QuadEngine;

namespace _01___initialization
{
    public partial class Form1 : Form
    {
        private IQuadDevice quadDevice;
        private IQuadRender quadRender;
        private IQuadTimer quadTimer;

        private TimerProcedure timer;

        private void OnTimer(ref double delta, UInt32 Id)
        {
            quadRender.BeginRender();
            quadRender.Clear(0xFF000000);

            quadRender.Rectangle(new Vec2f(100, 100), new Vec2f(200, 200), 0xFFFF0000);

            quadRender.EndRender();
        }

        public Form1()
        {
            InitializeComponent();
            this.SetClientSizeCore(800, 600);
            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);

            quadDevice.CreateRender(out quadRender);

            quadRender.Initialize(this.Handle, 800, 600, false);

            quadDevice.CreateTimer(out quadTimer);
            timer = (TimerProcedure)OnTimer;
            quadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));
            quadTimer.SetInterval(200);
            quadTimer.SetState(true);
        }
    }
}
