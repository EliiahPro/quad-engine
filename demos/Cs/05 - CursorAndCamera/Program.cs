using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using QuadEngine;

namespace _05___CursorAndCamera
{
    class Program
    {
        struct Point
        {
            public int X;
            public int Y;
        };

        [DllImport("user32.dll")]
        static extern bool ClientToScreen(IntPtr hwnd, ref Point lpPoint);

        private const int WINDOW_WIDTH = 800;
        private const int WINDOW_HEIGHT = 600;

        private static IQuadDevice quadDevice;
        private static IQuadWindow quadWindow;
        private static IQuadRender quadRender;
        private static IQuadTimer quadTimer;
        private static IQuadCamera quadCamera;
        private static IQuadInput quadInput;

        private static IQuadTexture quadLogoTexture;
        private static IQuadTexture cursorTexture;

        private static bool isCursorMove = true;

        private static TimerProcedure timer;
        private static OnEvent activate;
        private static OnEvent deactivate;

        private static void OnActivate()
        {
            isCursorMove = true;
            ResetCursor();
        }

        private static void OnDeactivate()
        {
            isCursorMove = false;
        }

        private static void ResetCursor()
        {
            if (!isCursorMove)
                return;

            Point mousePositionToScreen;
            mousePositionToScreen.X = (int)WINDOW_WIDTH / 2;
            mousePositionToScreen.Y = (int)WINDOW_HEIGHT / 2;
            
            ClientToScreen((IntPtr)(int)(uint)quadWindow.GetHandle(), ref mousePositionToScreen);
            quadDevice.SetCursorPosition(mousePositionToScreen.X, mousePositionToScreen.Y);
        }

        private static void OnTimer(ref double delta, UInt32 Id)
        {
            quadInput.Update();

            Vec2f mouseWheel, mouseVector, mousePosition;
            quadInput.GetMousePosition(out mousePosition);
            quadInput.GetMouseVector(out mouseVector);
            quadInput.GetMouseWheel(out mouseWheel);
            
            if (mouseWheel.Y != 0)
                quadCamera.Scale(Math.Max(0.1f, Math.Min(3.0f, quadCamera.GetScale() + mouseWheel.Normalize().Y / 10)));
            
            quadCamera.Translate(mouseVector);
            
            //ResetCursor();
           
            quadRender.BeginRender();
            quadRender.Clear(0xFF000000);

            quadRender.SetBlendMode(TQuadBlendMode.qbmSrcAlpha);

            quadCamera.Enable();
            quadLogoTexture.DrawRot(new Vec2f(0, 0), 0, 1);
            quadCamera.Disable();

            Vec2f cameraPosition;
            quadCamera.GetPosition(out cameraPosition);
                     
            quadWindow.SetCaption(mousePosition.X.ToString() + "x" + mousePosition.Y.ToString());

            quadRender.DrawQuadLine(
              new Vec2f(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2),
                mousePosition,
              5, 1, 0xFFFF0000, 0xFF00FF00
            );

            quadRender.EndRender();
        }

        static void Main(string[] args)
        {
            isCursorMove = true;
            QuadEngine.QuadEngine.CreateQuadDevice(out quadDevice);
            quadDevice.CreateWindow(out quadWindow);
            quadWindow.SetCaption("05 - Cursor and Camera");
            quadWindow.SetSize(800, 600);
            quadWindow.CreateInput(out quadInput);

            activate = (OnEvent)OnActivate;
            quadWindow.SetOnActivate(Marshal.GetFunctionPointerForDelegate(activate));

            deactivate = (OnEvent)OnDeactivate;
            quadWindow.SetOnDeactivate(Marshal.GetFunctionPointerForDelegate(deactivate));

            quadDevice.CreateRender(out quadRender);
            quadRender.Initialize((IntPtr)(int)(uint)quadWindow.GetHandle(), 800, 600, false);

            quadDevice.CreateAndLoadTexture(0, "data\\quadlogo.png", out quadLogoTexture);

            quadDevice.ShowCursor(true);
            quadDevice.CreateAndLoadTexture(0, "data\\cursor.png", out cursorTexture);

            quadDevice.SetCursorProperties(0, 0, cursorTexture);

            quadDevice.CreateCamera(out quadCamera);
            quadCamera.SetPosition(new Vec2f(-WINDOW_WIDTH, -WINDOW_HEIGHT));

            quadDevice.CreateTimer(out quadTimer);

            timer = (TimerProcedure)OnTimer;
            quadTimer.SetCallBack(Marshal.GetFunctionPointerForDelegate(timer));
            quadTimer.SetInterval(16);
            quadTimer.SetState(true);

            quadWindow.Start();
        }
    }
}
