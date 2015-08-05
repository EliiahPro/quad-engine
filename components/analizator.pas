unit analizator;

interface

uses
  windows, classes, sysutils;

const
  DevidersCount = 24;
  OperatorsCount = 10;
  ReservedCount = 74;
  FunctionsCount = 61;
  TokenReserved : array [0..ReservedCount-1] of String = ('asm',
                                                          'blendstate',
                                                          'bool',
                                                          'break',
                                                          'buffer',
                                                          'compile',
                                                          'const',
                                                          'decl',
                                                          'discard',
                                                          'do',
                                                          'double',
                                                          'dword',
                                                          'else',
                                                          'extern',
                                                          'false',
                                                          'float',
                                                          'float2',
                                                          'float2x2',
                                                          'float3',
                                                          'float3x3',
                                                          'float4',
                                                          'float4x4',
                                                          'for',
                                                          'half',
                                                          'if',
                                                          'in',
                                                          'inline',
                                                          'inout',
                                                          'int',
                                                          'interface',
                                                          'line',
                                                          'linear',
                                                          'matrix',
                                                          'namespace',
                                                          'null',
                                                          'out',
                                                          'pass',
                                                          'pixelshader',
                                                          'point',
                                                          'precise',
                                                          'rasterizerstate',
                                                          'rendertargetview',
                                                          'register',
                                                          'return',
                                                          'row_major',
                                                          'sampler',
                                                          'sampler1d',
                                                          'sampler2d',
                                                          'sampler3d',
                                                          'samplerstate',
                                                          'sampler_state',
                                                          'share',
                                                          'shared',
                                                          'static',
                                                          'string',
                                                          'struct',
                                                          'switch',
                                                          'technique',
                                                          'tex2d',
                                                          'texture1d',
                                                          'texture2d',
                                                          'texture3d',
                                                          'texture',
                                                          'true',
                                                          'typedef',
                                                          'triangle',
                                                          'uniform',
                                                          'unorm',
                                                          'uint',
                                                          'vector',
                                                          'vertexshader',
                                                          'void',
                                                          'volatile',
                                                          'while');
  TokenFunctions : array [0..FunctionsCount-1] of String = ('abs',
                                                            'acos',
                                                            'all',
                                                            'any',
                                                            'asin',
                                                            'atan',
                                                            'atan2',
                                                            'ceil',
                                                            'clamp',
                                                            'clip',
                                                            'cos',
                                                            'cosh',
                                                            'cross',
                                                            'ddx',
                                                            'ddy',
                                                            'degrees',
                                                            'determinant',
                                                            'distance',
                                                            'exp',
                                                            'exp2',
                                                            'faceforward',
                                                            'dot',
                                                            'floor',
                                                            'fmod',
                                                            'frac',
                                                            'frexp',
                                                            'fwidth',
                                                            'isfinite',
                                                            'isinf',
                                                            'isnan',
                                                            'ldexp',
                                                            'len',
                                                            'length',
                                                            'lerp',
                                                            'lit',
                                                            'log',
                                                            'log10',
                                                            'log2',
                                                            'max',
                                                            'min',
                                                            'mul',
                                                            'noise',
                                                            'normalize',
                                                            'pow',
                                                            'radians',
                                                            'reflect',
                                                            'refract',
                                                            'round',
                                                            'rsqrt',
                                                            'saturate',
                                                            'sign',
                                                            'sin',
                                                            'sincos',
                                                            'sinh',
                                                            'smoothstep',
                                                            'sqrt',
                                                            'step',
                                                            'tan',
                                                            'tanh',
                                                            'transpose',
                                                            'trunc');
  TokenOperator  : array [0..OperatorsCount - 1] of String = ('!', '+', '-', '*', '/', '=', ':', '<>', '>', '<');
  TokenDevider   : array [0..DevidersCount - 1] of String = (' ', '.', ';', '(', ')', '[', ']', ',', '>', '<', ':', '=', '-', '+', '/', '*', #10, #13, #9, '{', '}', '''', '"', '!');

type
  TTokenTypes = (ttReserved, ttComments, ttOperator, ttString, ttConstant, ttVariable, ttFunction, ttDevider, ttUnknown, ttDefine);

  PToken = ^TToken;
  TToken = record
    TChar     : Cardinal;
    TLineChar : Cardinal;
    TLine     : Cardinal;
    TType     : TTokenTypes;
    TText     : String;
    TLength   : Integer;
  end;

  Tparser = class
  private
    FSource: string;
    FCurrentLine: Cardinal;
    procedure RecognizeTokens;
    function GetSize: Integer;
    procedure SetSource(const Value: String);
    function GetTokenItem(index: Integer): PToken;
  public
    tokens: TList;
    constructor create;
    destructor destroy; override;
    procedure LoadFromFile(const Filename: string);
    procedure GetTokens;
    procedure addtoken(last, now: cardinal);
    procedure addSpecialToken(AType: TTokenTypes; ALast, ANow: cardinal);
    function GetPossibleTokens(const AText: String): String;
    function GetTokenAtPos(ALine, AChar: Integer): PToken;
    property size: Integer read GetSize;
    property Source: String read FSource write SetSource;
    property TokenItems[index: Integer]: PToken read GetTokenItem;
  end;

implementation

constructor Tparser.create;
begin
  inherited;

  tokens := TList.Create;
end;

procedure Tparser.LoadFromFile(const Filename : string);
var
  f: File of Byte;
  a: array of Byte;
  b: array of Byte;
  i, j: integer;
  ASize: Integer;
begin
  AssignFile(f, Filename);
  Reset(f);

  Asize:= FileSize(f);
  SetLength(a, Asize);
  BlockRead(f, a[0], Asize);

  j := 0;
  for i := 0 to size do
  if a[i] <> $D then
  begin
    SetLength(b, j + 1);
 //   if a[i] = $A then
 //   b[j]:= 32 else
    b[j] := a[i];
    inc(j);
  end;
  Source := PAnsiChar(b);

  CloseFile(f);
end;

procedure Tparser.addtoken(last, now : cardinal);
var
  tok: PToken;
begin
  // разделитель с токеном
  if now - last > 0 then
  begin
    New(tok);
    tok.TType     := ttUnknown;
    tok.TText     := Copy(Source, last, now - last);
    tok.TChar     := last;
    tok.TLine     := FCurrentLine;
    tok.TLength   := now - last;
    if tokens.Count > 0 then
      if TokenItems[tokens.Count - 1].TLine = FCurrentLine then
        tok.TLineChar := TokenItems[tokens.Count - 1].TLineChar + TokenItems[tokens.Count - 1].TLength
      else
        tok.TLineChar := 0
    else
      tok.TLineChar := 0;
    tokens.Add(tok);
  end;

  new(tok);
  tok.TType     := ttDevider;
  tok.TText     := Source[now];
  tok.TLine     := FCurrentLine;
  tok.TChar     := now;
  tok.TLength   := 1;
  if tokens.Count > 0 then
    if TokenItems[tokens.Count - 1].TLine = FCurrentLine then
      tok.TLineChar := TokenItems[tokens.Count - 1].TLineChar + TokenItems[tokens.Count - 1].TLength
    else
      tok.TLineChar := 0
  else
    tok.TLineChar := 0;
  tokens.Add(tok);

  if Source[now] = #$A then
    Inc(FCurrentLine);
end;

procedure Tparser.addSpecialToken(AType: TTokenTypes; ALast, ANow: cardinal);
var
  tok: PToken;
begin
  // разделитель с токеном
  if ANow - ALast > 0 then
  begin
    New(tok);
    tok.TType := AType;
    tok.TText    := Copy(Source, ALast, ANow - ALast);
    tok.TChar    := ALast;
    tok.TLine    := FCurrentLine;
    tok.TLength  := ANow - ALast;
    if tokens.Count > 0 then
      if TokenItems[tokens.Count - 1].TLine = FCurrentLine then
        tok.TLineChar := TokenItems[tokens.Count - 1].TLineChar + TokenItems[tokens.Count - 1].TLength
      else
        tok.TLineChar := 0
    else
      tok.TLineChar := 0;        
    tokens.Add(tok);
  end;
end;

procedure Tparser.GetTokens;
var
  i, j: Integer;
  found: Boolean;
  LastToken: Cardinal;
  temp: Char;
begin
  i := 1;
  LastToken := 1;
  FCurrentLine := 0;

  repeat
    j := 0;
    found := False;

    // строки
    if source[i] = '''' then
    repeat
      Inc(i);
      if (source[i] = '''') or (source[i] = #$A) or (source[i] = #$D) then
      begin
        addSpecialToken(ttString, LastToken, i + 1);
        LastToken := i + 1;
        found := True;
      end;
    until (i = size) or (found)
    else
    // строки
    if source[i] = '"' then
    repeat
      inc(i);
      if (source[i] = '"') or (source[i] = #$A) or (source[i] = #$D) then
      begin
        addSpecialToken(ttString, LastToken, i + 1);
        LastToken := i + 1;
        found := True;
      end;
    until (i = size) or (found)
    else
    // комменты
    if (i < size - 1) and (source[i] = '/') and (source[i + 1] = '/') then
    repeat
      inc(i);
      if source[i] = #$A then
      begin
        addSpecialToken(ttComments, LastToken, i - 1);
        LastToken := i + 1;
        found := True;
        Inc(FCurrentLine);
      end;
    until (i = size) or (found)
    else
    // define
    if (source[i] = '#') then
    repeat
      inc(i);
      if (source[i] = ']') or (source[i] = ' ') or (source[i] = #$A) or (source[i] = #$D) then
      begin
        addSpecialToken(ttDefine, LastToken, i);
        LastToken := i + 1;
        found := True;
      end;
    until (i = size) or (found)
    else
    repeat
      temp := Source[i];
      // добавляем и разделяем
      if temp = TokenDevider[j] then
      begin
        addtoken(LastToken, i);
        LastToken := i + 1;
        found := True;
      end;
      Inc(j);
    until found or (j = deviderscount);

    Inc(i);
  until i = size;
  addtoken(LastToken, i);

  RecognizeTokens;
end;

procedure Tparser.RecognizeTokens;
var
  i, j: Integer;
  found: Boolean;
begin
  for i := 0 to tokens.Count - 1 do
  begin
    if TokenItems[i].TType <> ttUnknown then
      Continue;

  {  if i > 1 then
    begin
      if TokenItems[i - 2].TType = ttReserved then
      begin
        TokenItems[i].TType := ttVariable;
        found := True;
      end;
    end;   } // ??? пока х3, выделение рушится 

    j := 0;
    found := False;

    // операторы
    repeat
      if TokenItems[i].TText = TokenOperator[j] then
      begin
        TokenItems[i].TType := ttOperator;
        found := True;
      end;
      Inc(j);
    until j = operatorscount;

    // резервированные слова
    j := 0;
    if not found then
    repeat
      if LowerCase(TokenItems[i].TText) = TokenReserved[j] then
      begin
        TokenItems[i].TType := ttReserved;
        found := True;
      end;
      Inc(j);
    until j = ReservedCount;

    // процедуры
    j := 0;
    if not found then
    repeat
      if LowerCase(TokenItems[i].TText) = TokenFunctions[j] then
      begin
        TokenItems[i].TType := ttFunction;
        found := True;
      end;
      Inc(j);
    until j = FunctionsCount;

    // числа
    j := 1;
    if not found then
    begin
      found := True;
      repeat
        if not (TokenItems[i].TText[j] in ['#', '$', '0'..'9']) then
        found := False;
       inc(j);
      until j > TokenItems[i].TLength;
      if found then
        TokenItems[i].TType := ttConstant;
    end;

    // переменные
  {  j:= 1;
    if not found then
    begin
      found := True;
      repeat
        if not (TokenItems[i].TText[1] = '$') then
        found:= False;
       Inc(j);
      until j > Length(TokenItems[i].TText);
      if found then
        TokenItems[i].TType := ttVariable;
    end;         }
  end;
end;

function Tparser.GetSize: Integer;
begin
  Result := Length(Source);
end;

destructor Tparser.destroy;
begin
  tokens.Free;

  inherited;
end;

procedure Tparser.SetSource(const Value: String);
var
  i: Integer;
begin
  for i := 0 to tokens.Count - 1 do
    Dispose(TokenItems[i]);

  tokens.Clear;
  FSource := Value;
  if FSource <> '' then
  GetTokens;
end;

function Tparser.GetTokenItem(index: Integer): PToken;
begin
  Result := PToken(tokens[index]);
end;

function Tparser.GetPossibleTokens(const AText: String): String;
var
  i: Integer;
begin
  Result := '';

  for i := 0 to ReservedCount - 1 do
    if Pos(AText, TokenReserved[i]) > 0 then
      Result := Result + TokenReserved[i] + #13#10;

  for i := 0 to FunctionsCount - 1 do
    if Pos(AText, TokenFunctions[i]) > 0 then
      Result := Result + TokenFunctions[i] + #13#10;
end;

function Tparser.GetTokenAtPos(ALine, AChar: Integer): PToken;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to tokens.Count - 1 do
  begin
    if (TokenItems[i].TLine = ALine) and
      (TokenItems[i].TLineChar <= AChar) and
      ((TokenItems[i].TLength + TokenItems[i].TLineChar) >= Achar) and
      ((TokenItems[i].TType = ttUnknown) or (TokenItems[i].TType = ttVariable)) then
    begin
      Result := TokenItems[i];
      Break;
    end;
  end;
end;

end.
