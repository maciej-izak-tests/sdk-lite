{
  @html(<b>)
  Fast String functions
  @html(</b>)
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)
  @html(<br><br>)
  Fast Huge String manipulation, search classes and Unicode to ANSI support.
}

unit rtcFastStrings;

{$include rtcDefs.inc}

interface

uses
  SysUtils, Classes,

  rtcTypes,
  memStrIntList,
  memStringIntList;


type
  // "Fix" Types for RTC_STRING_FIXMODE
  TRtcStrFixType = (
    //Do NOT modify RtcString data when converting to/from RtcByteArray
    rtcStr_NoFIX,
    // Replace Unicode characters above #255 with ANSI when converting RtcString to RtcByteArray
    rtcStr_FixDown,
    // rtcStr_FixDown option + Replace ANSI characters with Unicode when converting RtcByteArray to RtcString
    rtcStr_FixUpDown
    );

var
  // RtcString "fix" mode (rtcStr_NoFix, rtcStr_FixDown, rtcStr_FixUpDown)
  RTC_STRING_FIXMODE:TRtcStrFixType=rtcStr_FixDown;

  // Raise an exception if conversion from RtcString to RtcByteArray would result in data loss
  RTC_STRING_CHECK:boolean=False;

  // Character to be used as a replacement for all Unicode characters not in the current ANSI codepage
  RTC_INVALID_CHAR:byte=63;

const
  // @exclude
  RTC_STROBJ_SHIFT = 4; // = 16
  // @exclude
  RTC_STROBJ_PACK = 1 shl RTC_STROBJ_SHIFT;
  // @exclude
  RTC_STROBJ_AND = RTC_STROBJ_PACK-1;

type
  // @exclude
  tRtcStrRec=record
    str:RtcString;
    siz:integer;
    end;
  // @exclude
  tRtcStrArr=array[0..RTC_STROBJ_PACK-1] of tRtcStrRec;
  // @exclude
  PRtcStrArr=^tRtcStrArr;
  // @exclude
  tRtcStrArray=array of PRtcStrArr;

  // @abstract(Fast Huge Ansi String manipulation)
  TRtcHugeString=class(TRtcFastObject)
  private
    FSize:int64;

    FData:tRtcStrArray;
    FPack:PRtcStrArr;

    FDataCnt,
    FPackCnt,
    FPackFree,
    FPackLoc:integer;

    FCount:integer;

    procedure GrowHugeStringList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    procedure AddEx(s:byte); overload;
    procedure AddEx(const s:RtcByteArray; len:Integer=-1); overload;
    procedure Add(const s:RtcString; len:Integer=-1);

    function GetEx:RtcByteArray;
    function Get:RtcString;

    property Size:int64 read FSize;
    end;

  // @exclude
  tRtcBytesRec=record
    str:RtcByteArray;
    siz:integer;
    end;
  // @exclude
  tRtcBytesArr=array[0..RTC_STROBJ_PACK-1] of tRtcBytesRec;
  // @exclude
  PRtcBytesArr=^tRtcBytesArr;
  // @exclude
  tRtcBytesArray=array of PRtcBytesArr;

  // @abstract(Fast Huge Byte Array manipulation)
  TRtcHugeByteArray=class(TRtcFastObject)
  private
    FSize:int64;
    
    FData:tRtcBytesArray;
    FPack:PRtcBytesArr;

    FDataCnt,
    FPackCnt,
    FPackFree,
    FPackLoc:integer;

    FCount:integer;

    procedure GrowHugeStringList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    procedure AddEx(s:byte); overload;
    procedure AddEx(const s:RtcByteArray; len:Integer=-1; loc:integer=0); overload;
    procedure Add(const s:RtcString; len:Integer=-1; loc:integer=1);

    procedure AddPackEx(const s:RtcByteArray; packSize:integer; len:Integer=-1; loc:integer=0);
    procedure AddPack(const s:RtcString; packSize:integer; len:Integer=-1; loc:integer=1);

    function GetStartEx(len:integer):RtcByteArray;
    procedure DelStart(len:integer);

    function GetEx:RtcByteArray;
    function Get:RtcString;

    property Size:int64 read FSize;
    end;

  // @exclude
  tRtcStrObjRec=record
    str:RtcString;
    obj:TObject;
    end;
  // @exclude
  tRtcStrObjArr=array[0..RTC_STROBJ_PACK-1] of tRtcStrObjRec;
  // @exclude
  PRtcStrObjArr=^tRtcStrObjArr;

  // @exclude
  tRtcStrObjArray=array of PRtcStrObjArr;

  // @abstract(Fast Ansi String Object List)
  tRtcFastStrObjList=class(TRtcFastObject)
  private
    FData:tRtcStrObjArray; // array of PRtcStrObjArr;
    FPack:PRtcStrObjArr;
    Tree:TStrIntList;

    FDataCnt, 
    FPackCnt:integer;
    FCnt:integer;
    FOnChange: TNotifyEvent;

    function GetName(const index: integer): RtcString;
    function GetValue(const index: integer): TObject;
    procedure SetName(const index: integer; const _Value: RtcString);
    procedure SetValue(const index: integer; const _Value: TObject);
    function GetCount: integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure DestroyObjects;

    function Add(const Name:RtcString; _Value:TObject=nil):integer;
    function Find(const Name:RtcString):integer;
    function IndexOf(const Name:RtcString):integer;

    // Case-sensitive Add, Find and IndexOf
    function AddCS(const Name:RtcString; _Value:TObject=nil):integer;
    function FindCS(const Name:RtcString):integer;
    function IndexOfCS(const Name:RtcString):integer;

    property Objects[const index:integer]:TObject read GetValue write SetValue;
    property Strings[const index:integer]:RtcString read GetName write SetName;

    property Count:integer read GetCount;

    property OnChange:TNotifyEvent read FOnChange write FOnChange;
    end;

  // @exclude
  tRtcStringObjRec=record
    str:RtcWideString;
    obj:TObject;
    end;
  // @exclude
  tRtcStringObjArr=array[0..RTC_STROBJ_PACK-1] of tRtcStringObjRec;
  // @exclude
  PRtcStringObjArr=^tRtcStringObjArr;

  // @exclude
  tRtcStringObjArray=array of PRtcStringObjArr;

  // @abstract(Fast Unicode / Wide String Object List)
  tRtcFastStringObjList=class(TRtcFastObject)
  private
    FData:tRtcStringObjArray; // array of PRtcStringObjArr;
    FPack:PRtcStringObjArr;
    Tree:TStringIntList;

    FDataCnt,
    FPackCnt:integer;
    FCnt:integer;
    FOnChange: TNotifyEvent;

    function GetName(const index: integer): RtcWideString;
    function GetValue(const index: integer): TObject;
    procedure SetName(const index: integer; const _Value: RtcWideString);
    procedure SetValue(const index: integer; const _Value: TObject);
    function GetCount: integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure DestroyObjects;

    function Add(const Name:RtcWideString; _Value:TObject=nil):integer;
    function Find(const Name:RtcWideString):integer;
    function IndexOf(const Name:RtcWideString):integer;

    // Case-sensitive Add, Find and IndexOf
    function AddCS(const Name:RtcWideString; _Value:TObject=nil):integer;
    function FindCS(const Name:RtcWideString):integer;
    function IndexOfCS(const Name:RtcWideString):integer;

    property Objects[const index:integer]:TObject read GetValue write SetValue;
    property Strings[const index:integer]:RtcWideString read GetName write SetName;

    property Count:integer read GetCount;

    property OnChange:TNotifyEvent read FOnChange write FOnChange;
    end;

type
  // @abstract(function type used for Unicode to ANSI code conversions)
  RtcUnicodeToAnsiFunc = function(Chr:Word):Byte;
  // @abstract(function type used for ANSI to Unicode code conversions)
  RtcAnsiToUnicodeFunc = function(Chr:Byte):Word;

{ By default, RTC will be using code-page cpWin1252 (Latin I) for implicit Unicode to ANSI conversions.
  To change the code-page used by RTC (use a different convertion), you have two options:  @html(<br><br>)

   A) If you need one of the code-pages listed above, simply use the function "RtcSetAnsiCodePage" 
      and set the code-page which you want to be used from this point on.   @html(<br><br>)

   B) If support for the code-page you need is NOT included, then you can implement your own functions similar 
      to the "RtcUnicodeToAnsiCharWin1252" and "RtcAnsiToUnicodeCharWin1252" functions provided below (implementation section), 
      then assign their addresses to global "RtcUnicodeToAnsiChar" and "RtcAnsiToUnicodeChar" variables (function pointers).
      NOTE: Only conversions for single-byte ANSI code-pages can be implemented.  @html(<br><br>)

   To define how implicit Unicode<->ANSI conversions should work, use "RTC_STRING_FIXMODE" and "RTC_STRING_CHECK" variables.  @html(<br><br>)

   By default, RTC_STRING_MODE will be set to rtcStr_FixDown and RTC_STRING_CHECK will be FALSE, which means that
   implicit conversions will automatically be done from Unicode Strings to ANSI, but NOT in the other direction and
   there will be NO exceptions if a Unicode character is found which can NOT be mapped to the current ANSI code-page. }
  RtcAnsiCodePages=(// no conversion
                    cpNone,
                    // Central Europe (windows-1250)
                    cpWin1250,
                    // Cyrillic (windows-1251)
                    cpWin1251,
                    // Latin I (windows-1252)
                    cpWin1252,
                    // Greek (windows-1253)
                    cpWin1253,
                    // Turkish (windows-1254)
                    cpWin1254,
                    // Hebrew (windows-1255)
                    cpWin1255,
                    // Arabic (windows-1256)
                    cpWin1256,
                    // Baltic (windows-1257)
                    cpWin1257,
                    // Vietnam (windows-1258)
                    cpWin1258,
                    // Thai (windows-874)
                    cpWin874,
                    // Latin 1 (iso-8859-1)
                    cpISO8859_1,
                    // Latin 2 (iso-8859-2)
                    cpISO8859_2,
                    // Latin 3 (iso-8859-3)
                    cpISO8859_3,
                    // Baltic (iso-8859-4)
                    cpISO8859_4,
                    // Cyrillic (iso-8859-5)
                    cpISO8859_5,
                    // Arabic (iso-8859-6)
                    cpISO8859_6,
                    // Greek (iso-8859-7)
                    cpISO8859_7,
                    // Hebrew (iso-8859-8)
                    cpISO8859_8,
                    // Turkish (iso-8859-9)
                    cpISO8859_9,
                    // Latin 9 (iso-8859-15)
                    cpISO8859_15 );

var
  // @abstract(Pointer to the function used for Unicode to ANSI character conversions)
  RtcUnicodeToAnsiChar:RtcUnicodeToAnsiFunc=nil;
  // @abstract(Pointer to the function used for ANSI to Unicode character conversions)
  RtcAnsiToUnicodeChar:RtcAnsiToUnicodeFunc=nil;

{$IFDEF UNICODE}
  {$IFDEF RTC_BYTESTRING}

  //@exclude
  function UpperCase(const s:RtcString):RtcString; overload;

  //@exclude
  function Trim(const S: RtcString): RtcString; overload;

  {$ENDIF}
{$ENDIF}

// @exclude
function Upper_Case(const s:RtcString):RtcString;
// @exclude
function Same_Text(const s1,s2:RtcString):boolean; overload;
{$IFDEF RTC_BYTESTRING}
// @exclude
function Same_Text(const s1,s2:RtcWideString):boolean; overload;
{$ENDIF}

// @exclude
function Up_Case(const c:RtcChar):RtcChar;

// @exclude
function UpperCaseStr(const s:RtcWideString):RtcWideString;

{ Set the code-page for implicit Unicode <-> ANSI conversions done by RTC.
  This will assign the "RtcUnicodeToAnsiChar" and "RtcAnsiToUnicodeChar" functions
  to use one of the built-in implementations for ANSI <-> Unicode character conversions.
  Supported built-in code-pages are cpWin874 and cpWin1250 through cpWin1258.
  Use "cpNone" to disable all implicit ANSI <-> Unicode conversions by RTC.
  For all other code-pages, you can write your own conversion functions and assign
  them manually to the "RtcUnicodeToAnsiChar" and "RtcAnsiToUnicodeChar" variables. }
procedure RtcSetAnsiCodePage(page:RtcAnsiCodePages);

// Convert Unicode String to ANSI String with the RtcUnicodeToAnsiChar function
function RtcUnicodeToAnsiString(const Source:RtcString):RtcString;

// Convert ANSI String to Unicode String with the RtcAnsiToUnicodeChar function
function RtcAnsiToUnicodeString(const Source:RtcString):RtcString;

implementation

(****** ANSI to Unicode char conversion functions ******)

function RtcAnsiToUnicodeCharNone(Chr: Byte): Word;
  begin
  Result := Chr;
  end;

