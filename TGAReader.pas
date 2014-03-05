unit TGAReader;

interface

uses 
  Windows, classes, Graphics, QuadEngine.Utils, System.SysUtils;

type
  TTGAHeader = packed record
    hIDLength     : Byte;
    hColorMapType : Byte;
    hImageType    : Byte;
    hColorMapSpec : array [0..4] of Byte;
    hOrigX        : Word;
    hOrigY        : Word;
    hWidth        : Word;
    hHeight       : Word;
    hBpp          : Byte;
    hImageDesc    : Byte;
  end;

  TBitmapEx = class(TBitmap)
  private
    procedure NoImage;
  public
    invalid_image : boolean;
    procedure LoadFromFile(const FileName: String); override;
    procedure LoadFromStream(const Stream: TStream); reintroduce;
  end;

implementation

procedure TBitmapEx.NoImage;
begin
  Width := 64;
  Height := 64;
  PixelFormat := pf32bit;
  Canvas.Brush.Color := $00AEFF;
  Canvas.Brush.Style := bsDiagCross;
  Canvas.FillRect(rect(0, 0, 64, 64));
  Canvas.Brush.Color := $00AEFF;
  canvas.Font.Color := $0;
  Canvas.Brush.Style := bsSolid;
  Canvas.TextOut(5, 25, 'NO IMAGE');
  invalid_image := True;
end;

procedure TBitmapEx.LoadFromFile(const FileName: String);
var
  F: File;
  Header: TTGAHeader;
  Bpp, I: Integer;
  Flip: Boolean;
  RLE: Boolean;    // RLE flag
  p,               // pointer to move trough data
  Data: Pointer;   // temp store for imagedata, used for unpacking RLE data
  BytePP: Integer; // Bytes Per Pixels
  b,               // RLE BlockLength
  RLEHeader: Byte; // RLE blockheader
  RLEBuf: Cardinal;// Temp store for one pixel
  TSize: Integer;
begin
  invalid_image := False;

  if not FileExists(filename) then
  begin
    NoImage;
    Exit;
  end;

  AssignFile(F, FileName);
  Reset(F, 1);

  BlockRead(F, Header, SizeOf(Header));

  RLE := Header.hImageType = 10;
  // checking if True-Color format is present
  if (Header.hImageType <> 2) and (not RLE) then
  begin
    CloseFile(F);
    //raise Exception.Create('TGA graphics is not in True-Color');
  end;

  // checking is colormapping present
  if (Header.hColorMapType <> 0) then
  begin
    CloseFile(F);
    //raise Exception.Create('Color-mapped TGA is not supported');
  end;

  // checking bit-depth
  Bpp:= Header.hBpp;
  if (Bpp <> 32)and(Bpp <> 24) then
  begin
    CloseFile(F);
    //raise Exception.Create('Invalid TGA Bit-depth!');
  end;

  // checking if the image is mirrored
  if (Header.hImageDesc and $10 = $10) then
  begin
    CloseFile(F);
    //raise Exception.Create('Mirrored TGA is not supported!');
  end;
  Flip := (Header.hImageDesc and $20 <> $20);

  // skip Image ID field
  if (Header.hIDLength <> 0) then
    Seek(F, FilePos(F) + Header.hIDLength);

  Width := Header.hWidth;
  Height := Header.hHeight;

  BytePP := Bpp div 8;
  TSize := Width * Height * BytePP;
  GetMem(Data, TSize);

  if RLE then
  begin
    i:= 0;
    while (i < TSize) do
    begin
      // read the RLE header
      BlockRead(F, RLEHeader, 1);
      // RLE Block length
      b := RLEHeader and $7F + 1;
      if (RLEHeader and $80) = $80 then
      begin
        // If highest bit is set, the read one pixel and repeat it b times
        BlockRead(F, RLEBuf, BytePP); // read the pixel
        while (b > 0) do
        begin
          Move(RLEBuf, Pointer(Integer(Data) + i)^, BytePP); // repeat the pixel, one at a time
          Inc(i, BytePP);  // inc "read pointer"
          Dec(b);          // dec remaining pixels
        end; 
      end 
      else
      begin
        // read b pixels
        BlockRead(f,Pointer(Integer(Data)+i)^,BytePP*b);
        // inc "read pointer"
        Inc(i, BytePP * b);
      end; 
    end; 
  end 
  else
    BlockRead(F, Data^, TSize); // Not RunLengthEncoded, just read it all

  p := data;
  if (Bpp = 32) then 
    PixelFormat := pf32bit
  else 
    PixelFormat := pf24bit;

  // move the picture from data to scanlines
  if Flip then
  begin
    for I := Height - 1 downto 0 do
    begin
      Move(p^, ScanLine[I]^, Width * BytePP);
      p := Pointer(Integer(p) + Width * BytePP);
    end;
  end 
  else
  begin
   for I := 0 to Height - 1 do
    begin
      Move(p^, ScanLine[I]^, Width * BytePP);
      p := Pointer(Integer(p) + Width * BytePP);
    end;
  end;

  // clean up
  FreeMem(Data);
  CloseFile(F);
