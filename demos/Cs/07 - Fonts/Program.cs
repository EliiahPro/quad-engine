using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;
using System.Runtime.InteropServices;

namespace demo07
{
    class Program
    {
        private static IQuadDevice quadDevice;
        private static IQuadWindow quadWindow;
        private static IQuadRender quadRender;
        private static IQuadTimer quadTimer;
        private static IQuadFont quadFont;

        private static TimerProcedure timer;

        private static void OnTimer(ref double delta, UInt32 Id)
        {
            TDistanceFieldParams df = new TDistanceFieldParams();
            
            quadRender.BeginRender();
            quadRender.Clear(0xFF111111);
            quadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);

            //Simple non-antialiased text
            df.FirstEdge = false;
            df.Edge1X = 0.5f;
            quadFont.SetDistanceFieldParams(df);
            quadFont.TextOut(new Vec2f(30, 30), 1.0f, "Simple non-antialiased text");


            //Simple antialiased text
            df.FirstEdge = true;
            df.Edge1X = 0.43f;
            df.Edge1Y = 0.5f;
            quadFont.SetDistanceFieldParams(df);

            quadFont.TextOut(new Vec2f(30, 70), 1.0f, "Simple antialiased text");

            //Thin antialiased text
            df.FirstEdge = true;
            df.Edge1X = 0.53f;
            df.Edge1Y = 0.58f;
            quadFont.SetDistanceFieldParams(df);

            quadFont.TextOut(new Vec2f(30, 110), 1.0f, "Thin antialiased text");

            //Bold antialiased text
            df.FirstEdge = true;
            df.Edge1X = 0.40f;
            df.Edge1Y = 0.45f;
            quadFont.SetDistanceFieldParams(df);

            quadFont.TextOut(new Vec2f(30, 150), 1.0f, "Bold antialiased text");


            // Text with inking
            df.FirstEdge = true;
            df.Edge1X = 0.35f;
            df.Edge1Y = 0.40f;
            df.SecondEdge = true;
            df.Edge2X = 0.45f;
            df.Edge2Y = 0.50f;
            df.OuterColor = QuadColor.Orange;
            quadFont.SetDistanceFieldParams(df);

            quadFont.TextOut(new Vec2f(30, 190), 1.0f, "Text with inking");

            //Outlined text
            df.FirstEdge = true;
            df.Edge1X = 0.35f;
            df.Edge1Y = 0.40f;
            df.SecondEdge = true;
            df.Edge2X = 0.45f;
            df.Edge2Y = 0.50f;
            df.OuterColor = QuadColor.White;
            quadFont.SetDistanceFieldParams(df);

            quadFont.TextOut(new Vec2f(30, 230), 1.0f, "Outlined text", 0x00000000);

            //Outlined text
            df.FirstEdge = true;
            df.Edge1X = 0.05f;
            df.Edge1Y = 0.50f;
            df.SecondEdge = true;
            df.Edge2X = 0.45f;
            df.Edge2Y = 0.50f;
            df.OuterColor = QuadColor.Violet;
            quadFont.SetDistanceFieldParams(df);
            quadFont.SetKerning(5);
            quadFont.TextOut(new Vec2f(30, 270), 1.0f, "Glowing text", QuadColor.Fuchsia);
            quadFont.SetKerning(0);

            // downscale
            df.FirstEdge = true;
            df.Edge1X = 0.40f;
            df.Edge1Y = 0.5f;
            df.SecondEdge = false;
            quadFont.SetDistanceFieldParams(df);

            quadFont.SetKerning(0.5f); // for better readability
            quadFont.TextOut(new Vec2f(30, 330), 0.5f, "downscaled to 0.5 antialiased text");
            quadFont.TextOut(new Vec2f(30, 345), 0.3f, "downscaled to 0.3 antialiased text");
            quadFont.TextOut(new Vec2f(30, 370), 0.75f, "downscaled to 0.75 antialiased text");
            quadFont.SetKerning(0);

            // upscale
            df.FirstEdge = true;
            df.Edge1X = 0.43f;
            df.Edge1Y = 0.5f;
            quadFont.SetDistanceFieldParams(df);
            quadFont.TextOut(new Vec2f(30, 430), 1.75f, "Upscale to 1.75 antialiased text");

            df.FirstEdge = true;
            df.Edge1X = 0.47f;
            df.Edge1Y = 0.5f;
            quadFont.SetDistanceFieldParams(df);
            quadFont.TextOut(new Vec2f(30, 530), 3.33f, "Upscale to 3.33");

            df.FirstEdge = true;
            df.Edge1X = 0.49f;
            df.Edge1Y = 0.5f;
            quadFont.SetDistanceFieldParams(df);
            quadFont.TextOut(new Vec2f(330, 300), 7.0f, "Zoom 7");


            quadRender.EndRender();
        }

        static void Main(string[] args)
        {
            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);
            quadDevice.CreateWindow(out quadWindow);
            quadWindow.SetCaption("QuadEngine - Demo07 - Fonts");
            quadWindow.SetSize(800, 600);
            quadWindow.SetPosition(100, 100);

            quadDevice.CreateRender(out quadRender);
            quadRender.Initialize((IntPtr)(int)(uint)quadWindow.GetHandle(), 800, 600, false);

            quadDevice.CreateAndLoadFont("data\\font.png", "data\\font.qef", out quadFont);

            quadDevice.CreateTimer(out quadTimer);
            timer = (TimerProcedure)OnTimer;
            quadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));
            quadTimer.SetInterval(16);
            quadTimer.SetState(true);

            quadWindow.Start();
        }
    }
}