function RtcAnsiToUnicodeCharWin1250(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $89: Result:= $2030; // PER MILLE SIGN
      $8A: Result:= $0160; // LATIN CAPITAL LETTER S WITH CARON
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8C: Result:= $015A; // LATIN CAPITAL LETTER S WITH ACUTE
      $8D: Result:= $0164; // LATIN CAPITAL LETTER T WITH CARON
      $8E: Result:= $017D; // LATIN CAPITAL LETTER Z WITH CARON
      $8F: Result:= $0179; // LATIN CAPITAL LETTER Z WITH ACUTE
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $99: Result:= $2122; // TRADE MARK SIGN
      $9A: Result:= $0161; // LATIN SMALL LETTER S WITH CARON
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9C: Result:= $015B; // LATIN SMALL LETTER S WITH ACUTE
      $9D: Result:= $0165; // LATIN SMALL LETTER T WITH CARON
      $9E: Result:= $017E; // LATIN SMALL LETTER Z WITH CARON
      $9F: Result:= $017A; // LATIN SMALL LETTER Z WITH ACUTE
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $02C7; // CARON
      $A2: Result:= $02D8; // BREVE
      $A3: Result:= $0141; // LATIN CAPITAL LETTER L WITH STROKE
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $0104; // LATIN CAPITAL LETTER A WITH OGONEK
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $015E; // LATIN CAPITAL LETTER S WITH CEDILLA
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $017B; // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $02DB; // OGONEK
      $B3: Result:= $0142; // LATIN SMALL LETTER L WITH STROKE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $0105; // LATIN SMALL LETTER A WITH OGONEK
      $BA: Result:= $015F; // LATIN SMALL LETTER S WITH CEDILLA
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $013D; // LATIN CAPITAL LETTER L WITH CARON
      $BD: Result:= $02DD; // DOUBLE ACUTE ACCENT
      $BE: Result:= $013E; // LATIN SMALL LETTER L WITH CARON
      $BF: Result:= $017C; // LATIN SMALL LETTER Z WITH DOT ABOVE
      $C0: Result:= $0154; // LATIN CAPITAL LETTER R WITH ACUTE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $0102; // LATIN CAPITAL LETTER A WITH BREVE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $0139; // LATIN CAPITAL LETTER L WITH ACUTE
      $C6: Result:= $0106; // LATIN CAPITAL LETTER C WITH ACUTE
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $010C; // LATIN CAPITAL LETTER C WITH CARON
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $0118; // LATIN CAPITAL LETTER E WITH OGONEK
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $011A; // LATIN CAPITAL LETTER E WITH CARON
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $010E; // LATIN CAPITAL LETTER D WITH CARON
      $D0: Result:= $0110; // LATIN CAPITAL LETTER D WITH STROKE
      $D1: Result:= $0143; // LATIN CAPITAL LETTER N WITH ACUTE
      $D2: Result:= $0147; // LATIN CAPITAL LETTER N WITH CARON
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $0150; // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $0158; // LATIN CAPITAL LETTER R WITH CARON
      $D9: Result:= $016E; // LATIN CAPITAL LETTER U WITH RING ABOVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $0170; // LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $00DD; // LATIN CAPITAL LETTER Y WITH ACUTE
      $DE: Result:= $0162; // LATIN CAPITAL LETTER T WITH CEDILLA
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $0155; // LATIN SMALL LETTER R WITH ACUTE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $0103; // LATIN SMALL LETTER A WITH BREVE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $013A; // LATIN SMALL LETTER L WITH ACUTE
      $E6: Result:= $0107; // LATIN SMALL LETTER C WITH ACUTE
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $010D; // LATIN SMALL LETTER C WITH CARON
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $0119; // LATIN SMALL LETTER E WITH OGONEK
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $011B; // LATIN SMALL LETTER E WITH CARON
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $010F; // LATIN SMALL LETTER D WITH CARON
      $F0: Result:= $0111; // LATIN SMALL LETTER D WITH STROKE
      $F1: Result:= $0144; // LATIN SMALL LETTER N WITH ACUTE
      $F2: Result:= $0148; // LATIN SMALL LETTER N WITH CARON
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $0151; // LATIN SMALL LETTER O WITH DOUBLE ACUTE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $0159; // LATIN SMALL LETTER R WITH CARON
      $F9: Result:= $016F; // LATIN SMALL LETTER U WITH RING ABOVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $0171; // LATIN SMALL LETTER U WITH DOUBLE ACUTE
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $00FD; // LATIN SMALL LETTER Y WITH ACUTE
      $FE: Result:= $0163; // LATIN SMALL LETTER T WITH CEDILLA
      $FF: Result:= $02D9; // DOT ABOVE
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin1251(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $0402; // CYRILLIC CAPITAL LETTER DJE
      $81: Result:= $0403; // CYRILLIC CAPITAL LETTER GJE
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $83: Result:= $0453; // CYRILLIC SMALL LETTER GJE
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $88: Result:= $20AC; // EURO SIGN
      $89: Result:= $2030; // PER MILLE SIGN
      $8A: Result:= $0409; // CYRILLIC CAPITAL LETTER LJE
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8C: Result:= $040A; // CYRILLIC CAPITAL LETTER NJE
      $8D: Result:= $040C; // CYRILLIC CAPITAL LETTER KJE
      $8E: Result:= $040B; // CYRILLIC CAPITAL LETTER TSHE
      $8F: Result:= $040F; // CYRILLIC CAPITAL LETTER DZHE
      $90: Result:= $0452; // CYRILLIC SMALL LETTER DJE
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $99: Result:= $2122; // TRADE MARK SIGN
      $9A: Result:= $0459; // CYRILLIC SMALL LETTER LJE
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9C: Result:= $045A; // CYRILLIC SMALL LETTER NJE
      $9D: Result:= $045C; // CYRILLIC SMALL LETTER KJE
      $9E: Result:= $045B; // CYRILLIC SMALL LETTER TSHE
      $9F: Result:= $045F; // CYRILLIC SMALL LETTER DZHE
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $040E; // CYRILLIC CAPITAL LETTER SHORT U
      $A2: Result:= $045E; // CYRILLIC SMALL LETTER SHORT U
      $A3: Result:= $0408; // CYRILLIC CAPITAL LETTER JE
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $0490; // CYRILLIC CAPITAL LETTER GHE WITH UPTURN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $0401; // CYRILLIC CAPITAL LETTER IO
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $0404; // CYRILLIC CAPITAL LETTER UKRAINIAN IE
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $0407; // CYRILLIC CAPITAL LETTER YI
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $0406; // CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
      $B3: Result:= $0456; // CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
      $B4: Result:= $0491; // CYRILLIC SMALL LETTER GHE WITH UPTURN
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $0451; // CYRILLIC SMALL LETTER IO
      $B9: Result:= $2116; // NUMERO SIGN
      $BA: Result:= $0454; // CYRILLIC SMALL LETTER UKRAINIAN IE
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $0458; // CYRILLIC SMALL LETTER JE
      $BD: Result:= $0405; // CYRILLIC CAPITAL LETTER DZE
      $BE: Result:= $0455; // CYRILLIC SMALL LETTER DZE
      $BF: Result:= $0457; // CYRILLIC SMALL LETTER YI
      $C0: Result:= $0410; // CYRILLIC CAPITAL LETTER A
      $C1: Result:= $0411; // CYRILLIC CAPITAL LETTER BE
      $C2: Result:= $0412; // CYRILLIC CAPITAL LETTER VE
      $C3: Result:= $0413; // CYRILLIC CAPITAL LETTER GHE
      $C4: Result:= $0414; // CYRILLIC CAPITAL LETTER DE
      $C5: Result:= $0415; // CYRILLIC CAPITAL LETTER IE
      $C6: Result:= $0416; // CYRILLIC CAPITAL LETTER ZHE
      $C7: Result:= $0417; // CYRILLIC CAPITAL LETTER ZE
      $C8: Result:= $0418; // CYRILLIC CAPITAL LETTER I
      $C9: Result:= $0419; // CYRILLIC CAPITAL LETTER SHORT I
      $CA: Result:= $041A; // CYRILLIC CAPITAL LETTER KA
      $CB: Result:= $041B; // CYRILLIC CAPITAL LETTER EL
      $CC: Result:= $041C; // CYRILLIC CAPITAL LETTER EM
      $CD: Result:= $041D; // CYRILLIC CAPITAL LETTER EN
      $CE: Result:= $041E; // CYRILLIC CAPITAL LETTER O
      $CF: Result:= $041F; // CYRILLIC CAPITAL LETTER PE
      $D0: Result:= $0420; // CYRILLIC CAPITAL LETTER ER
      $D1: Result:= $0421; // CYRILLIC CAPITAL LETTER ES
      $D2: Result:= $0422; // CYRILLIC CAPITAL LETTER TE
      $D3: Result:= $0423; // CYRILLIC CAPITAL LETTER U
      $D4: Result:= $0424; // CYRILLIC CAPITAL LETTER EF
      $D5: Result:= $0425; // CYRILLIC CAPITAL LETTER HA
      $D6: Result:= $0426; // CYRILLIC CAPITAL LETTER TSE
      $D7: Result:= $0427; // CYRILLIC CAPITAL LETTER CHE
      $D8: Result:= $0428; // CYRILLIC CAPITAL LETTER SHA
      $D9: Result:= $0429; // CYRILLIC CAPITAL LETTER SHCHA
      $DA: Result:= $042A; // CYRILLIC CAPITAL LETTER HARD SIGN
      $DB: Result:= $042B; // CYRILLIC CAPITAL LETTER YERU
      $DC: Result:= $042C; // CYRILLIC CAPITAL LETTER SOFT SIGN
      $DD: Result:= $042D; // CYRILLIC CAPITAL LETTER E
      $DE: Result:= $042E; // CYRILLIC CAPITAL LETTER YU
      $DF: Result:= $042F; // CYRILLIC CAPITAL LETTER YA
      $E0: Result:= $0430; // CYRILLIC SMALL LETTER A
      $E1: Result:= $0431; // CYRILLIC SMALL LETTER BE
      $E2: Result:= $0432; // CYRILLIC SMALL LETTER VE
      $E3: Result:= $0433; // CYRILLIC SMALL LETTER GHE
      $E4: Result:= $0434; // CYRILLIC SMALL LETTER DE
      $E5: Result:= $0435; // CYRILLIC SMALL LETTER IE
      $E6: Result:= $0436; // CYRILLIC SMALL LETTER ZHE
      $E7: Result:= $0437; // CYRILLIC SMALL LETTER ZE
      $E8: Result:= $0438; // CYRILLIC SMALL LETTER I
      $E9: Result:= $0439; // CYRILLIC SMALL LETTER SHORT I
      $EA: Result:= $043A; // CYRILLIC SMALL LETTER KA
      $EB: Result:= $043B; // CYRILLIC SMALL LETTER EL
      $EC: Result:= $043C; // CYRILLIC SMALL LETTER EM
      $ED: Result:= $043D; // CYRILLIC SMALL LETTER EN
      $EE: Result:= $043E; // CYRILLIC SMALL LETTER O
      $EF: Result:= $043F; // CYRILLIC SMALL LETTER PE
      $F0: Result:= $0440; // CYRILLIC SMALL LETTER ER
      $F1: Result:= $0441; // CYRILLIC SMALL LETTER ES
      $F2: Result:= $0442; // CYRILLIC SMALL LETTER TE
      $F3: Result:= $0443; // CYRILLIC SMALL LETTER U
      $F4: Result:= $0444; // CYRILLIC SMALL LETTER EF
      $F5: Result:= $0445; // CYRILLIC SMALL LETTER HA
      $F6: Result:= $0446; // CYRILLIC SMALL LETTER TSE
      $F7: Result:= $0447; // CYRILLIC SMALL LETTER CHE
      $F8: Result:= $0448; // CYRILLIC SMALL LETTER SHA
      $F9: Result:= $0449; // CYRILLIC SMALL LETTER SHCHA
      $FA: Result:= $044A; // CYRILLIC SMALL LETTER HARD SIGN
      $FB: Result:= $044B; // CYRILLIC SMALL LETTER YERU
      $FC: Result:= $044C; // CYRILLIC SMALL LETTER SOFT SIGN
      $FD: Result:= $044D; // CYRILLIC SMALL LETTER E
      $FE: Result:= $044E; // CYRILLIC SMALL LETTER YU
      $FF: Result:= $044F; // CYRILLIC SMALL LETTER YA
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin1252(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $83: Result:= $0192; // LATIN SMALL LETTER F WITH HOOK
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $88: Result:= $02C6; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $89: Result:= $2030; // PER MILLE SIGN
      $8A: Result:= $0160; // LATIN CAPITAL LETTER S WITH CARON
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8C: Result:= $0152; // LATIN CAPITAL LIGATURE OE
      $8E: Result:= $017D; // LATIN CAPITAL LETTER Z WITH CARON
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $98: Result:= $02DC; // SMALL TILDE
      $99: Result:= $2122; // TRADE MARK SIGN
      $9A: Result:= $0161; // LATIN SMALL LETTER S WITH CARON
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9C: Result:= $0153; // LATIN SMALL LIGATURE OE
      $9E: Result:= $017E; // LATIN SMALL LETTER Z WITH CARON
      $9F: Result:= $0178; // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $00A1; // INVERTED EXCLAMATION MARK
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $00AA; // FEMININE ORDINAL INDICATOR
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $00BA; // MASCULINE ORDINAL INDICATOR
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $BF: Result:= $00BF; // INVERTED QUESTION MARK
      $C0: Result:= $00C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $00C3; // LATIN CAPITAL LETTER A WITH TILDE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $00C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $C6: Result:= $00C6; // LATIN CAPITAL LETTER AE
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $00C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $00CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $00CC; // LATIN CAPITAL LETTER I WITH GRAVE
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $00CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $D0: Result:= $00D0; // LATIN CAPITAL LETTER ETH
      $D1: Result:= $00D1; // LATIN CAPITAL LETTER N WITH TILDE
      $D2: Result:= $00D2; // LATIN CAPITAL LETTER O WITH GRAVE
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $00D5; // LATIN CAPITAL LETTER O WITH TILDE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $00D8; // LATIN CAPITAL LETTER O WITH STROKE
      $D9: Result:= $00D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $00DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $00DD; // LATIN CAPITAL LETTER Y WITH ACUTE
      $DE: Result:= $00DE; // LATIN CAPITAL LETTER THORN
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $00E0; // LATIN SMALL LETTER A WITH GRAVE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $00E3; // LATIN SMALL LETTER A WITH TILDE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $00E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $E6: Result:= $00E6; // LATIN SMALL LETTER AE
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $00E8; // LATIN SMALL LETTER E WITH GRAVE
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $00EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $00EC; // LATIN SMALL LETTER I WITH GRAVE
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $00EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $F0: Result:= $00F0; // LATIN SMALL LETTER ETH
      $F1: Result:= $00F1; // LATIN SMALL LETTER N WITH TILDE
      $F2: Result:= $00F2; // LATIN SMALL LETTER O WITH GRAVE
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $00F5; // LATIN SMALL LETTER O WITH TILDE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $00F8; // LATIN SMALL LETTER O WITH STROKE
      $F9: Result:= $00F9; // LATIN SMALL LETTER U WITH GRAVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $00FD; // LATIN SMALL LETTER Y WITH ACUTE
      $FE: Result:= $00FE; // LATIN SMALL LETTER THORN
      $FF: Result:= $00FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin1253(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $83: Result:= $0192; // LATIN SMALL LETTER F WITH HOOK
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $89: Result:= $2030; // PER MILLE SIGN
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $99: Result:= $2122; // TRADE MARK SIGN
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $0385; // GREEK DIALYTIKA TONOS
      $A2: Result:= $0386; // GREEK CAPITAL LETTER ALPHA WITH TONOS
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $2015; // HORIZONTAL BAR
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $0384; // GREEK TONOS
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $0388; // GREEK CAPITAL LETTER EPSILON WITH TONOS
      $B9: Result:= $0389; // GREEK CAPITAL LETTER ETA WITH TONOS
      $BA: Result:= $038A; // GREEK CAPITAL LETTER IOTA WITH TONOS
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $038C; // GREEK CAPITAL LETTER OMICRON WITH TONOS
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $038E; // GREEK CAPITAL LETTER UPSILON WITH TONOS
      $BF: Result:= $038F; // GREEK CAPITAL LETTER OMEGA WITH TONOS
      $C0: Result:= $0390; // GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS
      $C1: Result:= $0391; // GREEK CAPITAL LETTER ALPHA
      $C2: Result:= $0392; // GREEK CAPITAL LETTER BETA
      $C3: Result:= $0393; // GREEK CAPITAL LETTER GAMMA
      $C4: Result:= $0394; // GREEK CAPITAL LETTER DELTA
      $C5: Result:= $0395; // GREEK CAPITAL LETTER EPSILON
      $C6: Result:= $0396; // GREEK CAPITAL LETTER ZETA
      $C7: Result:= $0397; // GREEK CAPITAL LETTER ETA
      $C8: Result:= $0398; // GREEK CAPITAL LETTER THETA
      $C9: Result:= $0399; // GREEK CAPITAL LETTER IOTA
      $CA: Result:= $039A; // GREEK CAPITAL LETTER KAPPA
      $CB: Result:= $039B; // GREEK CAPITAL LETTER LAMDA
      $CC: Result:= $039C; // GREEK CAPITAL LETTER MU
      $CD: Result:= $039D; // GREEK CAPITAL LETTER NU
      $CE: Result:= $039E; // GREEK CAPITAL LETTER XI
      $CF: Result:= $039F; // GREEK CAPITAL LETTER OMICRON
      $D0: Result:= $03A0; // GREEK CAPITAL LETTER PI
      $D1: Result:= $03A1; // GREEK CAPITAL LETTER RHO
      $D3: Result:= $03A3; // GREEK CAPITAL LETTER SIGMA
      $D4: Result:= $03A4; // GREEK CAPITAL LETTER TAU
      $D5: Result:= $03A5; // GREEK CAPITAL LETTER UPSILON
      $D6: Result:= $03A6; // GREEK CAPITAL LETTER PHI
      $D7: Result:= $03A7; // GREEK CAPITAL LETTER CHI
      $D8: Result:= $03A8; // GREEK CAPITAL LETTER PSI
      $D9: Result:= $03A9; // GREEK CAPITAL LETTER OMEGA
      $DA: Result:= $03AA; // GREEK CAPITAL LETTER IOTA WITH DIALYTIKA
      $DB: Result:= $03AB; // GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA
      $DC: Result:= $03AC; // GREEK SMALL LETTER ALPHA WITH TONOS
      $DD: Result:= $03AD; // GREEK SMALL LETTER EPSILON WITH TONOS
      $DE: Result:= $03AE; // GREEK SMALL LETTER ETA WITH TONOS
      $DF: Result:= $03AF; // GREEK SMALL LETTER IOTA WITH TONOS
      $E0: Result:= $03B0; // GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS
      $E1: Result:= $03B1; // GREEK SMALL LETTER ALPHA
      $E2: Result:= $03B2; // GREEK SMALL LETTER BETA
      $E3: Result:= $03B3; // GREEK SMALL LETTER GAMMA
      $E4: Result:= $03B4; // GREEK SMALL LETTER DELTA
      $E5: Result:= $03B5; // GREEK SMALL LETTER EPSILON
      $E6: Result:= $03B6; // GREEK SMALL LETTER ZETA
      $E7: Result:= $03B7; // GREEK SMALL LETTER ETA
      $E8: Result:= $03B8; // GREEK SMALL LETTER THETA
      $E9: Result:= $03B9; // GREEK SMALL LETTER IOTA
      $EA: Result:= $03BA; // GREEK SMALL LETTER KAPPA
      $EB: Result:= $03BB; // GREEK SMALL LETTER LAMDA
      $EC: Result:= $03BC; // GREEK SMALL LETTER MU
      $ED: Result:= $03BD; // GREEK SMALL LETTER NU
      $EE: Result:= $03BE; // GREEK SMALL LETTER XI
      $EF: Result:= $03BF; // GREEK SMALL LETTER OMICRON
      $F0: Result:= $03C0; // GREEK SMALL LETTER PI
      $F1: Result:= $03C1; // GREEK SMALL LETTER RHO
      $F2: Result:= $03C2; // GREEK SMALL LETTER FINAL SIGMA
      $F3: Result:= $03C3; // GREEK SMALL LETTER SIGMA
      $F4: Result:= $03C4; // GREEK SMALL LETTER TAU
      $F5: Result:= $03C5; // GREEK SMALL LETTER UPSILON
      $F6: Result:= $03C6; // GREEK SMALL LETTER PHI
      $F7: Result:= $03C7; // GREEK SMALL LETTER CHI
      $F8: Result:= $03C8; // GREEK SMALL LETTER PSI
      $F9: Result:= $03C9; // GREEK SMALL LETTER OMEGA
      $FA: Result:= $03CA; // GREEK SMALL LETTER IOTA WITH DIALYTIKA
      $FB: Result:= $03CB; // GREEK SMALL LETTER UPSILON WITH DIALYTIKA
      $FC: Result:= $03CC; // GREEK SMALL LETTER OMICRON WITH TONOS
      $FD: Result:= $03CD; // GREEK SMALL LETTER UPSILON WITH TONOS
      $FE: Result:= $03CE; // GREEK SMALL LETTER OMEGA WITH TONOS
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin1254(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $83: Result:= $0192; // LATIN SMALL LETTER F WITH HOOK
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $88: Result:= $02C6; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $89: Result:= $2030; // PER MILLE SIGN
      $8A: Result:= $0160; // LATIN CAPITAL LETTER S WITH CARON
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8C: Result:= $0152; // LATIN CAPITAL LIGATURE OE
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $98: Result:= $02DC; // SMALL TILDE
      $99: Result:= $2122; // TRADE MARK SIGN
      $9A: Result:= $0161; // LATIN SMALL LETTER S WITH CARON
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9C: Result:= $0153; // LATIN SMALL LIGATURE OE
      $9F: Result:= $0178; // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $00A1; // INVERTED EXCLAMATION MARK
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $00AA; // FEMININE ORDINAL INDICATOR
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $00BA; // MASCULINE ORDINAL INDICATOR
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $BF: Result:= $00BF; // INVERTED QUESTION MARK
      $C0: Result:= $00C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $00C3; // LATIN CAPITAL LETTER A WITH TILDE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $00C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $C6: Result:= $00C6; // LATIN CAPITAL LETTER AE
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $00C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $00CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $00CC; // LATIN CAPITAL LETTER I WITH GRAVE
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $00CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $D0: Result:= $011E; // LATIN CAPITAL LETTER G WITH BREVE
      $D1: Result:= $00D1; // LATIN CAPITAL LETTER N WITH TILDE
      $D2: Result:= $00D2; // LATIN CAPITAL LETTER O WITH GRAVE
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $00D5; // LATIN CAPITAL LETTER O WITH TILDE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $00D8; // LATIN CAPITAL LETTER O WITH STROKE
      $D9: Result:= $00D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $00DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $0130; // LATIN CAPITAL LETTER I WITH DOT ABOVE
      $DE: Result:= $015E; // LATIN CAPITAL LETTER S WITH CEDILLA
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $00E0; // LATIN SMALL LETTER A WITH GRAVE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $00E3; // LATIN SMALL LETTER A WITH TILDE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $00E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $E6: Result:= $00E6; // LATIN SMALL LETTER AE
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $00E8; // LATIN SMALL LETTER E WITH GRAVE
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $00EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $00EC; // LATIN SMALL LETTER I WITH GRAVE
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $00EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $F0: Result:= $011F; // LATIN SMALL LETTER G WITH BREVE
      $F1: Result:= $00F1; // LATIN SMALL LETTER N WITH TILDE
      $F2: Result:= $00F2; // LATIN SMALL LETTER O WITH GRAVE
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $00F5; // LATIN SMALL LETTER O WITH TILDE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $00F8; // LATIN SMALL LETTER O WITH STROKE
      $F9: Result:= $00F9; // LATIN SMALL LETTER U WITH GRAVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $0131; // LATIN SMALL LETTER DOTLESS I
      $FE: Result:= $015F; // LATIN SMALL LETTER S WITH CEDILLA
      $FF: Result:= $00FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin1255(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $83: Result:= $0192; // LATIN SMALL LETTER F WITH HOOK
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $88: Result:= $02C6; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $89: Result:= $2030; // PER MILLE SIGN
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $98: Result:= $02DC; // SMALL TILDE
      $99: Result:= $2122; // TRADE MARK SIGN
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $00A1; // INVERTED EXCLAMATION MARK
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $20AA; // NEW SHEQEL SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $00D7; // MULTIPLICATION SIGN
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $00F7; // DIVISION SIGN
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $BF: Result:= $00BF; // INVERTED QUESTION MARK
      $C0: Result:= $05B0; // HEBREW POINT SHEVA
      $C1: Result:= $05B1; // HEBREW POINT HATAF SEGOL
      $C2: Result:= $05B2; // HEBREW POINT HATAF PATAH
      $C3: Result:= $05B3; // HEBREW POINT HATAF QAMATS
      $C4: Result:= $05B4; // HEBREW POINT HIRIQ
      $C5: Result:= $05B5; // HEBREW POINT TSERE
      $C6: Result:= $05B6; // HEBREW POINT SEGOL
      $C7: Result:= $05B7; // HEBREW POINT PATAH
      $C8: Result:= $05B8; // HEBREW POINT QAMATS
      $C9: Result:= $05B9; // HEBREW POINT HOLAM
      $CB: Result:= $05BB; // HEBREW POINT QUBUTS
      $CC: Result:= $05BC; // HEBREW POINT DAGESH OR MAPIQ
      $CD: Result:= $05BD; // HEBREW POINT METEG
      $CE: Result:= $05BE; // HEBREW PUNCTUATION MAQAF
      $CF: Result:= $05BF; // HEBREW POINT RAFE
      $D0: Result:= $05C0; // HEBREW PUNCTUATION PASEQ
      $D1: Result:= $05C1; // HEBREW POINT SHIN DOT
      $D2: Result:= $05C2; // HEBREW POINT SIN DOT
      $D3: Result:= $05C3; // HEBREW PUNCTUATION SOF PASUQ
      $D4: Result:= $05F0; // HEBREW LIGATURE YIDDISH DOUBLE VAV
      $D5: Result:= $05F1; // HEBREW LIGATURE YIDDISH VAV YOD
      $D6: Result:= $05F2; // HEBREW LIGATURE YIDDISH DOUBLE YOD
      $D7: Result:= $05F3; // HEBREW PUNCTUATION GERESH
      $D8: Result:= $05F4; // HEBREW PUNCTUATION GERSHAYIM
      $E0: Result:= $05D0; // HEBREW LETTER ALEF
      $E1: Result:= $05D1; // HEBREW LETTER BET
      $E2: Result:= $05D2; // HEBREW LETTER GIMEL
      $E3: Result:= $05D3; // HEBREW LETTER DALET
      $E4: Result:= $05D4; // HEBREW LETTER HE
      $E5: Result:= $05D5; // HEBREW LETTER VAV
      $E6: Result:= $05D6; // HEBREW LETTER ZAYIN
      $E7: Result:= $05D7; // HEBREW LETTER HET
      $E8: Result:= $05D8; // HEBREW LETTER TET
      $E9: Result:= $05D9; // HEBREW LETTER YOD
      $EA: Result:= $05DA; // HEBREW LETTER FINAL KAF
      $EB: Result:= $05DB; // HEBREW LETTER KAF
      $EC: Result:= $05DC; // HEBREW LETTER LAMED
      $ED: Result:= $05DD; // HEBREW LETTER FINAL MEM
      $EE: Result:= $05DE; // HEBREW LETTER MEM
      $EF: Result:= $05DF; // HEBREW LETTER FINAL NUN
      $F0: Result:= $05E0; // HEBREW LETTER NUN
      $F1: Result:= $05E1; // HEBREW LETTER SAMEKH
      $F2: Result:= $05E2; // HEBREW LETTER AYIN
      $F3: Result:= $05E3; // HEBREW LETTER FINAL PE
      $F4: Result:= $05E4; // HEBREW LETTER PE
      $F5: Result:= $05E5; // HEBREW LETTER FINAL TSADI
      $F6: Result:= $05E6; // HEBREW LETTER TSADI
      $F7: Result:= $05E7; // HEBREW LETTER QOF
      $F8: Result:= $05E8; // HEBREW LETTER RESH
      $F9: Result:= $05E9; // HEBREW LETTER SHIN
      $FA: Result:= $05EA; // HEBREW LETTER TAV
      $FD: Result:= $200E; // LEFT-TO-RIGHT MARK
      $FE: Result:= $200F; // RIGHT-TO-LEFT MARK
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin1256(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $81: Result:= $067E; // ARABIC LETTER PEH
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $83: Result:= $0192; // LATIN SMALL LETTER F WITH HOOK
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $88: Result:= $02C6; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $89: Result:= $2030; // PER MILLE SIGN
      $8A: Result:= $0679; // ARABIC LETTER TTEH
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8C: Result:= $0152; // LATIN CAPITAL LIGATURE OE
      $8D: Result:= $0686; // ARABIC LETTER TCHEH
      $8E: Result:= $0698; // ARABIC LETTER JEH
      $8F: Result:= $0688; // ARABIC LETTER DDAL
      $90: Result:= $06AF; // ARABIC LETTER GAF
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $98: Result:= $06A9; // ARABIC LETTER KEHEH
      $99: Result:= $2122; // TRADE MARK SIGN
      $9A: Result:= $0691; // ARABIC LETTER RREH
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9C: Result:= $0153; // LATIN SMALL LIGATURE OE
      $9D: Result:= $200C; // ZERO WIDTH NON-JOINER
      $9E: Result:= $200D; // ZERO WIDTH JOINER
      $9F: Result:= $06BA; // ARABIC LETTER NOON GHUNNA
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $060C; // ARABIC COMMA
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $06BE; // ARABIC LETTER HEH DOACHASHMEE
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $061B; // ARABIC SEMICOLON
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $BF: Result:= $061F; // ARABIC QUESTION MARK
      $C0: Result:= $06C1; // ARABIC LETTER HEH GOAL
      $C1: Result:= $0621; // ARABIC LETTER HAMZA
      $C2: Result:= $0622; // ARABIC LETTER ALEF WITH MADDA ABOVE
      $C3: Result:= $0623; // ARABIC LETTER ALEF WITH HAMZA ABOVE
      $C4: Result:= $0624; // ARABIC LETTER WAW WITH HAMZA ABOVE
      $C5: Result:= $0625; // ARABIC LETTER ALEF WITH HAMZA BELOW
      $C6: Result:= $0626; // ARABIC LETTER YEH WITH HAMZA ABOVE
      $C7: Result:= $0627; // ARABIC LETTER ALEF
      $C8: Result:= $0628; // ARABIC LETTER BEH
      $C9: Result:= $0629; // ARABIC LETTER TEH MARBUTA
      $CA: Result:= $062A; // ARABIC LETTER TEH
      $CB: Result:= $062B; // ARABIC LETTER THEH
      $CC: Result:= $062C; // ARABIC LETTER JEEM
      $CD: Result:= $062D; // ARABIC LETTER HAH
      $CE: Result:= $062E; // ARABIC LETTER KHAH
      $CF: Result:= $062F; // ARABIC LETTER DAL
      $D0: Result:= $0630; // ARABIC LETTER THAL
      $D1: Result:= $0631; // ARABIC LETTER REH
      $D2: Result:= $0632; // ARABIC LETTER ZAIN
      $D3: Result:= $0633; // ARABIC LETTER SEEN
      $D4: Result:= $0634; // ARABIC LETTER SHEEN
      $D5: Result:= $0635; // ARABIC LETTER SAD
      $D6: Result:= $0636; // ARABIC LETTER DAD
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $0637; // ARABIC LETTER TAH
      $D9: Result:= $0638; // ARABIC LETTER ZAH
      $DA: Result:= $0639; // ARABIC LETTER AIN
      $DB: Result:= $063A; // ARABIC LETTER GHAIN
      $DC: Result:= $0640; // ARABIC TATWEEL
      $DD: Result:= $0641; // ARABIC LETTER FEH
      $DE: Result:= $0642; // ARABIC LETTER QAF
      $DF: Result:= $0643; // ARABIC LETTER KAF
      $E0: Result:= $00E0; // LATIN SMALL LETTER A WITH GRAVE
      $E1: Result:= $0644; // ARABIC LETTER LAM
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $0645; // ARABIC LETTER MEEM
      $E4: Result:= $0646; // ARABIC LETTER NOON
      $E5: Result:= $0647; // ARABIC LETTER HEH
      $E6: Result:= $0648; // ARABIC LETTER WAW
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $00E8; // LATIN SMALL LETTER E WITH GRAVE
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $00EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $0649; // ARABIC LETTER ALEF MAKSURA
      $ED: Result:= $064A; // ARABIC LETTER YEH
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $00EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $F0: Result:= $064B; // ARABIC FATHATAN
      $F1: Result:= $064C; // ARABIC DAMMATAN
      $F2: Result:= $064D; // ARABIC KASRATAN
      $F3: Result:= $064E; // ARABIC FATHA
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $064F; // ARABIC DAMMA
      $F6: Result:= $0650; // ARABIC KASRA
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $0651; // ARABIC SHADDA
      $F9: Result:= $00F9; // LATIN SMALL LETTER U WITH GRAVE
      $FA: Result:= $0652; // ARABIC SUKUN
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $200E; // LEFT-TO-RIGHT MARK
      $FE: Result:= $200F; // RIGHT-TO-LEFT MARK
      $FF: Result:= $06D2; // ARABIC LETTER YEH BARREE
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin1257(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $89: Result:= $2030; // PER MILLE SIGN
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8D: Result:= $00A8; // DIAERESIS
      $8E: Result:= $02C7; // CARON
      $8F: Result:= $00B8; // CEDILLA
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $99: Result:= $2122; // TRADE MARK SIGN
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9D: Result:= $00AF; // MACRON
      $9E: Result:= $02DB; // OGONEK
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00D8; // LATIN CAPITAL LETTER O WITH STROKE
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $0156; // LATIN CAPITAL LETTER R WITH CEDILLA
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00C6; // LATIN CAPITAL LETTER AE
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00F8; // LATIN SMALL LETTER O WITH STROKE
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $0157; // LATIN SMALL LETTER R WITH CEDILLA
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $BF: Result:= $00E6; // LATIN SMALL LETTER AE
      $C0: Result:= $0104; // LATIN CAPITAL LETTER A WITH OGONEK
      $C1: Result:= $012E; // LATIN CAPITAL LETTER I WITH OGONEK
      $C2: Result:= $0100; // LATIN CAPITAL LETTER A WITH MACRON
      $C3: Result:= $0106; // LATIN CAPITAL LETTER C WITH ACUTE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $00C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $C6: Result:= $0118; // LATIN CAPITAL LETTER E WITH OGONEK
      $C7: Result:= $0112; // LATIN CAPITAL LETTER E WITH MACRON
      $C8: Result:= $010C; // LATIN CAPITAL LETTER C WITH CARON
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $0179; // LATIN CAPITAL LETTER Z WITH ACUTE
      $CB: Result:= $0116; // LATIN CAPITAL LETTER E WITH DOT ABOVE
      $CC: Result:= $0122; // LATIN CAPITAL LETTER G WITH CEDILLA
      $CD: Result:= $0136; // LATIN CAPITAL LETTER K WITH CEDILLA
      $CE: Result:= $012A; // LATIN CAPITAL LETTER I WITH MACRON
      $CF: Result:= $013B; // LATIN CAPITAL LETTER L WITH CEDILLA
      $D0: Result:= $0160; // LATIN CAPITAL LETTER S WITH CARON
      $D1: Result:= $0143; // LATIN CAPITAL LETTER N WITH ACUTE
      $D2: Result:= $0145; // LATIN CAPITAL LETTER N WITH CEDILLA
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $014C; // LATIN CAPITAL LETTER O WITH MACRON
      $D5: Result:= $00D5; // LATIN CAPITAL LETTER O WITH TILDE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $0172; // LATIN CAPITAL LETTER U WITH OGONEK
      $D9: Result:= $0141; // LATIN CAPITAL LETTER L WITH STROKE
      $DA: Result:= $015A; // LATIN CAPITAL LETTER S WITH ACUTE
      $DB: Result:= $016A; // LATIN CAPITAL LETTER U WITH MACRON
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $017B; // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $DE: Result:= $017D; // LATIN CAPITAL LETTER Z WITH CARON
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $0105; // LATIN SMALL LETTER A WITH OGONEK
      $E1: Result:= $012F; // LATIN SMALL LETTER I WITH OGONEK
      $E2: Result:= $0101; // LATIN SMALL LETTER A WITH MACRON
      $E3: Result:= $0107; // LATIN SMALL LETTER C WITH ACUTE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $00E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $E6: Result:= $0119; // LATIN SMALL LETTER E WITH OGONEK
      $E7: Result:= $0113; // LATIN SMALL LETTER E WITH MACRON
      $E8: Result:= $010D; // LATIN SMALL LETTER C WITH CARON
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $017A; // LATIN SMALL LETTER Z WITH ACUTE
      $EB: Result:= $0117; // LATIN SMALL LETTER E WITH DOT ABOVE
      $EC: Result:= $0123; // LATIN SMALL LETTER G WITH CEDILLA
      $ED: Result:= $0137; // LATIN SMALL LETTER K WITH CEDILLA
      $EE: Result:= $012B; // LATIN SMALL LETTER I WITH MACRON
      $EF: Result:= $013C; // LATIN SMALL LETTER L WITH CEDILLA
      $F0: Result:= $0161; // LATIN SMALL LETTER S WITH CARON
      $F1: Result:= $0144; // LATIN SMALL LETTER N WITH ACUTE
      $F2: Result:= $0146; // LATIN SMALL LETTER N WITH CEDILLA
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $014D; // LATIN SMALL LETTER O WITH MACRON
      $F5: Result:= $00F5; // LATIN SMALL LETTER O WITH TILDE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $0173; // LATIN SMALL LETTER U WITH OGONEK
      $F9: Result:= $0142; // LATIN SMALL LETTER L WITH STROKE
      $FA: Result:= $015B; // LATIN SMALL LETTER S WITH ACUTE
      $FB: Result:= $016B; // LATIN SMALL LETTER U WITH MACRON
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $017C; // LATIN SMALL LETTER Z WITH DOT ABOVE
      $FE: Result:= $017E; // LATIN SMALL LETTER Z WITH CARON
      $FF: Result:= $02D9; // DOT ABOVE
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin1258(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $82: Result:= $201A; // SINGLE LOW-9 QUOTATION MARK
      $83: Result:= $0192; // LATIN SMALL LETTER F WITH HOOK
      $84: Result:= $201E; // DOUBLE LOW-9 QUOTATION MARK
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $86: Result:= $2020; // DAGGER
      $87: Result:= $2021; // DOUBLE DAGGER
      $88: Result:= $02C6; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $89: Result:= $2030; // PER MILLE SIGN
      $8B: Result:= $2039; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $8C: Result:= $0152; // LATIN CAPITAL LIGATURE OE
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $98: Result:= $02DC; // SMALL TILDE
      $99: Result:= $2122; // TRADE MARK SIGN
      $9B: Result:= $203A; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $9C: Result:= $0153; // LATIN SMALL LIGATURE OE
      $9F: Result:= $0178; // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $00A1; // INVERTED EXCLAMATION MARK
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $00AA; // FEMININE ORDINAL INDICATOR
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $00BA; // MASCULINE ORDINAL INDICATOR
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $BF: Result:= $00BF; // INVERTED QUESTION MARK
      $C0: Result:= $00C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $0102; // LATIN CAPITAL LETTER A WITH BREVE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $00C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $C6: Result:= $00C6; // LATIN CAPITAL LETTER AE
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $00C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $00CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $0300; // COMBINING GRAVE ACCENT
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $00CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $D0: Result:= $0110; // LATIN CAPITAL LETTER D WITH STROKE
      $D1: Result:= $00D1; // LATIN CAPITAL LETTER N WITH TILDE
      $D2: Result:= $0309; // COMBINING HOOK ABOVE
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $01A0; // LATIN CAPITAL LETTER O WITH HORN
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $00D8; // LATIN CAPITAL LETTER O WITH STROKE
      $D9: Result:= $00D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $00DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $01AF; // LATIN CAPITAL LETTER U WITH HORN
      $DE: Result:= $0303; // COMBINING TILDE
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $00E0; // LATIN SMALL LETTER A WITH GRAVE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $0103; // LATIN SMALL LETTER A WITH BREVE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $00E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $E6: Result:= $00E6; // LATIN SMALL LETTER AE
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $00E8; // LATIN SMALL LETTER E WITH GRAVE
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $00EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $0301; // COMBINING ACUTE ACCENT
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $00EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $F0: Result:= $0111; // LATIN SMALL LETTER D WITH STROKE
      $F1: Result:= $00F1; // LATIN SMALL LETTER N WITH TILDE
      $F2: Result:= $0323; // COMBINING DOT BELOW
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $01A1; // LATIN SMALL LETTER O WITH HORN
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $00F8; // LATIN SMALL LETTER O WITH STROKE
      $F9: Result:= $00F9; // LATIN SMALL LETTER U WITH GRAVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $01B0; // LATIN SMALL LETTER U WITH HORN
      $FE: Result:= $20AB; // DONG SIGN
      $FF: Result:= $00FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharWin874(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < 128) then
    Result := Chr
  else
    case Chr of
      $80: Result:= $20AC; // EURO SIGN
      $85: Result:= $2026; // HORIZONTAL ELLIPSIS
      $91: Result:= $2018; // LEFT SINGLE QUOTATION MARK
      $92: Result:= $2019; // RIGHT SINGLE QUOTATION MARK
      $93: Result:= $201C; // LEFT DOUBLE QUOTATION MARK
      $94: Result:= $201D; // RIGHT DOUBLE QUOTATION MARK
      $95: Result:= $2022; // BULLET
      $96: Result:= $2013; // EN DASH
      $97: Result:= $2014; // EM DASH
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $0E01; // THAI CHARACTER KO KAI
      $A2: Result:= $0E02; // THAI CHARACTER KHO KHAI
      $A3: Result:= $0E03; // THAI CHARACTER KHO KHUAT
      $A4: Result:= $0E04; // THAI CHARACTER KHO KHWAI
      $A5: Result:= $0E05; // THAI CHARACTER KHO KHON
      $A6: Result:= $0E06; // THAI CHARACTER KHO RAKHANG
      $A7: Result:= $0E07; // THAI CHARACTER NGO NGU
      $A8: Result:= $0E08; // THAI CHARACTER CHO CHAN
      $A9: Result:= $0E09; // THAI CHARACTER CHO CHING
      $AA: Result:= $0E0A; // THAI CHARACTER CHO CHANG
      $AB: Result:= $0E0B; // THAI CHARACTER SO SO
      $AC: Result:= $0E0C; // THAI CHARACTER CHO CHOE
      $AD: Result:= $0E0D; // THAI CHARACTER YO YING
      $AE: Result:= $0E0E; // THAI CHARACTER DO CHADA
      $AF: Result:= $0E0F; // THAI CHARACTER TO PATAK
      $B0: Result:= $0E10; // THAI CHARACTER THO THAN
      $B1: Result:= $0E11; // THAI CHARACTER THO NANGMONTHO
      $B2: Result:= $0E12; // THAI CHARACTER THO PHUTHAO
      $B3: Result:= $0E13; // THAI CHARACTER NO NEN
      $B4: Result:= $0E14; // THAI CHARACTER DO DEK
      $B5: Result:= $0E15; // THAI CHARACTER TO TAO
      $B6: Result:= $0E16; // THAI CHARACTER THO THUNG
      $B7: Result:= $0E17; // THAI CHARACTER THO THAHAN
      $B8: Result:= $0E18; // THAI CHARACTER THO THONG
      $B9: Result:= $0E19; // THAI CHARACTER NO NU
      $BA: Result:= $0E1A; // THAI CHARACTER BO BAIMAI
      $BB: Result:= $0E1B; // THAI CHARACTER PO PLA
      $BC: Result:= $0E1C; // THAI CHARACTER PHO PHUNG
      $BD: Result:= $0E1D; // THAI CHARACTER FO FA
      $BE: Result:= $0E1E; // THAI CHARACTER PHO PHAN
      $BF: Result:= $0E1F; // THAI CHARACTER FO FAN
      $C0: Result:= $0E20; // THAI CHARACTER PHO SAMPHAO
      $C1: Result:= $0E21; // THAI CHARACTER MO MA
      $C2: Result:= $0E22; // THAI CHARACTER YO YAK
      $C3: Result:= $0E23; // THAI CHARACTER RO RUA
      $C4: Result:= $0E24; // THAI CHARACTER RU
      $C5: Result:= $0E25; // THAI CHARACTER LO LING
      $C6: Result:= $0E26; // THAI CHARACTER LU
      $C7: Result:= $0E27; // THAI CHARACTER WO WAEN
      $C8: Result:= $0E28; // THAI CHARACTER SO SALA
      $C9: Result:= $0E29; // THAI CHARACTER SO RUSI
      $CA: Result:= $0E2A; // THAI CHARACTER SO SUA
      $CB: Result:= $0E2B; // THAI CHARACTER HO HIP
      $CC: Result:= $0E2C; // THAI CHARACTER LO CHULA
      $CD: Result:= $0E2D; // THAI CHARACTER O ANG
      $CE: Result:= $0E2E; // THAI CHARACTER HO NOKHUK
      $CF: Result:= $0E2F; // THAI CHARACTER PAIYANNOI
      $D0: Result:= $0E30; // THAI CHARACTER SARA A
      $D1: Result:= $0E31; // THAI CHARACTER MAI HAN-AKAT
      $D2: Result:= $0E32; // THAI CHARACTER SARA AA
      $D3: Result:= $0E33; // THAI CHARACTER SARA AM
      $D4: Result:= $0E34; // THAI CHARACTER SARA I
      $D5: Result:= $0E35; // THAI CHARACTER SARA II
      $D6: Result:= $0E36; // THAI CHARACTER SARA UE
      $D7: Result:= $0E37; // THAI CHARACTER SARA UEE
      $D8: Result:= $0E38; // THAI CHARACTER SARA U
      $D9: Result:= $0E39; // THAI CHARACTER SARA UU
      $DA: Result:= $0E3A; // THAI CHARACTER PHINTHU
      $DF: Result:= $0E3F; // THAI CURRENCY SYMBOL BAHT
      $E0: Result:= $0E40; // THAI CHARACTER SARA E
      $E1: Result:= $0E41; // THAI CHARACTER SARA AE
      $E2: Result:= $0E42; // THAI CHARACTER SARA O
      $E3: Result:= $0E43; // THAI CHARACTER SARA AI MAIMUAN
      $E4: Result:= $0E44; // THAI CHARACTER SARA AI MAIMALAI
      $E5: Result:= $0E45; // THAI CHARACTER LAKKHANGYAO
      $E6: Result:= $0E46; // THAI CHARACTER MAIYAMOK
      $E7: Result:= $0E47; // THAI CHARACTER MAITAIKHU
      $E8: Result:= $0E48; // THAI CHARACTER MAI EK
      $E9: Result:= $0E49; // THAI CHARACTER MAI THO
      $EA: Result:= $0E4A; // THAI CHARACTER MAI TRI
      $EB: Result:= $0E4B; // THAI CHARACTER MAI CHATTAWA
      $EC: Result:= $0E4C; // THAI CHARACTER THANTHAKHAT
      $ED: Result:= $0E4D; // THAI CHARACTER NIKHAHIT
      $EE: Result:= $0E4E; // THAI CHARACTER YAMAKKAN
      $EF: Result:= $0E4F; // THAI CHARACTER FONGMAN
      $F0: Result:= $0E50; // THAI DIGIT ZERO
      $F1: Result:= $0E51; // THAI DIGIT ONE
      $F2: Result:= $0E52; // THAI DIGIT TWO
      $F3: Result:= $0E53; // THAI DIGIT THREE
      $F4: Result:= $0E54; // THAI DIGIT FOUR
      $F5: Result:= $0E55; // THAI DIGIT FIVE
      $F6: Result:= $0E56; // THAI DIGIT SIX
      $F7: Result:= $0E57; // THAI DIGIT SEVEN
      $F8: Result:= $0E58; // THAI DIGIT EIGHT
      $F9: Result:= $0E59; // THAI DIGIT NINE
      $FA: Result:= $0E5A; // THAI CHARACTER ANGKHANKHU
      $FB: Result:= $0E5B; // THAI CHARACTER KHOMUT
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_1(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $00A1; // INVERTED EXCLAMATION MARK
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $00AA; // FEMININE ORDINAL INDICATOR
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $00BA; // MASCULINE ORDINAL INDICATOR
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $BF: Result:= $00BF; // INVERTED QUESTION MARK
      $C0: Result:= $00C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $00C3; // LATIN CAPITAL LETTER A WITH TILDE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $00C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $C6: Result:= $00C6; // LATIN CAPITAL LETTER AE
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $00C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $00CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $00CC; // LATIN CAPITAL LETTER I WITH GRAVE
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $00CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $D0: Result:= $00D0; // LATIN CAPITAL LETTER ETH
      $D1: Result:= $00D1; // LATIN CAPITAL LETTER N WITH TILDE
      $D2: Result:= $00D2; // LATIN CAPITAL LETTER O WITH GRAVE
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $00D5; // LATIN CAPITAL LETTER O WITH TILDE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $00D8; // LATIN CAPITAL LETTER O WITH STROKE
      $D9: Result:= $00D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $00DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $00DD; // LATIN CAPITAL LETTER Y WITH ACUTE
      $DE: Result:= $00DE; // LATIN CAPITAL LETTER THORN
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $00E0; // LATIN SMALL LETTER A WITH GRAVE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $00E3; // LATIN SMALL LETTER A WITH TILDE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $00E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $E6: Result:= $00E6; // LATIN SMALL LETTER AE
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $00E8; // LATIN SMALL LETTER E WITH GRAVE
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $00EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $00EC; // LATIN SMALL LETTER I WITH GRAVE
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $00EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $F0: Result:= $00F0; // LATIN SMALL LETTER ETH
      $F1: Result:= $00F1; // LATIN SMALL LETTER N WITH TILDE
      $F2: Result:= $00F2; // LATIN SMALL LETTER O WITH GRAVE
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $00F5; // LATIN SMALL LETTER O WITH TILDE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $00F8; // LATIN SMALL LETTER O WITH STROKE
      $F9: Result:= $00F9; // LATIN SMALL LETTER U WITH GRAVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $00FD; // LATIN SMALL LETTER Y WITH ACUTE
      $FE: Result:= $00FE; // LATIN SMALL LETTER THORN
      $FF: Result:= $00FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_2(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $0104; // LATIN CAPITAL LETTER A WITH OGONEK
      $A2: Result:= $02D8; // BREVE
      $A3: Result:= $0141; // LATIN CAPITAL LETTER L WITH STROKE
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $013D; // LATIN CAPITAL LETTER L WITH CARON
      $A6: Result:= $015A; // LATIN CAPITAL LETTER S WITH ACUTE
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $0160; // LATIN CAPITAL LETTER S WITH CARON
      $AA: Result:= $015E; // LATIN CAPITAL LETTER S WITH CEDILLA
      $AB: Result:= $0164; // LATIN CAPITAL LETTER T WITH CARON
      $AC: Result:= $0179; // LATIN CAPITAL LETTER Z WITH ACUTE
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $017D; // LATIN CAPITAL LETTER Z WITH CARON
      $AF: Result:= $017B; // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $0105; // LATIN SMALL LETTER A WITH OGONEK
      $B2: Result:= $02DB; // OGONEK
      $B3: Result:= $0142; // LATIN SMALL LETTER L WITH STROKE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $013E; // LATIN SMALL LETTER L WITH CARON
      $B6: Result:= $015B; // LATIN SMALL LETTER S WITH ACUTE
      $B7: Result:= $02C7; // CARON
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $0161; // LATIN SMALL LETTER S WITH CARON
      $BA: Result:= $015F; // LATIN SMALL LETTER S WITH CEDILLA
      $BB: Result:= $0165; // LATIN SMALL LETTER T WITH CARON
      $BC: Result:= $017A; // LATIN SMALL LETTER Z WITH ACUTE
      $BD: Result:= $02DD; // DOUBLE ACUTE ACCENT
      $BE: Result:= $017E; // LATIN SMALL LETTER Z WITH CARON
      $BF: Result:= $017C; // LATIN SMALL LETTER Z WITH DOT ABOVE
      $C0: Result:= $0154; // LATIN CAPITAL LETTER R WITH ACUTE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $0102; // LATIN CAPITAL LETTER A WITH BREVE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $0139; // LATIN CAPITAL LETTER L WITH ACUTE
      $C6: Result:= $0106; // LATIN CAPITAL LETTER C WITH ACUTE
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $010C; // LATIN CAPITAL LETTER C WITH CARON
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $0118; // LATIN CAPITAL LETTER E WITH OGONEK
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $011A; // LATIN CAPITAL LETTER E WITH CARON
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $010E; // LATIN CAPITAL LETTER D WITH CARON
      $D0: Result:= $0110; // LATIN CAPITAL LETTER D WITH STROKE
      $D1: Result:= $0143; // LATIN CAPITAL LETTER N WITH ACUTE
      $D2: Result:= $0147; // LATIN CAPITAL LETTER N WITH CARON
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $0150; // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $0158; // LATIN CAPITAL LETTER R WITH CARON
      $D9: Result:= $016E; // LATIN CAPITAL LETTER U WITH RING ABOVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $0170; // LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $00DD; // LATIN CAPITAL LETTER Y WITH ACUTE
      $DE: Result:= $0162; // LATIN CAPITAL LETTER T WITH CEDILLA
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $0155; // LATIN SMALL LETTER R WITH ACUTE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $0103; // LATIN SMALL LETTER A WITH BREVE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $013A; // LATIN SMALL LETTER L WITH ACUTE
      $E6: Result:= $0107; // LATIN SMALL LETTER C WITH ACUTE
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $010D; // LATIN SMALL LETTER C WITH CARON
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $0119; // LATIN SMALL LETTER E WITH OGONEK
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $011B; // LATIN SMALL LETTER E WITH CARON
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $010F; // LATIN SMALL LETTER D WITH CARON
      $F0: Result:= $0111; // LATIN SMALL LETTER D WITH STROKE
      $F1: Result:= $0144; // LATIN SMALL LETTER N WITH ACUTE
      $F2: Result:= $0148; // LATIN SMALL LETTER N WITH CARON
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $0151; // LATIN SMALL LETTER O WITH DOUBLE ACUTE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $0159; // LATIN SMALL LETTER R WITH CARON
      $F9: Result:= $016F; // LATIN SMALL LETTER U WITH RING ABOVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $0171; // LATIN SMALL LETTER U WITH DOUBLE ACUTE
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $00FD; // LATIN SMALL LETTER Y WITH ACUTE
      $FE: Result:= $0163; // LATIN SMALL LETTER T WITH CEDILLA
      $FF: Result:= $02D9; // DOT ABOVE
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_3(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $0126; // LATIN CAPITAL LETTER H WITH STROKE
      $A2: Result:= $02D8; // BREVE
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A6: Result:= $0124; // LATIN CAPITAL LETTER H WITH CIRCUMFLEX
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $0130; // LATIN CAPITAL LETTER I WITH DOT ABOVE
      $AA: Result:= $015E; // LATIN CAPITAL LETTER S WITH CEDILLA
      $AB: Result:= $011E; // LATIN CAPITAL LETTER G WITH BREVE
      $AC: Result:= $0134; // LATIN CAPITAL LETTER J WITH CIRCUMFLEX
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AF: Result:= $017B; // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $0127; // LATIN SMALL LETTER H WITH STROKE
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $0125; // LATIN SMALL LETTER H WITH CIRCUMFLEX
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $0131; // LATIN SMALL LETTER DOTLESS I
      $BA: Result:= $015F; // LATIN SMALL LETTER S WITH CEDILLA
      $BB: Result:= $011F; // LATIN SMALL LETTER G WITH BREVE
      $BC: Result:= $0135; // LATIN SMALL LETTER J WITH CIRCUMFLEX
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BF: Result:= $017C; // LATIN SMALL LETTER Z WITH DOT ABOVE
      $C0: Result:= $00C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $010A; // LATIN CAPITAL LETTER C WITH DOT ABOVE
      $C6: Result:= $0108; // LATIN CAPITAL LETTER C WITH CIRCUMFLEX
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $00C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $00CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $00CC; // LATIN CAPITAL LETTER I WITH GRAVE
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $00CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $D1: Result:= $00D1; // LATIN CAPITAL LETTER N WITH TILDE
      $D2: Result:= $00D2; // LATIN CAPITAL LETTER O WITH GRAVE
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $0120; // LATIN CAPITAL LETTER G WITH DOT ABOVE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $011C; // LATIN CAPITAL LETTER G WITH CIRCUMFLEX
      $D9: Result:= $00D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $00DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $016C; // LATIN CAPITAL LETTER U WITH BREVE
      $DE: Result:= $015C; // LATIN CAPITAL LETTER S WITH CIRCUMFLEX
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $00E0; // LATIN SMALL LETTER A WITH GRAVE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $010B; // LATIN SMALL LETTER C WITH DOT ABOVE
      $E6: Result:= $0109; // LATIN SMALL LETTER C WITH CIRCUMFLEX
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $00E8; // LATIN SMALL LETTER E WITH GRAVE
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $00EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $00EC; // LATIN SMALL LETTER I WITH GRAVE
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $00EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $F1: Result:= $00F1; // LATIN SMALL LETTER N WITH TILDE
      $F2: Result:= $00F2; // LATIN SMALL LETTER O WITH GRAVE
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $0121; // LATIN SMALL LETTER G WITH DOT ABOVE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $011D; // LATIN SMALL LETTER G WITH CIRCUMFLEX
      $F9: Result:= $00F9; // LATIN SMALL LETTER U WITH GRAVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $016D; // LATIN SMALL LETTER U WITH BREVE
      $FE: Result:= $015D; // LATIN SMALL LETTER S WITH CIRCUMFLEX
      $FF: Result:= $02D9; // DOT ABOVE
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_4(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $0104; // LATIN CAPITAL LETTER A WITH OGONEK
      $A2: Result:= $0138; // LATIN SMALL LETTER KRA
      $A3: Result:= $0156; // LATIN CAPITAL LETTER R WITH CEDILLA
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $0128; // LATIN CAPITAL LETTER I WITH TILDE
      $A6: Result:= $013B; // LATIN CAPITAL LETTER L WITH CEDILLA
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $0160; // LATIN CAPITAL LETTER S WITH CARON
      $AA: Result:= $0112; // LATIN CAPITAL LETTER E WITH MACRON
      $AB: Result:= $0122; // LATIN CAPITAL LETTER G WITH CEDILLA
      $AC: Result:= $0166; // LATIN CAPITAL LETTER T WITH STROKE
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $017D; // LATIN CAPITAL LETTER Z WITH CARON
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $0105; // LATIN SMALL LETTER A WITH OGONEK
      $B2: Result:= $02DB; // OGONEK
      $B3: Result:= $0157; // LATIN SMALL LETTER R WITH CEDILLA
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $0129; // LATIN SMALL LETTER I WITH TILDE
      $B6: Result:= $013C; // LATIN SMALL LETTER L WITH CEDILLA
      $B7: Result:= $02C7; // CARON
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $0161; // LATIN SMALL LETTER S WITH CARON
      $BA: Result:= $0113; // LATIN SMALL LETTER E WITH MACRON
      $BB: Result:= $0123; // LATIN SMALL LETTER G WITH CEDILLA
      $BC: Result:= $0167; // LATIN SMALL LETTER T WITH STROKE
      $BD: Result:= $014A; // LATIN CAPITAL LETTER ENG
      $BE: Result:= $017E; // LATIN SMALL LETTER Z WITH CARON
      $BF: Result:= $014B; // LATIN SMALL LETTER ENG
      $C0: Result:= $0100; // LATIN CAPITAL LETTER A WITH MACRON
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $00C3; // LATIN CAPITAL LETTER A WITH TILDE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $00C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $C6: Result:= $00C6; // LATIN CAPITAL LETTER AE
      $C7: Result:= $012E; // LATIN CAPITAL LETTER I WITH OGONEK
      $C8: Result:= $010C; // LATIN CAPITAL LETTER C WITH CARON
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $0118; // LATIN CAPITAL LETTER E WITH OGONEK
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $0116; // LATIN CAPITAL LETTER E WITH DOT ABOVE
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $012A; // LATIN CAPITAL LETTER I WITH MACRON
      $D0: Result:= $0110; // LATIN CAPITAL LETTER D WITH STROKE
      $D1: Result:= $0145; // LATIN CAPITAL LETTER N WITH CEDILLA
      $D2: Result:= $014C; // LATIN CAPITAL LETTER O WITH MACRON
      $D3: Result:= $0136; // LATIN CAPITAL LETTER K WITH CEDILLA
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $00D5; // LATIN CAPITAL LETTER O WITH TILDE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $00D8; // LATIN CAPITAL LETTER O WITH STROKE
      $D9: Result:= $0172; // LATIN CAPITAL LETTER U WITH OGONEK
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $00DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $0168; // LATIN CAPITAL LETTER U WITH TILDE
      $DE: Result:= $016A; // LATIN CAPITAL LETTER U WITH MACRON
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $0101; // LATIN SMALL LETTER A WITH MACRON
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $00E3; // LATIN SMALL LETTER A WITH TILDE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $00E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $E6: Result:= $00E6; // LATIN SMALL LETTER AE
      $E7: Result:= $012F; // LATIN SMALL LETTER I WITH OGONEK
      $E8: Result:= $010D; // LATIN SMALL LETTER C WITH CARON
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $0119; // LATIN SMALL LETTER E WITH OGONEK
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $0117; // LATIN SMALL LETTER E WITH DOT ABOVE
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $012B; // LATIN SMALL LETTER I WITH MACRON
      $F0: Result:= $0111; // LATIN SMALL LETTER D WITH STROKE
      $F1: Result:= $0146; // LATIN SMALL LETTER N WITH CEDILLA
      $F2: Result:= $014D; // LATIN SMALL LETTER O WITH MACRON
      $F3: Result:= $0137; // LATIN SMALL LETTER K WITH CEDILLA
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $00F5; // LATIN SMALL LETTER O WITH TILDE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $00F8; // LATIN SMALL LETTER O WITH STROKE
      $F9: Result:= $0173; // LATIN SMALL LETTER U WITH OGONEK
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $0169; // LATIN SMALL LETTER U WITH TILDE
      $FE: Result:= $016B; // LATIN SMALL LETTER U WITH MACRON
      $FF: Result:= $02D9; // DOT ABOVE
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_5(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $0401; // CYRILLIC CAPITAL LETTER IO
      $A2: Result:= $0402; // CYRILLIC CAPITAL LETTER DJE
      $A3: Result:= $0403; // CYRILLIC CAPITAL LETTER GJE
      $A4: Result:= $0404; // CYRILLIC CAPITAL LETTER UKRAINIAN IE
      $A5: Result:= $0405; // CYRILLIC CAPITAL LETTER DZE
      $A6: Result:= $0406; // CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
      $A7: Result:= $0407; // CYRILLIC CAPITAL LETTER YI
      $A8: Result:= $0408; // CYRILLIC CAPITAL LETTER JE
      $A9: Result:= $0409; // CYRILLIC CAPITAL LETTER LJE
      $AA: Result:= $040A; // CYRILLIC CAPITAL LETTER NJE
      $AB: Result:= $040B; // CYRILLIC CAPITAL LETTER TSHE
      $AC: Result:= $040C; // CYRILLIC CAPITAL LETTER KJE
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $040E; // CYRILLIC CAPITAL LETTER SHORT U
      $AF: Result:= $040F; // CYRILLIC CAPITAL LETTER DZHE
      $B0: Result:= $0410; // CYRILLIC CAPITAL LETTER A
      $B1: Result:= $0411; // CYRILLIC CAPITAL LETTER BE
      $B2: Result:= $0412; // CYRILLIC CAPITAL LETTER VE
      $B3: Result:= $0413; // CYRILLIC CAPITAL LETTER GHE
      $B4: Result:= $0414; // CYRILLIC CAPITAL LETTER DE
      $B5: Result:= $0415; // CYRILLIC CAPITAL LETTER IE
      $B6: Result:= $0416; // CYRILLIC CAPITAL LETTER ZHE
      $B7: Result:= $0417; // CYRILLIC CAPITAL LETTER ZE
      $B8: Result:= $0418; // CYRILLIC CAPITAL LETTER I
      $B9: Result:= $0419; // CYRILLIC CAPITAL LETTER SHORT I
      $BA: Result:= $041A; // CYRILLIC CAPITAL LETTER KA
      $BB: Result:= $041B; // CYRILLIC CAPITAL LETTER EL
      $BC: Result:= $041C; // CYRILLIC CAPITAL LETTER EM
      $BD: Result:= $041D; // CYRILLIC CAPITAL LETTER EN
      $BE: Result:= $041E; // CYRILLIC CAPITAL LETTER O
      $BF: Result:= $041F; // CYRILLIC CAPITAL LETTER PE
      $C0: Result:= $0420; // CYRILLIC CAPITAL LETTER ER
      $C1: Result:= $0421; // CYRILLIC CAPITAL LETTER ES
      $C2: Result:= $0422; // CYRILLIC CAPITAL LETTER TE
      $C3: Result:= $0423; // CYRILLIC CAPITAL LETTER U
      $C4: Result:= $0424; // CYRILLIC CAPITAL LETTER EF
      $C5: Result:= $0425; // CYRILLIC CAPITAL LETTER HA
      $C6: Result:= $0426; // CYRILLIC CAPITAL LETTER TSE
      $C7: Result:= $0427; // CYRILLIC CAPITAL LETTER CHE
      $C8: Result:= $0428; // CYRILLIC CAPITAL LETTER SHA
      $C9: Result:= $0429; // CYRILLIC CAPITAL LETTER SHCHA
      $CA: Result:= $042A; // CYRILLIC CAPITAL LETTER HARD SIGN
      $CB: Result:= $042B; // CYRILLIC CAPITAL LETTER YERU
      $CC: Result:= $042C; // CYRILLIC CAPITAL LETTER SOFT SIGN
      $CD: Result:= $042D; // CYRILLIC CAPITAL LETTER E
      $CE: Result:= $042E; // CYRILLIC CAPITAL LETTER YU
      $CF: Result:= $042F; // CYRILLIC CAPITAL LETTER YA
      $D0: Result:= $0430; // CYRILLIC SMALL LETTER A
      $D1: Result:= $0431; // CYRILLIC SMALL LETTER BE
      $D2: Result:= $0432; // CYRILLIC SMALL LETTER VE
      $D3: Result:= $0433; // CYRILLIC SMALL LETTER GHE
      $D4: Result:= $0434; // CYRILLIC SMALL LETTER DE
      $D5: Result:= $0435; // CYRILLIC SMALL LETTER IE
      $D6: Result:= $0436; // CYRILLIC SMALL LETTER ZHE
      $D7: Result:= $0437; // CYRILLIC SMALL LETTER ZE
      $D8: Result:= $0438; // CYRILLIC SMALL LETTER I
      $D9: Result:= $0439; // CYRILLIC SMALL LETTER SHORT I
      $DA: Result:= $043A; // CYRILLIC SMALL LETTER KA
      $DB: Result:= $043B; // CYRILLIC SMALL LETTER EL
      $DC: Result:= $043C; // CYRILLIC SMALL LETTER EM
      $DD: Result:= $043D; // CYRILLIC SMALL LETTER EN
      $DE: Result:= $043E; // CYRILLIC SMALL LETTER O
      $DF: Result:= $043F; // CYRILLIC SMALL LETTER PE
      $E0: Result:= $0440; // CYRILLIC SMALL LETTER ER
      $E1: Result:= $0441; // CYRILLIC SMALL LETTER ES
      $E2: Result:= $0442; // CYRILLIC SMALL LETTER TE
      $E3: Result:= $0443; // CYRILLIC SMALL LETTER U
      $E4: Result:= $0444; // CYRILLIC SMALL LETTER EF
      $E5: Result:= $0445; // CYRILLIC SMALL LETTER HA
      $E6: Result:= $0446; // CYRILLIC SMALL LETTER TSE
      $E7: Result:= $0447; // CYRILLIC SMALL LETTER CHE
      $E8: Result:= $0448; // CYRILLIC SMALL LETTER SHA
      $E9: Result:= $0449; // CYRILLIC SMALL LETTER SHCHA
      $EA: Result:= $044A; // CYRILLIC SMALL LETTER HARD SIGN
      $EB: Result:= $044B; // CYRILLIC SMALL LETTER YERU
      $EC: Result:= $044C; // CYRILLIC SMALL LETTER SOFT SIGN
      $ED: Result:= $044D; // CYRILLIC SMALL LETTER E
      $EE: Result:= $044E; // CYRILLIC SMALL LETTER YU
      $EF: Result:= $044F; // CYRILLIC SMALL LETTER YA
      $F0: Result:= $2116; // NUMERO SIGN
      $F1: Result:= $0451; // CYRILLIC SMALL LETTER IO
      $F2: Result:= $0452; // CYRILLIC SMALL LETTER DJE
      $F3: Result:= $0453; // CYRILLIC SMALL LETTER GJE
      $F4: Result:= $0454; // CYRILLIC SMALL LETTER UKRAINIAN IE
      $F5: Result:= $0455; // CYRILLIC SMALL LETTER DZE
      $F6: Result:= $0456; // CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
      $F7: Result:= $0457; // CYRILLIC SMALL LETTER YI
      $F8: Result:= $0458; // CYRILLIC SMALL LETTER JE
      $F9: Result:= $0459; // CYRILLIC SMALL LETTER LJE
      $FA: Result:= $045A; // CYRILLIC SMALL LETTER NJE
      $FB: Result:= $045B; // CYRILLIC SMALL LETTER TSHE
      $FC: Result:= $045C; // CYRILLIC SMALL LETTER KJE
      $FD: Result:= $00A7; // SECTION SIGN
      $FE: Result:= $045E; // CYRILLIC SMALL LETTER SHORT U
      $FF: Result:= $045F; // CYRILLIC SMALL LETTER DZHE
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_6(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A4: Result:= $00A4; // CURRENCY SIGN
      $AC: Result:= $060C; // ARABIC COMMA
      $AD: Result:= $00AD; // SOFT HYPHEN
      $BB: Result:= $061B; // ARABIC SEMICOLON
      $BF: Result:= $061F; // ARABIC QUESTION MARK
      $C1: Result:= $0621; // ARABIC LETTER HAMZA
      $C2: Result:= $0622; // ARABIC LETTER ALEF WITH MADDA ABOVE
      $C3: Result:= $0623; // ARABIC LETTER ALEF WITH HAMZA ABOVE
      $C4: Result:= $0624; // ARABIC LETTER WAW WITH HAMZA ABOVE
      $C5: Result:= $0625; // ARABIC LETTER ALEF WITH HAMZA BELOW
      $C6: Result:= $0626; // ARABIC LETTER YEH WITH HAMZA ABOVE
      $C7: Result:= $0627; // ARABIC LETTER ALEF
      $C8: Result:= $0628; // ARABIC LETTER BEH
      $C9: Result:= $0629; // ARABIC LETTER TEH MARBUTA
      $CA: Result:= $062A; // ARABIC LETTER TEH
      $CB: Result:= $062B; // ARABIC LETTER THEH
      $CC: Result:= $062C; // ARABIC LETTER JEEM
      $CD: Result:= $062D; // ARABIC LETTER HAH
      $CE: Result:= $062E; // ARABIC LETTER KHAH
      $CF: Result:= $062F; // ARABIC LETTER DAL
      $D0: Result:= $0630; // ARABIC LETTER THAL
      $D1: Result:= $0631; // ARABIC LETTER REH
      $D2: Result:= $0632; // ARABIC LETTER ZAIN
      $D3: Result:= $0633; // ARABIC LETTER SEEN
      $D4: Result:= $0634; // ARABIC LETTER SHEEN
      $D5: Result:= $0635; // ARABIC LETTER SAD
      $D6: Result:= $0636; // ARABIC LETTER DAD
      $D7: Result:= $0637; // ARABIC LETTER TAH
      $D8: Result:= $0638; // ARABIC LETTER ZAH
      $D9: Result:= $0639; // ARABIC LETTER AIN
      $DA: Result:= $063A; // ARABIC LETTER GHAIN
      $E0: Result:= $0640; // ARABIC TATWEEL
      $E1: Result:= $0641; // ARABIC LETTER FEH
      $E2: Result:= $0642; // ARABIC LETTER QAF
      $E3: Result:= $0643; // ARABIC LETTER KAF
      $E4: Result:= $0644; // ARABIC LETTER LAM
      $E5: Result:= $0645; // ARABIC LETTER MEEM
      $E6: Result:= $0646; // ARABIC LETTER NOON
      $E7: Result:= $0647; // ARABIC LETTER HEH
      $E8: Result:= $0648; // ARABIC LETTER WAW
      $E9: Result:= $0649; // ARABIC LETTER ALEF MAKSURA
      $EA: Result:= $064A; // ARABIC LETTER YEH
      $EB: Result:= $064B; // ARABIC FATHATAN
      $EC: Result:= $064C; // ARABIC DAMMATAN
      $ED: Result:= $064D; // ARABIC KASRATAN
      $EE: Result:= $064E; // ARABIC FATHA
      $EF: Result:= $064F; // ARABIC DAMMA
      $F0: Result:= $0650; // ARABIC KASRA
      $F1: Result:= $0651; // ARABIC SHADDA
      $F2: Result:= $0652; // ARABIC SUKUN
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_7(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $02BD; // MODIFIER LETTER REVERSED COMMA
      $A2: Result:= $02BC; // MODIFIER LETTER APOSTROPHE
      $A3: Result:= $00A3; // POUND SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AF: Result:= $2015; // HORIZONTAL BAR
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $0384; // GREEK TONOS
      $B5: Result:= $0385; // GREEK DIALYTIKA TONOS
      $B6: Result:= $0386; // GREEK CAPITAL LETTER ALPHA WITH TONOS
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $0388; // GREEK CAPITAL LETTER EPSILON WITH TONOS
      $B9: Result:= $0389; // GREEK CAPITAL LETTER ETA WITH TONOS
      $BA: Result:= $038A; // GREEK CAPITAL LETTER IOTA WITH TONOS
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $038C; // GREEK CAPITAL LETTER OMICRON WITH TONOS
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $038E; // GREEK CAPITAL LETTER UPSILON WITH TONOS
      $BF: Result:= $038F; // GREEK CAPITAL LETTER OMEGA WITH TONOS
      $C0: Result:= $0390; // GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS
      $C1: Result:= $0391; // GREEK CAPITAL LETTER ALPHA
      $C2: Result:= $0392; // GREEK CAPITAL LETTER BETA
      $C3: Result:= $0393; // GREEK CAPITAL LETTER GAMMA
      $C4: Result:= $0394; // GREEK CAPITAL LETTER DELTA
      $C5: Result:= $0395; // GREEK CAPITAL LETTER EPSILON
      $C6: Result:= $0396; // GREEK CAPITAL LETTER ZETA
      $C7: Result:= $0397; // GREEK CAPITAL LETTER ETA
      $C8: Result:= $0398; // GREEK CAPITAL LETTER THETA
      $C9: Result:= $0399; // GREEK CAPITAL LETTER IOTA
      $CA: Result:= $039A; // GREEK CAPITAL LETTER KAPPA
      $CB: Result:= $039B; // GREEK CAPITAL LETTER LAMDA
      $CC: Result:= $039C; // GREEK CAPITAL LETTER MU
      $CD: Result:= $039D; // GREEK CAPITAL LETTER NU
      $CE: Result:= $039E; // GREEK CAPITAL LETTER XI
      $CF: Result:= $039F; // GREEK CAPITAL LETTER OMICRON
      $D0: Result:= $03A0; // GREEK CAPITAL LETTER PI
      $D1: Result:= $03A1; // GREEK CAPITAL LETTER RHO
      $D3: Result:= $03A3; // GREEK CAPITAL LETTER SIGMA
      $D4: Result:= $03A4; // GREEK CAPITAL LETTER TAU
      $D5: Result:= $03A5; // GREEK CAPITAL LETTER UPSILON
      $D6: Result:= $03A6; // GREEK CAPITAL LETTER PHI
      $D7: Result:= $03A7; // GREEK CAPITAL LETTER CHI
      $D8: Result:= $03A8; // GREEK CAPITAL LETTER PSI
      $D9: Result:= $03A9; // GREEK CAPITAL LETTER OMEGA
      $DA: Result:= $03AA; // GREEK CAPITAL LETTER IOTA WITH DIALYTIKA
      $DB: Result:= $03AB; // GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA
      $DC: Result:= $03AC; // GREEK SMALL LETTER ALPHA WITH TONOS
      $DD: Result:= $03AD; // GREEK SMALL LETTER EPSILON WITH TONOS
      $DE: Result:= $03AE; // GREEK SMALL LETTER ETA WITH TONOS
      $DF: Result:= $03AF; // GREEK SMALL LETTER IOTA WITH TONOS
      $E0: Result:= $03B0; // GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS
      $E1: Result:= $03B1; // GREEK SMALL LETTER ALPHA
      $E2: Result:= $03B2; // GREEK SMALL LETTER BETA
      $E3: Result:= $03B3; // GREEK SMALL LETTER GAMMA
      $E4: Result:= $03B4; // GREEK SMALL LETTER DELTA
      $E5: Result:= $03B5; // GREEK SMALL LETTER EPSILON
      $E6: Result:= $03B6; // GREEK SMALL LETTER ZETA
      $E7: Result:= $03B7; // GREEK SMALL LETTER ETA
      $E8: Result:= $03B8; // GREEK SMALL LETTER THETA
      $E9: Result:= $03B9; // GREEK SMALL LETTER IOTA
      $EA: Result:= $03BA; // GREEK SMALL LETTER KAPPA
      $EB: Result:= $03BB; // GREEK SMALL LETTER LAMDA
      $EC: Result:= $03BC; // GREEK SMALL LETTER MU
      $ED: Result:= $03BD; // GREEK SMALL LETTER NU
      $EE: Result:= $03BE; // GREEK SMALL LETTER XI
      $EF: Result:= $03BF; // GREEK SMALL LETTER OMICRON
      $F0: Result:= $03C0; // GREEK SMALL LETTER PI
      $F1: Result:= $03C1; // GREEK SMALL LETTER RHO
      $F2: Result:= $03C2; // GREEK SMALL LETTER FINAL SIGMA
      $F3: Result:= $03C3; // GREEK SMALL LETTER SIGMA
      $F4: Result:= $03C4; // GREEK SMALL LETTER TAU
      $F5: Result:= $03C5; // GREEK SMALL LETTER UPSILON
      $F6: Result:= $03C6; // GREEK SMALL LETTER PHI
      $F7: Result:= $03C7; // GREEK SMALL LETTER CHI
      $F8: Result:= $03C8; // GREEK SMALL LETTER PSI
      $F9: Result:= $03C9; // GREEK SMALL LETTER OMEGA
      $FA: Result:= $03CA; // GREEK SMALL LETTER IOTA WITH DIALYTIKA
      $FB: Result:= $03CB; // GREEK SMALL LETTER UPSILON WITH DIALYTIKA
      $FC: Result:= $03CC; // GREEK SMALL LETTER OMICRON WITH TONOS
      $FD: Result:= $03CD; // GREEK SMALL LETTER UPSILON WITH TONOS
      $FE: Result:= $03CE; // GREEK SMALL LETTER OMEGA WITH TONOS
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_8(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $00D7; // MULTIPLICATION SIGN
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $203E; // OVERLINE
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $00F7; // DIVISION SIGN
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $DF: Result:= $2017; // DOUBLE LOW LINE
      $E0: Result:= $05D0; // HEBREW LETTER ALEF
      $E1: Result:= $05D1; // HEBREW LETTER BET
      $E2: Result:= $05D2; // HEBREW LETTER GIMEL
      $E3: Result:= $05D3; // HEBREW LETTER DALET
      $E4: Result:= $05D4; // HEBREW LETTER HE
      $E5: Result:= $05D5; // HEBREW LETTER VAV
      $E6: Result:= $05D6; // HEBREW LETTER ZAYIN
      $E7: Result:= $05D7; // HEBREW LETTER HET
      $E8: Result:= $05D8; // HEBREW LETTER TET
      $E9: Result:= $05D9; // HEBREW LETTER YOD
      $EA: Result:= $05DA; // HEBREW LETTER FINAL KAF
      $EB: Result:= $05DB; // HEBREW LETTER KAF
      $EC: Result:= $05DC; // HEBREW LETTER LAMED
      $ED: Result:= $05DD; // HEBREW LETTER FINAL MEM
      $EE: Result:= $05DE; // HEBREW LETTER MEM
      $EF: Result:= $05DF; // HEBREW LETTER FINAL NUN
      $F0: Result:= $05E0; // HEBREW LETTER NUN
      $F1: Result:= $05E1; // HEBREW LETTER SAMEKH
      $F2: Result:= $05E2; // HEBREW LETTER AYIN
      $F3: Result:= $05E3; // HEBREW LETTER FINAL PE
      $F4: Result:= $05E4; // HEBREW LETTER PE
      $F5: Result:= $05E5; // HEBREW LETTER FINAL TSADI
      $F6: Result:= $05E6; // HEBREW LETTER TSADI
      $F7: Result:= $05E7; // HEBREW LETTER QOF
      $F8: Result:= $05E8; // HEBREW LETTER RESH
      $F9: Result:= $05E9; // HEBREW LETTER SHIN
      $FA: Result:= $05EA; // HEBREW LETTER TAV
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_9(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $00A1; // INVERTED EXCLAMATION MARK
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $00A4; // CURRENCY SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $00A6; // BROKEN BAR
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $00A8; // DIAERESIS
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $00AA; // FEMININE ORDINAL INDICATOR
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $00B4; // ACUTE ACCENT
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $00B8; // CEDILLA
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $00BA; // MASCULINE ORDINAL INDICATOR
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $00BC; // VULGAR FRACTION ONE QUARTER
      $BD: Result:= $00BD; // VULGAR FRACTION ONE HALF
      $BE: Result:= $00BE; // VULGAR FRACTION THREE QUARTERS
      $BF: Result:= $00BF; // INVERTED QUESTION MARK
      $C0: Result:= $00C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $00C3; // LATIN CAPITAL LETTER A WITH TILDE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $00C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $C6: Result:= $00C6; // LATIN CAPITAL LETTER AE
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $00C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $00CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $00CC; // LATIN CAPITAL LETTER I WITH GRAVE
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $00CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $D0: Result:= $011E; // LATIN CAPITAL LETTER G WITH BREVE
      $D1: Result:= $00D1; // LATIN CAPITAL LETTER N WITH TILDE
      $D2: Result:= $00D2; // LATIN CAPITAL LETTER O WITH GRAVE
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $00D5; // LATIN CAPITAL LETTER O WITH TILDE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $00D8; // LATIN CAPITAL LETTER O WITH STROKE
      $D9: Result:= $00D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $00DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $0130; // LATIN CAPITAL LETTER I WITH DOT ABOVE
      $DE: Result:= $015E; // LATIN CAPITAL LETTER S WITH CEDILLA
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $00E0; // LATIN SMALL LETTER A WITH GRAVE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $00E3; // LATIN SMALL LETTER A WITH TILDE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $00E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $E6: Result:= $00E6; // LATIN SMALL LETTER AE
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $00E8; // LATIN SMALL LETTER E WITH GRAVE
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $00EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $00EC; // LATIN SMALL LETTER I WITH GRAVE
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $00EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $F0: Result:= $011F; // LATIN SMALL LETTER G WITH BREVE
      $F1: Result:= $00F1; // LATIN SMALL LETTER N WITH TILDE
      $F2: Result:= $00F2; // LATIN SMALL LETTER O WITH GRAVE
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $00F5; // LATIN SMALL LETTER O WITH TILDE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $00F8; // LATIN SMALL LETTER O WITH STROKE
      $F9: Result:= $00F9; // LATIN SMALL LETTER U WITH GRAVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $0131; // LATIN SMALL LETTER DOTLESS I
      $FE: Result:= $015F; // LATIN SMALL LETTER S WITH CEDILLA
      $FF: Result:= $00FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result:=Chr;
    end;
{$ENDIF}
  end;

function RtcAnsiToUnicodeCharISO8859_15(Chr: Byte): Word;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Chr;
{$ELSE}
  if (Chr < $A0) then
    Result := Chr
  else
    case Chr of
      $A0: Result:= $00A0; // NO-BREAK SPACE
      $A1: Result:= $00A1; // INVERTED EXCLAMATION MARK
      $A2: Result:= $00A2; // CENT SIGN
      $A3: Result:= $00A3; // POUND SIGN
      $A4: Result:= $20AC; // EURO SIGN
      $A5: Result:= $00A5; // YEN SIGN
      $A6: Result:= $0160; // LATIN CAPITAL LETTER S WITH CARON
      $A7: Result:= $00A7; // SECTION SIGN
      $A8: Result:= $0161; // LATIN SMALL LETTER S WITH CARON
      $A9: Result:= $00A9; // COPYRIGHT SIGN
      $AA: Result:= $00AA; // FEMININE ORDINAL INDICATOR
      $AB: Result:= $00AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $AC: Result:= $00AC; // NOT SIGN
      $AD: Result:= $00AD; // SOFT HYPHEN
      $AE: Result:= $00AE; // REGISTERED SIGN
      $AF: Result:= $00AF; // MACRON
      $B0: Result:= $00B0; // DEGREE SIGN
      $B1: Result:= $00B1; // PLUS-MINUS SIGN
      $B2: Result:= $00B2; // SUPERSCRIPT TWO
      $B3: Result:= $00B3; // SUPERSCRIPT THREE
      $B4: Result:= $017D; // LATIN CAPITAL LETTER Z WITH CARON
      $B5: Result:= $00B5; // MICRO SIGN
      $B6: Result:= $00B6; // PILCROW SIGN
      $B7: Result:= $00B7; // MIDDLE DOT
      $B8: Result:= $017E; // LATIN SMALL LETTER Z WITH CARON
      $B9: Result:= $00B9; // SUPERSCRIPT ONE
      $BA: Result:= $00BA; // MASCULINE ORDINAL INDICATOR
      $BB: Result:= $00BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $BC: Result:= $0152; // LATIN CAPITAL LIGATURE OE
      $BD: Result:= $0153; // LATIN SMALL LIGATURE OE
      $BE: Result:= $0178; // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $BF: Result:= $00BF; // INVERTED QUESTION MARK
      $C0: Result:= $00C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $C1: Result:= $00C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $C2: Result:= $00C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $C3: Result:= $00C3; // LATIN CAPITAL LETTER A WITH TILDE
      $C4: Result:= $00C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $C5: Result:= $00C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $C6: Result:= $00C6; // LATIN CAPITAL LETTER AE
      $C7: Result:= $00C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $C8: Result:= $00C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $C9: Result:= $00C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $CA: Result:= $00CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $CB: Result:= $00CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $CC: Result:= $00CC; // LATIN CAPITAL LETTER I WITH GRAVE
      $CD: Result:= $00CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $CE: Result:= $00CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $CF: Result:= $00CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $D0: Result:= $00D0; // LATIN CAPITAL LETTER ETH
      $D1: Result:= $00D1; // LATIN CAPITAL LETTER N WITH TILDE
      $D2: Result:= $00D2; // LATIN CAPITAL LETTER O WITH GRAVE
      $D3: Result:= $00D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $D4: Result:= $00D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $D5: Result:= $00D5; // LATIN CAPITAL LETTER O WITH TILDE
      $D6: Result:= $00D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $D7: Result:= $00D7; // MULTIPLICATION SIGN
      $D8: Result:= $00D8; // LATIN CAPITAL LETTER O WITH STROKE
      $D9: Result:= $00D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $DA: Result:= $00DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $DB: Result:= $00DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $DC: Result:= $00DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $DD: Result:= $00DD; // LATIN CAPITAL LETTER Y WITH ACUTE
      $DE: Result:= $00DE; // LATIN CAPITAL LETTER THORN
      $DF: Result:= $00DF; // LATIN SMALL LETTER SHARP S
      $E0: Result:= $00E0; // LATIN SMALL LETTER A WITH GRAVE
      $E1: Result:= $00E1; // LATIN SMALL LETTER A WITH ACUTE
      $E2: Result:= $00E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $E3: Result:= $00E3; // LATIN SMALL LETTER A WITH TILDE
      $E4: Result:= $00E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $E5: Result:= $00E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $E6: Result:= $00E6; // LATIN SMALL LETTER AE
      $E7: Result:= $00E7; // LATIN SMALL LETTER C WITH CEDILLA
      $E8: Result:= $00E8; // LATIN SMALL LETTER E WITH GRAVE
      $E9: Result:= $00E9; // LATIN SMALL LETTER E WITH ACUTE
      $EA: Result:= $00EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $EB: Result:= $00EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $EC: Result:= $00EC; // LATIN SMALL LETTER I WITH GRAVE
      $ED: Result:= $00ED; // LATIN SMALL LETTER I WITH ACUTE
      $EE: Result:= $00EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $EF: Result:= $00EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $F0: Result:= $00F0; // LATIN SMALL LETTER ETH
      $F1: Result:= $00F1; // LATIN SMALL LETTER N WITH TILDE
      $F2: Result:= $00F2; // LATIN SMALL LETTER O WITH GRAVE
      $F3: Result:= $00F3; // LATIN SMALL LETTER O WITH ACUTE
      $F4: Result:= $00F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $F5: Result:= $00F5; // LATIN SMALL LETTER O WITH TILDE
      $F6: Result:= $00F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $F7: Result:= $00F7; // DIVISION SIGN
      $F8: Result:= $00F8; // LATIN SMALL LETTER O WITH STROKE
      $F9: Result:= $00F9; // LATIN SMALL LETTER U WITH GRAVE
      $FA: Result:= $00FA; // LATIN SMALL LETTER U WITH ACUTE
      $FB: Result:= $00FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $FC: Result:= $00FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $FD: Result:= $00FD; // LATIN SMALL LETTER Y WITH ACUTE
      $FE: Result:= $00FE; // LATIN SMALL LETTER THORN
      $FF: Result:= $00FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result:=Chr;
    end;
{$ENDIF}
  end;

(****** Unicode to ANSI char conversion functions *****)

function RtcUnicodeToAnsiCharNone(Chr: Word): Byte;
  begin
  Result := Byte(Chr);
  end;

function RtcUnicodeToAnsiCharWin1250(Chr: Word): Byte;
  begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
       $20AC: Result:= $80; // EURO SIGN
       $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
       $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
       $2026: Result:= $85; // HORIZONTAL ELLIPSIS
       $2020: Result:= $86; // DAGGER
       $2021: Result:= $87; // DOUBLE DAGGER
       $2030: Result:= $89; // PER MILLE SIGN
       $0160: Result:= $8A; // LATIN CAPITAL LETTER S WITH CARON
       $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
       $015A: Result:= $8C; // LATIN CAPITAL LETTER S WITH ACUTE
       $0164: Result:= $8D; // LATIN CAPITAL LETTER T WITH CARON
       $017D: Result:= $8E; // LATIN CAPITAL LETTER Z WITH CARON
       $0179: Result:= $8F; // LATIN CAPITAL LETTER Z WITH ACUTE
       $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
       $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
       $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
       $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
       $2022: Result:= $95; // BULLET
       $2013: Result:= $96; // EN DASH
       $2014: Result:= $97; // EM DASH
       $2122: Result:= $99; // TRADE MARK SIGN
       $0161: Result:= $9A; // LATIN SMALL LETTER S WITH CARON
       $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
       $015B: Result:= $9C; // LATIN SMALL LETTER S WITH ACUTE
       $0165: Result:= $9D; // LATIN SMALL LETTER T WITH CARON
       $017E: Result:= $9E; // LATIN SMALL LETTER Z WITH CARON
       $017A: Result:= $9F; // LATIN SMALL LETTER Z WITH ACUTE
       $00A0: Result:= $A0; // NO-BREAK SPACE
       $02C7: Result:= $A1; // CARON
       $02D8: Result:= $A2; // BREVE
       $0141: Result:= $A3; // LATIN CAPITAL LETTER L WITH STROKE
       $00A4: Result:= $A4; // CURRENCY SIGN
       $0104: Result:= $A5; // LATIN CAPITAL LETTER A WITH OGONEK
       $00A6: Result:= $A6; // BROKEN BAR
       $00A7: Result:= $A7; // SECTION SIGN
       $00A8: Result:= $A8; // DIAERESIS
       $00A9: Result:= $A9; // COPYRIGHT SIGN
       $015E: Result:= $AA; // LATIN CAPITAL LETTER S WITH CEDILLA
       $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
       $00AC: Result:= $AC; // NOT SIGN
       $00AD: Result:= $AD; // SOFT HYPHEN
       $00AE: Result:= $AE; // REGISTERED SIGN
       $017B: Result:= $AF; // LATIN CAPITAL LETTER Z WITH DOT ABOVE
       $00B0: Result:= $B0; // DEGREE SIGN
       $00B1: Result:= $B1; // PLUS-MINUS SIGN
       $02DB: Result:= $B2; // OGONEK
       $0142: Result:= $B3; // LATIN SMALL LETTER L WITH STROKE
       $00B4: Result:= $B4; // ACUTE ACCENT
       $00B5: Result:= $B5; // MICRO SIGN
       $00B6: Result:= $B6; // PILCROW SIGN
       $00B7: Result:= $B7; // MIDDLE DOT
       $00B8: Result:= $B8; // CEDILLA
       $0105: Result:= $B9; // LATIN SMALL LETTER A WITH OGONEK
       $015F: Result:= $BA; // LATIN SMALL LETTER S WITH CEDILLA
       $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
       $013D: Result:= $BC; // LATIN CAPITAL LETTER L WITH CARON
       $02DD: Result:= $BD; // DOUBLE ACUTE ACCENT
       $013E: Result:= $BE; // LATIN SMALL LETTER L WITH CARON
       $017C: Result:= $BF; // LATIN SMALL LETTER Z WITH DOT ABOVE
       $0154: Result:= $C0; // LATIN CAPITAL LETTER R WITH ACUTE
       $00C1: Result:= $C1; // LATIN CAPITAL LETTER A WITH ACUTE
       $00C2: Result:= $C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
       $0102: Result:= $C3; // LATIN CAPITAL LETTER A WITH BREVE
       $00C4: Result:= $C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
       $0139: Result:= $C5; // LATIN CAPITAL LETTER L WITH ACUTE
       $0106: Result:= $C6; // LATIN CAPITAL LETTER C WITH ACUTE
       $00C7: Result:= $C7; // LATIN CAPITAL LETTER C WITH CEDILLA
       $010C: Result:= $C8; // LATIN CAPITAL LETTER C WITH CARON
       $00C9: Result:= $C9; // LATIN CAPITAL LETTER E WITH ACUTE
       $0118: Result:= $CA; // LATIN CAPITAL LETTER E WITH OGONEK
       $00CB: Result:= $CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
       $011A: Result:= $CC; // LATIN CAPITAL LETTER E WITH CARON
       $00CD: Result:= $CD; // LATIN CAPITAL LETTER I WITH ACUTE
       $00CE: Result:= $CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
       $010E: Result:= $CF; // LATIN CAPITAL LETTER D WITH CARON
       $0110: Result:= $D0; // LATIN CAPITAL LETTER D WITH STROKE
       $0143: Result:= $D1; // LATIN CAPITAL LETTER N WITH ACUTE
       $0147: Result:= $D2; // LATIN CAPITAL LETTER N WITH CARON
       $00D3: Result:= $D3; // LATIN CAPITAL LETTER O WITH ACUTE
       $00D4: Result:= $D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
       $0150: Result:= $D5; // LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
       $00D6: Result:= $D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
       $00D7: Result:= $D7; // MULTIPLICATION SIGN
       $0158: Result:= $D8; // LATIN CAPITAL LETTER R WITH CARON
       $016E: Result:= $D9; // LATIN CAPITAL LETTER U WITH RING ABOVE
       $00DA: Result:= $DA; // LATIN CAPITAL LETTER U WITH ACUTE
       $0170: Result:= $DB; // LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
       $00DC: Result:= $DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
       $00DD: Result:= $DD; // LATIN CAPITAL LETTER Y WITH ACUTE
       $0162: Result:= $DE; // LATIN CAPITAL LETTER T WITH CEDILLA
       $00DF: Result:= $DF; // LATIN SMALL LETTER SHARP S
       $0155: Result:= $E0; // LATIN SMALL LETTER R WITH ACUTE
       $00E1: Result:= $E1; // LATIN SMALL LETTER A WITH ACUTE
       $00E2: Result:= $E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
       $0103: Result:= $E3; // LATIN SMALL LETTER A WITH BREVE
       $00E4: Result:= $E4; // LATIN SMALL LETTER A WITH DIAERESIS
       $013A: Result:= $E5; // LATIN SMALL LETTER L WITH ACUTE
       $0107: Result:= $E6; // LATIN SMALL LETTER C WITH ACUTE
       $00E7: Result:= $E7; // LATIN SMALL LETTER C WITH CEDILLA
       $010D: Result:= $E8; // LATIN SMALL LETTER C WITH CARON
       $00E9: Result:= $E9; // LATIN SMALL LETTER E WITH ACUTE
       $0119: Result:= $EA; // LATIN SMALL LETTER E WITH OGONEK
       $00EB: Result:= $EB; // LATIN SMALL LETTER E WITH DIAERESIS
       $011B: Result:= $EC; // LATIN SMALL LETTER E WITH CARON
       $00ED: Result:= $ED; // LATIN SMALL LETTER I WITH ACUTE
       $00EE: Result:= $EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
       $010F: Result:= $EF; // LATIN SMALL LETTER D WITH CARON
       $0111: Result:= $F0; // LATIN SMALL LETTER D WITH STROKE
       $0144: Result:= $F1; // LATIN SMALL LETTER N WITH ACUTE
       $0148: Result:= $F2; // LATIN SMALL LETTER N WITH CARON
       $00F3: Result:= $F3; // LATIN SMALL LETTER O WITH ACUTE
       $00F4: Result:= $F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
       $0151: Result:= $F5; // LATIN SMALL LETTER O WITH DOUBLE ACUTE
       $00F6: Result:= $F6; // LATIN SMALL LETTER O WITH DIAERESIS
       $00F7: Result:= $F7; // DIVISION SIGN
       $0159: Result:= $F8; // LATIN SMALL LETTER R WITH CARON
       $016F: Result:= $F9; // LATIN SMALL LETTER U WITH RING ABOVE
       $00FA: Result:= $FA; // LATIN SMALL LETTER U WITH ACUTE
       $0171: Result:= $FB; // LATIN SMALL LETTER U WITH DOUBLE ACUTE
       $00FC: Result:= $FC; // LATIN SMALL LETTER U WITH DIAERESIS
       $00FD: Result:= $FD; // LATIN SMALL LETTER Y WITH ACUTE
       $0163: Result:= $FE; // LATIN SMALL LETTER T WITH CEDILLA
       $02D9: Result:= $FF; // DOT ABOVE
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin1251(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $0402: Result:= $80; // CYRILLIC CAPITAL LETTER DJE
      $0403: Result:= $81; // CYRILLIC CAPITAL LETTER GJE
      $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
      $0453: Result:= $83; // CYRILLIC SMALL LETTER GJE
      $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2020: Result:= $86; // DAGGER
      $2021: Result:= $87; // DOUBLE DAGGER
      $20AC: Result:= $88; // EURO SIGN
      $2030: Result:= $89; // PER MILLE SIGN
      $0409: Result:= $8A; // CYRILLIC CAPITAL LETTER LJE
      $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $040A: Result:= $8C; // CYRILLIC CAPITAL LETTER NJE
      $040C: Result:= $8D; // CYRILLIC CAPITAL LETTER KJE
      $040B: Result:= $8E; // CYRILLIC CAPITAL LETTER TSHE
      $040F: Result:= $8F; // CYRILLIC CAPITAL LETTER DZHE
      $0452: Result:= $90; // CYRILLIC SMALL LETTER DJE
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $2122: Result:= $99; // TRADE MARK SIGN
      $0459: Result:= $9A; // CYRILLIC SMALL LETTER LJE
      $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $045A: Result:= $9C; // CYRILLIC SMALL LETTER NJE
      $045C: Result:= $9D; // CYRILLIC SMALL LETTER KJE
      $045B: Result:= $9E; // CYRILLIC SMALL LETTER TSHE
      $045F: Result:= $9F; // CYRILLIC SMALL LETTER DZHE
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $040E: Result:= $A1; // CYRILLIC CAPITAL LETTER SHORT U
      $045E: Result:= $A2; // CYRILLIC SMALL LETTER SHORT U
      $0408: Result:= $A3; // CYRILLIC CAPITAL LETTER JE
      $00A4: Result:= $A4; // CURRENCY SIGN
      $0490: Result:= $A5; // CYRILLIC CAPITAL LETTER GHE WITH UPTURN
      $00A6: Result:= $A6; // BROKEN BAR
      $00A7: Result:= $A7; // SECTION SIGN
      $0401: Result:= $A8; // CYRILLIC CAPITAL LETTER IO
      $00A9: Result:= $A9; // COPYRIGHT SIGN
      $0404: Result:= $AA; // CYRILLIC CAPITAL LETTER UKRAINIAN IE
      $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; // NOT SIGN
      $00AD: Result:= $AD; // SOFT HYPHEN
      $00AE: Result:= $AE; // REGISTERED SIGN
      $0407: Result:= $AF; // CYRILLIC CAPITAL LETTER YI
      $00B0: Result:= $B0; // DEGREE SIGN
      $00B1: Result:= $B1; // PLUS-MINUS SIGN
      $0406: Result:= $B2; // CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
      $0456: Result:= $B3; // CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
      $0491: Result:= $B4; // CYRILLIC SMALL LETTER GHE WITH UPTURN
      $00B5: Result:= $B5; // MICRO SIGN
      $00B6: Result:= $B6; // PILCROW SIGN
      $00B7: Result:= $B7; // MIDDLE DOT
      $0451: Result:= $B8; // CYRILLIC SMALL LETTER IO
      $2116: Result:= $B9; // NUMERO SIGN
      $0454: Result:= $BA; // CYRILLIC SMALL LETTER UKRAINIAN IE
      $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $0458: Result:= $BC; // CYRILLIC SMALL LETTER JE
      $0405: Result:= $BD; // CYRILLIC CAPITAL LETTER DZE
      $0455: Result:= $BE; // CYRILLIC SMALL LETTER DZE
      $0457: Result:= $BF; // CYRILLIC SMALL LETTER YI
      $0410: Result:= $C0; // CYRILLIC CAPITAL LETTER A
      $0411: Result:= $C1; // CYRILLIC CAPITAL LETTER BE
      $0412: Result:= $C2; // CYRILLIC CAPITAL LETTER VE
      $0413: Result:= $C3; // CYRILLIC CAPITAL LETTER GHE
      $0414: Result:= $C4; // CYRILLIC CAPITAL LETTER DE
      $0415: Result:= $C5; // CYRILLIC CAPITAL LETTER IE
      $0416: Result:= $C6; // CYRILLIC CAPITAL LETTER ZHE
      $0417: Result:= $C7; // CYRILLIC CAPITAL LETTER ZE
      $0418: Result:= $C8; // CYRILLIC CAPITAL LETTER I
      $0419: Result:= $C9; // CYRILLIC CAPITAL LETTER SHORT I
      $041A: Result:= $CA; // CYRILLIC CAPITAL LETTER KA
      $041B: Result:= $CB; // CYRILLIC CAPITAL LETTER EL
      $041C: Result:= $CC; // CYRILLIC CAPITAL LETTER EM
      $041D: Result:= $CD; // CYRILLIC CAPITAL LETTER EN
      $041E: Result:= $CE; // CYRILLIC CAPITAL LETTER O
      $041F: Result:= $CF; // CYRILLIC CAPITAL LETTER PE
      $0420: Result:= $D0; // CYRILLIC CAPITAL LETTER ER
      $0421: Result:= $D1; // CYRILLIC CAPITAL LETTER ES
      $0422: Result:= $D2; // CYRILLIC CAPITAL LETTER TE
      $0423: Result:= $D3; // CYRILLIC CAPITAL LETTER U
      $0424: Result:= $D4; // CYRILLIC CAPITAL LETTER EF
      $0425: Result:= $D5; // CYRILLIC CAPITAL LETTER HA
      $0426: Result:= $D6; // CYRILLIC CAPITAL LETTER TSE
      $0427: Result:= $D7; // CYRILLIC CAPITAL LETTER CHE
      $0428: Result:= $D8; // CYRILLIC CAPITAL LETTER SHA
      $0429: Result:= $D9; // CYRILLIC CAPITAL LETTER SHCHA
      $042A: Result:= $DA; // CYRILLIC CAPITAL LETTER HARD SIGN
      $042B: Result:= $DB; // CYRILLIC CAPITAL LETTER YERU
      $042C: Result:= $DC; // CYRILLIC CAPITAL LETTER SOFT SIGN
      $042D: Result:= $DD; // CYRILLIC CAPITAL LETTER E
      $042E: Result:= $DE; // CYRILLIC CAPITAL LETTER YU
      $042F: Result:= $DF; // CYRILLIC CAPITAL LETTER YA
      $0430: Result:= $E0; // CYRILLIC SMALL LETTER A
      $0431: Result:= $E1; // CYRILLIC SMALL LETTER BE
      $0432: Result:= $E2; // CYRILLIC SMALL LETTER VE
      $0433: Result:= $E3; // CYRILLIC SMALL LETTER GHE
      $0434: Result:= $E4; // CYRILLIC SMALL LETTER DE
      $0435: Result:= $E5; // CYRILLIC SMALL LETTER IE
      $0436: Result:= $E6; // CYRILLIC SMALL LETTER ZHE
      $0437: Result:= $E7; // CYRILLIC SMALL LETTER ZE
      $0438: Result:= $E8; // CYRILLIC SMALL LETTER I
      $0439: Result:= $E9; // CYRILLIC SMALL LETTER SHORT I
      $043A: Result:= $EA; // CYRILLIC SMALL LETTER KA
      $043B: Result:= $EB; // CYRILLIC SMALL LETTER EL
      $043C: Result:= $EC; // CYRILLIC SMALL LETTER EM
      $043D: Result:= $ED; // CYRILLIC SMALL LETTER EN
      $043E: Result:= $EE; // CYRILLIC SMALL LETTER O
      $043F: Result:= $EF; // CYRILLIC SMALL LETTER PE
      $0440: Result:= $F0; // CYRILLIC SMALL LETTER ER
      $0441: Result:= $F1; // CYRILLIC SMALL LETTER ES
      $0442: Result:= $F2; // CYRILLIC SMALL LETTER TE
      $0443: Result:= $F3; // CYRILLIC SMALL LETTER U
      $0444: Result:= $F4; // CYRILLIC SMALL LETTER EF
      $0445: Result:= $F5; // CYRILLIC SMALL LETTER HA
      $0446: Result:= $F6; // CYRILLIC SMALL LETTER TSE
      $0447: Result:= $F7; // CYRILLIC SMALL LETTER CHE
      $0448: Result:= $F8; // CYRILLIC SMALL LETTER SHA
      $0449: Result:= $F9; // CYRILLIC SMALL LETTER SHCHA
      $044A: Result:= $FA; // CYRILLIC SMALL LETTER HARD SIGN
      $044B: Result:= $FB; // CYRILLIC SMALL LETTER YERU
      $044C: Result:= $FC; // CYRILLIC SMALL LETTER SOFT SIGN
      $044D: Result:= $FD; // CYRILLIC SMALL LETTER E
      $044E: Result:= $FE; // CYRILLIC SMALL LETTER YU
      $044F: Result:= $FF; // CYRILLIC SMALL LETTER YA
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin1252(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $20AC: Result:= $80; // EURO SIGN
      $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
      $0192: Result:= $83; // LATIN SMALL LETTER F WITH HOOK
      $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2020: Result:= $86; // DAGGER
      $2021: Result:= $87; // DOUBLE DAGGER
      $02C6: Result:= $88; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $2030: Result:= $89; // PER MILLE SIGN
      $0160: Result:= $8A; // LATIN CAPITAL LETTER S WITH CARON
      $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $0152: Result:= $8C; // LATIN CAPITAL LIGATURE OE
      $017D: Result:= $8E; // LATIN CAPITAL LETTER Z WITH CARON
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $02DC: Result:= $98; // SMALL TILDE
      $2122: Result:= $99; // TRADE MARK SIGN
      $0161: Result:= $9A; // LATIN SMALL LETTER S WITH CARON
      $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $0153: Result:= $9C; // LATIN SMALL LIGATURE OE
      $017E: Result:= $9E; // LATIN SMALL LETTER Z WITH CARON
      $0178: Result:= $9F; // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $00A1: Result:= $A1; // INVERTED EXCLAMATION MARK
      $00A2: Result:= $A2; // CENT SIGN
      $00A3: Result:= $A3; // POUND SIGN
      $00A4: Result:= $A4; // CURRENCY SIGN
      $00A5: Result:= $A5; // YEN SIGN
      $00A6: Result:= $A6; // BROKEN BAR
      $00A7: Result:= $A7; // SECTION SIGN
      $00A8: Result:= $A8; // DIAERESIS
      $00A9: Result:= $A9; // COPYRIGHT SIGN
      $00AA: Result:= $AA; // FEMININE ORDINAL INDICATOR
      $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; // NOT SIGN
      $00AD: Result:= $AD; // SOFT HYPHEN
      $00AE: Result:= $AE; // REGISTERED SIGN
      $00AF: Result:= $AF; // MACRON
      $00B0: Result:= $B0; // DEGREE SIGN
      $00B1: Result:= $B1; // PLUS-MINUS SIGN
      $00B2: Result:= $B2; // SUPERSCRIPT TWO
      $00B3: Result:= $B3; // SUPERSCRIPT THREE
      $00B4: Result:= $B4; // ACUTE ACCENT
      $00B5: Result:= $B5; // MICRO SIGN
      $00B6: Result:= $B6; // PILCROW SIGN
      $00B7: Result:= $B7; // MIDDLE DOT
      $00B8: Result:= $B8; // CEDILLA
      $00B9: Result:= $B9; // SUPERSCRIPT ONE
      $00BA: Result:= $BA; // MASCULINE ORDINAL INDICATOR
      $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; // VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; // VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; // VULGAR FRACTION THREE QUARTERS
      $00BF: Result:= $BF; // INVERTED QUESTION MARK
      $00C0: Result:= $C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $00C1: Result:= $C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $00C3: Result:= $C3; // LATIN CAPITAL LETTER A WITH TILDE
      $00C4: Result:= $C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $00C5: Result:= $C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $00C6: Result:= $C6; // LATIN CAPITAL LETTER AE
      $00C7: Result:= $C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $00C8: Result:= $C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $00C9: Result:= $C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $00CA: Result:= $CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $00CB: Result:= $CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $00CC: Result:= $CC; // LATIN CAPITAL LETTER I WITH GRAVE
      $00CD: Result:= $CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $00CF: Result:= $CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $00D0: Result:= $D0; // LATIN CAPITAL LETTER ETH
      $00D1: Result:= $D1; // LATIN CAPITAL LETTER N WITH TILDE
      $00D2: Result:= $D2; // LATIN CAPITAL LETTER O WITH GRAVE
      $00D3: Result:= $D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $00D4: Result:= $D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $00D5: Result:= $D5; // LATIN CAPITAL LETTER O WITH TILDE
      $00D6: Result:= $D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; // MULTIPLICATION SIGN
      $00D8: Result:= $D8; // LATIN CAPITAL LETTER O WITH STROKE
      $00D9: Result:= $D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $00DA: Result:= $DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $00DB: Result:= $DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $00DC: Result:= $DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $00DD: Result:= $DD; // LATIN CAPITAL LETTER Y WITH ACUTE
      $00DE: Result:= $DE; // LATIN CAPITAL LETTER THORN
      $00DF: Result:= $DF; // LATIN SMALL LETTER SHARP S
      $00E0: Result:= $E0; // LATIN SMALL LETTER A WITH GRAVE
      $00E1: Result:= $E1; // LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $00E3: Result:= $E3; // LATIN SMALL LETTER A WITH TILDE
      $00E4: Result:= $E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $00E5: Result:= $E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $00E6: Result:= $E6; // LATIN SMALL LETTER AE
      $00E7: Result:= $E7; // LATIN SMALL LETTER C WITH CEDILLA
      $00E8: Result:= $E8; // LATIN SMALL LETTER E WITH GRAVE
      $00E9: Result:= $E9; // LATIN SMALL LETTER E WITH ACUTE
      $00EA: Result:= $EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $00EB: Result:= $EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $00EC: Result:= $EC; // LATIN SMALL LETTER I WITH GRAVE
      $00ED: Result:= $ED; // LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $00EF: Result:= $EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $00F0: Result:= $F0; // LATIN SMALL LETTER ETH
      $00F1: Result:= $F1; // LATIN SMALL LETTER N WITH TILDE
      $00F2: Result:= $F2; // LATIN SMALL LETTER O WITH GRAVE
      $00F3: Result:= $F3; // LATIN SMALL LETTER O WITH ACUTE
      $00F4: Result:= $F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $00F5: Result:= $F5; // LATIN SMALL LETTER O WITH TILDE
      $00F6: Result:= $F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; // DIVISION SIGN
      $00F8: Result:= $F8; // LATIN SMALL LETTER O WITH STROKE
      $00F9: Result:= $F9; // LATIN SMALL LETTER U WITH GRAVE
      $00FA: Result:= $FA; // LATIN SMALL LETTER U WITH ACUTE
      $00FB: Result:= $FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $00FD: Result:= $FD; // LATIN SMALL LETTER Y WITH ACUTE
      $00FE: Result:= $FE; // LATIN SMALL LETTER THORN
      $00FF: Result:= $FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin1253(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $20AC: Result:= $80; // EURO SIGN
      $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
      $0192: Result:= $83; // LATIN SMALL LETTER F WITH HOOK
      $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2020: Result:= $86; // DAGGER
      $2021: Result:= $87; // DOUBLE DAGGER
      $2030: Result:= $89; // PER MILLE SIGN
      $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $2122: Result:= $99; // TRADE MARK SIGN
      $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $0385: Result:= $A1; // GREEK DIALYTIKA TONOS
      $0386: Result:= $A2; // GREEK CAPITAL LETTER ALPHA WITH TONOS
      $00A3: Result:= $A3; // POUND SIGN
      $00A4: Result:= $A4; // CURRENCY SIGN
      $00A5: Result:= $A5; // YEN SIGN
      $00A6: Result:= $A6; // BROKEN BAR
      $00A7: Result:= $A7; // SECTION SIGN
      $00A8: Result:= $A8; // DIAERESIS
      $00A9: Result:= $A9; // COPYRIGHT SIGN
      $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; // NOT SIGN
      $00AD: Result:= $AD; // SOFT HYPHEN
      $00AE: Result:= $AE; // REGISTERED SIGN
      $2015: Result:= $AF; // HORIZONTAL BAR
      $00B0: Result:= $B0; // DEGREE SIGN
      $00B1: Result:= $B1; // PLUS-MINUS SIGN
      $00B2: Result:= $B2; // SUPERSCRIPT TWO
      $00B3: Result:= $B3; // SUPERSCRIPT THREE
      $0384: Result:= $B4; // GREEK TONOS
      $00B5: Result:= $B5; // MICRO SIGN
      $00B6: Result:= $B6; // PILCROW SIGN
      $00B7: Result:= $B7; // MIDDLE DOT
      $0388: Result:= $B8; // GREEK CAPITAL LETTER EPSILON WITH TONOS
      $0389: Result:= $B9; // GREEK CAPITAL LETTER ETA WITH TONOS
      $038A: Result:= $BA; // GREEK CAPITAL LETTER IOTA WITH TONOS
      $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $038C: Result:= $BC; // GREEK CAPITAL LETTER OMICRON WITH TONOS
      $00BD: Result:= $BD; // VULGAR FRACTION ONE HALF
      $038E: Result:= $BE; // GREEK CAPITAL LETTER UPSILON WITH TONOS
      $038F: Result:= $BF; // GREEK CAPITAL LETTER OMEGA WITH TONOS
      $0390: Result:= $C0; // GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS
      $0391: Result:= $C1; // GREEK CAPITAL LETTER ALPHA
      $0392: Result:= $C2; // GREEK CAPITAL LETTER BETA
      $0393: Result:= $C3; // GREEK CAPITAL LETTER GAMMA
      $0394: Result:= $C4; // GREEK CAPITAL LETTER DELTA
      $0395: Result:= $C5; // GREEK CAPITAL LETTER EPSILON
      $0396: Result:= $C6; // GREEK CAPITAL LETTER ZETA
      $0397: Result:= $C7; // GREEK CAPITAL LETTER ETA
      $0398: Result:= $C8; // GREEK CAPITAL LETTER THETA
      $0399: Result:= $C9; // GREEK CAPITAL LETTER IOTA
      $039A: Result:= $CA; // GREEK CAPITAL LETTER KAPPA
      $039B: Result:= $CB; // GREEK CAPITAL LETTER LAMDA
      $039C: Result:= $CC; // GREEK CAPITAL LETTER MU
      $039D: Result:= $CD; // GREEK CAPITAL LETTER NU
      $039E: Result:= $CE; // GREEK CAPITAL LETTER XI
      $039F: Result:= $CF; // GREEK CAPITAL LETTER OMICRON
      $03A0: Result:= $D0; // GREEK CAPITAL LETTER PI
      $03A1: Result:= $D1; // GREEK CAPITAL LETTER RHO
      $03A3: Result:= $D3; // GREEK CAPITAL LETTER SIGMA
      $03A4: Result:= $D4; // GREEK CAPITAL LETTER TAU
      $03A5: Result:= $D5; // GREEK CAPITAL LETTER UPSILON
      $03A6: Result:= $D6; // GREEK CAPITAL LETTER PHI
      $03A7: Result:= $D7; // GREEK CAPITAL LETTER CHI
      $03A8: Result:= $D8; // GREEK CAPITAL LETTER PSI
      $03A9: Result:= $D9; // GREEK CAPITAL LETTER OMEGA
      $03AA: Result:= $DA; // GREEK CAPITAL LETTER IOTA WITH DIALYTIKA
      $03AB: Result:= $DB; // GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA
      $03AC: Result:= $DC; // GREEK SMALL LETTER ALPHA WITH TONOS
      $03AD: Result:= $DD; // GREEK SMALL LETTER EPSILON WITH TONOS
      $03AE: Result:= $DE; // GREEK SMALL LETTER ETA WITH TONOS
      $03AF: Result:= $DF; // GREEK SMALL LETTER IOTA WITH TONOS
      $03B0: Result:= $E0; // GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS
      $03B1: Result:= $E1; // GREEK SMALL LETTER ALPHA
      $03B2: Result:= $E2; // GREEK SMALL LETTER BETA
      $03B3: Result:= $E3; // GREEK SMALL LETTER GAMMA
      $03B4: Result:= $E4; // GREEK SMALL LETTER DELTA
      $03B5: Result:= $E5; // GREEK SMALL LETTER EPSILON
      $03B6: Result:= $E6; // GREEK SMALL LETTER ZETA
      $03B7: Result:= $E7; // GREEK SMALL LETTER ETA
      $03B8: Result:= $E8; // GREEK SMALL LETTER THETA
      $03B9: Result:= $E9; // GREEK SMALL LETTER IOTA
      $03BA: Result:= $EA; // GREEK SMALL LETTER KAPPA
      $03BB: Result:= $EB; // GREEK SMALL LETTER LAMDA
      $03BC: Result:= $EC; // GREEK SMALL LETTER MU
      $03BD: Result:= $ED; // GREEK SMALL LETTER NU
      $03BE: Result:= $EE; // GREEK SMALL LETTER XI
      $03BF: Result:= $EF; // GREEK SMALL LETTER OMICRON
      $03C0: Result:= $F0; // GREEK SMALL LETTER PI
      $03C1: Result:= $F1; // GREEK SMALL LETTER RHO
      $03C2: Result:= $F2; // GREEK SMALL LETTER FINAL SIGMA
      $03C3: Result:= $F3; // GREEK SMALL LETTER SIGMA
      $03C4: Result:= $F4; // GREEK SMALL LETTER TAU
      $03C5: Result:= $F5; // GREEK SMALL LETTER UPSILON
      $03C6: Result:= $F6; // GREEK SMALL LETTER PHI
      $03C7: Result:= $F7; // GREEK SMALL LETTER CHI
      $03C8: Result:= $F8; // GREEK SMALL LETTER PSI
      $03C9: Result:= $F9; // GREEK SMALL LETTER OMEGA
      $03CA: Result:= $FA; // GREEK SMALL LETTER IOTA WITH DIALYTIKA
      $03CB: Result:= $FB; // GREEK SMALL LETTER UPSILON WITH DIALYTIKA
      $03CC: Result:= $FC; // GREEK SMALL LETTER OMICRON WITH TONOS
      $03CD: Result:= $FD; // GREEK SMALL LETTER UPSILON WITH TONOS
      $03CE: Result:= $FE; // GREEK SMALL LETTER OMEGA WITH TONOS
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin1254(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $20AC: Result:= $80; // EURO SIGN
      $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
      $0192: Result:= $83; // LATIN SMALL LETTER F WITH HOOK
      $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2020: Result:= $86; // DAGGER
      $2021: Result:= $87; // DOUBLE DAGGER
      $02C6: Result:= $88; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $2030: Result:= $89; // PER MILLE SIGN
      $0160: Result:= $8A; // LATIN CAPITAL LETTER S WITH CARON
      $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $0152: Result:= $8C; // LATIN CAPITAL LIGATURE OE
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $02DC: Result:= $98; // SMALL TILDE
      $2122: Result:= $99; // TRADE MARK SIGN
      $0161: Result:= $9A; // LATIN SMALL LETTER S WITH CARON
      $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $0153: Result:= $9C; // LATIN SMALL LIGATURE OE
      $0178: Result:= $9F; // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $00A1: Result:= $A1; // INVERTED EXCLAMATION MARK
      $00A2: Result:= $A2; // CENT SIGN
      $00A3: Result:= $A3; // POUND SIGN
      $00A4: Result:= $A4; // CURRENCY SIGN
      $00A5: Result:= $A5; // YEN SIGN
      $00A6: Result:= $A6; // BROKEN BAR
      $00A7: Result:= $A7; // SECTION SIGN
      $00A8: Result:= $A8; // DIAERESIS
      $00A9: Result:= $A9; // COPYRIGHT SIGN
      $00AA: Result:= $AA; // FEMININE ORDINAL INDICATOR
      $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; // NOT SIGN
      $00AD: Result:= $AD; // SOFT HYPHEN
      $00AE: Result:= $AE; // REGISTERED SIGN
      $00AF: Result:= $AF; // MACRON
      $00B0: Result:= $B0; // DEGREE SIGN
      $00B1: Result:= $B1; // PLUS-MINUS SIGN
      $00B2: Result:= $B2; // SUPERSCRIPT TWO
      $00B3: Result:= $B3; // SUPERSCRIPT THREE
      $00B4: Result:= $B4; // ACUTE ACCENT
      $00B5: Result:= $B5; // MICRO SIGN
      $00B6: Result:= $B6; // PILCROW SIGN
      $00B7: Result:= $B7; // MIDDLE DOT
      $00B8: Result:= $B8; // CEDILLA
      $00B9: Result:= $B9; // SUPERSCRIPT ONE
      $00BA: Result:= $BA; // MASCULINE ORDINAL INDICATOR
      $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; // VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; // VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; // VULGAR FRACTION THREE QUARTERS
      $00BF: Result:= $BF; // INVERTED QUESTION MARK
      $00C0: Result:= $C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $00C1: Result:= $C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $00C3: Result:= $C3; // LATIN CAPITAL LETTER A WITH TILDE
      $00C4: Result:= $C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $00C5: Result:= $C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $00C6: Result:= $C6; // LATIN CAPITAL LETTER AE
      $00C7: Result:= $C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $00C8: Result:= $C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $00C9: Result:= $C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $00CA: Result:= $CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $00CB: Result:= $CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $00CC: Result:= $CC; // LATIN CAPITAL LETTER I WITH GRAVE
      $00CD: Result:= $CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $00CF: Result:= $CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $011E: Result:= $D0; // LATIN CAPITAL LETTER G WITH BREVE
      $00D1: Result:= $D1; // LATIN CAPITAL LETTER N WITH TILDE
      $00D2: Result:= $D2; // LATIN CAPITAL LETTER O WITH GRAVE
      $00D3: Result:= $D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $00D4: Result:= $D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $00D5: Result:= $D5; // LATIN CAPITAL LETTER O WITH TILDE
      $00D6: Result:= $D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; // MULTIPLICATION SIGN
      $00D8: Result:= $D8; // LATIN CAPITAL LETTER O WITH STROKE
      $00D9: Result:= $D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $00DA: Result:= $DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $00DB: Result:= $DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $00DC: Result:= $DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $0130: Result:= $DD; // LATIN CAPITAL LETTER I WITH DOT ABOVE
      $015E: Result:= $DE; // LATIN CAPITAL LETTER S WITH CEDILLA
      $00DF: Result:= $DF; // LATIN SMALL LETTER SHARP S
      $00E0: Result:= $E0; // LATIN SMALL LETTER A WITH GRAVE
      $00E1: Result:= $E1; // LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $00E3: Result:= $E3; // LATIN SMALL LETTER A WITH TILDE
      $00E4: Result:= $E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $00E5: Result:= $E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $00E6: Result:= $E6; // LATIN SMALL LETTER AE
      $00E7: Result:= $E7; // LATIN SMALL LETTER C WITH CEDILLA
      $00E8: Result:= $E8; // LATIN SMALL LETTER E WITH GRAVE
      $00E9: Result:= $E9; // LATIN SMALL LETTER E WITH ACUTE
      $00EA: Result:= $EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $00EB: Result:= $EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $00EC: Result:= $EC; // LATIN SMALL LETTER I WITH GRAVE
      $00ED: Result:= $ED; // LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $00EF: Result:= $EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $011F: Result:= $F0; // LATIN SMALL LETTER G WITH BREVE
      $00F1: Result:= $F1; // LATIN SMALL LETTER N WITH TILDE
      $00F2: Result:= $F2; // LATIN SMALL LETTER O WITH GRAVE
      $00F3: Result:= $F3; // LATIN SMALL LETTER O WITH ACUTE
      $00F4: Result:= $F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $00F5: Result:= $F5; // LATIN SMALL LETTER O WITH TILDE
      $00F6: Result:= $F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; // DIVISION SIGN
      $00F8: Result:= $F8; // LATIN SMALL LETTER O WITH STROKE
      $00F9: Result:= $F9; // LATIN SMALL LETTER U WITH GRAVE
      $00FA: Result:= $FA; // LATIN SMALL LETTER U WITH ACUTE
      $00FB: Result:= $FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $0131: Result:= $FD; // LATIN SMALL LETTER DOTLESS I
      $015F: Result:= $FE; // LATIN SMALL LETTER S WITH CEDILLA
      $00FF: Result:= $FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin1255(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $20AC: Result:= $80; // EURO SIGN
      $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
      $0192: Result:= $83; // LATIN SMALL LETTER F WITH HOOK
      $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2020: Result:= $86; // DAGGER
      $2021: Result:= $87; // DOUBLE DAGGER
      $02C6: Result:= $88; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $2030: Result:= $89; // PER MILLE SIGN
      $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $02DC: Result:= $98; // SMALL TILDE
      $2122: Result:= $99; // TRADE MARK SIGN
      $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $00A1: Result:= $A1; // INVERTED EXCLAMATION MARK
      $00A2: Result:= $A2; // CENT SIGN
      $00A3: Result:= $A3; // POUND SIGN
      $20AA: Result:= $A4; // NEW SHEQEL SIGN
      $00A5: Result:= $A5; // YEN SIGN
      $00A6: Result:= $A6; // BROKEN BAR
      $00A7: Result:= $A7; // SECTION SIGN
      $00A8: Result:= $A8; // DIAERESIS
      $00A9: Result:= $A9; // COPYRIGHT SIGN
      $00D7: Result:= $AA; // MULTIPLICATION SIGN
      $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; // NOT SIGN
      $00AD: Result:= $AD; // SOFT HYPHEN
      $00AE: Result:= $AE; // REGISTERED SIGN
      $00AF: Result:= $AF; // MACRON
      $00B0: Result:= $B0; // DEGREE SIGN
      $00B1: Result:= $B1; // PLUS-MINUS SIGN
      $00B2: Result:= $B2; // SUPERSCRIPT TWO
      $00B3: Result:= $B3; // SUPERSCRIPT THREE
      $00B4: Result:= $B4; // ACUTE ACCENT
      $00B5: Result:= $B5; // MICRO SIGN
      $00B6: Result:= $B6; // PILCROW SIGN
      $00B7: Result:= $B7; // MIDDLE DOT
      $00B8: Result:= $B8; // CEDILLA
      $00B9: Result:= $B9; // SUPERSCRIPT ONE
      $00F7: Result:= $BA; // DIVISION SIGN
      $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; // VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; // VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; // VULGAR FRACTION THREE QUARTERS
      $00BF: Result:= $BF; // INVERTED QUESTION MARK
      $05B0: Result:= $C0; // HEBREW POINT SHEVA
      $05B1: Result:= $C1; // HEBREW POINT HATAF SEGOL
      $05B2: Result:= $C2; // HEBREW POINT HATAF PATAH
      $05B3: Result:= $C3; // HEBREW POINT HATAF QAMATS
      $05B4: Result:= $C4; // HEBREW POINT HIRIQ
      $05B5: Result:= $C5; // HEBREW POINT TSERE
      $05B6: Result:= $C6; // HEBREW POINT SEGOL
      $05B7: Result:= $C7; // HEBREW POINT PATAH
      $05B8: Result:= $C8; // HEBREW POINT QAMATS
      $05B9: Result:= $C9; // HEBREW POINT HOLAM
      $05BB: Result:= $CB; // HEBREW POINT QUBUTS
      $05BC: Result:= $CC; // HEBREW POINT DAGESH OR MAPIQ
      $05BD: Result:= $CD; // HEBREW POINT METEG
      $05BE: Result:= $CE; // HEBREW PUNCTUATION MAQAF
      $05BF: Result:= $CF; // HEBREW POINT RAFE
      $05C0: Result:= $D0; // HEBREW PUNCTUATION PASEQ
      $05C1: Result:= $D1; // HEBREW POINT SHIN DOT
      $05C2: Result:= $D2; // HEBREW POINT SIN DOT
      $05C3: Result:= $D3; // HEBREW PUNCTUATION SOF PASUQ
      $05F0: Result:= $D4; // HEBREW LIGATURE YIDDISH DOUBLE VAV
      $05F1: Result:= $D5; // HEBREW LIGATURE YIDDISH VAV YOD
      $05F2: Result:= $D6; // HEBREW LIGATURE YIDDISH DOUBLE YOD
      $05F3: Result:= $D7; // HEBREW PUNCTUATION GERESH
      $05F4: Result:= $D8; // HEBREW PUNCTUATION GERSHAYIM
      $05D0: Result:= $E0; // HEBREW LETTER ALEF
      $05D1: Result:= $E1; // HEBREW LETTER BET
      $05D2: Result:= $E2; // HEBREW LETTER GIMEL
      $05D3: Result:= $E3; // HEBREW LETTER DALET
      $05D4: Result:= $E4; // HEBREW LETTER HE
      $05D5: Result:= $E5; // HEBREW LETTER VAV
      $05D6: Result:= $E6; // HEBREW LETTER ZAYIN
      $05D7: Result:= $E7; // HEBREW LETTER HET
      $05D8: Result:= $E8; // HEBREW LETTER TET
      $05D9: Result:= $E9; // HEBREW LETTER YOD
      $05DA: Result:= $EA; // HEBREW LETTER FINAL KAF
      $05DB: Result:= $EB; // HEBREW LETTER KAF
      $05DC: Result:= $EC; // HEBREW LETTER LAMED
      $05DD: Result:= $ED; // HEBREW LETTER FINAL MEM
      $05DE: Result:= $EE; // HEBREW LETTER MEM
      $05DF: Result:= $EF; // HEBREW LETTER FINAL NUN
      $05E0: Result:= $F0; // HEBREW LETTER NUN
      $05E1: Result:= $F1; // HEBREW LETTER SAMEKH
      $05E2: Result:= $F2; // HEBREW LETTER AYIN
      $05E3: Result:= $F3; // HEBREW LETTER FINAL PE
      $05E4: Result:= $F4; // HEBREW LETTER PE
      $05E5: Result:= $F5; // HEBREW LETTER FINAL TSADI
      $05E6: Result:= $F6; // HEBREW LETTER TSADI
      $05E7: Result:= $F7; // HEBREW LETTER QOF
      $05E8: Result:= $F8; // HEBREW LETTER RESH
      $05E9: Result:= $F9; // HEBREW LETTER SHIN
      $05EA: Result:= $FA; // HEBREW LETTER TAV
      $200E: Result:= $FD; // LEFT-TO-RIGHT MARK
      $200F: Result:= $FE; // RIGHT-TO-LEFT MARK
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin1256(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $20AC: Result:= $80; // EURO SIGN
      $067E: Result:= $81; // ARABIC LETTER PEH
      $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
      $0192: Result:= $83; // LATIN SMALL LETTER F WITH HOOK
      $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2020: Result:= $86; // DAGGER
      $2021: Result:= $87; // DOUBLE DAGGER
      $02C6: Result:= $88; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $2030: Result:= $89; // PER MILLE SIGN
      $0679: Result:= $8A; // ARABIC LETTER TTEH
      $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $0152: Result:= $8C; // LATIN CAPITAL LIGATURE OE
      $0686: Result:= $8D; // ARABIC LETTER TCHEH
      $0698: Result:= $8E; // ARABIC LETTER JEH
      $0688: Result:= $8F; // ARABIC LETTER DDAL
      $06AF: Result:= $90; // ARABIC LETTER GAF
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $06A9: Result:= $98; // ARABIC LETTER KEHEH
      $2122: Result:= $99; // TRADE MARK SIGN
      $0691: Result:= $9A; // ARABIC LETTER RREH
      $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $0153: Result:= $9C; // LATIN SMALL LIGATURE OE
      $200C: Result:= $9D; // ZERO WIDTH NON-JOINER
      $200D: Result:= $9E; // ZERO WIDTH JOINER
      $06BA: Result:= $9F; // ARABIC LETTER NOON GHUNNA
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $060C: Result:= $A1; // ARABIC COMMA
      $00A2: Result:= $A2; // CENT SIGN
      $00A3: Result:= $A3; // POUND SIGN
      $00A4: Result:= $A4; // CURRENCY SIGN
      $00A5: Result:= $A5; // YEN SIGN
      $00A6: Result:= $A6; // BROKEN BAR
      $00A7: Result:= $A7; // SECTION SIGN
      $00A8: Result:= $A8; // DIAERESIS
      $00A9: Result:= $A9; // COPYRIGHT SIGN
      $06BE: Result:= $AA; // ARABIC LETTER HEH DOACHASHMEE
      $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; // NOT SIGN
      $00AD: Result:= $AD; // SOFT HYPHEN
      $00AE: Result:= $AE; // REGISTERED SIGN
      $00AF: Result:= $AF; // MACRON
      $00B0: Result:= $B0; // DEGREE SIGN
      $00B1: Result:= $B1; // PLUS-MINUS SIGN
      $00B2: Result:= $B2; // SUPERSCRIPT TWO
      $00B3: Result:= $B3; // SUPERSCRIPT THREE
      $00B4: Result:= $B4; // ACUTE ACCENT
      $00B5: Result:= $B5; // MICRO SIGN
      $00B6: Result:= $B6; // PILCROW SIGN
      $00B7: Result:= $B7; // MIDDLE DOT
      $00B8: Result:= $B8; // CEDILLA
      $00B9: Result:= $B9; // SUPERSCRIPT ONE
      $061B: Result:= $BA; // ARABIC SEMICOLON
      $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; // VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; // VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; // VULGAR FRACTION THREE QUARTERS
      $061F: Result:= $BF; // ARABIC QUESTION MARK
      $06C1: Result:= $C0; // ARABIC LETTER HEH GOAL
      $0621: Result:= $C1; // ARABIC LETTER HAMZA
      $0622: Result:= $C2; // ARABIC LETTER ALEF WITH MADDA ABOVE
      $0623: Result:= $C3; // ARABIC LETTER ALEF WITH HAMZA ABOVE
      $0624: Result:= $C4; // ARABIC LETTER WAW WITH HAMZA ABOVE
      $0625: Result:= $C5; // ARABIC LETTER ALEF WITH HAMZA BELOW
      $0626: Result:= $C6; // ARABIC LETTER YEH WITH HAMZA ABOVE
      $0627: Result:= $C7; // ARABIC LETTER ALEF
      $0628: Result:= $C8; // ARABIC LETTER BEH
      $0629: Result:= $C9; // ARABIC LETTER TEH MARBUTA
      $062A: Result:= $CA; // ARABIC LETTER TEH
      $062B: Result:= $CB; // ARABIC LETTER THEH
      $062C: Result:= $CC; // ARABIC LETTER JEEM
      $062D: Result:= $CD; // ARABIC LETTER HAH
      $062E: Result:= $CE; // ARABIC LETTER KHAH
      $062F: Result:= $CF; // ARABIC LETTER DAL
      $0630: Result:= $D0; // ARABIC LETTER THAL
      $0631: Result:= $D1; // ARABIC LETTER REH
      $0632: Result:= $D2; // ARABIC LETTER ZAIN
      $0633: Result:= $D3; // ARABIC LETTER SEEN
      $0634: Result:= $D4; // ARABIC LETTER SHEEN
      $0635: Result:= $D5; // ARABIC LETTER SAD
      $0636: Result:= $D6; // ARABIC LETTER DAD
      $00D7: Result:= $D7; // MULTIPLICATION SIGN
      $0637: Result:= $D8; // ARABIC LETTER TAH
      $0638: Result:= $D9; // ARABIC LETTER ZAH
      $0639: Result:= $DA; // ARABIC LETTER AIN
      $063A: Result:= $DB; // ARABIC LETTER GHAIN
      $0640: Result:= $DC; // ARABIC TATWEEL
      $0641: Result:= $DD; // ARABIC LETTER FEH
      $0642: Result:= $DE; // ARABIC LETTER QAF
      $0643: Result:= $DF; // ARABIC LETTER KAF
      $00E0: Result:= $E0; // LATIN SMALL LETTER A WITH GRAVE
      $0644: Result:= $E1; // ARABIC LETTER LAM
      $00E2: Result:= $E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $0645: Result:= $E3; // ARABIC LETTER MEEM
      $0646: Result:= $E4; // ARABIC LETTER NOON
      $0647: Result:= $E5; // ARABIC LETTER HEH
      $0648: Result:= $E6; // ARABIC LETTER WAW
      $00E7: Result:= $E7; // LATIN SMALL LETTER C WITH CEDILLA
      $00E8: Result:= $E8; // LATIN SMALL LETTER E WITH GRAVE
      $00E9: Result:= $E9; // LATIN SMALL LETTER E WITH ACUTE
      $00EA: Result:= $EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $00EB: Result:= $EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $0649: Result:= $EC; // ARABIC LETTER ALEF MAKSURA
      $064A: Result:= $ED; // ARABIC LETTER YEH
      $00EE: Result:= $EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $00EF: Result:= $EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $064B: Result:= $F0; // ARABIC FATHATAN
      $064C: Result:= $F1; // ARABIC DAMMATAN
      $064D: Result:= $F2; // ARABIC KASRATAN
      $064E: Result:= $F3; // ARABIC FATHA
      $00F4: Result:= $F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $064F: Result:= $F5; // ARABIC DAMMA
      $0650: Result:= $F6; // ARABIC KASRA
      $00F7: Result:= $F7; // DIVISION SIGN
      $0651: Result:= $F8; // ARABIC SHADDA
      $00F9: Result:= $F9; // LATIN SMALL LETTER U WITH GRAVE
      $0652: Result:= $FA; // ARABIC SUKUN
      $00FB: Result:= $FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $200E: Result:= $FD; // LEFT-TO-RIGHT MARK
      $200F: Result:= $FE; // RIGHT-TO-LEFT MARK
      $06D2: Result:= $FF; // ARABIC LETTER YEH BARREE
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin1257(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $20AC: Result:= $80; // EURO SIGN
      $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
      $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2020: Result:= $86; // DAGGER
      $2021: Result:= $87; // DOUBLE DAGGER
      $2030: Result:= $89; // PER MILLE SIGN
      $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $00A8: Result:= $8D; // DIAERESIS
      $02C7: Result:= $8E; // CARON
      $00B8: Result:= $8F; // CEDILLA
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $2122: Result:= $99; // TRADE MARK SIGN
      $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $00AF: Result:= $9D; // MACRON
      $02DB: Result:= $9E; // OGONEK
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $00A2: Result:= $A2; // CENT SIGN
      $00A3: Result:= $A3; // POUND SIGN
      $00A4: Result:= $A4; // CURRENCY SIGN
      $00A6: Result:= $A6; // BROKEN BAR
      $00A7: Result:= $A7; // SECTION SIGN
      $00D8: Result:= $A8; // LATIN CAPITAL LETTER O WITH STROKE
      $00A9: Result:= $A9; // COPYRIGHT SIGN
      $0156: Result:= $AA; // LATIN CAPITAL LETTER R WITH CEDILLA
      $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; // NOT SIGN
      $00AD: Result:= $AD; // SOFT HYPHEN
      $00AE: Result:= $AE; // REGISTERED SIGN
      $00C6: Result:= $AF; // LATIN CAPITAL LETTER AE
      $00B0: Result:= $B0; // DEGREE SIGN
      $00B1: Result:= $B1; // PLUS-MINUS SIGN
      $00B2: Result:= $B2; // SUPERSCRIPT TWO
      $00B3: Result:= $B3; // SUPERSCRIPT THREE
      $00B4: Result:= $B4; // ACUTE ACCENT
      $00B5: Result:= $B5; // MICRO SIGN
      $00B6: Result:= $B6; // PILCROW SIGN
      $00B7: Result:= $B7; // MIDDLE DOT
      $00F8: Result:= $B8; // LATIN SMALL LETTER O WITH STROKE
      $00B9: Result:= $B9; // SUPERSCRIPT ONE
      $0157: Result:= $BA; // LATIN SMALL LETTER R WITH CEDILLA
      $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; // VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; // VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; // VULGAR FRACTION THREE QUARTERS
      $00E6: Result:= $BF; // LATIN SMALL LETTER AE
      $0104: Result:= $C0; // LATIN CAPITAL LETTER A WITH OGONEK
      $012E: Result:= $C1; // LATIN CAPITAL LETTER I WITH OGONEK
      $0100: Result:= $C2; // LATIN CAPITAL LETTER A WITH MACRON
      $0106: Result:= $C3; // LATIN CAPITAL LETTER C WITH ACUTE
      $00C4: Result:= $C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $00C5: Result:= $C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $0118: Result:= $C6; // LATIN CAPITAL LETTER E WITH OGONEK
      $0112: Result:= $C7; // LATIN CAPITAL LETTER E WITH MACRON
      $010C: Result:= $C8; // LATIN CAPITAL LETTER C WITH CARON
      $00C9: Result:= $C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $0179: Result:= $CA; // LATIN CAPITAL LETTER Z WITH ACUTE
      $0116: Result:= $CB; // LATIN CAPITAL LETTER E WITH DOT ABOVE
      $0122: Result:= $CC; // LATIN CAPITAL LETTER G WITH CEDILLA
      $0136: Result:= $CD; // LATIN CAPITAL LETTER K WITH CEDILLA
      $012A: Result:= $CE; // LATIN CAPITAL LETTER I WITH MACRON
      $013B: Result:= $CF; // LATIN CAPITAL LETTER L WITH CEDILLA
      $0160: Result:= $D0; // LATIN CAPITAL LETTER S WITH CARON
      $0143: Result:= $D1; // LATIN CAPITAL LETTER N WITH ACUTE
      $0145: Result:= $D2; // LATIN CAPITAL LETTER N WITH CEDILLA
      $00D3: Result:= $D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $014C: Result:= $D4; // LATIN CAPITAL LETTER O WITH MACRON
      $00D5: Result:= $D5; // LATIN CAPITAL LETTER O WITH TILDE
      $00D6: Result:= $D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; // MULTIPLICATION SIGN
      $0172: Result:= $D8; // LATIN CAPITAL LETTER U WITH OGONEK
      $0141: Result:= $D9; // LATIN CAPITAL LETTER L WITH STROKE
      $015A: Result:= $DA; // LATIN CAPITAL LETTER S WITH ACUTE
      $016A: Result:= $DB; // LATIN CAPITAL LETTER U WITH MACRON
      $00DC: Result:= $DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $017B: Result:= $DD; // LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $017D: Result:= $DE; // LATIN CAPITAL LETTER Z WITH CARON
      $00DF: Result:= $DF; // LATIN SMALL LETTER SHARP S
      $0105: Result:= $E0; // LATIN SMALL LETTER A WITH OGONEK
      $012F: Result:= $E1; // LATIN SMALL LETTER I WITH OGONEK
      $0101: Result:= $E2; // LATIN SMALL LETTER A WITH MACRON
      $0107: Result:= $E3; // LATIN SMALL LETTER C WITH ACUTE
      $00E4: Result:= $E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $00E5: Result:= $E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $0119: Result:= $E6; // LATIN SMALL LETTER E WITH OGONEK
      $0113: Result:= $E7; // LATIN SMALL LETTER E WITH MACRON
      $010D: Result:= $E8; // LATIN SMALL LETTER C WITH CARON
      $00E9: Result:= $E9; // LATIN SMALL LETTER E WITH ACUTE
      $017A: Result:= $EA; // LATIN SMALL LETTER Z WITH ACUTE
      $0117: Result:= $EB; // LATIN SMALL LETTER E WITH DOT ABOVE
      $0123: Result:= $EC; // LATIN SMALL LETTER G WITH CEDILLA
      $0137: Result:= $ED; // LATIN SMALL LETTER K WITH CEDILLA
      $012B: Result:= $EE; // LATIN SMALL LETTER I WITH MACRON
      $013C: Result:= $EF; // LATIN SMALL LETTER L WITH CEDILLA
      $0161: Result:= $F0; // LATIN SMALL LETTER S WITH CARON
      $0144: Result:= $F1; // LATIN SMALL LETTER N WITH ACUTE
      $0146: Result:= $F2; // LATIN SMALL LETTER N WITH CEDILLA
      $00F3: Result:= $F3; // LATIN SMALL LETTER O WITH ACUTE
      $014D: Result:= $F4; // LATIN SMALL LETTER O WITH MACRON
      $00F5: Result:= $F5; // LATIN SMALL LETTER O WITH TILDE
      $00F6: Result:= $F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; // DIVISION SIGN
      $0173: Result:= $F8; // LATIN SMALL LETTER U WITH OGONEK
      $0142: Result:= $F9; // LATIN SMALL LETTER L WITH STROKE
      $015B: Result:= $FA; // LATIN SMALL LETTER S WITH ACUTE
      $016B: Result:= $FB; // LATIN SMALL LETTER U WITH MACRON
      $00FC: Result:= $FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $017C: Result:= $FD; // LATIN SMALL LETTER Z WITH DOT ABOVE
      $017E: Result:= $FE; // LATIN SMALL LETTER Z WITH CARON
      $02D9: Result:= $FF; // DOT ABOVE
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin1258(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $20AC: Result:= $80; // EURO SIGN
      $201A: Result:= $82; // SINGLE LOW-9 QUOTATION MARK
      $0192: Result:= $83; // LATIN SMALL LETTER F WITH HOOK
      $201E: Result:= $84; // DOUBLE LOW-9 QUOTATION MARK
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2020: Result:= $86; // DAGGER
      $2021: Result:= $87; // DOUBLE DAGGER
      $02C6: Result:= $88; // MODIFIER LETTER CIRCUMFLEX ACCENT
      $2030: Result:= $89; // PER MILLE SIGN
      $2039: Result:= $8B; // SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      $0152: Result:= $8C; // LATIN CAPITAL LIGATURE OE
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $02DC: Result:= $98; // SMALL TILDE
      $2122: Result:= $99; // TRADE MARK SIGN
      $203A: Result:= $9B; // SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      $0153: Result:= $9C; // LATIN SMALL LIGATURE OE
      $0178: Result:= $9F; // LATIN CAPITAL LETTER Y WITH DIAERESIS
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $00A1: Result:= $A1; // INVERTED EXCLAMATION MARK
      $00A2: Result:= $A2; // CENT SIGN
      $00A3: Result:= $A3; // POUND SIGN
      $00A4: Result:= $A4; // CURRENCY SIGN
      $00A5: Result:= $A5; // YEN SIGN
      $00A6: Result:= $A6; // BROKEN BAR
      $00A7: Result:= $A7; // SECTION SIGN
      $00A8: Result:= $A8; // DIAERESIS
      $00A9: Result:= $A9; // COPYRIGHT SIGN
      $00AA: Result:= $AA; // FEMININE ORDINAL INDICATOR
      $00AB: Result:= $AB; // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; // NOT SIGN
      $00AD: Result:= $AD; // SOFT HYPHEN
      $00AE: Result:= $AE; // REGISTERED SIGN
      $00AF: Result:= $AF; // MACRON
      $00B0: Result:= $B0; // DEGREE SIGN
      $00B1: Result:= $B1; // PLUS-MINUS SIGN
      $00B2: Result:= $B2; // SUPERSCRIPT TWO
      $00B3: Result:= $B3; // SUPERSCRIPT THREE
      $00B4: Result:= $B4; // ACUTE ACCENT
      $00B5: Result:= $B5; // MICRO SIGN
      $00B6: Result:= $B6; // PILCROW SIGN
      $00B7: Result:= $B7; // MIDDLE DOT
      $00B8: Result:= $B8; // CEDILLA
      $00B9: Result:= $B9; // SUPERSCRIPT ONE
      $00BA: Result:= $BA; // MASCULINE ORDINAL INDICATOR
      $00BB: Result:= $BB; // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; // VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; // VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; // VULGAR FRACTION THREE QUARTERS
      $00BF: Result:= $BF; // INVERTED QUESTION MARK
      $00C0: Result:= $C0; // LATIN CAPITAL LETTER A WITH GRAVE
      $00C1: Result:= $C1; // LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; // LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $0102: Result:= $C3; // LATIN CAPITAL LETTER A WITH BREVE
      $00C4: Result:= $C4; // LATIN CAPITAL LETTER A WITH DIAERESIS
      $00C5: Result:= $C5; // LATIN CAPITAL LETTER A WITH RING ABOVE
      $00C6: Result:= $C6; // LATIN CAPITAL LETTER AE
      $00C7: Result:= $C7; // LATIN CAPITAL LETTER C WITH CEDILLA
      $00C8: Result:= $C8; // LATIN CAPITAL LETTER E WITH GRAVE
      $00C9: Result:= $C9; // LATIN CAPITAL LETTER E WITH ACUTE
      $00CA: Result:= $CA; // LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $00CB: Result:= $CB; // LATIN CAPITAL LETTER E WITH DIAERESIS
      $0300: Result:= $CC; // COMBINING GRAVE ACCENT
      $00CD: Result:= $CD; // LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; // LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $00CF: Result:= $CF; // LATIN CAPITAL LETTER I WITH DIAERESIS
      $0110: Result:= $D0; // LATIN CAPITAL LETTER D WITH STROKE
      $00D1: Result:= $D1; // LATIN CAPITAL LETTER N WITH TILDE
      $0309: Result:= $D2; // COMBINING HOOK ABOVE
      $00D3: Result:= $D3; // LATIN CAPITAL LETTER O WITH ACUTE
      $00D4: Result:= $D4; // LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $01A0: Result:= $D5; // LATIN CAPITAL LETTER O WITH HORN
      $00D6: Result:= $D6; // LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; // MULTIPLICATION SIGN
      $00D8: Result:= $D8; // LATIN CAPITAL LETTER O WITH STROKE
      $00D9: Result:= $D9; // LATIN CAPITAL LETTER U WITH GRAVE
      $00DA: Result:= $DA; // LATIN CAPITAL LETTER U WITH ACUTE
      $00DB: Result:= $DB; // LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $00DC: Result:= $DC; // LATIN CAPITAL LETTER U WITH DIAERESIS
      $01AF: Result:= $DD; // LATIN CAPITAL LETTER U WITH HORN
      $0303: Result:= $DE; // COMBINING TILDE
      $00DF: Result:= $DF; // LATIN SMALL LETTER SHARP S
      $00E0: Result:= $E0; // LATIN SMALL LETTER A WITH GRAVE
      $00E1: Result:= $E1; // LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; // LATIN SMALL LETTER A WITH CIRCUMFLEX
      $0103: Result:= $E3; // LATIN SMALL LETTER A WITH BREVE
      $00E4: Result:= $E4; // LATIN SMALL LETTER A WITH DIAERESIS
      $00E5: Result:= $E5; // LATIN SMALL LETTER A WITH RING ABOVE
      $00E6: Result:= $E6; // LATIN SMALL LETTER AE
      $00E7: Result:= $E7; // LATIN SMALL LETTER C WITH CEDILLA
      $00E8: Result:= $E8; // LATIN SMALL LETTER E WITH GRAVE
      $00E9: Result:= $E9; // LATIN SMALL LETTER E WITH ACUTE
      $00EA: Result:= $EA; // LATIN SMALL LETTER E WITH CIRCUMFLEX
      $00EB: Result:= $EB; // LATIN SMALL LETTER E WITH DIAERESIS
      $0301: Result:= $EC; // COMBINING ACUTE ACCENT
      $00ED: Result:= $ED; // LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; // LATIN SMALL LETTER I WITH CIRCUMFLEX
      $00EF: Result:= $EF; // LATIN SMALL LETTER I WITH DIAERESIS
      $0111: Result:= $F0; // LATIN SMALL LETTER D WITH STROKE
      $00F1: Result:= $F1; // LATIN SMALL LETTER N WITH TILDE
      $0323: Result:= $F2; // COMBINING DOT BELOW
      $00F3: Result:= $F3; // LATIN SMALL LETTER O WITH ACUTE
      $00F4: Result:= $F4; // LATIN SMALL LETTER O WITH CIRCUMFLEX
      $01A1: Result:= $F5; // LATIN SMALL LETTER O WITH HORN
      $00F6: Result:= $F6; // LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; // DIVISION SIGN
      $00F8: Result:= $F8; // LATIN SMALL LETTER O WITH STROKE
      $00F9: Result:= $F9; // LATIN SMALL LETTER U WITH GRAVE
      $00FA: Result:= $FA; // LATIN SMALL LETTER U WITH ACUTE
      $00FB: Result:= $FB; // LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; // LATIN SMALL LETTER U WITH DIAERESIS
      $01B0: Result:= $FD; // LATIN SMALL LETTER U WITH HORN
      $20AB: Result:= $FE; // DONG SIGN
      $00FF: Result:= $FF; // LATIN SMALL LETTER Y WITH DIAERESIS
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharWin874(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $20AC: Result:= $80; // EURO SIGN
      $2026: Result:= $85; // HORIZONTAL ELLIPSIS
      $2018: Result:= $91; // LEFT SINGLE QUOTATION MARK
      $2019: Result:= $92; // RIGHT SINGLE QUOTATION MARK
      $201C: Result:= $93; // LEFT DOUBLE QUOTATION MARK
      $201D: Result:= $94; // RIGHT DOUBLE QUOTATION MARK
      $2022: Result:= $95; // BULLET
      $2013: Result:= $96; // EN DASH
      $2014: Result:= $97; // EM DASH
      $00A0: Result:= $A0; // NO-BREAK SPACE
      $0E01: Result:= $A1; // THAI CHARACTER KO KAI
      $0E02: Result:= $A2; // THAI CHARACTER KHO KHAI
      $0E03: Result:= $A3; // THAI CHARACTER KHO KHUAT
      $0E04: Result:= $A4; // THAI CHARACTER KHO KHWAI
      $0E05: Result:= $A5; // THAI CHARACTER KHO KHON
      $0E06: Result:= $A6; // THAI CHARACTER KHO RAKHANG
      $0E07: Result:= $A7; // THAI CHARACTER NGO NGU
      $0E08: Result:= $A8; // THAI CHARACTER CHO CHAN
      $0E09: Result:= $A9; // THAI CHARACTER CHO CHING
      $0E0A: Result:= $AA; // THAI CHARACTER CHO CHANG
      $0E0B: Result:= $AB; // THAI CHARACTER SO SO
      $0E0C: Result:= $AC; // THAI CHARACTER CHO CHOE
      $0E0D: Result:= $AD; // THAI CHARACTER YO YING
      $0E0E: Result:= $AE; // THAI CHARACTER DO CHADA
      $0E0F: Result:= $AF; // THAI CHARACTER TO PATAK
      $0E10: Result:= $B0; // THAI CHARACTER THO THAN
      $0E11: Result:= $B1; // THAI CHARACTER THO NANGMONTHO
      $0E12: Result:= $B2; // THAI CHARACTER THO PHUTHAO
      $0E13: Result:= $B3; // THAI CHARACTER NO NEN
      $0E14: Result:= $B4; // THAI CHARACTER DO DEK
      $0E15: Result:= $B5; // THAI CHARACTER TO TAO
      $0E16: Result:= $B6; // THAI CHARACTER THO THUNG
      $0E17: Result:= $B7; // THAI CHARACTER THO THAHAN
      $0E18: Result:= $B8; // THAI CHARACTER THO THONG
      $0E19: Result:= $B9; // THAI CHARACTER NO NU
      $0E1A: Result:= $BA; // THAI CHARACTER BO BAIMAI
      $0E1B: Result:= $BB; // THAI CHARACTER PO PLA
      $0E1C: Result:= $BC; // THAI CHARACTER PHO PHUNG
      $0E1D: Result:= $BD; // THAI CHARACTER FO FA
      $0E1E: Result:= $BE; // THAI CHARACTER PHO PHAN
      $0E1F: Result:= $BF; // THAI CHARACTER FO FAN
      $0E20: Result:= $C0; // THAI CHARACTER PHO SAMPHAO
      $0E21: Result:= $C1; // THAI CHARACTER MO MA
      $0E22: Result:= $C2; // THAI CHARACTER YO YAK
      $0E23: Result:= $C3; // THAI CHARACTER RO RUA
      $0E24: Result:= $C4; // THAI CHARACTER RU
      $0E25: Result:= $C5; // THAI CHARACTER LO LING
      $0E26: Result:= $C6; // THAI CHARACTER LU
      $0E27: Result:= $C7; // THAI CHARACTER WO WAEN
      $0E28: Result:= $C8; // THAI CHARACTER SO SALA
      $0E29: Result:= $C9; // THAI CHARACTER SO RUSI
      $0E2A: Result:= $CA; // THAI CHARACTER SO SUA
      $0E2B: Result:= $CB; // THAI CHARACTER HO HIP
      $0E2C: Result:= $CC; // THAI CHARACTER LO CHULA
      $0E2D: Result:= $CD; // THAI CHARACTER O ANG
      $0E2E: Result:= $CE; // THAI CHARACTER HO NOKHUK
      $0E2F: Result:= $CF; // THAI CHARACTER PAIYANNOI
      $0E30: Result:= $D0; // THAI CHARACTER SARA A
      $0E31: Result:= $D1; // THAI CHARACTER MAI HAN-AKAT
      $0E32: Result:= $D2; // THAI CHARACTER SARA AA
      $0E33: Result:= $D3; // THAI CHARACTER SARA AM
      $0E34: Result:= $D4; // THAI CHARACTER SARA I
      $0E35: Result:= $D5; // THAI CHARACTER SARA II
      $0E36: Result:= $D6; // THAI CHARACTER SARA UE
      $0E37: Result:= $D7; // THAI CHARACTER SARA UEE
      $0E38: Result:= $D8; // THAI CHARACTER SARA U
      $0E39: Result:= $D9; // THAI CHARACTER SARA UU
      $0E3A: Result:= $DA; // THAI CHARACTER PHINTHU
      $0E3F: Result:= $DF; // THAI CURRENCY SYMBOL BAHT
      $0E40: Result:= $E0; // THAI CHARACTER SARA E
      $0E41: Result:= $E1; // THAI CHARACTER SARA AE
      $0E42: Result:= $E2; // THAI CHARACTER SARA O
      $0E43: Result:= $E3; // THAI CHARACTER SARA AI MAIMUAN
      $0E44: Result:= $E4; // THAI CHARACTER SARA AI MAIMALAI
      $0E45: Result:= $E5; // THAI CHARACTER LAKKHANGYAO
      $0E46: Result:= $E6; // THAI CHARACTER MAIYAMOK
      $0E47: Result:= $E7; // THAI CHARACTER MAITAIKHU
      $0E48: Result:= $E8; // THAI CHARACTER MAI EK
      $0E49: Result:= $E9; // THAI CHARACTER MAI THO
      $0E4A: Result:= $EA; // THAI CHARACTER MAI TRI
      $0E4B: Result:= $EB; // THAI CHARACTER MAI CHATTAWA
      $0E4C: Result:= $EC; // THAI CHARACTER THANTHAKHAT
      $0E4D: Result:= $ED; // THAI CHARACTER NIKHAHIT
      $0E4E: Result:= $EE; // THAI CHARACTER YAMAKKAN
      $0E4F: Result:= $EF; // THAI CHARACTER FONGMAN
      $0E50: Result:= $F0; // THAI DIGIT ZERO
      $0E51: Result:= $F1; // THAI DIGIT ONE
      $0E52: Result:= $F2; // THAI DIGIT TWO
      $0E53: Result:= $F3; // THAI DIGIT THREE
      $0E54: Result:= $F4; // THAI DIGIT FOUR
      $0E55: Result:= $F5; // THAI DIGIT FIVE
      $0E56: Result:= $F6; // THAI DIGIT SIX
      $0E57: Result:= $F7; // THAI DIGIT SEVEN
      $0E58: Result:= $F8; // THAI DIGIT EIGHT
      $0E59: Result:= $F9; // THAI DIGIT NINE
      $0E5A: Result:= $FA; // THAI CHARACTER ANGKHANKHU
      $0E5B: Result:= $FB; // THAI CHARACTER KHOMUT
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_1(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $00A1: Result:= $A1; //  INVERTED EXCLAMATION MARK
      $00A2: Result:= $A2; //  CENT SIGN
      $00A3: Result:= $A3; //  POUND SIGN
      $00A4: Result:= $A4; //  CURRENCY SIGN
      $00A5: Result:= $A5; //  YEN SIGN
      $00A6: Result:= $A6; //  BROKEN BAR
      $00A7: Result:= $A7; //  SECTION SIGN
      $00A8: Result:= $A8; //  DIAERESIS
      $00A9: Result:= $A9; //  COPYRIGHT SIGN
      $00AA: Result:= $AA; //  FEMININE ORDINAL INDICATOR
      $00AB: Result:= $AB; //  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; //  NOT SIGN
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $00AE: Result:= $AE; //  REGISTERED SIGN
      $00AF: Result:= $AF; //  MACRON
      $00B0: Result:= $B0; //  DEGREE SIGN
      $00B1: Result:= $B1; //  PLUS-MINUS SIGN
      $00B2: Result:= $B2; //  SUPERSCRIPT TWO
      $00B3: Result:= $B3; //  SUPERSCRIPT THREE
      $00B4: Result:= $B4; //  ACUTE ACCENT
      $00B5: Result:= $B5; //  MICRO SIGN
      $00B6: Result:= $B6; //  PILCROW SIGN
      $00B7: Result:= $B7; //  MIDDLE DOT
      $00B8: Result:= $B8; //  CEDILLA
      $00B9: Result:= $B9; //  SUPERSCRIPT ONE
      $00BA: Result:= $BA; //  MASCULINE ORDINAL INDICATOR
      $00BB: Result:= $BB; //  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; //  VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; //  VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; //  VULGAR FRACTION THREE QUARTERS
      $00BF: Result:= $BF; //  INVERTED QUESTION MARK
      $00C0: Result:= $C0; //  LATIN CAPITAL LETTER A WITH GRAVE
      $00C1: Result:= $C1; //  LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; //  LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $00C3: Result:= $C3; //  LATIN CAPITAL LETTER A WITH TILDE
      $00C4: Result:= $C4; //  LATIN CAPITAL LETTER A WITH DIAERESIS
      $00C5: Result:= $C5; //  LATIN CAPITAL LETTER A WITH RING ABOVE
      $00C6: Result:= $C6; //  LATIN CAPITAL LETTER AE
      $00C7: Result:= $C7; //  LATIN CAPITAL LETTER C WITH CEDILLA
      $00C8: Result:= $C8; //  LATIN CAPITAL LETTER E WITH GRAVE
      $00C9: Result:= $C9; //  LATIN CAPITAL LETTER E WITH ACUTE
      $00CA: Result:= $CA; //  LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $00CB: Result:= $CB; //  LATIN CAPITAL LETTER E WITH DIAERESIS
      $00CC: Result:= $CC; //  LATIN CAPITAL LETTER I WITH GRAVE
      $00CD: Result:= $CD; //  LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; //  LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $00CF: Result:= $CF; //  LATIN CAPITAL LETTER I WITH DIAERESIS
      $00D0: Result:= $D0; //  LATIN CAPITAL LETTER ETH
      $00D1: Result:= $D1; //  LATIN CAPITAL LETTER N WITH TILDE
      $00D2: Result:= $D2; //  LATIN CAPITAL LETTER O WITH GRAVE
      $00D3: Result:= $D3; //  LATIN CAPITAL LETTER O WITH ACUTE
      $00D4: Result:= $D4; //  LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $00D5: Result:= $D5; //  LATIN CAPITAL LETTER O WITH TILDE
      $00D6: Result:= $D6; //  LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; //  MULTIPLICATION SIGN
      $00D8: Result:= $D8; //  LATIN CAPITAL LETTER O WITH STROKE
      $00D9: Result:= $D9; //  LATIN CAPITAL LETTER U WITH GRAVE
      $00DA: Result:= $DA; //  LATIN CAPITAL LETTER U WITH ACUTE
      $00DB: Result:= $DB; //  LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $00DC: Result:= $DC; //  LATIN CAPITAL LETTER U WITH DIAERESIS
      $00DD: Result:= $DD; //  LATIN CAPITAL LETTER Y WITH ACUTE
      $00DE: Result:= $DE; //  LATIN CAPITAL LETTER THORN
      $00DF: Result:= $DF; //  LATIN SMALL LETTER SHARP S
      $00E0: Result:= $E0; //  LATIN SMALL LETTER A WITH GRAVE
      $00E1: Result:= $E1; //  LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; //  LATIN SMALL LETTER A WITH CIRCUMFLEX
      $00E3: Result:= $E3; //  LATIN SMALL LETTER A WITH TILDE
      $00E4: Result:= $E4; //  LATIN SMALL LETTER A WITH DIAERESIS
      $00E5: Result:= $E5; //  LATIN SMALL LETTER A WITH RING ABOVE
      $00E6: Result:= $E6; //  LATIN SMALL LETTER AE
      $00E7: Result:= $E7; //  LATIN SMALL LETTER C WITH CEDILLA
      $00E8: Result:= $E8; //  LATIN SMALL LETTER E WITH GRAVE
      $00E9: Result:= $E9; //  LATIN SMALL LETTER E WITH ACUTE
      $00EA: Result:= $EA; //  LATIN SMALL LETTER E WITH CIRCUMFLEX
      $00EB: Result:= $EB; //  LATIN SMALL LETTER E WITH DIAERESIS
      $00EC: Result:= $EC; //  LATIN SMALL LETTER I WITH GRAVE
      $00ED: Result:= $ED; //  LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; //  LATIN SMALL LETTER I WITH CIRCUMFLEX
      $00EF: Result:= $EF; //  LATIN SMALL LETTER I WITH DIAERESIS
      $00F0: Result:= $F0; //  LATIN SMALL LETTER ETH
      $00F1: Result:= $F1; //  LATIN SMALL LETTER N WITH TILDE
      $00F2: Result:= $F2; //  LATIN SMALL LETTER O WITH GRAVE
      $00F3: Result:= $F3; //  LATIN SMALL LETTER O WITH ACUTE
      $00F4: Result:= $F4; //  LATIN SMALL LETTER O WITH CIRCUMFLEX
      $00F5: Result:= $F5; //  LATIN SMALL LETTER O WITH TILDE
      $00F6: Result:= $F6; //  LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; //  DIVISION SIGN
      $00F8: Result:= $F8; //  LATIN SMALL LETTER O WITH STROKE
      $00F9: Result:= $F9; //  LATIN SMALL LETTER U WITH GRAVE
      $00FA: Result:= $FA; //  LATIN SMALL LETTER U WITH ACUTE
      $00FB: Result:= $FB; //  LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; //  LATIN SMALL LETTER U WITH DIAERESIS
      $00FD: Result:= $FD; //  LATIN SMALL LETTER Y WITH ACUTE
      $00FE: Result:= $FE; //  LATIN SMALL LETTER THORN
      $00FF: Result:= $FF; //  LATIN SMALL LETTER Y WITH DIAERESIS
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_2(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $0104: Result:= $A1; //  LATIN CAPITAL LETTER A WITH OGONEK
      $02D8: Result:= $A2; //  BREVE
      $0141: Result:= $A3; //  LATIN CAPITAL LETTER L WITH STROKE
      $00A4: Result:= $A4; //  CURRENCY SIGN
      $013D: Result:= $A5; //  LATIN CAPITAL LETTER L WITH CARON
      $015A: Result:= $A6; //  LATIN CAPITAL LETTER S WITH ACUTE
      $00A7: Result:= $A7; //  SECTION SIGN
      $00A8: Result:= $A8; //  DIAERESIS
      $0160: Result:= $A9; //  LATIN CAPITAL LETTER S WITH CARON
      $015E: Result:= $AA; //  LATIN CAPITAL LETTER S WITH CEDILLA
      $0164: Result:= $AB; //  LATIN CAPITAL LETTER T WITH CARON
      $0179: Result:= $AC; //  LATIN CAPITAL LETTER Z WITH ACUTE
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $017D: Result:= $AE; //  LATIN CAPITAL LETTER Z WITH CARON
      $017B: Result:= $AF; //  LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $00B0: Result:= $B0; //  DEGREE SIGN
      $0105: Result:= $B1; //  LATIN SMALL LETTER A WITH OGONEK
      $02DB: Result:= $B2; //  OGONEK
      $0142: Result:= $B3; //  LATIN SMALL LETTER L WITH STROKE
      $00B4: Result:= $B4; //  ACUTE ACCENT
      $013E: Result:= $B5; //  LATIN SMALL LETTER L WITH CARON
      $015B: Result:= $B6; //  LATIN SMALL LETTER S WITH ACUTE
      $02C7: Result:= $B7; //  CARON
      $00B8: Result:= $B8; //  CEDILLA
      $0161: Result:= $B9; //  LATIN SMALL LETTER S WITH CARON
      $015F: Result:= $BA; //  LATIN SMALL LETTER S WITH CEDILLA
      $0165: Result:= $BB; //  LATIN SMALL LETTER T WITH CARON
      $017A: Result:= $BC; //  LATIN SMALL LETTER Z WITH ACUTE
      $02DD: Result:= $BD; //  DOUBLE ACUTE ACCENT
      $017E: Result:= $BE; //  LATIN SMALL LETTER Z WITH CARON
      $017C: Result:= $BF; //  LATIN SMALL LETTER Z WITH DOT ABOVE
      $0154: Result:= $C0; //  LATIN CAPITAL LETTER R WITH ACUTE
      $00C1: Result:= $C1; //  LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; //  LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $0102: Result:= $C3; //  LATIN CAPITAL LETTER A WITH BREVE
      $00C4: Result:= $C4; //  LATIN CAPITAL LETTER A WITH DIAERESIS
      $0139: Result:= $C5; //  LATIN CAPITAL LETTER L WITH ACUTE
      $0106: Result:= $C6; //  LATIN CAPITAL LETTER C WITH ACUTE
      $00C7: Result:= $C7; //  LATIN CAPITAL LETTER C WITH CEDILLA
      $010C: Result:= $C8; //  LATIN CAPITAL LETTER C WITH CARON
      $00C9: Result:= $C9; //  LATIN CAPITAL LETTER E WITH ACUTE
      $0118: Result:= $CA; //  LATIN CAPITAL LETTER E WITH OGONEK
      $00CB: Result:= $CB; //  LATIN CAPITAL LETTER E WITH DIAERESIS
      $011A: Result:= $CC; //  LATIN CAPITAL LETTER E WITH CARON
      $00CD: Result:= $CD; //  LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; //  LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $010E: Result:= $CF; //  LATIN CAPITAL LETTER D WITH CARON
      $0110: Result:= $D0; //  LATIN CAPITAL LETTER D WITH STROKE
      $0143: Result:= $D1; //  LATIN CAPITAL LETTER N WITH ACUTE
      $0147: Result:= $D2; //  LATIN CAPITAL LETTER N WITH CARON
      $00D3: Result:= $D3; //  LATIN CAPITAL LETTER O WITH ACUTE
      $00D4: Result:= $D4; //  LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $0150: Result:= $D5; //  LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
      $00D6: Result:= $D6; //  LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; //  MULTIPLICATION SIGN
      $0158: Result:= $D8; //  LATIN CAPITAL LETTER R WITH CARON
      $016E: Result:= $D9; //  LATIN CAPITAL LETTER U WITH RING ABOVE
      $00DA: Result:= $DA; //  LATIN CAPITAL LETTER U WITH ACUTE
      $0170: Result:= $DB; //  LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
      $00DC: Result:= $DC; //  LATIN CAPITAL LETTER U WITH DIAERESIS
      $00DD: Result:= $DD; //  LATIN CAPITAL LETTER Y WITH ACUTE
      $0162: Result:= $DE; //  LATIN CAPITAL LETTER T WITH CEDILLA
      $00DF: Result:= $DF; //  LATIN SMALL LETTER SHARP S
      $0155: Result:= $E0; //  LATIN SMALL LETTER R WITH ACUTE
      $00E1: Result:= $E1; //  LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; //  LATIN SMALL LETTER A WITH CIRCUMFLEX
      $0103: Result:= $E3; //  LATIN SMALL LETTER A WITH BREVE
      $00E4: Result:= $E4; //  LATIN SMALL LETTER A WITH DIAERESIS
      $013A: Result:= $E5; //  LATIN SMALL LETTER L WITH ACUTE
      $0107: Result:= $E6; //  LATIN SMALL LETTER C WITH ACUTE
      $00E7: Result:= $E7; //  LATIN SMALL LETTER C WITH CEDILLA
      $010D: Result:= $E8; //  LATIN SMALL LETTER C WITH CARON
      $00E9: Result:= $E9; //  LATIN SMALL LETTER E WITH ACUTE
      $0119: Result:= $EA; //  LATIN SMALL LETTER E WITH OGONEK
      $00EB: Result:= $EB; //  LATIN SMALL LETTER E WITH DIAERESIS
      $011B: Result:= $EC; //  LATIN SMALL LETTER E WITH CARON
      $00ED: Result:= $ED; //  LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; //  LATIN SMALL LETTER I WITH CIRCUMFLEX
      $010F: Result:= $EF; //  LATIN SMALL LETTER D WITH CARON
      $0111: Result:= $F0; //  LATIN SMALL LETTER D WITH STROKE
      $0144: Result:= $F1; //  LATIN SMALL LETTER N WITH ACUTE
      $0148: Result:= $F2; //  LATIN SMALL LETTER N WITH CARON
      $00F3: Result:= $F3; //  LATIN SMALL LETTER O WITH ACUTE
      $00F4: Result:= $F4; //  LATIN SMALL LETTER O WITH CIRCUMFLEX
      $0151: Result:= $F5; //  LATIN SMALL LETTER O WITH DOUBLE ACUTE
      $00F6: Result:= $F6; //  LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; //  DIVISION SIGN
      $0159: Result:= $F8; //  LATIN SMALL LETTER R WITH CARON
      $016F: Result:= $F9; //  LATIN SMALL LETTER U WITH RING ABOVE
      $00FA: Result:= $FA; //  LATIN SMALL LETTER U WITH ACUTE
      $0171: Result:= $FB; //  LATIN SMALL LETTER U WITH DOUBLE ACUTE
      $00FC: Result:= $FC; //  LATIN SMALL LETTER U WITH DIAERESIS
      $00FD: Result:= $FD; //  LATIN SMALL LETTER Y WITH ACUTE
      $0163: Result:= $FE; //  LATIN SMALL LETTER T WITH CEDILLA
      $02D9: Result:= $FF; //  DOT ABOVE
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_3(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $0126: Result:= $A1; //  LATIN CAPITAL LETTER H WITH STROKE
      $02D8: Result:= $A2; //  BREVE
      $00A3: Result:= $A3; //  POUND SIGN
      $00A4: Result:= $A4; //  CURRENCY SIGN
      $0124: Result:= $A6; //  LATIN CAPITAL LETTER H WITH CIRCUMFLEX
      $00A7: Result:= $A7; //  SECTION SIGN
      $00A8: Result:= $A8; //  DIAERESIS
      $0130: Result:= $A9; //  LATIN CAPITAL LETTER I WITH DOT ABOVE
      $015E: Result:= $AA; //  LATIN CAPITAL LETTER S WITH CEDILLA
      $011E: Result:= $AB; //  LATIN CAPITAL LETTER G WITH BREVE
      $0134: Result:= $AC; //  LATIN CAPITAL LETTER J WITH CIRCUMFLEX
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $017B: Result:= $AF; //  LATIN CAPITAL LETTER Z WITH DOT ABOVE
      $00B0: Result:= $B0; //  DEGREE SIGN
      $0127: Result:= $B1; //  LATIN SMALL LETTER H WITH STROKE
      $00B2: Result:= $B2; //  SUPERSCRIPT TWO
      $00B3: Result:= $B3; //  SUPERSCRIPT THREE
      $00B4: Result:= $B4; //  ACUTE ACCENT
      $00B5: Result:= $B5; //  MICRO SIGN
      $0125: Result:= $B6; //  LATIN SMALL LETTER H WITH CIRCUMFLEX
      $00B7: Result:= $B7; //  MIDDLE DOT
      $00B8: Result:= $B8; //  CEDILLA
      $0131: Result:= $B9; //  LATIN SMALL LETTER DOTLESS I
      $015F: Result:= $BA; //  LATIN SMALL LETTER S WITH CEDILLA
      $011F: Result:= $BB; //  LATIN SMALL LETTER G WITH BREVE
      $0135: Result:= $BC; //  LATIN SMALL LETTER J WITH CIRCUMFLEX
      $00BD: Result:= $BD; //  VULGAR FRACTION ONE HALF
      $017C: Result:= $BF; //  LATIN SMALL LETTER Z WITH DOT ABOVE
      $00C0: Result:= $C0; //  LATIN CAPITAL LETTER A WITH GRAVE
      $00C1: Result:= $C1; //  LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; //  LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $00C4: Result:= $C4; //  LATIN CAPITAL LETTER A WITH DIAERESIS
      $010A: Result:= $C5; //  LATIN CAPITAL LETTER C WITH DOT ABOVE
      $0108: Result:= $C6; //  LATIN CAPITAL LETTER C WITH CIRCUMFLEX
      $00C7: Result:= $C7; //  LATIN CAPITAL LETTER C WITH CEDILLA
      $00C8: Result:= $C8; //  LATIN CAPITAL LETTER E WITH GRAVE
      $00C9: Result:= $C9; //  LATIN CAPITAL LETTER E WITH ACUTE
      $00CA: Result:= $CA; //  LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $00CB: Result:= $CB; //  LATIN CAPITAL LETTER E WITH DIAERESIS
      $00CC: Result:= $CC; //  LATIN CAPITAL LETTER I WITH GRAVE
      $00CD: Result:= $CD; //  LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; //  LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $00CF: Result:= $CF; //  LATIN CAPITAL LETTER I WITH DIAERESIS
      $00D1: Result:= $D1; //  LATIN CAPITAL LETTER N WITH TILDE
      $00D2: Result:= $D2; //  LATIN CAPITAL LETTER O WITH GRAVE
      $00D3: Result:= $D3; //  LATIN CAPITAL LETTER O WITH ACUTE
      $00D4: Result:= $D4; //  LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $0120: Result:= $D5; //  LATIN CAPITAL LETTER G WITH DOT ABOVE
      $00D6: Result:= $D6; //  LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; //  MULTIPLICATION SIGN
      $011C: Result:= $D8; //  LATIN CAPITAL LETTER G WITH CIRCUMFLEX
      $00D9: Result:= $D9; //  LATIN CAPITAL LETTER U WITH GRAVE
      $00DA: Result:= $DA; //  LATIN CAPITAL LETTER U WITH ACUTE
      $00DB: Result:= $DB; //  LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $00DC: Result:= $DC; //  LATIN CAPITAL LETTER U WITH DIAERESIS
      $016C: Result:= $DD; //  LATIN CAPITAL LETTER U WITH BREVE
      $015C: Result:= $DE; //  LATIN CAPITAL LETTER S WITH CIRCUMFLEX
      $00DF: Result:= $DF; //  LATIN SMALL LETTER SHARP S
      $00E0: Result:= $E0; //  LATIN SMALL LETTER A WITH GRAVE
      $00E1: Result:= $E1; //  LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; //  LATIN SMALL LETTER A WITH CIRCUMFLEX
      $00E4: Result:= $E4; //  LATIN SMALL LETTER A WITH DIAERESIS
      $010B: Result:= $E5; //  LATIN SMALL LETTER C WITH DOT ABOVE
      $0109: Result:= $E6; //  LATIN SMALL LETTER C WITH CIRCUMFLEX
      $00E7: Result:= $E7; //  LATIN SMALL LETTER C WITH CEDILLA
      $00E8: Result:= $E8; //  LATIN SMALL LETTER E WITH GRAVE
      $00E9: Result:= $E9; //  LATIN SMALL LETTER E WITH ACUTE
      $00EA: Result:= $EA; //  LATIN SMALL LETTER E WITH CIRCUMFLEX
      $00EB: Result:= $EB; //  LATIN SMALL LETTER E WITH DIAERESIS
      $00EC: Result:= $EC; //  LATIN SMALL LETTER I WITH GRAVE
      $00ED: Result:= $ED; //  LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; //  LATIN SMALL LETTER I WITH CIRCUMFLEX
      $00EF: Result:= $EF; //  LATIN SMALL LETTER I WITH DIAERESIS
      $00F1: Result:= $F1; //  LATIN SMALL LETTER N WITH TILDE
      $00F2: Result:= $F2; //  LATIN SMALL LETTER O WITH GRAVE
      $00F3: Result:= $F3; //  LATIN SMALL LETTER O WITH ACUTE
      $00F4: Result:= $F4; //  LATIN SMALL LETTER O WITH CIRCUMFLEX
      $0121: Result:= $F5; //  LATIN SMALL LETTER G WITH DOT ABOVE
      $00F6: Result:= $F6; //  LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; //  DIVISION SIGN
      $011D: Result:= $F8; //  LATIN SMALL LETTER G WITH CIRCUMFLEX
      $00F9: Result:= $F9; //  LATIN SMALL LETTER U WITH GRAVE
      $00FA: Result:= $FA; //  LATIN SMALL LETTER U WITH ACUTE
      $00FB: Result:= $FB; //  LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; //  LATIN SMALL LETTER U WITH DIAERESIS
      $016D: Result:= $FD; //  LATIN SMALL LETTER U WITH BREVE
      $015D: Result:= $FE; //  LATIN SMALL LETTER S WITH CIRCUMFLEX
      $02D9: Result:= $FF; //  DOT ABOVE
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_4(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $0104: Result:= $A1; //  LATIN CAPITAL LETTER A WITH OGONEK
      $0138: Result:= $A2; //  LATIN SMALL LETTER KRA
      $0156: Result:= $A3; //  LATIN CAPITAL LETTER R WITH CEDILLA
      $00A4: Result:= $A4; //  CURRENCY SIGN
      $0128: Result:= $A5; //  LATIN CAPITAL LETTER I WITH TILDE
      $013B: Result:= $A6; //  LATIN CAPITAL LETTER L WITH CEDILLA
      $00A7: Result:= $A7; //  SECTION SIGN
      $00A8: Result:= $A8; //  DIAERESIS
      $0160: Result:= $A9; //  LATIN CAPITAL LETTER S WITH CARON
      $0112: Result:= $AA; //  LATIN CAPITAL LETTER E WITH MACRON
      $0122: Result:= $AB; //  LATIN CAPITAL LETTER G WITH CEDILLA
      $0166: Result:= $AC; //  LATIN CAPITAL LETTER T WITH STROKE
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $017D: Result:= $AE; //  LATIN CAPITAL LETTER Z WITH CARON
      $00AF: Result:= $AF; //  MACRON
      $00B0: Result:= $B0; //  DEGREE SIGN
      $0105: Result:= $B1; //  LATIN SMALL LETTER A WITH OGONEK
      $02DB: Result:= $B2; //  OGONEK
      $0157: Result:= $B3; //  LATIN SMALL LETTER R WITH CEDILLA
      $00B4: Result:= $B4; //  ACUTE ACCENT
      $0129: Result:= $B5; //  LATIN SMALL LETTER I WITH TILDE
      $013C: Result:= $B6; //  LATIN SMALL LETTER L WITH CEDILLA
      $02C7: Result:= $B7; //  CARON
      $00B8: Result:= $B8; //  CEDILLA
      $0161: Result:= $B9; //  LATIN SMALL LETTER S WITH CARON
      $0113: Result:= $BA; //  LATIN SMALL LETTER E WITH MACRON
      $0123: Result:= $BB; //  LATIN SMALL LETTER G WITH CEDILLA
      $0167: Result:= $BC; //  LATIN SMALL LETTER T WITH STROKE
      $014A: Result:= $BD; //  LATIN CAPITAL LETTER ENG
      $017E: Result:= $BE; //  LATIN SMALL LETTER Z WITH CARON
      $014B: Result:= $BF; //  LATIN SMALL LETTER ENG
      $0100: Result:= $C0; //  LATIN CAPITAL LETTER A WITH MACRON
      $00C1: Result:= $C1; //  LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; //  LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $00C3: Result:= $C3; //  LATIN CAPITAL LETTER A WITH TILDE
      $00C4: Result:= $C4; //  LATIN CAPITAL LETTER A WITH DIAERESIS
      $00C5: Result:= $C5; //  LATIN CAPITAL LETTER A WITH RING ABOVE
      $00C6: Result:= $C6; //  LATIN CAPITAL LETTER AE
      $012E: Result:= $C7; //  LATIN CAPITAL LETTER I WITH OGONEK
      $010C: Result:= $C8; //  LATIN CAPITAL LETTER C WITH CARON
      $00C9: Result:= $C9; //  LATIN CAPITAL LETTER E WITH ACUTE
      $0118: Result:= $CA; //  LATIN CAPITAL LETTER E WITH OGONEK
      $00CB: Result:= $CB; //  LATIN CAPITAL LETTER E WITH DIAERESIS
      $0116: Result:= $CC; //  LATIN CAPITAL LETTER E WITH DOT ABOVE
      $00CD: Result:= $CD; //  LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; //  LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $012A: Result:= $CF; //  LATIN CAPITAL LETTER I WITH MACRON
      $0110: Result:= $D0; //  LATIN CAPITAL LETTER D WITH STROKE
      $0145: Result:= $D1; //  LATIN CAPITAL LETTER N WITH CEDILLA
      $014C: Result:= $D2; //  LATIN CAPITAL LETTER O WITH MACRON
      $0136: Result:= $D3; //  LATIN CAPITAL LETTER K WITH CEDILLA
      $00D4: Result:= $D4; //  LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $00D5: Result:= $D5; //  LATIN CAPITAL LETTER O WITH TILDE
      $00D6: Result:= $D6; //  LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; //  MULTIPLICATION SIGN
      $00D8: Result:= $D8; //  LATIN CAPITAL LETTER O WITH STROKE
      $0172: Result:= $D9; //  LATIN CAPITAL LETTER U WITH OGONEK
      $00DA: Result:= $DA; //  LATIN CAPITAL LETTER U WITH ACUTE
      $00DB: Result:= $DB; //  LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $00DC: Result:= $DC; //  LATIN CAPITAL LETTER U WITH DIAERESIS
      $0168: Result:= $DD; //  LATIN CAPITAL LETTER U WITH TILDE
      $016A: Result:= $DE; //  LATIN CAPITAL LETTER U WITH MACRON
      $00DF: Result:= $DF; //  LATIN SMALL LETTER SHARP S
      $0101: Result:= $E0; //  LATIN SMALL LETTER A WITH MACRON
      $00E1: Result:= $E1; //  LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; //  LATIN SMALL LETTER A WITH CIRCUMFLEX
      $00E3: Result:= $E3; //  LATIN SMALL LETTER A WITH TILDE
      $00E4: Result:= $E4; //  LATIN SMALL LETTER A WITH DIAERESIS
      $00E5: Result:= $E5; //  LATIN SMALL LETTER A WITH RING ABOVE
      $00E6: Result:= $E6; //  LATIN SMALL LETTER AE
      $012F: Result:= $E7; //  LATIN SMALL LETTER I WITH OGONEK
      $010D: Result:= $E8; //  LATIN SMALL LETTER C WITH CARON
      $00E9: Result:= $E9; //  LATIN SMALL LETTER E WITH ACUTE
      $0119: Result:= $EA; //  LATIN SMALL LETTER E WITH OGONEK
      $00EB: Result:= $EB; //  LATIN SMALL LETTER E WITH DIAERESIS
      $0117: Result:= $EC; //  LATIN SMALL LETTER E WITH DOT ABOVE
      $00ED: Result:= $ED; //  LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; //  LATIN SMALL LETTER I WITH CIRCUMFLEX
      $012B: Result:= $EF; //  LATIN SMALL LETTER I WITH MACRON
      $0111: Result:= $F0; //  LATIN SMALL LETTER D WITH STROKE
      $0146: Result:= $F1; //  LATIN SMALL LETTER N WITH CEDILLA
      $014D: Result:= $F2; //  LATIN SMALL LETTER O WITH MACRON
      $0137: Result:= $F3; //  LATIN SMALL LETTER K WITH CEDILLA
      $00F4: Result:= $F4; //  LATIN SMALL LETTER O WITH CIRCUMFLEX
      $00F5: Result:= $F5; //  LATIN SMALL LETTER O WITH TILDE
      $00F6: Result:= $F6; //  LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; //  DIVISION SIGN
      $00F8: Result:= $F8; //  LATIN SMALL LETTER O WITH STROKE
      $0173: Result:= $F9; //  LATIN SMALL LETTER U WITH OGONEK
      $00FA: Result:= $FA; //  LATIN SMALL LETTER U WITH ACUTE
      $00FB: Result:= $FB; //  LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; //  LATIN SMALL LETTER U WITH DIAERESIS
      $0169: Result:= $FD; //  LATIN SMALL LETTER U WITH TILDE
      $016B: Result:= $FE; //  LATIN SMALL LETTER U WITH MACRON
      $02D9: Result:= $FF; //  DOT ABOVE
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_5(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $0401: Result:= $A1; //  CYRILLIC CAPITAL LETTER IO
      $0402: Result:= $A2; //  CYRILLIC CAPITAL LETTER DJE
      $0403: Result:= $A3; //  CYRILLIC CAPITAL LETTER GJE
      $0404: Result:= $A4; //  CYRILLIC CAPITAL LETTER UKRAINIAN IE
      $0405: Result:= $A5; //  CYRILLIC CAPITAL LETTER DZE
      $0406: Result:= $A6; //  CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
      $0407: Result:= $A7; //  CYRILLIC CAPITAL LETTER YI
      $0408: Result:= $A8; //  CYRILLIC CAPITAL LETTER JE
      $0409: Result:= $A9; //  CYRILLIC CAPITAL LETTER LJE
      $040A: Result:= $AA; //  CYRILLIC CAPITAL LETTER NJE
      $040B: Result:= $AB; //  CYRILLIC CAPITAL LETTER TSHE
      $040C: Result:= $AC; //  CYRILLIC CAPITAL LETTER KJE
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $040E: Result:= $AE; //  CYRILLIC CAPITAL LETTER SHORT U
      $040F: Result:= $AF; //  CYRILLIC CAPITAL LETTER DZHE
      $0410: Result:= $B0; //  CYRILLIC CAPITAL LETTER A
      $0411: Result:= $B1; //  CYRILLIC CAPITAL LETTER BE
      $0412: Result:= $B2; //  CYRILLIC CAPITAL LETTER VE
      $0413: Result:= $B3; //  CYRILLIC CAPITAL LETTER GHE
      $0414: Result:= $B4; //  CYRILLIC CAPITAL LETTER DE
      $0415: Result:= $B5; //  CYRILLIC CAPITAL LETTER IE
      $0416: Result:= $B6; //  CYRILLIC CAPITAL LETTER ZHE
      $0417: Result:= $B7; //  CYRILLIC CAPITAL LETTER ZE
      $0418: Result:= $B8; //  CYRILLIC CAPITAL LETTER I
      $0419: Result:= $B9; //  CYRILLIC CAPITAL LETTER SHORT I
      $041A: Result:= $BA; //  CYRILLIC CAPITAL LETTER KA
      $041B: Result:= $BB; //  CYRILLIC CAPITAL LETTER EL
      $041C: Result:= $BC; //  CYRILLIC CAPITAL LETTER EM
      $041D: Result:= $BD; //  CYRILLIC CAPITAL LETTER EN
      $041E: Result:= $BE; //  CYRILLIC CAPITAL LETTER O
      $041F: Result:= $BF; //  CYRILLIC CAPITAL LETTER PE
      $0420: Result:= $C0; //  CYRILLIC CAPITAL LETTER ER
      $0421: Result:= $C1; //  CYRILLIC CAPITAL LETTER ES
      $0422: Result:= $C2; //  CYRILLIC CAPITAL LETTER TE
      $0423: Result:= $C3; //  CYRILLIC CAPITAL LETTER U
      $0424: Result:= $C4; //  CYRILLIC CAPITAL LETTER EF
      $0425: Result:= $C5; //  CYRILLIC CAPITAL LETTER HA
      $0426: Result:= $C6; //  CYRILLIC CAPITAL LETTER TSE
      $0427: Result:= $C7; //  CYRILLIC CAPITAL LETTER CHE
      $0428: Result:= $C8; //  CYRILLIC CAPITAL LETTER SHA
      $0429: Result:= $C9; //  CYRILLIC CAPITAL LETTER SHCHA
      $042A: Result:= $CA; //  CYRILLIC CAPITAL LETTER HARD SIGN
      $042B: Result:= $CB; //  CYRILLIC CAPITAL LETTER YERU
      $042C: Result:= $CC; //  CYRILLIC CAPITAL LETTER SOFT SIGN
      $042D: Result:= $CD; //  CYRILLIC CAPITAL LETTER E
      $042E: Result:= $CE; //  CYRILLIC CAPITAL LETTER YU
      $042F: Result:= $CF; //  CYRILLIC CAPITAL LETTER YA
      $0430: Result:= $D0; //  CYRILLIC SMALL LETTER A
      $0431: Result:= $D1; //  CYRILLIC SMALL LETTER BE
      $0432: Result:= $D2; //  CYRILLIC SMALL LETTER VE
      $0433: Result:= $D3; //  CYRILLIC SMALL LETTER GHE
      $0434: Result:= $D4; //  CYRILLIC SMALL LETTER DE
      $0435: Result:= $D5; //  CYRILLIC SMALL LETTER IE
      $0436: Result:= $D6; //  CYRILLIC SMALL LETTER ZHE
      $0437: Result:= $D7; //  CYRILLIC SMALL LETTER ZE
      $0438: Result:= $D8; //  CYRILLIC SMALL LETTER I
      $0439: Result:= $D9; //  CYRILLIC SMALL LETTER SHORT I
      $043A: Result:= $DA; //  CYRILLIC SMALL LETTER KA
      $043B: Result:= $DB; //  CYRILLIC SMALL LETTER EL
      $043C: Result:= $DC; //  CYRILLIC SMALL LETTER EM
      $043D: Result:= $DD; //  CYRILLIC SMALL LETTER EN
      $043E: Result:= $DE; //  CYRILLIC SMALL LETTER O
      $043F: Result:= $DF; //  CYRILLIC SMALL LETTER PE
      $0440: Result:= $E0; //  CYRILLIC SMALL LETTER ER
      $0441: Result:= $E1; //  CYRILLIC SMALL LETTER ES
      $0442: Result:= $E2; //  CYRILLIC SMALL LETTER TE
      $0443: Result:= $E3; //  CYRILLIC SMALL LETTER U
      $0444: Result:= $E4; //  CYRILLIC SMALL LETTER EF
      $0445: Result:= $E5; //  CYRILLIC SMALL LETTER HA
      $0446: Result:= $E6; //  CYRILLIC SMALL LETTER TSE
      $0447: Result:= $E7; //  CYRILLIC SMALL LETTER CHE
      $0448: Result:= $E8; //  CYRILLIC SMALL LETTER SHA
      $0449: Result:= $E9; //  CYRILLIC SMALL LETTER SHCHA
      $044A: Result:= $EA; //  CYRILLIC SMALL LETTER HARD SIGN
      $044B: Result:= $EB; //  CYRILLIC SMALL LETTER YERU
      $044C: Result:= $EC; //  CYRILLIC SMALL LETTER SOFT SIGN
      $044D: Result:= $ED; //  CYRILLIC SMALL LETTER E
      $044E: Result:= $EE; //  CYRILLIC SMALL LETTER YU
      $044F: Result:= $EF; //  CYRILLIC SMALL LETTER YA
      $2116: Result:= $F0; //  NUMERO SIGN
      $0451: Result:= $F1; //  CYRILLIC SMALL LETTER IO
      $0452: Result:= $F2; //  CYRILLIC SMALL LETTER DJE
      $0453: Result:= $F3; //  CYRILLIC SMALL LETTER GJE
      $0454: Result:= $F4; //  CYRILLIC SMALL LETTER UKRAINIAN IE
      $0455: Result:= $F5; //  CYRILLIC SMALL LETTER DZE
      $0456: Result:= $F6; //  CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
      $0457: Result:= $F7; //  CYRILLIC SMALL LETTER YI
      $0458: Result:= $F8; //  CYRILLIC SMALL LETTER JE
      $0459: Result:= $F9; //  CYRILLIC SMALL LETTER LJE
      $045A: Result:= $FA; //  CYRILLIC SMALL LETTER NJE
      $045B: Result:= $FB; //  CYRILLIC SMALL LETTER TSHE
      $045C: Result:= $FC; //  CYRILLIC SMALL LETTER KJE
      $00A7: Result:= $FD; //  SECTION SIGN
      $045E: Result:= $FE; //  CYRILLIC SMALL LETTER SHORT U
      $045F: Result:= $FF; //  CYRILLIC SMALL LETTER DZHE
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_6(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $00A4: Result:= $A4; //  CURRENCY SIGN
      $060C: Result:= $AC; //  ARABIC COMMA
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $061B: Result:= $BB; //  ARABIC SEMICOLON
      $061F: Result:= $BF; //  ARABIC QUESTION MARK
      $0621: Result:= $C1; //  ARABIC LETTER HAMZA
      $0622: Result:= $C2; //  ARABIC LETTER ALEF WITH MADDA ABOVE
      $0623: Result:= $C3; //  ARABIC LETTER ALEF WITH HAMZA ABOVE
      $0624: Result:= $C4; //  ARABIC LETTER WAW WITH HAMZA ABOVE
      $0625: Result:= $C5; //  ARABIC LETTER ALEF WITH HAMZA BELOW
      $0626: Result:= $C6; //  ARABIC LETTER YEH WITH HAMZA ABOVE
      $0627: Result:= $C7; //  ARABIC LETTER ALEF
      $0628: Result:= $C8; //  ARABIC LETTER BEH
      $0629: Result:= $C9; //  ARABIC LETTER TEH MARBUTA
      $062A: Result:= $CA; //  ARABIC LETTER TEH
      $062B: Result:= $CB; //  ARABIC LETTER THEH
      $062C: Result:= $CC; //  ARABIC LETTER JEEM
      $062D: Result:= $CD; //  ARABIC LETTER HAH
      $062E: Result:= $CE; //  ARABIC LETTER KHAH
      $062F: Result:= $CF; //  ARABIC LETTER DAL
      $0630: Result:= $D0; //  ARABIC LETTER THAL
      $0631: Result:= $D1; //  ARABIC LETTER REH
      $0632: Result:= $D2; //  ARABIC LETTER ZAIN
      $0633: Result:= $D3; //  ARABIC LETTER SEEN
      $0634: Result:= $D4; //  ARABIC LETTER SHEEN
      $0635: Result:= $D5; //  ARABIC LETTER SAD
      $0636: Result:= $D6; //  ARABIC LETTER DAD
      $0637: Result:= $D7; //  ARABIC LETTER TAH
      $0638: Result:= $D8; //  ARABIC LETTER ZAH
      $0639: Result:= $D9; //  ARABIC LETTER AIN
      $063A: Result:= $DA; //  ARABIC LETTER GHAIN
      $0640: Result:= $E0; //  ARABIC TATWEEL
      $0641: Result:= $E1; //  ARABIC LETTER FEH
      $0642: Result:= $E2; //  ARABIC LETTER QAF
      $0643: Result:= $E3; //  ARABIC LETTER KAF
      $0644: Result:= $E4; //  ARABIC LETTER LAM
      $0645: Result:= $E5; //  ARABIC LETTER MEEM
      $0646: Result:= $E6; //  ARABIC LETTER NOON
      $0647: Result:= $E7; //  ARABIC LETTER HEH
      $0648: Result:= $E8; //  ARABIC LETTER WAW
      $0649: Result:= $E9; //  ARABIC LETTER ALEF MAKSURA
      $064A: Result:= $EA; //  ARABIC LETTER YEH
      $064B: Result:= $EB; //  ARABIC FATHATAN
      $064C: Result:= $EC; //  ARABIC DAMMATAN
      $064D: Result:= $ED; //  ARABIC KASRATAN
      $064E: Result:= $EE; //  ARABIC FATHA
      $064F: Result:= $EF; //  ARABIC DAMMA
      $0650: Result:= $F0; //  ARABIC KASRA
      $0651: Result:= $F1; //  ARABIC SHADDA
      $0652: Result:= $F2; //  ARABIC SUKUN
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_7(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $02BD: Result:= $A1; //  MODIFIER LETTER REVERSED COMMA
      $02BC: Result:= $A2; //  MODIFIER LETTER APOSTROPHE
      $00A3: Result:= $A3; //  POUND SIGN
      $00A6: Result:= $A6; //  BROKEN BAR
      $00A7: Result:= $A7; //  SECTION SIGN
      $00A8: Result:= $A8; //  DIAERESIS
      $00A9: Result:= $A9; //  COPYRIGHT SIGN
      $00AB: Result:= $AB; //  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; //  NOT SIGN
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $2015: Result:= $AF; //  HORIZONTAL BAR
      $00B0: Result:= $B0; //  DEGREE SIGN
      $00B1: Result:= $B1; //  PLUS-MINUS SIGN
      $00B2: Result:= $B2; //  SUPERSCRIPT TWO
      $00B3: Result:= $B3; //  SUPERSCRIPT THREE
      $0384: Result:= $B4; //  GREEK TONOS
      $0385: Result:= $B5; //  GREEK DIALYTIKA TONOS
      $0386: Result:= $B6; //  GREEK CAPITAL LETTER ALPHA WITH TONOS
      $00B7: Result:= $B7; //  MIDDLE DOT
      $0388: Result:= $B8; //  GREEK CAPITAL LETTER EPSILON WITH TONOS
      $0389: Result:= $B9; //  GREEK CAPITAL LETTER ETA WITH TONOS
      $038A: Result:= $BA; //  GREEK CAPITAL LETTER IOTA WITH TONOS
      $00BB: Result:= $BB; //  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $038C: Result:= $BC; //  GREEK CAPITAL LETTER OMICRON WITH TONOS
      $00BD: Result:= $BD; //  VULGAR FRACTION ONE HALF
      $038E: Result:= $BE; //  GREEK CAPITAL LETTER UPSILON WITH TONOS
      $038F: Result:= $BF; //  GREEK CAPITAL LETTER OMEGA WITH TONOS
      $0390: Result:= $C0; //  GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS
      $0391: Result:= $C1; //  GREEK CAPITAL LETTER ALPHA
      $0392: Result:= $C2; //  GREEK CAPITAL LETTER BETA
      $0393: Result:= $C3; //  GREEK CAPITAL LETTER GAMMA
      $0394: Result:= $C4; //  GREEK CAPITAL LETTER DELTA
      $0395: Result:= $C5; //  GREEK CAPITAL LETTER EPSILON
      $0396: Result:= $C6; //  GREEK CAPITAL LETTER ZETA
      $0397: Result:= $C7; //  GREEK CAPITAL LETTER ETA
      $0398: Result:= $C8; //  GREEK CAPITAL LETTER THETA
      $0399: Result:= $C9; //  GREEK CAPITAL LETTER IOTA
      $039A: Result:= $CA; //  GREEK CAPITAL LETTER KAPPA
      $039B: Result:= $CB; //  GREEK CAPITAL LETTER LAMDA
      $039C: Result:= $CC; //  GREEK CAPITAL LETTER MU
      $039D: Result:= $CD; //  GREEK CAPITAL LETTER NU
      $039E: Result:= $CE; //  GREEK CAPITAL LETTER XI
      $039F: Result:= $CF; //  GREEK CAPITAL LETTER OMICRON
      $03A0: Result:= $D0; //  GREEK CAPITAL LETTER PI
      $03A1: Result:= $D1; //  GREEK CAPITAL LETTER RHO
      $03A3: Result:= $D3; //  GREEK CAPITAL LETTER SIGMA
      $03A4: Result:= $D4; //  GREEK CAPITAL LETTER TAU
      $03A5: Result:= $D5; //  GREEK CAPITAL LETTER UPSILON
      $03A6: Result:= $D6; //  GREEK CAPITAL LETTER PHI
      $03A7: Result:= $D7; //  GREEK CAPITAL LETTER CHI
      $03A8: Result:= $D8; //  GREEK CAPITAL LETTER PSI
      $03A9: Result:= $D9; //  GREEK CAPITAL LETTER OMEGA
      $03AA: Result:= $DA; //  GREEK CAPITAL LETTER IOTA WITH DIALYTIKA
      $03AB: Result:= $DB; //  GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA
      $03AC: Result:= $DC; //  GREEK SMALL LETTER ALPHA WITH TONOS
      $03AD: Result:= $DD; //  GREEK SMALL LETTER EPSILON WITH TONOS
      $03AE: Result:= $DE; //  GREEK SMALL LETTER ETA WITH TONOS
      $03AF: Result:= $DF; //  GREEK SMALL LETTER IOTA WITH TONOS
      $03B0: Result:= $E0; //  GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS
      $03B1: Result:= $E1; //  GREEK SMALL LETTER ALPHA
      $03B2: Result:= $E2; //  GREEK SMALL LETTER BETA
      $03B3: Result:= $E3; //  GREEK SMALL LETTER GAMMA
      $03B4: Result:= $E4; //  GREEK SMALL LETTER DELTA
      $03B5: Result:= $E5; //  GREEK SMALL LETTER EPSILON
      $03B6: Result:= $E6; //  GREEK SMALL LETTER ZETA
      $03B7: Result:= $E7; //  GREEK SMALL LETTER ETA
      $03B8: Result:= $E8; //  GREEK SMALL LETTER THETA
      $03B9: Result:= $E9; //  GREEK SMALL LETTER IOTA
      $03BA: Result:= $EA; //  GREEK SMALL LETTER KAPPA
      $03BB: Result:= $EB; //  GREEK SMALL LETTER LAMDA
      $03BC: Result:= $EC; //  GREEK SMALL LETTER MU
      $03BD: Result:= $ED; //  GREEK SMALL LETTER NU
      $03BE: Result:= $EE; //  GREEK SMALL LETTER XI
      $03BF: Result:= $EF; //  GREEK SMALL LETTER OMICRON
      $03C0: Result:= $F0; //  GREEK SMALL LETTER PI
      $03C1: Result:= $F1; //  GREEK SMALL LETTER RHO
      $03C2: Result:= $F2; //  GREEK SMALL LETTER FINAL SIGMA
      $03C3: Result:= $F3; //  GREEK SMALL LETTER SIGMA
      $03C4: Result:= $F4; //  GREEK SMALL LETTER TAU
      $03C5: Result:= $F5; //  GREEK SMALL LETTER UPSILON
      $03C6: Result:= $F6; //  GREEK SMALL LETTER PHI
      $03C7: Result:= $F7; //  GREEK SMALL LETTER CHI
      $03C8: Result:= $F8; //  GREEK SMALL LETTER PSI
      $03C9: Result:= $F9; //  GREEK SMALL LETTER OMEGA
      $03CA: Result:= $FA; //  GREEK SMALL LETTER IOTA WITH DIALYTIKA
      $03CB: Result:= $FB; //  GREEK SMALL LETTER UPSILON WITH DIALYTIKA
      $03CC: Result:= $FC; //  GREEK SMALL LETTER OMICRON WITH TONOS
      $03CD: Result:= $FD; //  GREEK SMALL LETTER UPSILON WITH TONOS
      $03CE: Result:= $FE; //  GREEK SMALL LETTER OMEGA WITH TONOS
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_8(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $00A2: Result:= $A2; //  CENT SIGN
      $00A3: Result:= $A3; //  POUND SIGN
      $00A4: Result:= $A4; //  CURRENCY SIGN
      $00A5: Result:= $A5; //  YEN SIGN
      $00A6: Result:= $A6; //  BROKEN BAR
      $00A7: Result:= $A7; //  SECTION SIGN
      $00A8: Result:= $A8; //  DIAERESIS
      $00A9: Result:= $A9; //  COPYRIGHT SIGN
      $00D7: Result:= $AA; //  MULTIPLICATION SIGN
      $00AB: Result:= $AB; //  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; //  NOT SIGN
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $00AE: Result:= $AE; //  REGISTERED SIGN
      $203E: Result:= $AF; //  OVERLINE
      $00B0: Result:= $B0; //  DEGREE SIGN
      $00B1: Result:= $B1; //  PLUS-MINUS SIGN
      $00B2: Result:= $B2; //  SUPERSCRIPT TWO
      $00B3: Result:= $B3; //  SUPERSCRIPT THREE
      $00B4: Result:= $B4; //  ACUTE ACCENT
      $00B5: Result:= $B5; //  MICRO SIGN
      $00B6: Result:= $B6; //  PILCROW SIGN
      $00B7: Result:= $B7; //  MIDDLE DOT
      $00B8: Result:= $B8; //  CEDILLA
      $00B9: Result:= $B9; //  SUPERSCRIPT ONE
      $00F7: Result:= $BA; //  DIVISION SIGN
      $00BB: Result:= $BB; //  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; //  VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; //  VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; //  VULGAR FRACTION THREE QUARTERS
      $2017: Result:= $DF; //  DOUBLE LOW LINE
      $05D0: Result:= $E0; //  HEBREW LETTER ALEF
      $05D1: Result:= $E1; //  HEBREW LETTER BET
      $05D2: Result:= $E2; //  HEBREW LETTER GIMEL
      $05D3: Result:= $E3; //  HEBREW LETTER DALET
      $05D4: Result:= $E4; //  HEBREW LETTER HE
      $05D5: Result:= $E5; //  HEBREW LETTER VAV
      $05D6: Result:= $E6; //  HEBREW LETTER ZAYIN
      $05D7: Result:= $E7; //  HEBREW LETTER HET
      $05D8: Result:= $E8; //  HEBREW LETTER TET
      $05D9: Result:= $E9; //  HEBREW LETTER YOD
      $05DA: Result:= $EA; //  HEBREW LETTER FINAL KAF
      $05DB: Result:= $EB; //  HEBREW LETTER KAF
      $05DC: Result:= $EC; //  HEBREW LETTER LAMED
      $05DD: Result:= $ED; //  HEBREW LETTER FINAL MEM
      $05DE: Result:= $EE; //  HEBREW LETTER MEM
      $05DF: Result:= $EF; //  HEBREW LETTER FINAL NUN
      $05E0: Result:= $F0; //  HEBREW LETTER NUN
      $05E1: Result:= $F1; //  HEBREW LETTER SAMEKH
      $05E2: Result:= $F2; //  HEBREW LETTER AYIN
      $05E3: Result:= $F3; //  HEBREW LETTER FINAL PE
      $05E4: Result:= $F4; //  HEBREW LETTER PE
      $05E5: Result:= $F5; //  HEBREW LETTER FINAL TSADI
      $05E6: Result:= $F6; //  HEBREW LETTER TSADI
      $05E7: Result:= $F7; //  HEBREW LETTER QOF
      $05E8: Result:= $F8; //  HEBREW LETTER RESH
      $05E9: Result:= $F9; //  HEBREW LETTER SHIN
      $05EA: Result:= $FA; //  HEBREW LETTER TAV
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_9(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $00A1: Result:= $A1; //  INVERTED EXCLAMATION MARK
      $00A2: Result:= $A2; //  CENT SIGN
      $00A3: Result:= $A3; //  POUND SIGN
      $00A4: Result:= $A4; //  CURRENCY SIGN
      $00A5: Result:= $A5; //  YEN SIGN
      $00A6: Result:= $A6; //  BROKEN BAR
      $00A7: Result:= $A7; //  SECTION SIGN
      $00A8: Result:= $A8; //  DIAERESIS
      $00A9: Result:= $A9; //  COPYRIGHT SIGN
      $00AA: Result:= $AA; //  FEMININE ORDINAL INDICATOR
      $00AB: Result:= $AB; //  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; //  NOT SIGN
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $00AE: Result:= $AE; //  REGISTERED SIGN
      $00AF: Result:= $AF; //  MACRON
      $00B0: Result:= $B0; //  DEGREE SIGN
      $00B1: Result:= $B1; //  PLUS-MINUS SIGN
      $00B2: Result:= $B2; //  SUPERSCRIPT TWO
      $00B3: Result:= $B3; //  SUPERSCRIPT THREE
      $00B4: Result:= $B4; //  ACUTE ACCENT
      $00B5: Result:= $B5; //  MICRO SIGN
      $00B6: Result:= $B6; //  PILCROW SIGN
      $00B7: Result:= $B7; //  MIDDLE DOT
      $00B8: Result:= $B8; //  CEDILLA
      $00B9: Result:= $B9; //  SUPERSCRIPT ONE
      $00BA: Result:= $BA; //  MASCULINE ORDINAL INDICATOR
      $00BB: Result:= $BB; //  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00BC: Result:= $BC; //  VULGAR FRACTION ONE QUARTER
      $00BD: Result:= $BD; //  VULGAR FRACTION ONE HALF
      $00BE: Result:= $BE; //  VULGAR FRACTION THREE QUARTERS
      $00BF: Result:= $BF; //  INVERTED QUESTION MARK
      $00C0: Result:= $C0; //  LATIN CAPITAL LETTER A WITH GRAVE
      $00C1: Result:= $C1; //  LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; //  LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $00C3: Result:= $C3; //  LATIN CAPITAL LETTER A WITH TILDE
      $00C4: Result:= $C4; //  LATIN CAPITAL LETTER A WITH DIAERESIS
      $00C5: Result:= $C5; //  LATIN CAPITAL LETTER A WITH RING ABOVE
      $00C6: Result:= $C6; //  LATIN CAPITAL LETTER AE
      $00C7: Result:= $C7; //  LATIN CAPITAL LETTER C WITH CEDILLA
      $00C8: Result:= $C8; //  LATIN CAPITAL LETTER E WITH GRAVE
      $00C9: Result:= $C9; //  LATIN CAPITAL LETTER E WITH ACUTE
      $00CA: Result:= $CA; //  LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $00CB: Result:= $CB; //  LATIN CAPITAL LETTER E WITH DIAERESIS
      $00CC: Result:= $CC; //  LATIN CAPITAL LETTER I WITH GRAVE
      $00CD: Result:= $CD; //  LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; //  LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $00CF: Result:= $CF; //  LATIN CAPITAL LETTER I WITH DIAERESIS
      $011E: Result:= $D0; //  LATIN CAPITAL LETTER G WITH BREVE
      $00D1: Result:= $D1; //  LATIN CAPITAL LETTER N WITH TILDE
      $00D2: Result:= $D2; //  LATIN CAPITAL LETTER O WITH GRAVE
      $00D3: Result:= $D3; //  LATIN CAPITAL LETTER O WITH ACUTE
      $00D4: Result:= $D4; //  LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $00D5: Result:= $D5; //  LATIN CAPITAL LETTER O WITH TILDE
      $00D6: Result:= $D6; //  LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; //  MULTIPLICATION SIGN
      $00D8: Result:= $D8; //  LATIN CAPITAL LETTER O WITH STROKE
      $00D9: Result:= $D9; //  LATIN CAPITAL LETTER U WITH GRAVE
      $00DA: Result:= $DA; //  LATIN CAPITAL LETTER U WITH ACUTE
      $00DB: Result:= $DB; //  LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $00DC: Result:= $DC; //  LATIN CAPITAL LETTER U WITH DIAERESIS
      $0130: Result:= $DD; //  LATIN CAPITAL LETTER I WITH DOT ABOVE
      $015E: Result:= $DE; //  LATIN CAPITAL LETTER S WITH CEDILLA
      $00DF: Result:= $DF; //  LATIN SMALL LETTER SHARP S
      $00E0: Result:= $E0; //  LATIN SMALL LETTER A WITH GRAVE
      $00E1: Result:= $E1; //  LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; //  LATIN SMALL LETTER A WITH CIRCUMFLEX
      $00E3: Result:= $E3; //  LATIN SMALL LETTER A WITH TILDE
      $00E4: Result:= $E4; //  LATIN SMALL LETTER A WITH DIAERESIS
      $00E5: Result:= $E5; //  LATIN SMALL LETTER A WITH RING ABOVE
      $00E6: Result:= $E6; //  LATIN SMALL LETTER AE
      $00E7: Result:= $E7; //  LATIN SMALL LETTER C WITH CEDILLA
      $00E8: Result:= $E8; //  LATIN SMALL LETTER E WITH GRAVE
      $00E9: Result:= $E9; //  LATIN SMALL LETTER E WITH ACUTE
      $00EA: Result:= $EA; //  LATIN SMALL LETTER E WITH CIRCUMFLEX
      $00EB: Result:= $EB; //  LATIN SMALL LETTER E WITH DIAERESIS
      $00EC: Result:= $EC; //  LATIN SMALL LETTER I WITH GRAVE
      $00ED: Result:= $ED; //  LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; //  LATIN SMALL LETTER I WITH CIRCUMFLEX
      $00EF: Result:= $EF; //  LATIN SMALL LETTER I WITH DIAERESIS
      $011F: Result:= $F0; //  LATIN SMALL LETTER G WITH BREVE
      $00F1: Result:= $F1; //  LATIN SMALL LETTER N WITH TILDE
      $00F2: Result:= $F2; //  LATIN SMALL LETTER O WITH GRAVE
      $00F3: Result:= $F3; //  LATIN SMALL LETTER O WITH ACUTE
      $00F4: Result:= $F4; //  LATIN SMALL LETTER O WITH CIRCUMFLEX
      $00F5: Result:= $F5; //  LATIN SMALL LETTER O WITH TILDE
      $00F6: Result:= $F6; //  LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; //  DIVISION SIGN
      $00F8: Result:= $F8; //  LATIN SMALL LETTER O WITH STROKE
      $00F9: Result:= $F9; //  LATIN SMALL LETTER U WITH GRAVE
      $00FA: Result:= $FA; //  LATIN SMALL LETTER U WITH ACUTE
      $00FB: Result:= $FB; //  LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; //  LATIN SMALL LETTER U WITH DIAERESIS
      $0131: Result:= $FD; //  LATIN SMALL LETTER DOTLESS I
      $015F: Result:= $FE; //  LATIN SMALL LETTER S WITH CEDILLA
      $00FF: Result:= $FF; //  LATIN SMALL LETTER Y WITH DIAERESIS
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

function RtcUnicodeToAnsiCharISO8859_15(Chr: Word): Byte;
begin
{$IFDEF RTC_BYTESTRING}
  Result := Byte(Chr);
{$ELSE}
  if (Chr <= 255) then
    Result := Chr
  else
    case Chr of
      $00A0: Result:= $A0; //  NO-BREAK SPACE
      $00A1: Result:= $A1; //  INVERTED EXCLAMATION MARK
      $00A2: Result:= $A2; //  CENT SIGN
      $00A3: Result:= $A3; //  POUND SIGN
      $20AC: Result:= $A4; //  EURO SIGN
      $00A5: Result:= $A5; //  YEN SIGN
      $0160: Result:= $A6; //  LATIN CAPITAL LETTER S WITH CARON
      $00A7: Result:= $A7; //  SECTION SIGN
      $0161: Result:= $A8; //  LATIN SMALL LETTER S WITH CARON
      $00A9: Result:= $A9; //  COPYRIGHT SIGN
      $00AA: Result:= $AA; //  FEMININE ORDINAL INDICATOR
      $00AB: Result:= $AB; //  LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      $00AC: Result:= $AC; //  NOT SIGN
      $00AD: Result:= $AD; //  SOFT HYPHEN
      $00AE: Result:= $AE; //  REGISTERED SIGN
      $00AF: Result:= $AF; //  MACRON
      $00B0: Result:= $B0; //  DEGREE SIGN
      $00B1: Result:= $B1; //  PLUS-MINUS SIGN
      $00B2: Result:= $B2; //  SUPERSCRIPT TWO
      $00B3: Result:= $B3; //  SUPERSCRIPT THREE
      $017D: Result:= $B4; //  LATIN CAPITAL LETTER Z WITH CARON
      $00B5: Result:= $B5; //  MICRO SIGN
      $00B6: Result:= $B6; //  PILCROW SIGN
      $00B7: Result:= $B7; //  MIDDLE DOT
      $017E: Result:= $B8; //  LATIN SMALL LETTER Z WITH CARON
      $00B9: Result:= $B9; //  SUPERSCRIPT ONE
      $00BA: Result:= $BA; //  MASCULINE ORDINAL INDICATOR
      $00BB: Result:= $BB; //  RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      $0152: Result:= $BC; //  LATIN CAPITAL LIGATURE OE
      $0153: Result:= $BD; //  LATIN SMALL LIGATURE OE
      $0178: Result:= $BE; //  LATIN CAPITAL LETTER Y WITH DIAERESIS
      $00BF: Result:= $BF; //  INVERTED QUESTION MARK
      $00C0: Result:= $C0; //  LATIN CAPITAL LETTER A WITH GRAVE
      $00C1: Result:= $C1; //  LATIN CAPITAL LETTER A WITH ACUTE
      $00C2: Result:= $C2; //  LATIN CAPITAL LETTER A WITH CIRCUMFLEX
      $00C3: Result:= $C3; //  LATIN CAPITAL LETTER A WITH TILDE
      $00C4: Result:= $C4; //  LATIN CAPITAL LETTER A WITH DIAERESIS
      $00C5: Result:= $C5; //  LATIN CAPITAL LETTER A WITH RING ABOVE
      $00C6: Result:= $C6; //  LATIN CAPITAL LETTER AE
      $00C7: Result:= $C7; //  LATIN CAPITAL LETTER C WITH CEDILLA
      $00C8: Result:= $C8; //  LATIN CAPITAL LETTER E WITH GRAVE
      $00C9: Result:= $C9; //  LATIN CAPITAL LETTER E WITH ACUTE
      $00CA: Result:= $CA; //  LATIN CAPITAL LETTER E WITH CIRCUMFLEX
      $00CB: Result:= $CB; //  LATIN CAPITAL LETTER E WITH DIAERESIS
      $00CC: Result:= $CC; //  LATIN CAPITAL LETTER I WITH GRAVE
      $00CD: Result:= $CD; //  LATIN CAPITAL LETTER I WITH ACUTE
      $00CE: Result:= $CE; //  LATIN CAPITAL LETTER I WITH CIRCUMFLEX
      $00CF: Result:= $CF; //  LATIN CAPITAL LETTER I WITH DIAERESIS
      $00D0: Result:= $D0; //  LATIN CAPITAL LETTER ETH
      $00D1: Result:= $D1; //  LATIN CAPITAL LETTER N WITH TILDE
      $00D2: Result:= $D2; //  LATIN CAPITAL LETTER O WITH GRAVE
      $00D3: Result:= $D3; //  LATIN CAPITAL LETTER O WITH ACUTE
      $00D4: Result:= $D4; //  LATIN CAPITAL LETTER O WITH CIRCUMFLEX
      $00D5: Result:= $D5; //  LATIN CAPITAL LETTER O WITH TILDE
      $00D6: Result:= $D6; //  LATIN CAPITAL LETTER O WITH DIAERESIS
      $00D7: Result:= $D7; //  MULTIPLICATION SIGN
      $00D8: Result:= $D8; //  LATIN CAPITAL LETTER O WITH STROKE
      $00D9: Result:= $D9; //  LATIN CAPITAL LETTER U WITH GRAVE
      $00DA: Result:= $DA; //  LATIN CAPITAL LETTER U WITH ACUTE
      $00DB: Result:= $DB; //  LATIN CAPITAL LETTER U WITH CIRCUMFLEX
      $00DC: Result:= $DC; //  LATIN CAPITAL LETTER U WITH DIAERESIS
      $00DD: Result:= $DD; //  LATIN CAPITAL LETTER Y WITH ACUTE
      $00DE: Result:= $DE; //  LATIN CAPITAL LETTER THORN
      $00DF: Result:= $DF; //  LATIN SMALL LETTER SHARP S
      $00E0: Result:= $E0; //  LATIN SMALL LETTER A WITH GRAVE
      $00E1: Result:= $E1; //  LATIN SMALL LETTER A WITH ACUTE
      $00E2: Result:= $E2; //  LATIN SMALL LETTER A WITH CIRCUMFLEX
      $00E3: Result:= $E3; //  LATIN SMALL LETTER A WITH TILDE
      $00E4: Result:= $E4; //  LATIN SMALL LETTER A WITH DIAERESIS
      $00E5: Result:= $E5; //  LATIN SMALL LETTER A WITH RING ABOVE
      $00E6: Result:= $E6; //  LATIN SMALL LETTER AE
      $00E7: Result:= $E7; //  LATIN SMALL LETTER C WITH CEDILLA
      $00E8: Result:= $E8; //  LATIN SMALL LETTER E WITH GRAVE
      $00E9: Result:= $E9; //  LATIN SMALL LETTER E WITH ACUTE
      $00EA: Result:= $EA; //  LATIN SMALL LETTER E WITH CIRCUMFLEX
      $00EB: Result:= $EB; //  LATIN SMALL LETTER E WITH DIAERESIS
      $00EC: Result:= $EC; //  LATIN SMALL LETTER I WITH GRAVE
      $00ED: Result:= $ED; //  LATIN SMALL LETTER I WITH ACUTE
      $00EE: Result:= $EE; //  LATIN SMALL LETTER I WITH CIRCUMFLEX
      $00EF: Result:= $EF; //  LATIN SMALL LETTER I WITH DIAERESIS
      $00F0: Result:= $F0; //  LATIN SMALL LETTER ETH
      $00F1: Result:= $F1; //  LATIN SMALL LETTER N WITH TILDE
      $00F2: Result:= $F2; //  LATIN SMALL LETTER O WITH GRAVE
      $00F3: Result:= $F3; //  LATIN SMALL LETTER O WITH ACUTE
      $00F4: Result:= $F4; //  LATIN SMALL LETTER O WITH CIRCUMFLEX
      $00F5: Result:= $F5; //  LATIN SMALL LETTER O WITH TILDE
      $00F6: Result:= $F6; //  LATIN SMALL LETTER O WITH DIAERESIS
      $00F7: Result:= $F7; //  DIVISION SIGN
      $00F8: Result:= $F8; //  LATIN SMALL LETTER O WITH STROKE
      $00F9: Result:= $F9; //  LATIN SMALL LETTER U WITH GRAVE
      $00FA: Result:= $FA; //  LATIN SMALL LETTER U WITH ACUTE
      $00FB: Result:= $FB; //  LATIN SMALL LETTER U WITH CIRCUMFLEX
      $00FC: Result:= $FC; //  LATIN SMALL LETTER U WITH DIAERESIS
      $00FD: Result:= $FD; //  LATIN SMALL LETTER Y WITH ACUTE
      $00FE: Result:= $FE; //  LATIN SMALL LETTER THORN
      $00FF: Result:= $FF; //  LATIN SMALL LETTER Y WITH DIAERESIS
      else Result := RTC_INVALID_CHAR;
    end;
{$ENDIF}
  end;

procedure RtcSetAnsiCodePage(page:RtcAnsiCodePages);
  begin
  case page of
    cpNone:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharNone;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharNone;
      end;
    cpWin1250:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1250;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1250;
      end;
    cpWin1251:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1251;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1251;
      end;
    cpWin1252:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1252;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1252;
      end;
    cpWin1253:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1253;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1253;
      end;
    cpWin1254:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1254;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1254;
      end;
    cpWin1255:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1255;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1255;
      end;
    cpWin1256:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1256;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1256;
      end;
    cpWin1257:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1257;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1257;
      end;
    cpWin1258:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin1258;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin1258;
      end;
    cpWin874:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharWin874;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharWin874;
      end;
    cpISO8859_1:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_1;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_1;
      end;
    cpISO8859_2:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_2;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_2;
      end;
    cpISO8859_3:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_3;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_3;
      end;
    cpISO8859_4:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_4;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_4;
      end;
    cpISO8859_5:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_5;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_5;
      end;
    cpISO8859_6:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_6;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_6;
      end;
    cpISO8859_7:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_7;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_7;
      end;
    cpISO8859_8:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_8;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_8;
      end;
    cpISO8859_9:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_9;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_9;
      end;
    cpISO8859_15:
      begin
      @RtcUnicodeToAnsiChar := @RtcUnicodeToAnsiCharISO8859_15;
      @RtcAnsiToUnicodeChar := @RtcAnsiToUnicodeCharISO8859_15;
      end;
    end;
  end;

function RtcUnicodeToAnsiString(const Source:RtcString):RtcString;
{$IFDEF RTC_BYTESTRING}
  begin
  Result:=Source;
  end;
{$ELSE}
  var
    i: Integer;
  begin
  SetLength(Result,length(Source));
  for i := 1 to Length(Source) do
    Result[i]:=RtcChar(RtcUnicodeToAnsiChar(Word(Source[i])));
  end;
{$ENDIF}

function RtcAnsiToUnicodeString(const Source:RtcString):RtcString;
{$IFDEF RTC_BYTESTRING}
  begin
  Result:=Source;
  end;
{$ELSE}
  var
    i: Integer;
  begin
  SetLength(Result,length(Source));
  for i := 1 to Length(Source) do
    Result[i]:=RtcChar(RtcAnsiToUnicodeChar(Byte(Source[i])));
  end;
{$ENDIF}

const
  CHR_A = Ord('a');
  CHR_Z = Ord('z');

{$IFDEF UNICODE}
  {$IFDEF RTC_BYTESTRING}
function UpperCase(const s:RtcString):RtcString; overload;
  var
    i:integer;
    c,d:^RtcBinChar;
  begin
  i:=length(s);
  SetLength(Result,i);
  if i>0 then
    begin
    c:=@(s[1]);
    d:=@(Result[1]);
    for i:=1 to i do
      begin
      if (c^>=CHR_A) and (c^<=CHR_Z) then
        d^:=c^ - 32
      else
        d^:=c^;
      Inc(d);
      Inc(c);
      end;
    end;
  end;

function Trim(const S: RtcString): RtcString; overload;
  var
    I, L: Integer;
  begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then
    SetLength(Result,0)
  else
    begin
    while S[L] <= ' ' do Dec(L);
    Result := Copy(S, I, L - I + 1);
    end;
  end;
  {$ENDIF}
{$ENDIF}

function Upper_Case(const s:RtcString):RtcString;
  var
    i:integer;
    c,d:^RtcBinChar;
  begin
  i:=length(s);
  SetLength(Result,i);
  if i>0 then
    begin
    c:=@(s[1]);
    d:=@(Result[1]);
    for i:=1 to i do
      begin
      if (c^>=CHR_A) and (c^<=CHR_Z) then
        d^:=c^ - 32
      else
        d^:=c^;
      Inc(d);
      Inc(c);
      end;
    end;
  end;

function Up_Case(const c:RtcChar):RtcChar;
  begin
  if (c>='a') and (c<='z') then
    Result:=RtcChar(Ord(c) - 32)
  else
    Result:=c;
  end;

function Same_Text(const s1,s2:RtcString):boolean;
  var
    i:integer;
    c,d:^RtcBinChar;
    e,f:RtcBinChar;
  begin
  i:=length(s1);
  if i<>length(s2) then
    Result:=False
  else if i>0 then
    begin
    Result:=True;
    c:=@(s1[1]);
    d:=@(s2[1]);
    for i:=1 to i do
      begin
      if (c^>=CHR_A) and (c^<=CHR_Z) then
        e:=c^ - 32
      else
        e:=c^;
      if (d^>=CHR_A) and (d^<=CHR_Z) then
        f:=d^ - 32
      else
        f:=d^;
      if e<>f then
        begin
        Result:=False;
        Break;
        end;
      Inc(d);
      Inc(c);
      end;
    end
  else
    Result:=True;
  end;

{$IFDEF RTC_BYTESTRING}
function Same_Text(const s1,s2:RtcWideString):boolean;
  var
    i:integer;
    c,d:^RtcBinWideChar;
    e,f:RtcBinWideChar;
  begin
  i:=length(s1);
  if i<>length(s2) then
    Result:=False
  else if i>0 then
    begin
    Result:=True;
    c:=@(s1[1]);
    d:=@(s2[1]);
    for i:=1 to i do
      begin
      if (c^>=CHR_A) and (c^<=CHR_Z) then
        e:=c^ - 32
      else
        e:=c^;
      if (d^>=CHR_A) and (d^<=CHR_Z) then
        f:=d^ - 32
      else
        f:=d^;
      if e<>f then
        begin
        Result:=False;
        Break;
        end;
      Inc(d);
      Inc(c);
      end;
    end
  else
    Result:=True;
  end;
{$ENDIF}

function UpperCaseStr(const s:RtcWideString):RtcWideString;
  var
    i:integer;
    c,d:^RtcBinWideChar;
  begin
  i:=length(s);
  SetLength(Result,i);
  if i>0 then
    begin
    c:=@(s[1]);
    d:=@(Result[1]);
    for i:=1 to i do
      begin
      if (c^>=CHR_A) and (c^<=CHR_Z) then
        d^:=c^ - 32
      else
        d^:=c^;
      Inc(d);
      Inc(c);
      end;
    end;
  end;

procedure RtcStringToByteArray(const Source:RtcString; var Dest:RtcByteArray; SourceLoc:Integer=1; len:Integer=-1; DestLoc:Integer=0);
  var
    i, k: Integer;
  begin
  if len<0 then len:=length(Source)-SourceLoc+1;
  if len = 0 then Exit;
  k := SourceLoc;
{$IFNDEF RTC_BYTESTRING}
  if RTC_STRING_FIXMODE>=rtcStr_FixDown then
    begin
    for i:=DestLoc to DestLoc+len-1 do
      begin
      if Ord(Source[k])>255 then
        begin
        Dest[i] := RtcUnicodeToAnsiChar(Ord(Source[k]));
        if RTC_STRING_CHECK and (Dest[i]=RTC_INVALID_CHAR) then
          raise Exception.Create('RtcStringToByteArray: String contains Unicode character #'+IntToStr(Ord(Source[k]))+' = '+Source[k]);
        end
      else
        Dest[i] := Byte(Source[k]);
      Inc(k);
      end;
    end
  else if RTC_STRING_CHECK then
    begin
    for i:=DestLoc to DestLoc+len-1 do
      begin
      if Ord(Source[k])>255 then
        raise Exception.Create('RtcStringToByteArray: String contains Unicode character #'+IntToStr(Ord(Source[k]))+' = '+Source[k])
      else
        Dest[i] := Byte(Source[k]);
      Inc(k);
      end;
    end
  else
{$ENDIF}
    begin
    for i:=DestLoc to DestLoc+len-1 do
      begin
      Dest[i] := Byte(Source[k]);
      Inc(k);
      end;
    end;
  end;

procedure RtcByteArrayToString(const Source:RtcByteArray; var Dest:RtcString; SourceLoc:Integer=0; len:Integer=-1; DestLoc:Integer=1);
  var
    i, k: Integer;
  begin
  if len<0 then len:=length(Source)-SourceLoc;
  if len = 0 then Exit;
  k := SourceLoc;
{$IFNDEF RTC_BYTESTRING}
  if RTC_STRING_FIXMODE>=rtcStr_FixUpDown then
    begin
    for i:=DestLoc to DestLoc+len-1 do
      begin
      if (Source[k]<128) or (Source[k]>159) then
        Dest[i] := RtcChar(Source[k])
      else
        Dest[i] := RtcChar(RtcAnsiToUnicodeChar(Source[k]));
      Inc(k);
      end;
    end
  else
{$ENDIF}
    begin
    for i:=DestLoc to DestLoc+len-1 do
      begin
      Dest[i] := RtcChar(Source[k]);
      Inc(k);
      end;
    end;
  end;

{ TRtcHugeString }

constructor TRtcHugeString.Create;
  begin
  inherited;

  FPack:=nil;
  SetLength(FData,0);
  FDataCnt:=0;

  New(FPack);
  FillChar(FPack^,SizeOf(FPack^),0);

  FPackCnt:=0;
  FPackFree:=0;
  FPackLoc:=0;

  FCount:=0;
  FSize:=0;
  end;

destructor TRtcHugeString.Destroy;
  begin
  Clear;
  if FPack<>nil then Dispose(FPack);
  inherited;
  end;

procedure TRtcHugeString.Clear;
  var
    a,b:integer;
    FPack2:PRtcStrArr;
  begin
  if FDataCnt>0 then
    begin
    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        SetLength(FPack2^[b].str,0);
      Dispose(FPack2);
      end;
    SetLength(FData,0);
    FDataCnt:=0;
    end;

  if FPackCnt>0 then
    begin
    for b:=0 to FPackCnt-1 do
      SetLength(FPack^[b].str,0);
    FPackCnt:=0;
    FPackFree:=0;
    FPackLoc:=0;
    end;

  FSize:=0;
  FCount:=0;
  end;

procedure TRtcHugeString.GrowHugeStringList;
  begin
  if length(FData)<=FDataCnt then
    SetLength(FData, FDataCnt + RTC_STROBJ_PACK);
  FData[FDataCnt]:=FPack;
  Inc(FDataCnt);

  New(FPack);
  FillChar(FPack^,SizeOf(FPack^),0);
  FPackCnt:=0;
  end;

procedure TRtcHugeString.Add(const s: RtcString; len:Integer=-1);
  begin
  if len<0 then len:=length(s);
  if len>0 then
    begin
    FSize:=FSize + len;

    if FPackFree>=len then
      begin
      with FPack^[FPackCnt-1] do
        begin
        Move(s[1], str[FPackLoc], len * SizeOf(RtcChar));
        Inc(siz, len);
        end;
      Inc(FPackLoc,len);
      Dec(FPackFree,len);
      end
    else
      begin
      if FPackCnt>=RTC_STROBJ_PACK then
        GrowHugeStringList;

      if len>=255 then
        begin
        with FPack^[FPackCnt] do
          begin
          {$IFDEF RTC_WIDESTRING}
            SetLength(str, len);
            Move(s[1],str[1],len * SizeOf(RtcChar));
          {$ELSE}
            str:=s;
          {$ENDIF}
          siz:=len;
          end;
        FPackFree:=0;
        FPackLoc:=0;
        end
      else
        begin
        with FPack^[FPackCnt] do
          begin
          SetLength(str, 254);
          Move(s[1],str[1],len * SizeOf(RtcChar));
          siz:=len;
          end;
        FPackFree:=254-len;
        FPackLoc:=len+1;
        end;
      Inc(FPackCnt);
      Inc(FCount);
      end;
    end;
  end;

procedure TRtcHugeString.AddEx(s:byte);
  var
    b:RtcByteArray;
  begin
  SetLength(b,1);
  b[0]:=s;
  AddEx(b);
  SetLength(b,0);
  end;

procedure TRtcHugeString.AddEx(const s:RtcByteArray; len: Integer);
  begin
  if len<0 then len:=length(s);
  if len>0 then
    begin
    FSize:=FSize + len;

    if FPackFree>=len then
      begin
      with FPack^[FPackCnt-1] do
        begin
      {$IFDEF RTC_BYTESTRING}
        Move(s[0], str[FPackLoc], len);
      {$ELSE}
        RtcByteArrayToString(s,str,0,len,FPackLoc);
      {$ENDIF}
        Inc(siz, len);
        end;
      Inc(FPackLoc,len);
      Dec(FPackFree,len);
      end
    else
      begin
      if FPackCnt>=RTC_STROBJ_PACK then
        GrowHugeStringList;

      if len>=255 then
        begin
        with FPack^[FPackCnt] do
          begin
          SetLength(str, len);
        {$IFDEF RTC_BYTESTRING}
          Move(s[0],str[1],len);
        {$ELSE}
          RtcByteArrayToString(s,str,0,len,1);
        {$ENDIF}
          siz:=len;
          end;
        FPackFree:=0;
        FPackLoc:=0;
        end
      else
        begin
        with FPack^[FPackCnt] do
          begin
          SetLength(str, 254);
        {$IFDEF RTC_BYTESTRING}
          Move(s[0],str[1],len);
        {$ELSE}
          RtcByteArrayToString(s,str,0,len,1);
        {$ENDIF}
          siz:=len;
          end;
        FPackFree:=254-len;
        FPackLoc:=len+1;
        end;
      Inc(FPackCnt);
      Inc(FCount);
      end;
    end;
  end;

function TRtcHugeString.Get: RtcString;
  var
    a,b,loc:integer;
    FPack2:PRtcStrArr;
  begin
  if FCount>1 then
    begin
    SetLength(Result, FSize);
    loc:=1;

    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          if siz>0 then
            begin
            Move(str[1], Result[loc], siz * SizeOf(RtcChar));
            Inc(loc, siz);
            end;
      end;

    for b:=0 to FPackCnt-1 do
      with FPack^[b] do
        if siz>0 then
          begin
          Move(str[1], Result[loc], siz * SizeOf(RtcChar));
          Inc(loc, siz);
          end;

    if loc<>FSize+1 then
      raise Exception.Create('TRtcHugeString.Get: Internal error.');
    end
  else if FCount>0 then
    begin
    with FPack^[0] do
      if siz>=254 then
        Result:=str
      else
        begin
        SetLength(Result, siz);
        if siz>0 then
          Move(str[1], Result[1], siz * SizeOf(RtcChar));
        end;
    end
  else
    SetLength(Result,0);
  end;

function TRtcHugeString.GetEx: RtcByteArray;
  var
    a,b,loc:integer;
    FPack2:PRtcStrArr;
  begin
  if FCount>1 then
    begin
    SetLength(Result, FSize);
    loc:=0;

    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          if siz>0 then
            begin
          {$IFDEF RTC_BYTESTRING}
            Move(str[1], Result[loc], siz);
          {$ELSE}
            RtcStringToByteArray(str,Result,1,siz,loc);
          {$ENDIF}
            Inc(loc, siz);
            end;
      end;

    for b:=0 to FPackCnt-1 do
      with FPack^[b] do
        if siz>0 then
          begin
        {$IFDEF RTC_BYTESTRING}
          Move(str[1], Result[loc], siz);
        {$ELSE}
          RtcStringToByteArray(str,Result,1,siz,loc);
        {$ENDIF}
          Inc(loc, siz);
          end;

    if loc<>FSize then
      raise Exception.Create('TRtcHugeString.GetEx: Internal error.');
    end
  else if FCount>0 then
    begin
    with FPack^[0] do
      begin
      SetLength(Result, siz);
      if siz>0 then
        begin
      {$IFDEF RTC_BYTESTRING}
        Move(str[1], Result[0], siz);
      {$ELSE}
        RtcStringToByteArray(str,Result,1,siz,0);
      {$ENDIF}
        end;
      end;
    end
  else
    SetLength(Result,0);
  end;

{ TRtcHugeByteArray }

constructor TRtcHugeByteArray.Create;
  begin
  inherited;

  FPack:=nil;
  SetLength(FData,0);
  FDataCnt:=0;

  New(FPack);
  FillChar(FPack^,SizeOf(FPack^),0);

  FPackCnt:=0;
  FPackFree:=0;
  FPackLoc:=0;

  FCount:=0;
  FSize:=0;
  end;

destructor TRtcHugeByteArray.Destroy;
  begin
  Clear;
  if FPack<>nil then Dispose(FPack);
  inherited;
  end;

procedure TRtcHugeByteArray.Clear;
  var
    a,b:integer;
    FPack2:PRtcBytesArr;
  begin
  if FDataCnt>0 then
    begin
    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        SetLength(FPack2^[b].str,0);
      Dispose(FPack2);
      end;
    SetLength(FData,0);
    FDataCnt:=0;
    end;

  if FPackCnt>0 then
    begin
    for b:=0 to FPackCnt-1 do
      SetLength(FPack^[b].str,0);
    FPackCnt:=0;
    FPackFree:=0;
    FPackLoc:=0;
    end;

  FSize:=0;
  FCount:=0;
  end;

procedure TRtcHugeByteArray.GrowHugeStringList;
  begin
  if length(FData)<=FDataCnt then
    SetLength(FData, FDataCnt + RTC_STROBJ_PACK);
  FData[FDataCnt]:=FPack;
  Inc(FDataCnt);

  New(FPack);
  FillChar(FPack^,SizeOf(FPack^),0);
  FPackCnt:=0;
  end;

procedure TRtcHugeByteArray.AddEx(s:byte);
  var
    b:RtcByteArray;
  begin
  SetLength(b,1);
  b[0]:=s;
  AddEx(b);
  SetLength(b,0);
  end;

procedure TRtcHugeByteArray.AddEx(const s:RtcByteArray; len:integer=-1; loc:integer=0);
  begin
  if len=-1 then len:=length(s)-loc;
  if len>0 then
    begin
    FSize:=FSize + len;

    if FPackFree>=len then
      begin
      with FPack^[FPackCnt-1] do
        begin
        Move(s[loc], str[FPackLoc], len);
        Inc(siz, len);
        end;
      Inc(FPackLoc,len);
      Dec(FPackFree,len);
      end
    else
      begin
      if FPackCnt>=RTC_STROBJ_PACK then
        GrowHugeStringList;

      if len>=255 then
        begin
        with FPack^[FPackCnt] do
          begin
          SetLength(str, len);
          Move(s[loc],str[0],len);
          siz:=len;
          end;
        FPackFree:=0;
        FPackLoc:=0;
        end
      else
        begin
        with FPack^[FPackCnt] do
          begin
          SetLength(str, 254);
          Move(s[loc],str[0],len);
          siz:=len;
          end;
        FPackFree:=254-len;
        FPackLoc:=len;
        end;
      Inc(FPackCnt);
      Inc(FCount);
      end;
    end;
  end;

procedure TRtcHugeByteArray.Add(const s: RtcString; len: Integer=-1; loc: Integer=1);
  begin
  if len=-1 then len:=length(s)-loc+1;
  if len>0 then
    begin
    FSize:=FSize + len;

    if FPackFree>=len then
      begin
      with FPack^[FPackCnt-1] do
        begin
        {$IFDEF RTC_BYTESTRING}
        Move(s[loc], str[FPackLoc], len);
        {$ELSE}
        RtcStringToByteArray(s,str,loc,len,FPackLoc);
        {$ENDIF}
        Inc(siz, len);
        end;
      Inc(FPackLoc,len);
      Dec(FPackFree,len);
      end
    else
      begin
      if FPackCnt>=RTC_STROBJ_PACK then
        GrowHugeStringList;

      if len>=255 then
        begin
        with FPack^[FPackCnt] do
          begin
          SetLength(str, len);
          {$IFDEF RTC_BYTESTRING}
          Move(s[loc],str[0],len);
          {$ELSE}
          RtcStringToByteArray(s,str,loc,len,0);
          {$ENDIF}
          siz:=len;
          end;
        FPackFree:=0;
        FPackLoc:=0;
        end
      else
        begin
        with FPack^[FPackCnt] do
          begin
          SetLength(str, 254);
          {$IFDEF RTC_BYTESTRING}
          Move(s[loc],str[0],len);
          {$ELSE}
          RtcStringToByteArray(s,str,loc,len,0);
          {$ENDIF}
          siz:=len;
          end;
        FPackFree:=254-len;
        FPackLoc:=len;
        end;
      Inc(FPackCnt);
      Inc(FCount);
      end;
    end;
  end;

function TRtcHugeByteArray.GetEx: RtcByteArray;
  var
    a,b,loc:integer;
    FPack2:PRtcBytesArr;
  begin
  if FCount>1 then
    begin
    SetLength(Result, FSize);
    loc:=0;

    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          if siz>0 then
            begin
            Move(str[0], Result[loc], siz);
            Inc(loc, siz);
            end;
      end;

    for b:=0 to FPackCnt-1 do
      with FPack^[b] do
        if siz>0 then
          begin
          Move(str[0], Result[loc], siz);
          Inc(loc, siz);
          end;

    if loc<>FSize then
      raise Exception.Create('TRtcHugeByteArray.GetEx: Internal Error.');
    end
  else if FCount>0 then
    begin
    with FPack^[0] do
      if siz>=254 then
        Result:=str
      else
        begin
        SetLength(Result, siz);
        if siz>0 then
          Move(str[0], Result[0], siz);
        end;
    end
  else
    SetLength(Result,0);
  end;

function TRtcHugeByteArray.Get: RtcString;
  var
    a,b,loc:integer;
    FPack2:PRtcBytesArr;
  begin
  if FCount>1 then
    begin
    SetLength(Result, FSize);
    loc:=1;

    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          if siz>0 then
            begin
            {$IFDEF RTC_BYTESTRING}
            Move(str[0], Result[loc], siz);
            {$ELSE}
            RtcByteArrayToString(str,Result,0,siz,loc);
            {$ENDIF}
            Inc(loc, siz);
            end;
      end;

    for b:=0 to FPackCnt-1 do
      with FPack^[b] do
        if siz>0 then
          begin
          {$IFDEF RTC_BYTESTRING}
          Move(str[0], Result[loc], siz);
          {$ELSE}
          RtcByteArrayToString(str,Result,0,siz,loc);
          {$ENDIF}
          Inc(loc, siz);
          end;

    if loc<>FSize+1 then
      raise Exception.Create('TRtcHugeByteArray.Get: Internal Error.');
    end
  else if FCount>0 then
    begin
    with FPack^[0] do
      begin
      SetLength(Result, siz);
      if siz>0 then
        begin
        {$IFDEF RTC_BYTESTRING}
        Move(str[0], Result[1], siz);
        {$ELSE}
        RtcByteArrayToString(str,Result,0,siz,1);
        {$ENDIF}
        end;
      end;
    end
  else
    SetLength(Result,0);
  end;

function TRtcHugeByteArray.GetStartEx(len: integer): RtcByteArray;
  var
    a,b,loc:integer;
    FPack2:PRtcBytesArr;
  begin
  if FCount>1 then
    begin
    if len>FSize then len:=FSize;

    SetLength(Result, len);

    if len=0 then Exit;

    loc:=0;

    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          begin
          if siz>=len then
            begin
            Move(str[0], Result[loc], len);
            Exit;
            end
          else if siz>0 then
            begin
            Move(str[0], Result[loc], siz);
            Inc(loc, siz);
            Dec(len, siz);
            end;
          end;
      end;

    for b:=0 to FPackCnt-1 do
      with FPack^[b] do
        begin
        if siz>=len then
          begin
          Move(str[0], Result[loc], len);
          Exit;
          end
        else if siz>0 then
          begin
          Move(str[0], Result[loc], siz);
          Inc(loc, siz);
          Dec(len, siz);
          end;
        end;

    if loc<>FSize then
      raise Exception.Create('TRtcHugeByteArray.GetStartEx: Internal Error.');
    end
  else if FCount>0 then
    begin
    with FPack^[0] do
      begin
      if siz>=len then
        begin
        SetLength(Result, len);
        Move(str[0], Result[0], len);
        end
      else
        begin
        SetLength(Result, siz);
        if siz>0 then
          Move(str[0], Result[0], siz);
        end;
      end;
    end
  else
    SetLength(Result,0);
  end;


procedure TRtcHugeByteArray.DelStart(len: integer);
  var
    a,b,loc:integer;
    FPack2:PRtcBytesArr;
  begin
  if len=0 then
    Exit
  else if len>=Size then
    begin
    Clear;
    Exit;
    end;

  if FCount>1 then
    begin
    FSize:=FSize-len;

    loc:=0;

    FPackFree:=0;
    FPackLoc:=0;

    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          begin
          if siz>len then
            begin
            Move(str[len], str[0], siz-len);
            siz:=siz-len;
            Exit;
            end
          else
            begin
            SetLength(str,0);
            Inc(loc, siz);
            Dec(len, siz);
            siz:=0;
            end;
          end;
      end;

    for b:=0 to FPackCnt-1 do
      with FPack^[b] do
        begin
        if siz>len then
          begin
          Move(str[len], str[0], siz-len);
          siz:=siz-len;
          Exit;
          end
        else
          begin
          SetLength(str,0);
          Inc(loc, siz);
          Dec(len, siz);
          siz:=0;
          end;
        end;

    if loc<>FSize then
      raise Exception.Create('TRtcHugeByteArray.DelStart: Internal Error.');
    end
  else if FCount>0 then
    begin
    FPackFree:=0;
    FPackLoc:=0;
    FSize:=FSize-len;

    with FPack^[0] do
      begin
      if siz>len then
        begin
        Move(str[len], str[0], siz-len);
        siz:=siz-len;
        end
      else
        begin
        SetLength(str,0);
        siz:=0;
        end;
      end;
    end;
  end;

procedure TRtcHugeByteArray.AddPackEx(const s: RtcByteArray;
                                      packSize:integer; len:Integer=-1; loc:integer=0);
  var
    pack:integer;
  begin
  if len=-1 then len:=length(s)-loc;
  while len>0 do
    begin
    pack:=len;
    if pack>packSize then pack:=packSize;
    AddEx(s,pack,loc);
    len:=len-pack;
    loc:=loc+pack;
    end;
  end;

procedure TRtcHugeByteArray.AddPack(const s: RtcString;
                                    packSize:integer; len:Integer=-1; loc:integer=1);
  var
    pack:integer;
  begin
  if len=-1 then len:=length(s)-loc+1;
  while len>0 do
    begin
    pack:=len;
    if pack>packSize then pack:=packSize;
    Add(s,pack,loc);
    len:=len-pack;
    loc:=loc+pack;
    end;
  end;

{ tRtcFastStrObjList }

constructor tRtcFastStrObjList.Create;
  begin
  inherited;
  FPack:=nil;
  Tree:=tStrIntList.Create(RTC_STROBJ_PACK);

  SetLength(FData,0);
  New(FPack);
  FillChar(FPack^,SizeOf(FPack^),0);

  FCnt:=0;
  FDataCnt:=0;
  FPackCnt:=0;
  end;

destructor tRtcFastStrObjList.Destroy;
  begin
  Clear;
  if FPack<>nil then Dispose(FPack);
  RtcFreeAndNil(Tree);
  inherited;
  end;

procedure tRtcFastStrObjList.Clear;
  var
    a,b:integer;
    FPack2:PRtcStrObjArr;
  begin
  if self=nil then Exit;
  
  if FPackCnt>0 then
    begin
    for b:=0 to FPackCnt-1 do
      with FPack^[b] do
        begin
        SetLength(str,0);
        obj:=nil;
        end;
    FPackCnt:=0;
    end;

  if FDataCnt>0 then
    begin
    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          begin
          SetLength(str,0);
          obj:=nil;
          end;
      Dispose(FPack2);
      end;
    SetLength(FData,0);
    FDataCnt:=0;
    end;

  if assigned(Tree) then
    Tree.removeall;
  FCnt:=0;

  if assigned(FOnChange) then FOnChange(self);
  end;

procedure tRtcFastStrObjList.DestroyObjects;
  var
    a,b,c:integer;
    FPack2:PRtcStrObjArr;
  begin
  if self=nil then Exit;

  if FPackCnt>0 then
    begin
    c:=FPackCnt;
    FPackCnt:=0;
    for b:=0 to c-1 do
      with FPack^[b] do
        begin
        SetLength(str,0);
        obj.Free;
        end;
    end;

  if FDataCnt>0 then
    begin
    c:=FDataCnt;
    FDataCnt:=0;
    for a:=0 to c-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          begin
          SetLength(str,0);
          obj.Free;
          end;
      Dispose(FPack2);
      end;
    SetLength(FData,0);
    end;

  if assigned(Tree) then
    Tree.removeall;
  FCnt:=0;

  if assigned(FOnChange) then FOnChange(self);
  end;

function tRtcFastStrObjList.Add(const Name: RtcString; _Value:TObject=nil): integer;
  procedure GrowStrObjList;
    begin
    if length(FData)<=FDataCnt then
      SetLength(FData, FDataCnt + RTC_STROBJ_PACK);
    FData[FDataCnt]:=FPack;
    Inc(FDataCnt);

    New(FPack);
    FillChar(FPack^,SizeOf(FPack^),0);
    FPackCnt:=0;
    end;
  begin
  if FPackCnt>=RTC_STROBJ_PACK then
    GrowStrObjList;

  Tree.insert(Upper_Case(Name), FCnt);
  with FPack[FPackCnt] do
    begin
    str:=Name;
    obj:=_Value;
    end;
  Inc(FPackCnt);
  Inc(FCnt);

  Result:=FCnt-1;

  if assigned(FOnChange) then FOnChange(self);
  end;

function tRtcFastStrObjList.Find(const Name: RtcString): integer;
  begin
  Result:=Tree.search(Upper_Case(Name));
  end;

function tRtcFastStrObjList.IndexOf(const Name: RtcString): integer;
  begin
  Result:=Tree.search(Upper_Case(Name));
  end;

function tRtcFastStrObjList.AddCS(const Name: RtcString; _Value:TObject=nil): integer;
  begin
  if FPackCnt>=RTC_STROBJ_PACK then
    begin
    if length(FData)<=FDataCnt then
      SetLength(FData, FDataCnt + RTC_STROBJ_PACK);
    FData[FDataCnt]:=FPack;
    Inc(FDataCnt);

    New(FPack);
    FillChar(FPack^,SizeOf(FPack^),0);
    FPackCnt:=0;
    end;

  Tree.insert(Name, FCnt);
  with FPack[FPackCnt] do
    begin
    str:=Name;
    obj:=_Value;
    end;
  Inc(FPackCnt);
  Inc(FCnt);

  Result:=FCnt-1;

  if assigned(FOnChange) then FOnChange(self);
  end;

function tRtcFastStrObjList.FindCS(const Name: RtcString): integer;
  begin
  Result:=Tree.search(Name);
  end;

function tRtcFastStrObjList.IndexOfCS(const Name: RtcString): integer;
  begin
  Result:=Tree.search(Name);
  end;

function tRtcFastStrObjList.GetName(const index: integer): RtcString;
  begin
  if index shr RTC_STROBJ_SHIFT<FDataCnt then
    Result:=FData[index shr RTC_STROBJ_SHIFT]^[index and RTC_STROBJ_AND].str
  else
    Result:=FPack^[index and RTC_STROBJ_AND].str;
  end;

function tRtcFastStrObjList.GetValue(const index: integer): TObject;
  begin
  if index shr RTC_STROBJ_SHIFT<FDataCnt then
    Result:=FData[index shr RTC_STROBJ_SHIFT]^[index and RTC_STROBJ_AND].obj
  else
    Result:=FPack^[index and RTC_STROBJ_AND].obj;
  end;

procedure tRtcFastStrObjList.SetName(const index: integer; const _Value: RtcString);
  begin
  if index shr RTC_STROBJ_SHIFT<FDataCnt then
    begin
    with FData[index shr RTC_STROBJ_SHIFT]^[index and RTC_STROBJ_AND] do
      begin
      Tree.remove(Upper_Case(str));
      str:=_Value;
      Tree.insert(Upper_Case(_Value), index);
      end;
    end
  else
    begin
    with FPack^[index and RTC_STROBJ_AND] do
      begin
      Tree.remove(Upper_Case(str));
      str:=_Value;
      Tree.insert(Upper_Case(_Value), index);
      end;
    end;
  if assigned(FOnChange) then FOnChange(self);
  end;

procedure tRtcFastStrObjList.SetValue(const index: integer; const _Value: TObject);
  begin
  if index shr RTC_STROBJ_SHIFT<FDataCnt then
    FData[index shr RTC_STROBJ_SHIFT]^[index and RTC_STROBJ_AND].obj:=_Value
  else
    FPack^[index and RTC_STROBJ_AND].obj:=_Value;

  if assigned(FOnChange) then FOnChange(self);
  end;

function tRtcFastStrObjList.GetCount: integer;
  begin
  Result:=FCnt;
  end;

{ tRtcFastStringObjList }

constructor tRtcFastStringObjList.Create;
  begin
  inherited;
  FPack:=nil;
  Tree:=tStringIntList.Create(RTC_STROBJ_PACK);

  SetLength(FData,0);
  New(FPack);
  FillChar(FPack^,SizeOf(FPack^),0);

  FCnt:=0;
  FDataCnt:=0;
  FPackCnt:=0;
  end;

destructor tRtcFastStringObjList.Destroy;
  begin
  Clear;
  if FPack<>nil then Dispose(FPack);
  RtcFreeAndNil(Tree);
  inherited;
  end;

procedure tRtcFastStringObjList.Clear;
  var
    a,b:integer;
    FPack2:PRtcStringObjArr;
  begin
  if FPackCnt>0 then
    begin
    for b:=0 to FPackCnt-1 do
      with FPack^[b] do
        begin
        SetLength(str,0);
        obj:=nil;
        end;
    FPackCnt:=0;
    end;

  if FDataCnt>0 then
    begin
    for a:=0 to FDataCnt-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          begin
          SetLength(str,0);
          obj:=nil;
          end;
      Dispose(FPack2);
      end;
    SetLength(FData,0);
    FDataCnt:=0;
    end;

  if assigned(Tree) then
    Tree.removeall;
  FCnt:=0;

  if assigned(FOnChange) then FOnChange(self);
  end;

procedure tRtcFastStringObjList.DestroyObjects;
  var
    a,b,c:integer;
    FPack2:PRtcStringObjArr;
  begin
  if FPackCnt>0 then
    begin
    c:=FPackCnt;
    FPackCnt:=0;
    for b:=0 to c-1 do
      with FPack^[b] do
        begin
        SetLength(str,0);
        obj.Free;
        end;
    end;

  if FDataCnt>0 then
    begin
    c:=FDataCnt;
    FDataCnt:=0;
    for a:=0 to c-1 do
      begin
      FPack2:=FData[a];
      for b:=0 to RTC_STROBJ_PACK-1 do
        with FPack2^[b] do
          begin
          SetLength(str,0);
          obj.Free;
          end;
      Dispose(FPack2);
      end;
    SetLength(FData,0);
    end;

  if assigned(Tree) then
    Tree.removeall;
  FCnt:=0;

  if assigned(FOnChange) then FOnChange(self);
  end;

function tRtcFastStringObjList.Add(const Name: RtcWideString; _Value:TObject=nil): integer;
  procedure FastStringListGrow;
    begin
    if length(FData)<=FDataCnt then
      SetLength(FData, FDataCnt + RTC_STROBJ_PACK);
    FData[FDataCnt]:=FPack;
    Inc(FDataCnt);

    New(FPack);
    FillChar(FPack^,SizeOf(FPack^),0);
    FPackCnt:=0;
    end;
  begin
  if FPackCnt>=RTC_STROBJ_PACK then
    FastStringListGrow;

  Tree.insert(UpperCaseStr(Name), FCnt);
  with FPack[FPackCnt] do
    begin
    str:=Name;
    obj:=_Value;
    end;
  Inc(FPackCnt);
  Inc(FCnt);

  Result:=FCnt-1;

  if assigned(FOnChange) then FOnChange(self);
  end;

function tRtcFastStringObjList.Find(const Name: RtcWideString): integer;
  begin
  Result:=Tree.search(UpperCaseStr(Name));
  end;

function tRtcFastStringObjList.IndexOf(const Name: RtcWideString): integer;
  begin
  Result:=Tree.search(UpperCaseStr(Name));
  end;

function tRtcFastStringObjList.AddCS(const Name: RtcWideString; _Value:TObject=nil): integer;
  procedure FastStringListGrow;
    begin
    if length(FData)<=FDataCnt then
      SetLength(FData, FDataCnt + RTC_STROBJ_PACK);
    FData[FDataCnt]:=FPack;
    Inc(FDataCnt);

    New(FPack);
    FillChar(FPack^,SizeOf(FPack^),0);
    FPackCnt:=0;
    end;
  begin
  if FPackCnt>=RTC_STROBJ_PACK then
    FastStringListGrow;

  Tree.insert(Name, FCnt);
  with FPack[FPackCnt] do
    begin
    str:=Name;
    obj:=_Value;
    end;
  Inc(FPackCnt);
  Inc(FCnt);

  Result:=FCnt-1;

  if assigned(FOnChange) then FOnChange(self);
  end;

function tRtcFastStringObjList.FindCS(const Name: RtcWideString): integer;
  begin
  Result:=Tree.search(Name);
  end;

function tRtcFastStringObjList.IndexOfCS(const Name: RtcWideString): integer;
  begin
  Result:=Tree.search(Name);
  end;

function tRtcFastStringObjList.GetName(const index: integer): RtcWideString;
  begin
  if index shr RTC_STROBJ_SHIFT<FDataCnt then
    Result:=FData[index shr RTC_STROBJ_SHIFT]^[index and RTC_STROBJ_AND].str
  else
    Result:=FPack^[index and RTC_STROBJ_AND].str;
  end;

function tRtcFastStringObjList.GetValue(const index: integer): TObject;
  begin
  if index shr RTC_STROBJ_SHIFT<FDataCnt then
    Result:=FData[index shr RTC_STROBJ_SHIFT]^[index and RTC_STROBJ_AND].obj
  else
    Result:=FPack^[index and RTC_STROBJ_AND].obj;
  end;

procedure tRtcFastStringObjList.SetName(const index: integer; const _Value: RtcWideString);
  begin
  if index shr RTC_STROBJ_SHIFT<FDataCnt then
    begin
    with FData[index shr RTC_STROBJ_SHIFT]^[index and RTC_STROBJ_AND] do
      begin
      Tree.remove(UpperCaseStr(str));
      str:=_Value;
      Tree.insert(UpperCaseStr(_Value), index);
      end;
    end
  else
    begin
    with FPack^[index and RTC_STROBJ_AND] do
      begin
      Tree.remove(UpperCaseStr(str));
      str:=_Value;
      Tree.insert(UpperCaseStr(_Value), index);
      end;
    end;
  if assigned(FOnChange) then FOnChange(self);
  end;

procedure tRtcFastStringObjList.SetValue(const index: integer; const _Value: TObject);
  begin
  if index shr RTC_STROBJ_SHIFT<FDataCnt then
    FData[index shr RTC_STROBJ_SHIFT]^[index and RTC_STROBJ_AND].obj:=_Value
  else
    FPack^[index and RTC_STROBJ_AND].obj:=_Value;

  if assigned(FOnChange) then FOnChange(self);
  end;

function tRtcFastStringObjList.GetCount: integer;
  begin
  Result:=FCnt;
  end;

begin
  RtcSetAnsiCodePage(cpWin1252);
end.
