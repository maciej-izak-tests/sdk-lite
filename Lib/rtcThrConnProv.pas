{
  "Threaded Connection Provider wrapper"
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)
  @html(<br>)

  @exclude
}

unit rtcThrConnProv;

{$INCLUDE rtcDefs.inc}

interface

uses
  SysUtils,
  rtcTypes,
  rtcLog,
  rtcThrPool,
  rtcConnProv;

type
  TRtcThrClientProvider = class(TRtcBasicClientProvider)
  protected
    function GetClientThread:TRtcThread; virtual; abstract;

  public

    function GetThread:TRtcThread; override;

    function inThread:boolean; override;

    function PostJob(var _Job; HighPriority:boolean; ForceThread:boolean=False):boolean; override;

  (*** Methods that have to be implemented by the connection provider: *** ->

  protected
    function GetClientThread:TRtcThread; override;

  public
    procedure Connect(Force:boolean=False); override;
    procedure Disconnect; override;
    procedure InternalDisconnect; override;

    procedure WriteEx(const s:RtcByteArray); override;
    function ReadEx:RtcByteArray; override;

    procedure Write(const s:RtcString); override;
    function Read:RtcString; override;

    <- *** end ***)
    end;

  TRtcNoThrClientProvider = class(TRtcBasicClientProvider)
  public
    function inThread:boolean; override;

    function GetThread:TRtcThread; override;

    function PostJob(var _Job; HighPriority:boolean; ForceThread:boolean=False):boolean; override;

  (*** Methods that have to be implemented by the connection provider: *** ->

  public
    procedure Connect(Force:boolean=False); override;
    procedure Disconnect; override;
    procedure InternalDisconnect; override;

    procedure WriteEx(const s:RtcByteArray); override;
    function ReadEx:RtcByteArray; override;

    procedure Write(const s:RtcString); override;
    function Read:RtcString; override;

    <- *** end ***)
    end;

  TRtcThrServerProvider = class(TRtcBasicServerProvider)
  protected
    function GetServerThread:TRtcThread; virtual; abstract;
    function GetClientThread:TRtcThread; virtual; abstract;

  public
    function inThread:boolean; override;

    function GetThread:TRtcThread; override;

    function PostJob(var _Job; HighPriority:boolean; ForceThread:boolean=False):boolean; override;

  (*** Methods that have to be implemented by the connection provider: ***

  protected
    procedure CopyFrom(Dup:TRtcConnectionProvider);

    function GetClientThread:TRtcThread; override;
    function GetServerThread:TRtcThread; override;

  public
    procedure Listen; override;
    procedure Disconnect; override;
    procedure InternalDisconnect; override;

    function GetParent:TRtcConnectionProvider; override;

    procedure WriteEx(const s:RtcByteArray); override;
    function ReadEx:RtcByteArray; override;

    procedure Write(const s:RtcString); override;
    function Read:RtcString; override;

  *** end ***)
    end;

  TRtcNoThrServerProvider = class(TRtcBasicServerProvider)
  public
    function inThread:boolean; override;

    function GetThread:TRtcThread; override;

    function PostJob(var _Job; HighPriority:boolean; ForceThread:boolean=False):boolean; override;

  (*** Methods that have to be implemented by the connection provider: ***

  protected
    procedure CopyFrom(Dup:TRtcConnectionProvider);

  public
    procedure Listen; override;
    procedure Disconnect; override;
    procedure InternalDisconnect; override;

    function GetParent:TRtcConnectionProvider; override;

    procedure WriteEx(const s:RtcByteArray); override;
    function ReadEx:RtcByteArray; override;

    procedure Write(const s:RtcString); override;
    function Read:RtcString; override;

  *** end ***)
    end;

implementation

{ TRtcThrClientProvider }

function TRtcThrClientProvider.inThread: boolean;
  begin
  if GetClientThread<>nil then
    Result:=GetClientThread.InsideThread
  else if GetMultiThreaded then
    Result:=InsideMainThread
  else
    Result:=True;
  end;

