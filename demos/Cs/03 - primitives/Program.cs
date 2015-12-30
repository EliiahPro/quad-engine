using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;
using System.Runtime.InteropServices;

namespace Demo03
{
    class Program
    {
        private static IQuadDevice quadDevice;
        private static IQuadWindow quadWindow;
        private static IQuadRender quadRender;
        private static IQuadTimer quadTimer;

        private static TimerProcedure timer;
        private static OnMouseMoveEvent mouseMoveEvent;

        private static int xPos, yPos;

        private static void OnTimer(ref double delta, UInt32 Id)
        {
            quadRender.BeginRender();
            quadRender.Clear(0);

            quadRender.Rectangle(new Vec2f(100, 100), new Vec2f(400, 400), QuadColor.Blue);
            quadRender.Rectangle(new Vec2f(200, 200), new Vec2f(500, 500), QuadColor.Lime.Lerp(QuadColor.Red, xPos / 800.0f));

            quadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);
            quadRender.DrawCircle(new Vec2f(400, 400), 100, 95, QuadColor.Blue);
            quadRender.DrawCircle(new Vec2f(xPos, yPos), 30, 27, QuadColor.Aqua);

            quadRender.DrawQuadLine(new Vec2f(400, 400), new Vec2f(xPos, yPos), 5, 5, QuadColor.Blue, QuadColor.Aqua);

            quadRender.EndRender();
        }
        
        private static void OnMouseMove(ref Vec2i position, ref PressedMouseButtons pressedButtons)
        {
            xPos = position.X;
            yPos = position.Y;
        }

        static void Main(string[] args)
        {
            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);
            quadDevice.CreateWindow(out quadWindow);
            quadWindow.SetCaption("QuadEngine - Demo03 - Primitives");
            quadWindow.SetSize(800, 600);
            mouseMoveEvent = (OnMouseMoveEvent)OnMouseMove;
            quadWindow.SetOnMouseMove(Marshal.GetFunctionPointerForDelegate(mouseMoveEvent));

            quadDevice.CreateRender(out quadRender);
            quadRender.Initialize((IntPtr)(int)(uint)quadWindow.GetHandle(), 800, 600, false);

            quadDevice.CreateTimer(out quadTimer);

            timer = (TimerProcedure)OnTimer;
            quadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));
            quadTimer.SetInterval(16);
            quadTimer.SetState(true);

            quadWindow.Start();
        }
    }
}
