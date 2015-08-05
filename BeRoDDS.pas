unit BeRoDDS;
(*************************************
** 2-clause simplified BSD license ***
**************************************
**
** Copyright 2010-2011 Benjamin Rosseaux. All rights reserved.
**
** Redistribution and use in source and binary forms, with or without modification, are
** permitted provided that the following conditions are met:
**
**    1. Redistributions of source code must retain the above copyright notice, this list of
**       conditions and the following disclaimer.
**
**    2. Redistributions in binary form must reproduce the above copyright notice, this list
**       of conditions and the following disclaimer in the documentation and/or other materials
**       provided with the distribution.
**
** THIS SOFTWARE IS PROVIDED BY BENJAMIN ROSSEAUX ``AS IS'' AND ANY EXPRESS OR IMPLIED
** WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES of MERCHANTABILITY AND
** FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BENJAMIN ROSSEAUX OR
** CONTRIBUTORS BE LIABLE for ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
** CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED to, PROCUREMENT OF SUBSTITUTE GOODS OR
** SERVICES; LOSS OF USE, DATA, OR PROFITS; or BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
** ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE of THIS SOFTWARE, EVEN IF
** ADVISED OF THE POSSIBILITY of SUCH DAMAGE.
**
** The views and conclusions contained in the software and documentation are those of the
** authors and should not be interpreted as representing official policies, either expressed
** or implied, of Benjamin Rosseaux.
*)
{$ifdef fpc}
 {$mode delphi}
 {$warnings off}
 {$hints off}
 {$ifdef cpui386}
  {$define cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef fpc_little_endian}
  {$define little_endian}
 {$else}
  {$ifdef fpc_big_endian}
   {$define big_endian}
  {$endif}
 {$endif}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
{$else}
 {$define little_endian}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$optimization on}
 {$undef HasSAR}
 {$define UseDIV}
{$endif}
{$overflowchecks off}
{$rangechecks off}

interface