end;


procedure TBitmapEx.LoadFromStream(const Stream: TStream);
var
  Header: TTGAHeader;
  Bpp, I: Integer;
  Flip: Boolean;
  RLE: Boolean;    // RLE flag
  p,               // pointer to move trough data
  Data: Pointer;   // temp store for imagedata, used for unpacking RLE data
  BytePP: Integer; // Bytes Per Pixels
  b,               // RLE BlockLength
  RLEHeader: Byte; // RLE blockheader
  RLEBuf: Cardinal;// Temp store for one pixel
  TSize: Integer;
begin
  Stream.Read(Header, SizeOf(Header));

  RLE := Header.hImageType = 10;
  // checking if True-Color format is present
  if (Header.hImageType <> 2)and(not RLE) then
  begin
    //raise Exception.Create('TGA graphics is not in True-Color');
    Exit;
  end;

  // checking is colormapping present
  if (Header.hColorMapType <> 0) then
  begin
    //raise Exception.Create('Color-mapped TGA is not supported');
    Exit;
  end;

  // checking bit-depth
  Bpp := Header.hBpp;
  if (Bpp <> 32) and (Bpp <> 24) then
  begin
    //raise Exception.Create('Invalid TGA Bit-depth!');
    Exit;
  end;

  // checking if the image is mirrored
  if (Header.hImageDesc and $10 = $10) then
  begin
    //raise Exception.Create('Mirrored TGA is not supported!');
    Exit;
  end;
  Flip := (Header.hImageDesc and $20 <> $20);

  // skip Image ID field
  if (Header.hIDLength <> 0) then
    stream.Seek(stream.position + Header.hIDLength, soFromBeginning);

  Width := Header.hWidth;
  Height := Header.hHeight;

  BytePP := Bpp div 8;
  TSize := Width * Height * BytePP;
  GetMem(Data, TSize);

  if RLE then
  begin
    i:= 0;
    while (i < TSize) do
    begin
      // read the RLE header
      stream.Read(RLEHeader, 1);
      // RLE Block length
      b := RLEHeader and $7F + 1;
      if (RLEHeader and $80) = $80 then
      begin
        // If highest bit is set, the read one pixel and repeat it b times
        stream.Read(RLEBuf, BytePP); // read the pixel
        while (b > 0) do
        begin
          Move(RLEBuf, Pointer(Integer(Data) + i)^, BytePP); // repeat the pixel, one at a time
          Inc(i, BytePP);  // inc "read pointer"
          Dec(b);          // dec remaining pixels
        end; 
      end
      else
      begin
        // read b pixels
        stream.Read(Pointer(Integer(Data) + i)^, BytePP * b);
        // inc "read pointer"
        Inc(i, BytePP * b);
      end; 
    end; 
  end 
  else
    stream.Read(Data^, TSize); // Not RunLengthEncoded, just read it all

  p := data;
  if (Bpp = 32) then 
    PixelFormat := pf32bit
  else 
    PixelFormat := pf24bit;

  // move the picture from data to scanlines
  if Flip then
  begin
    for I := Height - 1 downto 0 do
    begin
      Move(p^, ScanLine[I]^, Width * BytePP);
      p := Pointer(Integer(p) + Width * BytePP);
    end;
  end 
  else
  begin
    for I := 0 to Height - 1 do
    begin
      Move(p^, ScanLine[I]^, Width * BytePP);
      p := Pointer(Integer(p) + Width * BytePP);
    end;
  end;

  // clean up
  FreeMem(Data);
end;

end.
