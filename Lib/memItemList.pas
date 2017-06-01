{
  "Balanced Binary Custom Item Search List" (longint>0, longint>0)
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)
  
  @exclude
}

unit memItemList;

{$INCLUDE rtcDefs.inc}

interface

uses
  SysUtils,

  rtcTypes, memPtrPool;

type
  itemType=longint;
  infoType=longint;

  pnode=^tnode;
  tnode=record
    key:itemType;
    info:infoType;
    l,r:pnode;
    b:boolean;
    end;
  pnodearr=^tnodearr;
  tnodearr=array of tnode;
  pParentList=^tParentList;
  tParentList=record
    Nodes:array[0..100] of pnode;
    NodeCount:byte;
    end;

  TCustomItemComparer=function(left,right:itemType):integer of object;

type
{ Balanced Binary Custom Item Search List (longint>0, longint>0) }
  tItemSearchList=class(TRtcFastObject)
  private
    // Temp variables needed for "Insert"
    nx,x,p,g,gg,c:pnode;
    xv:itemType;

    // Additional Temp variables needed for "remove"
    cb:boolean;
    y,p2,t:pnode;

    // data Pool
    myPoolSize:longint;
    myPools:array of pnodearr;
    pool:tPtrPool;
    cnt:cardinal;

    // search Tree
    head,z:pnode;
    Parents:pParentList;

    FUpdateCompare: TCustomItemComparer;
    FSearchCompare: TCustomItemComparer;

    procedure del_node(node:pnode);
    function new_node(const k:itemType; const i:infoType; const bi:boolean; const ll,rr:pnode):pnode;

    procedure RemoveThis(var t:pnode);

    procedure Insert_split;

    procedure Remove_AddParentNode(node:pnode);
    function Remove_GetParentNode:pnode;

  public
    constructor Create(size:integer); overload;

    destructor Destroy; override;

    function Empty:boolean;

    function Count:cardinal;

    procedure PoolSize(size:integer);

    function search(const v:itemType):infoType;      // Search for exact "v"
    function search_near(const v:itemType; var res:integer):infoType;      // Search for nearest "v"
    function search_min(var i:infoType):itemType;
    function search_max(var i:infoType):itemType;
    function search_l(const v:itemType; var i:infoType):itemType;  // Search index lower than "v"
    function search_g(const v:itemType; var i:infoType):itemType;  // Search index higher than "v"
    function search_le(const v:itemType; var i:infoType):itemType;  // Search index for lower or equel to "v"
    function search_ge(const v:itemType; var i:infoType):itemType;  // Search index for higher or equal to "v"

    procedure change(const v:itemType;const info:infoType);
    function insert(const v:itemType;const info:infoType):infoType;
    procedure remove(const v:itemType);
    procedure removeall;

    property UpdateComparer:TCustomItemComparer read FUpdateCompare write FUpdateCompare;
    property SearchComparer:TCustomItemComparer read FSearchCompare write FSearchCompare;

  public
    property RootNode:pnode read head;
    property NilNode:pnode read z;
    end;

implementation

const
  itemMin=0;
  infoNil=0;

function tItemSearchList.Empty:boolean;
  begin
  Result:=head^.r=z;
  end;

function tItemSearchList.New_Node(const k:itemType; const i:infoType; const bi:boolean; const ll,rr:pnode):pnode;
  var
    p:pnodearr;
    a:integer;
  begin
  if myPoolSize>0 then
    begin
    Result:=pool.Get;
    if Result=nil then // Pool empty, need to resize pool and create a new list
      begin
      SetLength(myPools,Length(myPools)+1); // Resize myPools list
      a:=SizeOf(pnodearr);
      GetMem(p,a);
      FillChar(p^,a,0);
      SetLength(p^,myPoolSize);
      myPools[length(myPools)-1]:=p; // store list
      pool.Size:=pool.Size+myPoolSize; // resize Pool
      for a:=0 to myPoolSize-1 do
        pool.Put(@(p^[a]));
      Result:=pool.Get;
      end;
    end
  else
    GetMem(Result,SizeOf(tnode));
  FillChar(Result^,SizeOf(tnode),0);
  with Result^ do
    begin
    key:=k;
    info:=i;
    l:=ll;
    r:=rr;
    b:=bi;
    end;
  end;

procedure tItemSearchList.PoolSize(size:integer);
  begin
  if (pool.Size=0) or (myPoolSize>0) then
    myPoolSize:=size;
  end;

procedure tItemSearchList.Del_Node(node:pnode);
  begin
  if myPoolSize>0 then
    pool.Put(node)
  else
    FreeMem(node);
  end;

