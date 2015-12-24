using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using QuadEngine;
using System.Runtime.InteropServices;

namespace _03___window
{
    class Program
    {
        private static IQuadDevice quadDevice;
        private static IQuadWindow quadWindow;
        private static IQuadRender quadRender;
        private static IQuadTimer quadTimer;

        private static TimerProcedure timer;

        private static void OnTimer(ref double delta, UInt32 Id)
        {
            quadRender.BeginRender();
            Random rand = new Random();
            quadRender.Clear((uint)rand.Next());

            quadRender.EndRender();
        }

        static void Main(string[] args)
        {
            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);
            quadDevice.CreateWindow(out quadWindow);
            quadWindow.SetCaption("03 - Window");
            quadWindow.SetSize(800, 600);

            quadDevice.CreateRender(out quadRender);
            quadRender.Initialize((IntPtr)(int)(uint)quadWindow.GetHandle(), 800, 600, false);

            quadDevice.CreateTimer(out quadTimer);

            timer = (TimerProcedure)OnTimer;
            quadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));
            quadTimer.SetInterval(200);
            quadTimer.SetState(true);

            quadWindow.Start();
        }
    }
}
