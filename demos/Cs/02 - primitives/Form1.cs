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

namespace _02___primitives
{
    public partial class Form1 : Form
    {
        private IQuadDevice quadDevice;
        private IQuadRender quadRender;
        private IQuadTimer quadTimer;

        private TimerProcedure timer;

        private int xPos, yPos;


        private void OnTimer(ref double delta, UInt32 Id)
        {
            quadRender.BeginRender();

            quadRender.Clear(0);

            quadRender.Rectangle(new Vec2f(100, 100), new Vec2f(400, 400), QuadColor.Blue);
            quadRender.Rectangle(new Vec2f(200, 200), new Vec2f(500, 500), QuadColor.Lime.Lerp(QuadColor.Red, xPos / 800));

            quadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            quadRender.DrawCircle(new Vec2f(400, 400), 100, 95, QuadColor.Blue);
            quadRender.DrawCircle(new Vec2f(xPos, yPos), 30, 27, QuadColor.Aqua);

            quadRender.DrawQuadLine(new Vec2f(400, 400), new Vec2f(xPos, yPos), 5, 5, QuadColor.Blue, QuadColor.Aqua);


            quadRender.EndRender();
        }

        private void Form1_MouseMove(object sender, MouseEventArgs e)
        {
            xPos = e.X;
            yPos = e.Y;
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
            quadTimer.SetInterval(16);
            quadTimer.SetState(true);
        }
    }
}
