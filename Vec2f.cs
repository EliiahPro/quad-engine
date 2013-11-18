using System;
using System.Runtime.InteropServices;

namespace QuadEngine
{
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct Vec2i
    {
        public int X;
        public int Y;

        public Vec2i(int X, int Y)
        {
            this.X = X;
            this.Y = Y;
        }
    }

    public struct Vec2f
    {
        public float X;
        public float Y;

        public Vec2f(float X, float Y)
        {
            this.X = X;
            this.Y = Y;
        }

        public static Vec2f operator +(Vec2f A, Vec2f B)
        {
            return new Vec2f(A.X + B.X, A.Y + B.Y);
        }

        public static Vec2f operator -(Vec2f A, Vec2f B)
        {
            return new Vec2f(A.X - B.X, A.Y - B.Y);
        }

        public static Vec2f operator *(Vec2f A, Vec2f B)
        {
            return new Vec2f(A.X * B.X, A.Y * B.Y);
        }

        public static Vec2f operator *(Vec2f A, float B)
        {
            return new Vec2f(A.X * B, A.Y * B);
        }       

        public static Vec2f operator *(float A, Vec2f B)
        {
            return new Vec2f(B.X * A, B.Y * A);
        }

        public static Vec2f operator /(Vec2f A, Vec2f B)
        {
            return new Vec2f(A.X / B.X, A.Y / B.Y);
        }

        public static Vec2f operator /(Vec2f A, float B)
        {
            return new Vec2f(A.X / B, A.Y / B);
        }

        public static bool operator ==(Vec2f A, Vec2f B)
        {
            return (A.X == B.X) && (A.Y == B.Y);
        }

        public static bool operator !=(Vec2f A, Vec2f B)
        {
            return (A.X != B.X) || (A.Y != B.Y);
        }

        public override int GetHashCode()
        {
            return base.GetHashCode();
        }

        public override bool Equals(object obj)
        {
            return base.Equals(obj);
        }

        public float Length()
        {
            return (float)Math.Sqrt(X * X + Y * Y);
        }

        public float Distance(Vec2f target)
        {
            return (this - target).Length();
        }
        
        public Vec2f Normal()
        {
            return new Vec2f(this.Y, -this.X);
        }
        
        public Vec2f Normalize()
        {
            float d;
            d = this.Distance(new Vec2f(0, 0));
            
            if (d > 0)
            {
                return this / d;
            } 
            else 
            {
                return new Vec2f(0, 0);
            }
        }
        
        public float Dot(Vec2f A)
        {
            return (A.X * this.X + A.Y * this.Y);
        }
        
        public Vec2f Lerp(Vec2f A, float dist)
        {
            return (A - this) * dist + this;
        }    
    }
}
