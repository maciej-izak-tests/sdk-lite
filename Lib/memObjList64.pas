{
  "Balanced Binary search List" (RtcIntPtr>0, TObject>nil)
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)
  
  @exclude
}

unit memObjList64;

{$INCLUDE rtcDefs.inc}

interface

uses
  SysUtils, memPtrPool, rtcTypes;

type
  itemType = int64;
  infoType = TObject;

{$I sort\types.inc}

type
{ Balanced Binary search List (RtcIntPtr>0, TObject>nil) }
  tObjList64={$I sort\class.inc};

implementation

const
  itemMin:itemType=0;
  infoNil:infoType=nil;

function tObjList64.{$I sort\Empty.inc};

function tObjList64.{$I sort\NewNode.inc};

procedure tObjList64.{$I sort\PoolSize.inc};

procedure tObjList64.{$I sort\DelNode.inc};

constructor tObjList64.{$I sort\Create.inc};

procedure tObjList64.{$I sort\Change.inc};

procedure tObjList64.{$I sort\RemoveThis.inc};

procedure tObjList64.{$I sort\RemoveAll.inc};

destructor tObjList64.{$I sort\Destroy.inc};

function tObjList64.{$I sort\Search.inc};

function tObjList64.{$I sort\SearchMin.inc};

function tObjList64.{$I sort\SearchMax.inc};

function tObjList64.{$I sort\SearchL.inc};

function tObjList64.{$I sort\SearchG.inc};

function tObjList64.{$I sort\SearchLE.inc};

function tObjList64.{$I sort\SearchGE.inc};

procedure tObjList64.{$I sort\InsertSplit.inc};

procedure tObjList64.{$I sort\Insert.inc};

procedure tObjList64.{$I sort\RemoveAddP.inc};

function tObjList64.{$I sort\RemoveGetP.inc};

procedure tObjList64.{$I sort\Remove.inc};

function tObjList64.{$I sort\Count.inc};

end.