const
  DDS_MAGIC = $20534444;

  // DDS_header.dwFlags
  DDSD_CAPS = $00000001;
  DDSD_HEIGHT = $00000002;
  DDSD_WIDTH = $00000004;
  DDSD_PITCH = $00000008;
  DDSD_PIXELFORMAT = $00001000;
  DDSD_MIPMAPCOUNT = $00020000;
  DDSD_LINEARSIZE = $00080000;
  DDSD_DEPTH = $00800000;

  DDPF_ALPHAPIXELS = $00000001;
  DDPF_FOURCC = $00000004;
  DDPF_INDEXED = $00000020;
  DDPF_RGB = $00000040;

  DDSCAPS_COMPLEX = $00000008;
  DDSCAPS_TEXTURE = $00001000;
  DDSCAPS_MIPMAP = $00400000;

  DDSCAPS2_CUBEMAP = $00000200;
  DDSCAPS2_CUBEMAP_POSITIVEX = $00000400;
  DDSCAPS2_CUBEMAP_NEGATIVEX = $00000800;
  DDSCAPS2_CUBEMAP_POSITIVEY = $00001000;
  DDSCAPS2_CUBEMAP_NEGATIVEY = $00002000;
  DDSCAPS2_CUBEMAP_POSITIVEZ = $00004000;
  DDSCAPS2_CUBEMAP_NEGATIVEZ = $00008000;
  DDSCAPS2_VOLUME = $00200000;

  D3DFMT_DXT1 = $31545844;
  D3DFMT_DXT2 = $32545844;
  D3DFMT_DXT3 = $33545844;
  D3DFMT_DXT4 = $34545844;
  D3DFMT_DXT5 = $35545844;

  D3DFMT_ATI1 = $31495441;
  D3DFMT_ATI2 = $32495441;

  D3DFMT_BC4U = $55344342;
  D3DFMT_BC4S = $53344342;

  D3DFMT_BC5U = $55354342;
  D3DFMT_BC5S = $53354342;

  D3DFMT_RXGB = $42475852;

  D3DFMT_DX10 = $30315844;

  DXGI_FORMAT_UNKNOWN = 0;
  DXGI_FORMAT_R32G32B32A32_TYPELESS = 1;
  DXGI_FORMAT_R32G32B32A32_FLOAT = 2;
  DXGI_FORMAT_R32G32B32A32_UINT = 3;
  DXGI_FORMAT_R32G32B32A32_SINT = 4;
  DXGI_FORMAT_R32G32B32_TYPELESS = 5;
  DXGI_FORMAT_R32G32B32_FLOAT = 6;
  DXGI_FORMAT_R32G32B32_UINT = 7;
  DXGI_FORMAT_R32G32B32_SINT = 8;
  DXGI_FORMAT_R16G16B16A16_TYPELESS = 9;
  DXGI_FORMAT_R16G16B16A16_FLOAT = 10;
  DXGI_FORMAT_R16G16B16A16_UNORM = 11;
  DXGI_FORMAT_R16G16B16A16_UINT = 12;
  DXGI_FORMAT_R16G16B16A16_SNORM = 13;
  DXGI_FORMAT_R16G16B16A16_SINT = 14;
  DXGI_FORMAT_R32G32_TYPELESS = 15;
  DXGI_FORMAT_R32G32_FLOAT = 16;
  DXGI_FORMAT_R32G32_UINT = 17;
  DXGI_FORMAT_R32G32_SINT = 18;
  DXGI_FORMAT_R32G8X24_TYPELESS = 19;
  DXGI_FORMAT_D32_FLOAT_S8X24_UINT = 20;
  DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS = 21;
  DXGI_FORMAT_X32_TYPELESS_G8X24_UINT = 22;
  DXGI_FORMAT_R10G10B10A2_TYPELESS = 23;
  DXGI_FORMAT_R10G10B10A2_UNORM = 24;
  DXGI_FORMAT_R10G10B10A2_UINT = 25;
  DXGI_FORMAT_R11G11B10_FLOAT = 26;
  DXGI_FORMAT_R8G8B8A8_TYPELESS = 27;
  DXGI_FORMAT_R8G8B8A8_UNORM = 28;
  DXGI_FORMAT_R8G8B8A8_UNORM_SRGB = 29;
  DXGI_FORMAT_R8G8B8A8_UINT = 30;
  DXGI_FORMAT_R8G8B8A8_SNORM = 31;
  DXGI_FORMAT_R8G8B8A8_SINT = 32;
  DXGI_FORMAT_R16G16_TYPELESS = 33;
  DXGI_FORMAT_R16G16_FLOAT = 34;
  DXGI_FORMAT_R16G16_UNORM = 35;
  DXGI_FORMAT_R16G16_UINT = 36;
  DXGI_FORMAT_R16G16_SNORM = 37;
  DXGI_FORMAT_R16G16_SINT = 38;
  DXGI_FORMAT_R32_TYPELESS = 39;
  DXGI_FORMAT_D32_FLOAT = 40;
  DXGI_FORMAT_R32_FLOAT = 41;
  DXGI_FORMAT_R32_UINT = 42;
  DXGI_FORMAT_R32_SINT = 43;
  DXGI_FORMAT_R24G8_TYPELESS = 44;
  DXGI_FORMAT_D24_UNORM_S8_UINT = 45;
  DXGI_FORMAT_R24_UNORM_X8_TYPELESS = 46;
  DXGI_FORMAT_X24_TYPELESS_G8_UINT = 47;
  DXGI_FORMAT_R8G8_TYPELESS = 48;
  DXGI_FORMAT_R8G8_UNORM = 49;
  DXGI_FORMAT_R8G8_UINT = 50;
  DXGI_FORMAT_R8G8_SNORM = 51;
  DXGI_FORMAT_R8G8_SINT = 52;
  DXGI_FORMAT_R16_TYPELESS = 53;
  DXGI_FORMAT_R16_FLOAT = 54;
  DXGI_FORMAT_D16_UNORM = 55;
  DXGI_FORMAT_R16_UNORM = 56;
  DXGI_FORMAT_R16_UINT = 57;
  DXGI_FORMAT_R16_SNORM = 58;
  DXGI_FORMAT_R16_SINT = 59;
  DXGI_FORMAT_R8_TYPELESS = 60;
  DXGI_FORMAT_R8_UNORM = 61;
  DXGI_FORMAT_R8_UINT = 62;
  DXGI_FORMAT_R8_SNORM = 63;
  DXGI_FORMAT_R8_SINT = 64;
  DXGI_FORMAT_A8_UNORM = 65;
  DXGI_FORMAT_R1_UNORM = 66;
  DXGI_FORMAT_R9G9B9E5_SHAREDEXP = 67;
  DXGI_FORMAT_R8G8_B8G8_UNORM = 68;
  DXGI_FORMAT_G8R8_G8B8_UNORM = 69;
  DXGI_FORMAT_BC1_TYPELESS = 70;
  DXGI_FORMAT_BC1_UNORM = 71;
  DXGI_FORMAT_BC1_UNORM_SRGB = 72;
  DXGI_FORMAT_BC2_TYPELESS = 73;
  DXGI_FORMAT_BC2_UNORM = 74;
  DXGI_FORMAT_BC2_UNORM_SRGB = 75;
  DXGI_FORMAT_BC3_TYPELESS = 76;
  DXGI_FORMAT_BC3_UNORM = 77;
  DXGI_FORMAT_BC3_UNORM_SRGB = 78;
  DXGI_FORMAT_BC4_TYPELESS = 79;
  DXGI_FORMAT_BC4_UNORM = 80;
  DXGI_FORMAT_BC4_SNORM = 81;
  DXGI_FORMAT_BC5_TYPELESS = 82;
  DXGI_FORMAT_BC5_UNORM = 83;
  DXGI_FORMAT_BC5_SNORM = 84;
  DXGI_FORMAT_B5G6R5_UNORM = 85;
  DXGI_FORMAT_B5G5R5A1_UNORM = 86;
  DXGI_FORMAT_B8G8R8A8_UNORM = 87;
  DXGI_FORMAT_B8G8R8X8_UNORM = 88;
  DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM = 89;
  DXGI_FORMAT_B8G8R8A8_TYPELESS = 90;
  DXGI_FORMAT_B8G8R8A8_UNORM_SRGB = 91;
  DXGI_FORMAT_B8G8R8X8_TYPELESS = 92;
  DXGI_FORMAT_B8G8R8X8_UNORM_SRGB = 93;
  DXGI_FORMAT_BC6H_TYPELESS = 94;
  DXGI_FORMAT_BC6H_UF16 = 95;
  DXGI_FORMAT_BC6H_SF16 = 96;
  DXGI_FORMAT_BC7_TYPELESS = 97;
  DXGI_FORMAT_BC7_UNORM = 98;
  DXGI_FORMAT_BC7_UNORM_SRGB = 99;
  DXGI_FORMAT_AYUV = 100;
  DXGI_FORMAT_Y410 = 101;
  DXGI_FORMAT_Y416 = 102;
  DXGI_FORMAT_NV12 = 103;
  DXGI_FORMAT_P010 = 104;
  DXGI_FORMAT_P016 = 105;
  DXGI_FORMAT_420_OPAQUE = 106;
  DXGI_FORMAT_YUY2 = 107;
  DXGI_FORMAT_Y210 = 108;
  DXGI_FORMAT_Y216 = 109;
  DXGI_FORMAT_NV11 = 110;
  DXGI_FORMAT_AI44 = 111;
  DXGI_FORMAT_IA44 = 112;
  DXGI_FORMAT_P8 = 113;
  DXGI_FORMAT_A8P8 = 114;
  DXGI_FORMAT_B4G4R4A4_UNORM = 115;