constructor tItemSearchList.Create(size:integer);
  begin
  inherited Create;
  cnt:=0;
  head:=nil;
  z:=nil;
  myPoolSize:=size;
  pool:=tPtrPool.Create;
  z:=new_node(itemMin,infoNil,false,nil,nil);
  z^.l:=z; z^.r:=z;
  head:=new_node(itemMin,infoNil,false,z,z);
  New(Parents);
  end;

procedure tItemSearchList.Change(const v:itemType;const info:infoType);
  var
    x:pnode;
    res:integer;
  begin
  x:=head^.r;
  while x<>z do
    begin
    res:=FUpdateCompare(v,x^.key);
    if res<0 then x:=x^.l
    else if res>0 then x:=x^.r
    else Break;
    end;
  x^.info:=info;
  end;

procedure tItemSearchList.RemoveThis(var t:pnode);
  begin
  if t^.l<>z then RemoveThis(t^.l);
  if t^.r<>z then RemoveThis(t^.r);
  t^.info:=infoNil;
  t^.key:=itemMin;
  del_node(t);
  t:=z;
  end;

procedure tItemSearchList.RemoveAll;
  begin
  if head=nil then Exit;
  if head^.r<>z then RemoveThis(head^.r);
  head^.info:=infoNil;
  head^.key:=itemMin;
  cnt:=0;
  end;

destructor tItemSearchList.Destroy;
  var
    a:longint;
  begin
  RemoveAll;

  if assigned(head) then
    begin
    head^.info:=infoNil;
    head^.key:=itemMin;
    del_node(head);
    end;

  if assigned(z) then
    begin
    z^.info:=infoNil;
    z^.key:=itemMin;
    del_node(z);
    end;

  if Parents<>nil then Dispose(Parents);

  for a:=0 to Length(myPools)-1 do
    begin
    SetLength(myPools[a]^,0);
    FreeMem(myPools[a]);
    end;
  SetLength(myPools,0);
  
  if assigned(pool) then pool.Free;

  inherited;
  end;

function tItemSearchList.Search(const v:itemType):infoType;
  var
    x:pnode;
    res:integer;
  begin
  x:=head^.r;
  while x<>z do
    begin
    res:=FSearchCompare(v,x^.key);
    if res<0 then x:=x^.l
    else if res>0 then x:=x^.r
    else Break;
    end;
  Result:=x^.info;
  end;

function tItemSearchList.Search_Near(const v:itemType; var res:integer):infoType;
  var
    x:pnode;
  begin
  res:=1;
  x:=head^.r;
  y:=z;
  while x<>z do
    begin
    res:=FSearchCompare(v,x^.key);
    if res<0 then
      begin
      y:=x;
      x:=x^.l;
      end
    else if res>0 then
      begin
      y:=x;
      x:=x^.r;
      end
    else
      begin
      y:=x;
      Break;
      end;
    end;
  Result:=y^.info;
  end;

function tItemSearchList.Search_Min(var i:infoType):itemType;
  var
    x:pnode;
  begin
  x:=head^.r;
  if x<>z then
    begin
    while x^.l<>z do x:=x^.l;
    i:=x^.info;
    Result:=x^.key;
    end
  else
    begin
    i:=infoNil;
    Result:=itemMin;
    end;
  end;

function tItemSearchList.Search_Max(var i:infoType):itemType;
  var
    x:pnode;
  begin
  x:=head^.r;
  if x<>z then
    begin
    while x^.r<>z do x:=x^.r;
    i:=x^.info;
    Result:=x^.key;
    end
  else
    begin
    i:=infoNil;
    Result:=itemMin;
    end;
  end;

function tItemSearchList.Search_L(const v:itemType; var i:infoType):itemType;
  var
    x,y:pnode;
    res:integer;
  begin
  x:=head^.r; y:=head;
  while x<>z do
    begin
    res:=FSearchCompare(v,x^.key);
    if res>0 then
      begin
      y:=x;
      x:=x^.r;
      end
    else
      begin
      if (res=0) and (x^.l<>z) then y:=x^.l;
      x:=x^.l;
      end;
    end;
  Result:=y^.key;
  i:=y^.info;
  end;

function tItemSearchList.Search_G(const v:itemType; var i:infoType):itemType;
  var
    x,y:pnode;
    res:integer;
  begin
  x:=head^.r; y:=head;
  while x<>z do
    begin
    res:=FSearchCompare(v,x^.key);
    if res<0 then
      begin
      y:=x;
      x:=x^.l;
      end
    else
      begin
      if (res=0) and (x^.r<>z) then y:=x^.r;
      x:=x^.r;
      end;
    end;
  Result:=y^.key;
  i:=y^.info;
  end;