function TRtcThrClientProvider.PostJob(var _Job; HighPriority: boolean; ForceThread:boolean=False): boolean;
  var
    Job:TObject absolute _Job;
    xJob:TRtcJob absolute _Job;
  begin
  if Job=nil then
    Result:=True
  else if GetClientThread<>nil then
    begin
    Result:=TRtcThread.PostJob(GetClientThread,Job,HighPriority,ForceThread);
    end
  else if (Job is TRtcJob) and not GetMultiThreaded then
    begin
    if xJob.Run(nil) then
      if xJob.SingleUse then
        RtcFreeAndNil(Job);
    Result:=True;
    end
  else
    Result:=False;
  end;

function TRtcThrClientProvider.GetThread: TRtcThread;
  begin
  Result:=GetClientThread;
  end;

{ TRtcNoThrClientProvider }

function TRtcNoThrClientProvider.inThread: boolean;
  begin
  Result:=True; // inMainThread;
  end;

function TRtcNoThrClientProvider.PostJob(var _Job; HighPriority: boolean; ForceThread:boolean=False): boolean;
  var
    Job:TObject absolute _Job;
    xJob:TRtcJob absolute _Job;
  begin
  if Job=nil then
    Result:=True
  else if Job is TRtcJob then
    begin
    if xJob.Run(nil) then
      if xJob.SingleUse then
        RtcFreeAndNil(Job);
    Result:=True;
    end
  else
    Result:=False;
  end;

function TRtcNoThrClientProvider.GetThread: TRtcThread;
  begin
  Result:=nil;
  end;

{ TRtcThrServerProvider }

function TRtcThrServerProvider.inThread: boolean;
  begin
  if GetClientThread<>nil then
    Result:=GetClientThread.InsideThread
  else if GetServerThread<>nil then
    Result:=GetServerThread.InsideThread
  else if GetMultiThreaded then
    Result:=InsideMainThread
  else
    Result:=True;
  end;

function TRtcThrServerProvider.PostJob(var _Job; HighPriority: boolean; ForceThread:boolean=False): boolean;
  var
    Job:TObject absolute _Job;
    xJob:TRtcJob absolute _Job;
  begin
  if Job=nil then
    Result:=True
  else if GetClientThread<>nil then
    begin
    Result:=TRtcThread.PostJob(GetClientThread,Job,HighPriority,ForceThread);
    end
  else if GetServerThread<>nil then
    begin
    Result:=TRtcThread.PostJob(GetServerThread,Job,HighPriority,ForceThread);
    end
  else if (Job is TRtcJob) and not GetMultiThreaded then
    begin
    if xJob.Run(nil) then
      if xJob.SingleUse then
        RtcFreeAndNil(xJob);
    Result:=True;
    end
  else
    Result:=False;
  end;

function TRtcThrServerProvider.GetThread: TRtcThread;
  begin
  Result:=GetClientThread;
  if not assigned(Result) then
    Result:=GetServerThread;
  end;

{ TRtcNoThrServerProvider }

function TRtcNoThrServerProvider.inThread: boolean;
  begin
  Result:=True;
  end;

function TRtcNoThrServerProvider.PostJob(var _Job; HighPriority: boolean; ForceThread:boolean=False): boolean;
  var
    Job:TObject absolute _Job;
    xJob:TRtcJob absolute _Job;
  begin
  if Job=nil then
    Result:=True
  else if Job is TRtcJob then
    begin
    if xJob.Run(nil) then
      if xJob.SingleUse then
        RtcFreeAndNil(Job);
    Result:=True;
    end
  else
    Result:=False;
  end;

function TRtcNoThrServerProvider.GetThread: TRtcThread;
  begin
  Result:=nil;
  end;

initialization
finalization
{$IFDEF RTC_DEBUG} Log('rtcThrConnProv Finalizing ...','DEBUG');{$ENDIF}
CloseThreadPool;
{$IFDEF RTC_DEBUG} Log('rtcThrConnProv Finalized.','DEBUG');{$ENDIF}
end.