type
  TDDSPixelFormat = packed record
    dwSize: LongWord;
    dwFlags: LongWord;
    dwFourCC: LongWord;
    dwRGBBitCount: LongWord;
    dwRBitMask: LongWord;
    dwGBitMask: LongWord;
    dwBBitMask: LongWord;
    dwABitMask: LongWord;
  end;

  TDDSCaps = packed record
    dwCaps1: LongWord;
    dwCaps2: LongWord;
    dwDDSX: LongWord;
    dwReserved: LongWord;
  end;

  TDDSHeader = packed record
    dwMagic: LongWord;
    dwSize: LongWord;
    dwFlags: LongWord;
    dwHeight: LongWord;
    dwWidth: LongWord;
    dwPitchOrLinearSize: LongWord;
    dwDepth: LongWord;
    dwMipMapCount: LongWord;
    dwReserved: array[0..10] of LongWord;
    PixelFormat: TDDSPixelFormat;
    Caps: TDDSCaps;
    dwReserved2: LongWord;
  end;

  TDDSHeaderDX10 = packed record
    dxgiFormat: LongWord;
    ResourceDimension: LongWord;
    MiscFlag: LongWord;
    ArraySize: LongWord;
    Reservedn: LongWord;
  end;

function LoadDDSImage(DataPointer: Pointer; DataSize: LongWord; var ImageData: Pointer; var ImageWidth, ImageHeight: LongInt; MipMapLevel: LongInt = 0): Boolean;

implementation

{$ifdef fpc}
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
type
  qword = UInt64;
  ptruint = NativeUInt;
  ptrint = NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
type
  qword = int64;
{$ifdef cpu64}
  ptruint = qword;
  ptrint = int64;
{$else}
  ptruint = longword;
  ptrint = longint;
{$endif}
{$endif}

function LoadDDSImage(DataPointer: Pointer; DataSize: LongWord; var ImageData: Pointer;
  var ImageWidth, ImageHeight: LongInt; MipMapLevel: LongInt = 0): Boolean;
type
  pbyte = ^byte;