function tItemSearchList.Search_LE(const v:itemType; var i:infoType):itemType;
  var
    x,y:pnode;
    res:integer;
  begin
  x:=head^.r; y:=head;
  while x<>z do
    begin
    res:=FSearchCompare(v,x^.key);
    if res>0 then
      begin
      y:=x;
      x:=x^.r;
      end
    else if res<0 then
      x:=x^.l
    else
      Break;
    end;
  if x<>z then
    begin
    Result:=x^.key;
    i:=x^.info;
    end
  else
    begin
    Result:=y^.key;
    i:=y^.info;
    end;
  end;

function tItemSearchList.Search_GE(const v:itemType; var i:infoType):itemType;
  var
    x,y:pnode;
    res:integer;
  begin
  x:=head^.r; y:=head;
  while x<>z do
    begin
    res:=FSearchCompare(v,x^.key);
    if res<0 then
      begin
      y:=x;
      x:=x^.l;
      end
    else if res>0 then
      x:=x^.r
    else
      Break;
    end;
  if x<>z then
    begin
    Result:=x^.key;
    i:=x^.info;
    end
  else
    begin
    Result:=y^.key;
    i:=y^.info;
    end;
  end;

procedure tItemSearchList.Insert_split;
  begin
  x^.b:=true;
  x^.l^.b:=false;
  x^.r^.b:=false;
  if (p^.b) then
    begin
    g^.b:=true;
    if (FUpdateCompare(xv,g^.key)<0)<>(FUpdateCompare(xv,p^.key)<0) then
      begin
      // procedure Insert_p_rotate_g; ->
      c:=p;
      if (FUpdateCompare(xv,c^.key)<0) then
        begin
        p:=c^.l;
        c^.l:=p^.r;
        p^.r:=c;
        end
      else
        begin
        p:=c^.r;
        c^.r:=p^.l;
        p^.l:=c;
        end;
      if (FUpdateCompare(xv,g^.key)<0) then
        g^.l:=p
      else
        g^.r:=p;
      // <-
      end;
    // Insert_x_rotate_gg; ->
    c:=g;
    if (FUpdateCompare(xv,c^.key)<0) then
      begin
      x:=c^.l;
      c^.l:=x^.r;
      x^.r:=c;
      end
    else
      begin
      x:=c^.r;
      c^.r:=x^.l;
      x^.l:=c;
      end;
    if (FUpdateCompare(xv,gg^.key)<0) then
      gg^.l:=x
    else
      gg^.r:=x;
    // <-
    x^.b:=false;
    end;
  head^.r^.b:=false;
  end;

function tItemSearchList.Insert(const v:itemType;const info:infoType):infoType;
  var
    res:integer;
  begin
  x:=head^.r;
  while x<>z do
    begin
    res:=FUpdateCompare(v,x^.key);
    if res<0 then x:=x^.l
    else if res>0 then x:=x^.r
    else Break;
    end;
  Result:=x^.info;

  if Result=infoNil then
    begin
    xv:=v;
    // xinfo:=info;
    nx:=new_node(v,info,True,z,z);
    // Key Sort
    x:=head; p:=head; g:=head;
    while (x<>z) do
      begin
      gg:=g; g:=p; p:=x;
      if (FUpdateCompare(v,x^.key)<0) then x:=x^.l else x:=x^.r;
      if (x^.l^.b and x^.r^.b) then Insert_split;
      end;
    x:=nx;
    if (FUpdateCompare(v,p^.key)<0) then p^.l:=x else p^.r:=x;
    Insert_Split;

    Inc(cnt);
    end;
  end;

procedure tItemSearchList.Remove_AddParentNode(node:pnode);
  begin
  if node<>nil then
    with Parents^ do
      begin
      Nodes[NodeCount]:=node;
      Inc(NodeCount);
      end;
  end;

function tItemSearchList.Remove_GetParentNode:pnode;
  begin
  with Parents^ do
    if NodeCount=0 then
      Result:=z
    else
      begin
      Dec(NodeCount);
      Result:=Nodes[NodeCount];
      end;
  end;
  
