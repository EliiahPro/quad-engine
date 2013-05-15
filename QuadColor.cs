using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuadEngine
{
    public struct QuadColor
    {
        public double A;
        public double R;
        public double G;
        public double B;

        public static readonly QuadColor White = new QuadColor(1.0, 1.0, 1.0);
        public static readonly QuadColor Black = new QuadColor(0.0, 0.0, 0.0);
        public static readonly QuadColor Red = new QuadColor(1.0, 0.0, 0.0);
        public static readonly QuadColor Lime = new QuadColor(0.0, 1.0, 0.0);
        public static readonly QuadColor Blue = new QuadColor(0.0, 0.0, 1.0);
        public static readonly QuadColor Maroon = new QuadColor(0.5, 0.0, 0.0);
        public static readonly QuadColor Green = new QuadColor(0.0, 0.5, 0.0);
        public static readonly QuadColor Navy = new QuadColor(0.0, 0.0, 0.5);
        public static readonly QuadColor Yellow = new QuadColor(1.0, 1.0, 0.0);
        public static readonly QuadColor Fuchsia = new QuadColor(1.0, 0.0, 1.0);
        public static readonly QuadColor Aqua = new QuadColor(0.0, 1.0, 1.0);
        public static readonly QuadColor Olive = new QuadColor(0.5, 0.5, 0.0);
        public static readonly QuadColor Purple = new QuadColor(0.5, 0.0, 0.5);
        public static readonly QuadColor Teal = new QuadColor(0.0, 0.5, 0.5);
        public static readonly QuadColor Gray = new QuadColor(0.5, 0.5, 0.5);
        public static readonly QuadColor Silver = new QuadColor(0.75, 0.75, 0.75);

        public void ClampToMin()
        {
            if (this.A < 0.0) { this.A = 0.0; }
            if (this.R < 0.0) { this.R = 0.0; }
            if (this.G < 0.0) { this.G = 0.0; }
            if (this.B < 0.0) { this.B = 0.0; }
        }

        public void ClampToMax()
        {
            if (this.A > 1.0) { this.A = 1.0; }
            if (this.R > 1.0) { this.R = 1.0; }
            if (this.G > 1.0) { this.G = 1.0; }
            if (this.B > 1.0) { this.B = 1.0; }
        }

        public QuadColor(double R, double G, double B, double A = 1.0)
        {
            this.A = A;
            this.R = R;
            this.G = G;
            this.B = B;
        }

        public QuadColor(byte R, byte G, byte B, byte A = 255)
        {
            this.A = A / 255.0;
            this.R = R / 255.0;
            this.G = G / 255.0;
            this.B = B / 255.0;
        }

        public QuadColor(uint ARGB)
        {
            this.A = (double)((ARGB & 0xFF000000) >> 24) / 255.0;
            this.R = (double)((ARGB & 0x00FF0000) >> 16) / 255.0;
            this.G = (double)((ARGB & 0x0000FF00) >> 8) / 255.0;
            this.B = (double)(ARGB & 0x000000FF) / 255.0;
        }

        public static implicit operator QuadColor(uint ARGB)
        {
            return new QuadColor(ARGB);
        }

        public static implicit operator UInt32(QuadColor quadColor)
        {
            return ((uint)(quadColor.A * 255) << 24) +
                   ((uint)(quadColor.R * 255) << 16) +
                   ((uint)(quadColor.G * 255) << 8) +
                   (uint)(quadColor.B * 255);
        }

        public static QuadColor operator +(QuadColor A, QuadColor B)
        {
            QuadColor quadColor = new QuadColor(A.A + B.A, A.R + B.R, A.G + B.G, A.B + B.B);
            quadColor.ClampToMax();
            return quadColor;
        }

        public static QuadColor operator -(QuadColor A, QuadColor B)
        {
            QuadColor quadColor = new QuadColor(A.A - B.A, A.R - B.R, A.G - B.G, A.B - B.B);
            quadColor.ClampToMin();
            return quadColor;
        }

        public static QuadColor operator *(QuadColor A, QuadColor B)
        {
            QuadColor quadColor = new QuadColor(A.A * B.A, A.R * B.R, A.G * B.G, A.B * B.B);
            quadColor.ClampToMax();
            return quadColor;
        }

        public static QuadColor operator *(QuadColor A, double B)
        {
            QuadColor quadColor = new QuadColor(A.A * B, A.R * B, A.G * B, A.B * B);
            quadColor.ClampToMax();
            return quadColor;
        }

        public static QuadColor operator /(QuadColor A, QuadColor B)
        {
            QuadColor quadColor = A;

            quadColor.A = (B.A == 0) ? 1.0 : A.A / B.A;
            quadColor.R = (B.R == 0) ? 1.0 : A.R / B.R;
            quadColor.G = (B.G == 0) ? 1.0 : A.G / B.G;
            quadColor.B = (B.B == 0) ? 1.0 : A.B / B.B;

            return quadColor;
        }

        public static QuadColor operator /(QuadColor A, double B)
        {
            if (B == 0.0)
                return (White);

            return new QuadColor(A.A / B, A.R / B, A.G / B, A.B / B);
        }

        public QuadColor Lerp(QuadColor A, double dist)
        {
            QuadColor result = new QuadColor((A.A - this.A) * dist + this.A,
                                 (A.R - this.R) * dist + this.R,
                                 (A.G - this.G) * dist + this.G,
                                 (A.B - this.B) * dist + this.B
                                );
            result.ClampToMin();
            result.ClampToMax();
            return result;
        }
    }
}