var
  Header:TDDSHeader;
  HeaderDX10:TDDSHeaderDX10;
  BlockSize:longword;
  DataPosition:longword;

  function Read(var Buffer; LengthCounter: LongWord): LongWord;
  var
    RealSize: LongWord;
  begin
    RealSize := LengthCounter;
    if (DataPosition + RealSize) > DataSize then
    begin
      RealSize := DataSize - DataPosition;
    end;

    if RealSize <> LengthCounter then
    begin
      FillChar(Buffer,LengthCounter,#0);
    end;

    if RealSize > 0 then
    begin
      Move(PAnsiChar(DataPointer)[DataPosition],Buffer,RealSize);
    end;

    Inc(DataPosition, RealSize);
    result := RealSize;
  end;

  procedure DecodeDXT(Version: LongInt; PremultiplyAlpha: Boolean);
  var
    i, x, y, bx, by, RowSize: LongInt;
    pData: PByte;
    c0, c1, Bits, rb0, rb1, rb2, rb3, g0, g1, g2, g3, r, g, b, a, v: LongWord;
    p: PAnsiChar;
    Colors: array[0..3] of LongWord;
    Alpha: Int64;
    AlphaValues: array[0..7] of Byte;
  begin
    pData := nil;
    try
      GetMem(ImageData,((((ImageWidth + 3) shr 2) shl 2) * (((ImageHeight + 3) shr 2) shl 2)) * 4);
      FillChar(ImageData^, ImageWidth * ImageHeight * 4, AnsiChar(#$FF));
      RowSize := ((ImageWidth + 3) shr 2) * LongInt(BlockSize);
      i := ((ImageHeight + 3) shr 2) * RowSize;
      GetMem(pData, i * 2);

      if Read(pData^, i) = LongWord(i) then
      begin
        y := 0;
        while y < ImageHeight do
        begin
          x := 0;
          while x < ImageWidth do
          begin
            i:=((y shr 2) * RowSize) + ((x shr 2) * LongInt(BlockSize));

            case Version of
            2, 3: begin
                    Alpha := (int64(byte(pansichar(pointer(pData))[i+0])) shl 0) or
                             (int64(byte(pansichar(pointer(pData))[i+1])) shl 8) or
                             (int64(byte(pansichar(pointer(pData))[i+2])) shl 16) or
                             (int64(byte(pansichar(pointer(pData))[i+3])) shl 24) or
                             (int64(byte(pansichar(pointer(pData))[i+4])) shl 32) or
                             (int64(byte(pansichar(pointer(pData))[i+5])) shl 40) or
                             (int64(byte(pansichar(pointer(pData))[i+6])) shl 48) or
                             (int64(byte(pansichar(pointer(pData))[i+7])) shl 56);
                    a := $00000000;
        inc(i,8);
       end;
       4,5:begin
        AlphaValues[0]:=byte(pansichar(pointer(pData))[i+0]);
        AlphaValues[1]:=byte(pansichar(pointer(pData))[i+1]);
        if AlphaValues[0]>AlphaValues[1] then begin
         AlphaValues[2]:=((6*AlphaValues[0])+(1*AlphaValues[1])) div 7;
         AlphaValues[3]:=((5*AlphaValues[0])+(2*AlphaValues[1])) div 7;
         AlphaValues[4]:=((4*AlphaValues[0])+(3*AlphaValues[1])) div 7;
         AlphaValues[5]:=((3*AlphaValues[0])+(4*AlphaValues[1])) div 7;
         AlphaValues[6]:=((2*AlphaValues[0])+(5*AlphaValues[1])) div 7;
         AlphaValues[7]:=((1*AlphaValues[0])+(6*AlphaValues[1])) div 7;
        end else begin
         AlphaValues[2]:=((4*AlphaValues[0])+(1*AlphaValues[1])) div 5;
         AlphaValues[3]:=((3*AlphaValues[0])+(2*AlphaValues[1])) div 5;
         AlphaValues[4]:=((2*AlphaValues[0])+(3*AlphaValues[1])) div 5;
         AlphaValues[5]:=((1*AlphaValues[0])+(4*AlphaValues[1])) div 5;
         AlphaValues[6]:=0;
         AlphaValues[7]:=255;
        end;
        Alpha:=(int64(byte(pansichar(pointer(pData))[i+2])) shl 0) or
               (int64(byte(pansichar(pointer(pData))[i+3])) shl 8) or
               (int64(byte(pansichar(pointer(pData))[i+4])) shl 16) or
               (int64(byte(pansichar(pointer(pData))[i+5])) shl 24) or
               (int64(byte(pansichar(pointer(pData))[i+6])) shl 32) or
               (int64(byte(pansichar(pointer(pData))[i+7])) shl 40);
        a:=$00000000;
        inc(i,8);
       end;
       else begin
        Alpha:=0;
        a:=$ff000000;
       end;
      end;
      c0:=byte(pansichar(pointer(pData))[i+0]) or (byte(pansichar(pointer(pData))[i+1]) shl 8);
      c1:=byte(pansichar(pointer(pData))[i+2]) or (byte(pansichar(pointer(pData))[i+3]) shl 8);
      rb0:=((c0 shl 3) or (c0 shl 8)) and $f800f8;
      rb1:=((c1 shl 3) or (c1 shl 8)) and $f800f8;
      inc(rb0,(rb0 shr 5) and $070007);
      inc(rb1,(rb1 shr 5) and $070007);
      g0:=(c0 shl 5) and $00fc00;
      g1:=(c1 shl 5) and $00fc00;
      inc(g0,(g0 shr 6) and $000300);
      inc(g1,(g1 shr 6) and $000300);
      Colors[0]:=(rb0 or g0) or a;
      Colors[1]:=(rb1 or g1) or a;
      if (c0>c1) or (Version in [2,3,4,5]) then begin
       rb2:=((((2*rb0)+rb1)*21) shr 6) and $ff00ff;
       g2:=((((2*g0)+g1)*21) shr 6) and $00ff00;
       rb3:=(((rb0+(2*rb1))*21) shr 6) and $ff00ff;
       g3:=(((g0+(2*g1))*21) shr 6) and $00ff00;
       Colors[3]:=(rb3 or g3) or a;
      end else begin
       rb2:=((rb0+rb1) shr 1) and $ff00ff;
       g2:=((g0+g1) shr 1) and $00ff00;
       Colors[3]:=$00000000;
      end;
      Colors[2]:=(rb2 or g2) or a;
      Bits:=byte(pansichar(pointer(pData))[i+4]) or (byte(pansichar(pointer(pData))[i+5]) shl 8) or (byte(pansichar(pointer(pData))[i+6]) shl 16) or (byte(pansichar(pointer(pData))[i+7]) shl 24);
      for by:=0 to 3 do begin
       for bx:=0 to 3 do begin
        case Version of
         2,3:begin
          a:=Alpha and $f;
          a:=a or (a shl 4);
          Alpha:=Alpha shr 4;
         end;
         4,5:begin
          a:=AlphaValues[Alpha and 7];
          Alpha:=Alpha shr 3;
         end;
         else begin
          a:=$00;
         end;
        end;
        p:=@pansichar(ImageData)[(((y+by)*ImageWidth)+(x+bx))*4];
        v:=Colors[Bits and 3] or (a shl 24);
        r:=(v shr 16) and $ff;
        g:=(v shr 8) and $ff;
        b:=(v shr 0) and $ff;
        a:=(v shr 24) and $ff;
        if PremultiplyAlpha and (a<>0) then begin
         // Unpremultiply
         r:=(r*255) div a;
         g:=(g*255) div a;
         b:=(b*255) div a;
         if r>255 then begin
          r:=255;
         end;
         if g>255 then begin
          g:=255;
         end;
         if b>255 then begin
          b:=255;
         end;
        end;
        byte(p[0]):=r;
        byte(p[1]):=g;
        byte(p[2]):=b;
        byte(p[3]):=a;
        Bits:=Bits shr 2;
       end;
      end;
      inc(x,4);
     end;
     inc(y,4);
    end;
   end;
  finally
   if assigned(pData) then begin
    FreeMem(pData);
   end;
  end;
 end;
 function DecodeBGRA:boolean;
 var i,j,k:longint;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  if Read(ImageData^,ImageWidth*ImageHeight*4)=longword(ImageWidth*ImageHeight*4) then begin
   i:=0;
   j:=ImageWidth*ImageHeight*4;
   while i<j do begin
    k:=byte(pansichar(pointer(ImageData))[i]);
    byte(pansichar(pointer(ImageData))[i]):=byte(pansichar(pointer(ImageData))[i+2]);
    byte(pansichar(pointer(ImageData))[i+2]):=k;
    inc(i,4);
   end;
   result:=true;
  end;
 end;
 function DecodeBGRX:boolean;
 var i,j:longint;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  if Read(ImageData^,ImageWidth*ImageHeight*4)=longword(ImageWidth*ImageHeight*4) then begin
   i:=0;
   j:=ImageWidth*ImageHeight*4;
   while i<j do begin
    byte(pansichar(pointer(ImageData))[i+3]):=0;
    inc(i,4);
   end;
   result:=true;
  end;
 end;
 function DecodeRGBA:boolean;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  if Read(ImageData^,ImageWidth*ImageHeight*4)=longword(ImageWidth*ImageHeight*4) then begin
   result:=true;
  end else begin
   FillChar(ImageData^,ImageWidth*ImageHeight*4,AnsiChar(#$ff));
  end;
 end;
 function DecodeBGR:boolean;
 var i,j:longint;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*3);
  try
   if Read(Temp^,ImageWidth*ImageHeight*3)=longword(ImageWidth*ImageHeight*3) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*3;
    while i<j do begin
     r:=byte(pansichar(pointer(Temp))[i+2]);
     g:=byte(pansichar(pointer(Temp))[i+1]);
     b:=byte(pansichar(pointer(Temp))[i+0]);
     a:=$ff;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,3);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeRGB:boolean;
 var i,j:longint;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*3);
  try
   if Read(Temp^,ImageWidth*ImageHeight*3)=longword(ImageWidth*ImageHeight*3) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*3;
    while i<j do begin
     r:=byte(pansichar(pointer(Temp))[i+0]);
     g:=byte(pansichar(pointer(Temp))[i+1]);
     b:=byte(pansichar(pointer(Temp))[i+2]);
     a:=$ff;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,3);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeB5G6R5:boolean;
 var i,j:longint;
     w:word;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*2);
  try
   if Read(Temp^,ImageWidth*ImageHeight*2)=longword(ImageWidth*ImageHeight*2) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*2;
    while i<j do begin
     w:=byte(pansichar(pointer(Temp))[i]) or (byte(pansichar(pointer(Temp))[i+1]) shl 8);
     r:=((w and $f800) shr 11) shl 3;
     g:=((w and $07e0) shr 5) shl 2;
     b:=((w and $001f) shr 0) shl 3;
     a:=$ff;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,2);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeB5G5R5A1:boolean;
 var i,j:longint;
     w:word;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*2);
  try
   if Read(Temp^,ImageWidth*ImageHeight*2)=longword(ImageWidth*ImageHeight*2) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*2;
    while i<j do begin
     w:=byte(pansichar(pointer(Temp))[i]) or (byte(pansichar(pointer(Temp))[i+1]) shl 8);
     r:=((w and $7c00) shr 10) shl 3;
     g:=((w and $03e0) shr 5) shl 3;
     b:=((w and $001f) shr 0) shl 3;
     if (w and $8000)<>0 then begin
      a:=$ff;
     end else begin
      a:=$00;
     end;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,2);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeR10G10B10A2:boolean;
 var i,j:longint;
     lw:longword;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*4);
  try
   if Read(Temp^,ImageWidth*ImageHeight*4)=longword(ImageWidth*ImageHeight*4) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*4;
    while i<j do begin
     lw:=byte(pansichar(pointer(Temp))[i]) or (byte(pansichar(pointer(Temp))[i+1]) shl 8) or (byte(pansichar(pointer(Temp))[i+2]) shl 16) or (byte(pansichar(pointer(Temp))[i+3]) shl 24);
     r:=(lw and $000003ff) shr 2;
     g:=(lw and $000ffc00) shr 12;
     b:=(lw and $3ff00000) shr 22;
     a:=(lw and $c0000000) shr 30;
     a:=a or (a shl 2);
     a:=a or (a shl 4);
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,4);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeA8:boolean;
 var i,j:longint;
     Temp,p:PAnsiChar;
     v,r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*1);
  try
   if Read(Temp^,ImageWidth*ImageHeight*1)=longword(ImageWidth*ImageHeight*1) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*1;
    while i<j do begin
     v:=byte(pansichar(pointer(Temp))[i]);
     r:=$ff;
     g:=$ff;
     b:=$ff;
     a:=v;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,1);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeR8:boolean;
 var i,j:longint;
     Temp,p:PAnsiChar;
     v,r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*1);
  try
   if Read(Temp^,ImageWidth*ImageHeight*1)=longword(ImageWidth*ImageHeight*1) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*1;
    while i<j do begin
     v:=byte(pansichar(pointer(Temp))[i]);
     r:=v;
     g:=$00;
     b:=$00;
     a:=$ff;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,1);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeB4G4R4A4:boolean;
 var i,j:longint;
     w:word;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*2);
  try
   if Read(Temp^,ImageWidth*ImageHeight*2)=longword(ImageWidth*ImageHeight*2) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*2;
    while i<j do begin
     w:=byte(pansichar(pointer(Temp))[i]) or (byte(pansichar(pointer(Temp))[i+1]) shl 8);
     r:=(w and $0f00) shr 8;
     g:=(w and $00f0) shr 4;
     b:=(w and $000f) shr 0;
     a:=(w and $f000) shr 12;
     byte(p[0]):=r or (r shl 4);
     byte(p[1]):=g or (g shl 4);
     byte(p[2]):=b or (b shl 4);
     byte(p[3]):=a or (a shl 4);
     p:=@p[4];
     inc(i,2);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeL8A8:boolean;
 var i,j:longint;
     w:word;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*2);
  try
   if Read(Temp^,ImageWidth*ImageHeight*2)=longword(ImageWidth*ImageHeight*2) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*2;
    while i<j do begin
     w:=byte(pansichar(pointer(Temp))[i]) or (byte(pansichar(pointer(Temp))[i+1]) shl 8);
     r:=(w and $00ff) shr 0;
     g:=$00;
     b:=$00;
     a:=(w and $ff00) shr 8;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,2);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeL16:boolean;
 var i,j:longint;
     w:word;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*2);
  try
   if Read(Temp^,ImageWidth*ImageHeight*2)=longword(ImageWidth*ImageHeight*2) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*2;
    while i<j do begin
     w:=byte(pansichar(pointer(Temp))[i]) or (byte(pansichar(pointer(Temp))[i+1]) shl 8);
     r:=(w and $ff00) shr 0;
     g:=$00;
     b:=$00;
     a:=$ff;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,2);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeL8:boolean;
 var i,j:longint;
     Temp,p:PAnsiChar;
     v,r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*1);
  try
   if Read(Temp^,ImageWidth*ImageHeight*1)=longword(ImageWidth*ImageHeight*1) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*1;
    while i<j do begin
     v:=byte(pansichar(pointer(Temp))[i]);
     r:=v;
     g:=$00;
     b:=$00;
     a:=$ff;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,1);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeR3G3B2:boolean;
 var i,j:longint;
     v:byte;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*1);
  try
   if Read(Temp^,ImageWidth*ImageHeight*1)=longword(ImageWidth*ImageHeight*1) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*1;
    while i<j do begin
     v:=byte(pansichar(pointer(Temp))[i]);
     r:=((v and $e0) shr 5) shl 5;
     g:=((v and $1c) shr 2) shl 6;
     b:=((v and $03) shr 0) shl 5;
     a:=$ff;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,1);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
 function DecodeP8:boolean;
 var i,j:longint;
     v:byte;
     Temp,p:PAnsiChar;
     r,g,b,a:byte;
 begin
  result:=false;
  GetMem(ImageData,ImageWidth*ImageHeight*4);
  GetMem(Temp,ImageWidth*ImageHeight*1);
  try
   if Read(Temp^,ImageWidth*ImageHeight*1)=longword(ImageWidth*ImageHeight*1) then begin
    p:=pointer(ImageData);
    i:=0;
    j:=ImageWidth*ImageHeight*1;
    while i<j do begin
     v:=byte(pansichar(pointer(Temp))[i]);
     r:=v;
     g:=v;
     b:=v;
     a:=v;
     byte(p[0]):=r;
     byte(p[1]):=g;
     byte(p[2]):=b;
     byte(p[3]):=a;
     p:=@p[4];
     inc(i,1);
    end;
    result:=true;
   end;
  finally
   FreeMem(Temp);
  end;
 end;