procedure tItemSearchList.Remove(const v:itemType);
  var
    a:byte;

  begin
  Parents^.NodeCount:=0;

  p:=head; t:=head^.r;
  Remove_AddParentNode(p);
  while (t<>z) and (FUpdateCompare(v,t^.key)<>0) do
    begin
    p:=t;
    Remove_AddParentNode(p);
    if (FUpdateCompare(v,t^.key)<0) then t:=t^.l else t:=t^.r;
    end;

  if t=z then
    raise Exception.Create('Key not found !');

  if (t^.r=z) then
    begin
    cb:=t^.b;
    x:=t^.l;
    if (p^.l=t) then p^.l:=x else p^.r:=x;
    end
  else if (t^.l=z) then
    begin
    cb:=t^.b;
    x:=t^.r;
    if (p^.l=t) then p^.l:=x else p^.r:=x;
    end
  else
    begin
    p2:=p; c:=t^.r;
    if c^.l=z then
      begin
      Remove_AddParentNode(c);
      x:=c^.r;
      cb:=c^.b;
      c^.b:=t^.b;
      c^.l:=t^.l;
      if p2^.l=t then p2^.l:=c else p2^.r:=c;
      end
    else
      begin
      Remove_AddParentNode(t);
      repeat
        Remove_AddParentNode(c); p:=c;
        c:=c^.l;
        until c^.l=z;
      // SwapParentNode; ->
      with Parents^ do
        for a:=0 to NodeCount-1 do
          if Nodes[a]=t then
            begin
            Nodes[a]:=c;
            Break;
            end;
      // <-
      x:=c^.r; p^.l:=x;
      cb:=c^.b;
      c^.b:=t^.b;
      c^.l:=t^.l;
      c^.r:=t^.r;
      if p2^.l=t then p2^.l:=c else p2^.r:=c;
      end;
    end;
  if cb=false then
    begin
    // deleteFixup; ->
    p:=Remove_GetParentNode;
    g:=Remove_GetParentNode;
    while (x <> head^.r) and (x^.b = false) do
      begin
      if (x = p^.l) then
        begin
        y:=p^.r;
        if (y^.b = true) then
          begin
          y^.b := false;
          p^.b := true;
          // p_rotateLeft_g; ->
          Remove_AddParentNode(g);
          p^.r := y^.l;
          if (p = g^.r) then g^.r := y else g^.l := y;
          y^.l := p;
          g:=y; y:=p^.r;
          // <-
          end;
        if (y^.l^.b = false) and (y^.r^.b = false) then
          begin
          y^.b := true;
          x := p; p := g; g := Remove_GetParentNode;
          end
        else if (p<>head) then
          begin
          if (y^.r^.b = false) then
            begin
            y^.l^.b := false;
            y^.b := true;
            // y_rotateRight_p; ->
            c := y^.l;
            y^.l := c^.r;
            if (p^.r = y) then p^.r := c else p^.l := c;
            c^.r := y;
            y := p^.r;
            // <-
            end;
          y^.b := p^.b;
          p^.b := false;
          y^.r^.b := false;
          // p_rotateLeft_g; ->
          Remove_AddParentNode(g);
          p^.r := y^.l;
          if (p = g^.r) then g^.r := y else g^.l := y;
          y^.l := p;
          g:=y; y:=p^.r;
          // <-
          x:=head^.r;
          break;
          end;
        end
      else
        begin
        y:=p^.l;
        if (y^.b = true) then
          begin
          y^.b := false;
          p^.b := true;
          // p_rotateRight_g; ->
          Remove_AddParentNode(g);
          p^.l := y^.r;
          if (p = g^.l) then
            begin
            g^.l := y
            end
          else
            begin
            g^.r := y;
            end;
          y^.r := p;
          g:=y; y:=p^.l;
          // <-
          end;
        if (y^.r^.b = false) and (y^.l^.b = false) then
          begin
          y^.b := true;
          x := p; p := g; g := Remove_GetParentNode;
          end
        else
          begin
          if (y^.l^.b = false) then
            begin
            y^.r^.b := false;
            y^.b := true;
            // y_rotateLeft_p; ->
            c := y^.r;
            y^.r := c^.l;
            if (p^.l = y) then p^.l := c else p^.r := c;
            c^.l := y;
            y := p^.l;
            // <-
            end;
          y^.b := p^.b;
          p^.b := false;
          y^.l^.b := false;
          // p_rotateRight_g; ->
          Remove_AddParentNode(g);
          p^.l := y^.r;
          if (p = g^.l) then g^.l := y else g^.r := y;
          y^.r := p;
          g:=y; y:=p^.l;
          // <-
          x:=head^.r;
          break;
          end;
        end;
      end;
    if (x<>z) then x^.b := false;
    // <-
    end;

  t^.info:=infoNil;
  t^.key:=itemMin;
  del_node(t);

  Dec(cnt);
  end;

function tItemSearchList.Count: cardinal;
  begin
  Result:=cnt;
  end;

end.

