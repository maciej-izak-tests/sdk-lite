Destroy;
  var
    a,i:longint;
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
    for i:=0 to length(myPools[a]^)-1 do
      myPools[a]^:=nil;
    SetLength(myPools[a]^,0);
    FreeMem(myPools[a]);
    myPools[a]:=nil;
    end;
  SetLength(myPools,0);
  
  if assigned(pool) then pool.Free;

  inherited;
  end
