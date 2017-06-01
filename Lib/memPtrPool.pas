{
  "Pointer Pool" (Pointer>nil)
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)
  
  @exclude
}

unit memPtrPool;

{$INCLUDE rtcDefs.inc}

interface

uses
  rtcTypes;

type
  tPoolItemType=pointer;

  tPtrPoolElems = array of tPoolItemType;

{ Pointer Pool (Pointer>nil) }
  tPtrPool = class(TRtcFastObject)
    private
      pObjs:tPtrPoolElems;
      fCount,fSize:integer;
      procedure SetSize(x:integer);
    public
      constructor Create(Size:integer=0);
      destructor Destroy; override;
      function Put(const x:tPoolItemType):boolean; // if Pool is full, return FALSE and Free object memory
      function Get:tPoolItemType; // if Pool is empty, return FALSE (you have to create the Object)
      property Size:integer read fSize write SetSize;
      property Count:integer read fCount;
    end;

implementation

{ tPrtPool }

constructor tPtrPool.Create(Size: integer);
  begin
  inherited Create;
  fSize:=Size;
  if fSize>0 then
    SetLength(pObjs,fSize);
  fCount:=0;
  end;

destructor tPtrPool.Destroy;
  var
    i:integer;
  begin
  if fCount>0 then
    begin
    for i:=0 to fCount-1 do
      pObjs[i]:=nil;
    fCount:=0;
    end;
  if fSize>0 then
    begin
    SetLength(pObjs,0);
    fSize:=0;
    end;
  inherited;
  end;

function tPtrPool.Get:tPoolItemType;
  begin
  if fCount>0 then
    begin
    Dec(fCount);
    Result:=pObjs[fCount];
    end
  else
    Result:=nil;
  end;

function tPtrPool.Put(const x: tPoolItemType): boolean;
  begin
  if fCount<fSize then
    begin
    pObjs[fCount]:=x;
    Inc(fCount);
    Result:=True;
    end
  else
    Result:=False;
  end;

procedure tPtrPool.SetSize(x: integer);
  var
    i:integer;
  begin
  if x>fSize then
    begin
    fSize:=x;
    SetLength(pObjs,fSize);
    end
  else if x<fSize then
    begin
    for i:=x to fSize-1 do
      pObjs[i]:=nil;
    fSize:=x;
    SetLength(pObjs,fSize);
    end;
  end;

end.