var i:longint;
    p:PAnsiChar;
    ImageBytes:longword;
begin
 result:=false;
 if assigned(DataPointer) and (DataSize>0) then begin
  DataPosition:=0;
  if Read(Header,SizeOf(TDDSHeader))<>SizeOf(TDDSHeader) then begin
   exit;
  end;
  if ((Header.dwMagic<>DDS_MAGIC) or (Header.dwSize<>124) or ((Header.dwFlags and DDSD_PIXELFORMAT)=0) or ((Header.dwFlags and DDSD_CAPS)=0)) then begin
   exit;
  end;
  if MipMapLevel>=longint(Header.dwMipMapCount) then begin
   exit;
  end;
  if (MipMapLevel>=1) and (((Header.dwWidth and 1)<>0) or ((Header.dwHeight and 1)<>0)) then begin
   exit;
  end;
  ImageWidth:=Header.dwWidth;
  ImageHeight:=Header.dwHeight;
  if ((Header.PixelFormat.dwFlags and DDPF_FOURCC)<>0) and (Header.PixelFormat.dwFourCC=D3DFMT_DX10) then begin
   if Read(HeaderDX10,SizeOf(TDDSHeaderDX10))<>SizeOf(TDDSHeaderDX10) then begin
    exit;
   end;
  end;
  if MipMapLevel>0 then begin
   for i:=1 to MipMapLevel do begin
 {  if (Header.dwFlags and DDSD_PITCH<>0) and (Header.dwPitchOrLinearSize<>0) then begin

    end else}begin
     ImageBytes:=0;
     if (Header.PixelFormat.dwFlags and DDPF_FOURCC)<>0 then begin
      case Header.PixelFormat.dwFourCC of
       D3DFMT_DXT1:begin
        ImageBytes:=((((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*8;
       end;
       D3DFMT_DXT2,D3DFMT_DXT3:begin
        ImageBytes:=((((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*16;
       end;
       D3DFMT_DXT4,D3DFMT_DXT5:begin
        ImageBytes:=((((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*16;
       end;
       D3DFMT_ATI1:begin
       end;
       D3DFMT_ATI2:begin
       end;
       D3DFMT_BC4U:begin
       end;
       D3DFMT_BC4S:begin
       end;
       D3DFMT_BC5U:begin
       end;
       D3DFMT_BC5S:begin
       end;
       D3DFMT_RXGB:begin
       end;
       D3DFMT_DX10:begin
        case HeaderDX10.dxgiFormat of
         DXGI_FORMAT_BC1_TYPELESS,DXGI_FORMAT_BC1_UNORM,DXGI_FORMAT_BC1_UNORM_SRGB:begin
          ImageBytes:=((((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*8;
         end;
         DXGI_FORMAT_BC2_TYPELESS,DXGI_FORMAT_BC2_UNORM,DXGI_FORMAT_BC2_UNORM_SRGB:begin
          ImageBytes:=((((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*16;
         end;
         DXGI_FORMAT_BC3_TYPELESS,DXGI_FORMAT_BC3_UNORM,DXGI_FORMAT_BC3_UNORM_SRGB:begin
          ImageBytes:=((((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*16;
         end;
         DXGI_FORMAT_BC4_TYPELESS,DXGI_FORMAT_BC4_UNORM:begin
          // ATI1
         end;
         DXGI_FORMAT_BC4_SNORM:begin
          // BC4S
         end;
         DXGI_FORMAT_BC5_TYPELESS,DXGI_FORMAT_BC5_UNORM:begin
          // ATI2
         end;
         DXGI_FORMAT_BC5_SNORM:begin
          // BC5S
         end;
         DXGI_FORMAT_B8G8R8A8_TYPELESS,DXGI_FORMAT_B8G8R8A8_UNORM,DXGI_FORMAT_B8G8R8A8_UNORM_SRGB:begin
          ImageBytes:=(ImageWidth*ImageHeight)*4;
         end;
         DXGI_FORMAT_B8G8R8X8_TYPELESS,DXGI_FORMAT_B8G8R8X8_UNORM,DXGI_FORMAT_B8G8R8X8_UNORM_SRGB:begin
          ImageBytes:=(ImageWidth*ImageHeight)*4;
         end;
         DXGI_FORMAT_R8G8B8A8_TYPELESS,DXGI_FORMAT_R8G8B8A8_UNORM,DXGI_FORMAT_R8G8B8A8_UNORM_SRGB,
         DXGI_FORMAT_R8G8B8A8_UINT,DXGI_FORMAT_R8G8B8A8_SNORM,DXGI_FORMAT_R8G8B8A8_SINT:begin
          ImageBytes:=(ImageWidth*ImageHeight)*4;
         end;
         DXGI_FORMAT_B5G6R5_UNORM:begin
          ImageBytes:=(ImageWidth*ImageHeight)*2;
         end;
         DXGI_FORMAT_B5G5R5A1_UNORM:begin
          ImageBytes:=(ImageWidth*ImageHeight)*2;
         end;
         DXGI_FORMAT_R10G10B10A2_TYPELESS,DXGI_FORMAT_R10G10B10A2_UNORM,DXGI_FORMAT_R10G10B10A2_UINT:begin
          ImageBytes:=(ImageWidth*ImageHeight)*4;
         end;
         DXGI_FORMAT_A8_UNORM:begin
          ImageBytes:=(ImageWidth*ImageHeight)*1;
         end;
         DXGI_FORMAT_R8_TYPELESS,DXGI_FORMAT_R8_UNORM,DXGI_FORMAT_R8_UINT,DXGI_FORMAT_R8_SNORM,
         DXGI_FORMAT_R8_SINT:begin
          ImageBytes:=(ImageWidth*ImageHeight)*1;
         end;
         DXGI_FORMAT_B4G4R4A4_UNORM:begin
          ImageBytes:=(ImageWidth*ImageHeight)*2;
         end;
        end;
       end;
      end;
     end else if (Header.PixelFormat.dwFlags and DDPF_RGB)=DDPF_RGB then begin
      ImageBytes:=((longword(ImageWidth*ImageHeight)*Header.PixelFormat.dwRGBBitCount)+7) shr 3;
     end;
    end;
    if (ImageBytes=0) or (DataPosition>=DataSize) or ((DataPosition+ImageBytes)>DataSize) then begin
     exit;
    end;
    inc(DataPosition,ImageBytes);
    ImageWidth:=ImageWidth shr 1;
    ImageHeight:=ImageHeight shr 1;
    if (ImageWidth=0) and (ImageHeight=0) then begin
     exit;
    end;
    if ImageWidth=0 then begin
     ImageWidth:=1;
    end;
    if ImageHeight=0 then begin
     ImageHeight:=1;
    end;
   end;
   if (ImageWidth=0) or (ImageHeight=0) then begin
    exit;
   end;
  end;
  BlockSize:=16;
  if (Header.PixelFormat.dwFlags and DDPF_FOURCC)<>0 then begin
   case Header.PixelFormat.dwFourCC of
    D3DFMT_DXT1:begin
     BlockSize:=8;
     if (((longword(((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*BlockSize)+DataPosition)>DataSize then begin
      exit;
     end;
     DecodeDXT(1,false);
     result:=true;
    end;
    D3DFMT_DXT2,D3DFMT_DXT3:begin
     BlockSize:=16;
     if (((longword(((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*BlockSize)+DataPosition)>DataSize then begin
      exit;
     end;
     DecodeDXT(3,Header.PixelFormat.dwFourCC=D3DFMT_DXT2);
     result:=true;
    end;
    D3DFMT_DXT4,D3DFMT_DXT5:begin
     BlockSize:=16;
     if (((longword(((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*BlockSize)+DataPosition)>DataSize then begin
      exit;
     end;
     DecodeDXT(5,Header.PixelFormat.dwFourCC=D3DFMT_DXT4);
     result:=true;
    end;
    D3DFMT_ATI1:begin
    end;
    D3DFMT_ATI2:begin
    end;
    D3DFMT_BC4U:begin
    end;
    D3DFMT_BC4S:begin
    end;
    D3DFMT_BC5U:begin
    end;
    D3DFMT_BC5S:begin
    end;
    D3DFMT_RXGB:begin
    end;
    D3DFMT_DX10:begin
     case HeaderDX10.dxgiFormat of
      DXGI_FORMAT_BC1_TYPELESS,DXGI_FORMAT_BC1_UNORM,DXGI_FORMAT_BC1_UNORM_SRGB:begin
       BlockSize:=8;
       if (((longword(((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*BlockSize)+DataPosition)>DataSize then begin
        exit;
       end;
       DecodeDXT(1,false);
       result:=true;
      end;
      DXGI_FORMAT_BC2_TYPELESS,DXGI_FORMAT_BC2_UNORM,DXGI_FORMAT_BC2_UNORM_SRGB:begin
       BlockSize:=16;
       if (((longword(((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*BlockSize)+DataPosition)>DataSize then begin
        exit;
       end;
       DecodeDXT(3,false);
       result:=true;
      end;
      DXGI_FORMAT_BC3_TYPELESS,DXGI_FORMAT_BC3_UNORM,DXGI_FORMAT_BC3_UNORM_SRGB:begin
       BlockSize:=16;
       if (((longword(((ImageWidth+3) shr 2)*((ImageHeight+3) shr 2)))*BlockSize)+DataPosition)>DataSize then begin
        exit;
       end;
       DecodeDXT(5,false);
       result:=true;
      end;
      DXGI_FORMAT_BC4_TYPELESS,DXGI_FORMAT_BC4_UNORM:begin
       // ATI1
      end;
      DXGI_FORMAT_BC4_SNORM:begin
       // BC4S
      end;
      DXGI_FORMAT_BC5_TYPELESS,DXGI_FORMAT_BC5_UNORM:begin
       // ATI2
      end;
      DXGI_FORMAT_BC5_SNORM:begin
       // BC5S
      end;
      DXGI_FORMAT_B8G8R8A8_TYPELESS,DXGI_FORMAT_B8G8R8A8_UNORM,DXGI_FORMAT_B8G8R8A8_UNORM_SRGB:begin
       result:=DecodeBGRA;
      end;
      DXGI_FORMAT_B8G8R8X8_TYPELESS,DXGI_FORMAT_B8G8R8X8_UNORM,DXGI_FORMAT_B8G8R8X8_UNORM_SRGB:begin
       result:=DecodeBGRX;
      end;
      DXGI_FORMAT_R8G8B8A8_TYPELESS,DXGI_FORMAT_R8G8B8A8_UNORM,DXGI_FORMAT_R8G8B8A8_UNORM_SRGB,
      DXGI_FORMAT_R8G8B8A8_UINT,DXGI_FORMAT_R8G8B8A8_SNORM,DXGI_FORMAT_R8G8B8A8_SINT:begin
       result:=DecodeRGBA;
      end;
      DXGI_FORMAT_B5G6R5_UNORM:begin
       result:=DecodeB5G6R5;
      end;
      DXGI_FORMAT_B5G5R5A1_UNORM:begin
       result:=DecodeB5G5R5A1;
      end;
      DXGI_FORMAT_R10G10B10A2_TYPELESS,DXGI_FORMAT_R10G10B10A2_UNORM,DXGI_FORMAT_R10G10B10A2_UINT:begin
       result:=DecodeR10G10B10A2;
      end;
      DXGI_FORMAT_A8_UNORM:begin
       result:=DecodeA8;
      end;
      DXGI_FORMAT_R8_TYPELESS,DXGI_FORMAT_R8_UNORM,DXGI_FORMAT_R8_UINT,DXGI_FORMAT_R8_SNORM,
      DXGI_FORMAT_R8_SINT:begin
       result:=DecodeR8;
      end;
      DXGI_FORMAT_B4G4R4A4_UNORM:begin
       result:=DecodeB4G4R4A4;
      end;
     end;
    end;
   end;
  end else if (Header.PixelFormat.dwFlags and DDPF_RGB)=DDPF_RGB then begin
   case Header.PixelFormat.dwRGBBitCount of
    8:begin
     if (Header.PixelFormat.dwFlags and DDPF_INDEXED)<>0 then begin
      result:=DecodeP8;
     end else begin
      if (Header.PixelFormat.dwRBitMask=$000000e0) and
         (Header.PixelFormat.dwGBitMask=$0000001c) and
         (Header.PixelFormat.dwBBitMask=$00000003) and
         (Header.PixelFormat.dwABitMask=$00000000) then begin
       result:=DecodeR3G3B2;
      end else if (Header.PixelFormat.dwFlags and DDPF_ALPHAPIXELS)<>0 then begin
       result:=DecodeA8;
      end else begin
       result:=DecodeL8;
      end;
     end;
    end;
    16:begin
     if (Header.PixelFormat.dwRBitMask=$0000f800) and
        (Header.PixelFormat.dwGBitMask=$000007e0) and
        (Header.PixelFormat.dwBBitMask=$0000001f) and
        (Header.PixelFormat.dwABitMask=$00000000) then begin
      result:=DecodeB5G6R5;
     end else if (Header.PixelFormat.dwRBitMask=$00007c00) and
                 (Header.PixelFormat.dwGBitMask=$000003e0) and
                 (Header.PixelFormat.dwBBitMask=$0000001f) and
                 (Header.PixelFormat.dwABitMask=$00008000) then begin
      result:=DecodeB5G5R5A1;
     end else if (Header.PixelFormat.dwRBitMask=$00000f00) and
                 (Header.PixelFormat.dwGBitMask=$000000f0) and
                 (Header.PixelFormat.dwBBitMask=$0000000f) and
                 (Header.PixelFormat.dwABitMask=$0000f000) then begin
      result:=DecodeB4G4R4A4;
     end else if (Header.PixelFormat.dwRBitMask=$000000ff) and
                 (Header.PixelFormat.dwGBitMask=$00000000) and
                 (Header.PixelFormat.dwBBitMask=$00000000) and
                 (Header.PixelFormat.dwABitMask=$0000ff00) then begin
      result:=DecodeL8A8;
     end else if (Header.PixelFormat.dwRBitMask=$0000ffff) or
                 (Header.PixelFormat.dwGBitMask=$0000ffff) or
                 (Header.PixelFormat.dwBBitMask=$0000ffff) or
                 (Header.PixelFormat.dwABitMask=$0000ffff) then begin
      result:=DecodeL16;
     end;
    end;
    24:begin
     if (Header.PixelFormat.dwRBitMask=$00ff0000) and
        (Header.PixelFormat.dwGBitMask=$0000ff00) and
        (Header.PixelFormat.dwBBitMask=$000000ff) then begin
      result:=DecodeBGR;
     end else if (Header.PixelFormat.dwRBitMask=$000000ff) and
                 (Header.PixelFormat.dwGBitMask=$0000ff00) and
                 (Header.PixelFormat.dwBBitMask=$00ff0000) then begin
      result:=DecodeRGB;
     end;
    end;
    32:begin
     if (Header.PixelFormat.dwRBitMask=$00ff0000) and
        (Header.PixelFormat.dwGBitMask=$0000ff00) and
        (Header.PixelFormat.dwBBitMask=$000000ff) and
        (Header.PixelFormat.dwABitMask=$ff000000) then begin
      result:=DecodeBGRA;
     end else if (Header.PixelFormat.dwRBitMask=$000000ff) and
                 (Header.PixelFormat.dwGBitMask=$0000ff00) and
                 (Header.PixelFormat.dwBBitMask=$00ff0000) and
                 (Header.PixelFormat.dwABitMask=$ff000000) then begin
      result:=DecodeRGBA;
     end else if (Header.PixelFormat.dwRBitMask=$000003ff) and
                 (Header.PixelFormat.dwGBitMask=$000ffc00) and
                 (Header.PixelFormat.dwBBitMask=$3ff00000) and
                 (Header.PixelFormat.dwABitMask=$c0000000) then begin
      result:=DecodeR10G10B10A2;
     end;
    end;
   end;
  end;
 end;
 if result and ((Header.PixelFormat.dwFlags and DDPF_ALPHAPIXELS)=0) then begin
  p:=pointer(ImageData);
  for i:=0 to (ImageWidth*ImageHeight)-1 do begin
   p[(i*4)+3]:=AnsiChar(#$ff);
  end;
 end;
end;

initialization
finalization
end.
