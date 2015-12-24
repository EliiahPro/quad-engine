using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using QuadEngine;

namespace _04___Input
{
    class Program
    {
        private static IQuadDevice quadDevice;
        private static IQuadWindow quadWindow;
        private static IQuadRender quadRender;
        private static IQuadTimer quadTimer;
        private static IQuadInput quadInput;
        
        private static TimerProcedure timer;

        private static void drawRect(Vec2f position, bool state)
        {
            if (state)
                quadRender.Rectangle(position * 15, position * 15 + new Vec2f(10, 10), 0xFFFF0000);
            else
                quadRender.Rectangle(position * 15, position * 15 + new Vec2f(10, 10), 0xFFFFFFFF);
        }

        private static void OnTimer(ref double delta, UInt32 Id)
        {
            quadInput.Update();

            quadRender.BeginRender();
            quadRender.Clear(0xFF000000);

            drawRect(new Vec2f(2, 1), quadInput.IsKeyDown((byte)'W'));
            drawRect(new Vec2f(2, 2), quadInput.IsKeyDown((byte)'S'));
            drawRect(new Vec2f(1, 2), quadInput.IsKeyDown((byte)'A'));
            drawRect(new Vec2f(3, 2), quadInput.IsKeyDown((byte)'D'));

            drawRect(new Vec2f(2, 4), quadInput.IsKeyPress((byte)'W'));
            drawRect(new Vec2f(2, 5), quadInput.IsKeyPress((byte)'S'));
            drawRect(new Vec2f(1, 5), quadInput.IsKeyPress((byte)'A'));
            drawRect(new Vec2f(3, 5), quadInput.IsKeyPress((byte)'D'));

            bool en = quadInput.IsMouseDown(MouseButtons.Left);
            drawRect(new Vec2f(6, 1), en);
            drawRect(new Vec2f(7, 1), quadInput.IsMouseDown(MouseButtons.Middle));
            drawRect(new Vec2f(8, 1), quadInput.IsMouseDown(MouseButtons.Right));
            drawRect(new Vec2f(9, 1), quadInput.IsMouseDown(MouseButtons.X1));
            drawRect(new Vec2f(10, 1), quadInput.IsMouseDown(MouseButtons.X2));

            drawRect(new Vec2f(6, 4), quadInput.IsMouseClick(MouseButtons.Left));
            drawRect(new Vec2f(7, 4), quadInput.IsMouseClick(MouseButtons.Middle));
            drawRect(new Vec2f(8, 4), quadInput.IsMouseClick(MouseButtons.Right));
            drawRect(new Vec2f(9, 4), quadInput.IsMouseClick(MouseButtons.X1));
            drawRect(new Vec2f(10, 4), quadInput.IsMouseClick(MouseButtons.X2));

            Vec2f mousePosition, mouseVector, mouseWheel;
            quadInput.GetMousePosition(out mousePosition);
            quadRender.DrawCircle(mousePosition, 20, 18);

            quadInput.GetMouseVector(out mouseVector);
            quadRender.DrawQuadLine(new Vec2f(400, 300), new Vec2f(400, 300) + mouseVector, 3, 1, 0xFFFFFFFF, 0xFFFFFFFF);

            quadInput.GetMouseWheel(out mouseWheel);
            quadRender.DrawQuadLine(new Vec2f(100, 300), new Vec2f(100, 300) + mouseWheel, 7, 1, 0xFFFFFFFF, 0xFF00FF00);
            
            quadRender.EndRender();
        }

        static void Main(string[] args)
        {
            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);
            quadDevice.CreateWindow(out quadWindow);
            quadWindow.CreateInput(out quadInput);
            quadWindow.SetCaption("04 - Input");
            quadWindow.SetSize(800, 600);

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
