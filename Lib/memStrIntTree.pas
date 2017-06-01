{
  "Balanced Binary search Tree" (RtcString>'', longint>-1)
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)
  
  @exclude
}

unit memStrIntTree;

{$INCLUDE rtcDefs.inc}

interface

uses
  SysUtils, rtcTypes, memPtrPool;

{$DEFINE RTC_BINTREE}

type
  itemType=RtcString;
  infoType=longint;

{$I sort\types.inc}

type
{ Balanced Binary search Tree (RtcString>'', longint>-1) }
  tStrIntTree={$I sort\class.inc};

implementation

const
  itemMin:itemType='';
  infoNil:infoType=-1;

function tStrIntTree.{$I sort\Empty.inc};

function tStrIntTree.{$I sort\NewNode.inc};

procedure tStrIntTree.{$I sort\PoolSize.inc};

procedure tStrIntTree.{$I sort\DelNode.inc};

constructor tStrIntTree.{$I sort\Create.inc};

procedure tStrIntTree.{$I sort\Change.inc};

procedure tStrIntTree.{$I sort\RemoveThis.inc};

procedure tStrIntTree.{$I sort\RemoveAll.inc};

destructor tStrIntTree.{$I sort\Destroy.inc};

function tStrIntTree.{$I sort\Search.inc};

function tStrIntTree.{$I sort\iSearch.inc};

function tStrIntTree.{$I sort\SearchMin.inc};

function tStrIntTree.{$I sort\iSearchMin.inc};

function tStrIntTree.{$I sort\SearchMax.inc};

function tStrIntTree.{$I sort\iSearchMax.inc};

function tStrIntTree.{$I sort\SearchL.inc};

function tStrIntTree.{$I sort\iSearchL.inc};

function tStrIntTree.{$I sort\SearchG.inc};

function tStrIntTree.{$I sort\iSearchG.inc};

function tStrIntTree.{$I sort\SearchLE.inc};

function tStrIntTree.{$I sort\iSearchLE.inc};

function tStrIntTree.{$i sort\SearchGE.inc};

function tStrIntTree.{$I sort\iSearchGE.inc};

procedure tStrIntTree.{$I sort\InsertSplit.inc};

procedure tStrIntTree.{$I sort\InsertSplit2.inc};

procedure tStrIntTree.{$I sort\Insert.inc};

procedure tStrIntTree.{$I sort\RemoveAddP.inc};

function tStrIntTree.{$I sort\RemoveGetP.inc};

procedure tStrIntTree.{$I sort\Remove.inc};

function tStrIntTree.{$I sort\Count.inc};

end.
