{
  RealThinClient SDK: Platform-independent Synchronous Socket API class
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)

  @exclude
}
unit rtcSynAPI;

{$INCLUDE rtcDefs.inc}

interface

uses
  SysUtils,

  rtcTypes,
  rtcConn,
  rtcInfo,
  rtcFastStrings,
  rtcSockBase,

{$IFDEF WINDOWS} //Win32 and Win64
  rtcWinSock;

type
  TAPISockAddr = TSockAddr;

{$ELSE}{$IFDEF POSIX} // Mac OSX
  Classes,
  Posix.Errno,
  Posix.Base, Posix.SysSocket, Posix.SysSelect,
  Posix.ArpaInet, Posix.NetinetIn, Posix.NetDB,
  Posix.Unistd, Posix.SysTime; // , PosixStrOpts;

type
  TSocket = integer;

  TSockAddrIn = sockaddr_in;
  TSockAddrIn6 = sockaddr_in6;
  TSockAddr = record
    case integer of
      0: ({$IFDEF MACOS} sa_len: UInt8; {$ENDIF}
          sa_family: sa_family_t;
          sa_port: in_port_t);
      1: (sin:TSockAddrIn);
      2: (sin6:TSockAddrIn6);
    end;

  TAPISockAddr = sockaddr;

  TFDSet = fd_set;

{$ELSE}{$IFDEF RTC_NIX_SOCK} // iOS (iPhone + iPad) on FPC
  rtcNixSock;

type
  TAPISockAddr = TSockAddr;

{$ELSE} // Anything else
  Classes,
  BaseUnix,
  Unix,
  termio,
  sockets,
  netdb;

type
  TAPISockAddr = TSockAddr;

{$ENDIF}{$ENDIF}{$ENDIF}

var
  LISTEN_BACKLOG:integer=200;

type
  TRtcSocket=class
  private
    FOSocket,
    FSocket: TSocket;
    NewSockID: TSocket;
    FFDSet: TFDSet;
    FErr: String;
    FErrCode: Integer;
    FSin, FLocalSin, FRemoteSin: TSockAddr;

  {$IFDEF WINDOWS}
    FLocalSinLen, FRemoteSinLen: integer;
  {$ELSE}{$IFDEF POSIX}
    FLocalSinLen, FRemoteSinLen: socklen_t;
    FTempBuffer: RtcByteArray;
  {$ELSE}{$IFDEF RTC_NIX_SOCK}
    FTempBuffer: RtcByteArray;
  {$ENDIF}{$ENDIF}{$ENDIF}

    procedure Sock_SetSin(var Sin: TSockAddr; const vAddr,vPort:RtcString; PreferIP4, PreferIPDef:boolean);
    procedure Sock_CreateSocket(Sin: TSockAddr);
    procedure Sock_SetLinger(vEnable: Boolean; vLinger: Integer);
    procedure Sock_SetDelay;
    procedure Sock_SetTimeouts(const TOA:TRtcTimeoutsOfAPI);

    procedure Sock_Connect(const vAddr,vPort: RtcString; const TOA:TRtcTimeoutsOfAPI; PreferIP4, PreferIPDef:boolean);
    procedure Sock_Listen(const vAddr,vPort: RtcString; const TOA:TRtcTimeoutsOfAPI; PreferIP4, PreferIPDef:boolean);

    function Sock_Accept:TSocket;
    procedure Sock_SetSocket(sid:TSocket; PreferIP4:boolean);

    function Sock_Shutdown:boolean;
    function Sock_Close:boolean;

    function Sock_Invalid:boolean;
    function Sock_CheckError:boolean;
    function Sock_Err(res:Integer):boolean;

    procedure Sock_ResetError;
    procedure Sock_CheckLastError;
    procedure Sock_CheckLastErrorDesc;

    function Sock_GetConnInfo:String;
    function Sock_GetLocalSinIP:RtcString;
    function Sock_GetLocalSinPort:RtcString;
    function Sock_GetRemoteSinIP:RtcString;
    function Sock_GetRemoteSinPort:RtcString;

    function Sock_WaitingData:integer;
    function Sock_RecvBuffer(var Buffer; Len: Integer): Integer;
    function Sock_SendBuffer(var Buffer; Len: Integer): Integer;

    function Sock_CanRead(vTimeout:integer):boolean;
    function Sock_CanWrite(vTimeout:integer):boolean;

  public
    { Constructor }
    constructor Create;

    { Destructor }
    destructor Destroy; override;

    { Start using this socket as Server listener,
      listening on port "FPort", bound to local network addapter "FAddr".
      Leave "FAddr" empty to listen on all network addapters.
      TOA can be passed as parameter to set Timeouts on API.
      Send NIL as TOA parameter to use default timeout values.
      Returns TRUE if success, FALSE if error. }
    function Listen(const FAddr,FPort:RtcString; const TOA:TRtcTimeoutsOfAPI; PreferIP4, PreferIPDef:boolean):boolean;

    { Connect to address "FAddr" on port "FPort".
      TOA can be passed as parameter to set Timeouts on API.
      Send NIL as TOA parameter to use default timeout values.
      Returns TRUE if success, FALSE if error. }
    function Connect(const FAddr,FPort:RtcString; const TOA:TRtcTimeoutsOfAPI; PreferIP4, PreferIPDef:boolean): boolean;

    { Shut down input and output connection, preparing for close.
      Returns TRUE if success, FALSE if conneciton was already closed. }
    function Shut_down:boolean;

    { Close socket connection.
      If it was a Listening socket, listener is closed but NOT connected clients.
      If it was a Client socket, it will be disconnected from Server.
      Returns TRUE if success, FALSE if error. }
    function Close: boolean;

    { Check if there are new client sockets waiting to be accepted.
      Returns the number of waiting sockets if there are sockets waiting,
      0 if no sockets were waiting after "vTimeout" (ms), or -1 if error. }
    function WaitingSockets(vTimeout:integer): integer;

    { After WaitingSockets has returned a positive result,
      use GetNewSocket to accept one socket and receive
      a new TRtcSocket component for the new socket.
      Returns a new TRtcSocket object if OK, or NIL if error. }
    function GetNewSocket: TRtcSocket;

    { Has to be called on a socket received from GetNewSocket
      before the new TRtcSocket component can be used.
      Returns TRUE is the socket can be used, FALSE if error. }
    function StartNewSocket(PreferIP4:boolean): boolean;

    { Try to receive data from the other side.
      If data is available, will read as much as can be read without blocking.
      If no data is available, will wait up to "vTimeout" ms for new data.
      If no data after "vTimeout", returns TRUE and an empty string in "Str".
      If data was read, "Str" will contain the data received, result will be TRUE.
      If there was an error, "Str" will be empty and FALSE will be returned as Result. }
    function ReceiveEx(var Str: RtcByteArray; vTimeout:integer): boolean;

    { Try to send as much data from "Str" starting at character location "at"
      as possible without blocking. If can not read (buffer full), will wait
      up to "vTimeout" ms to be able to send at least something. If something
      was sent, will return the number of characters (bytes) sent (to buffer).
      If can not send yet but connection seems OK, will return 0.
      If connection is not working anymore, will return -1. }
    function SendEx(var Str: RtcByteArray; at: integer; vTimeout:integer): Integer;

    { If any of the methods of this class returns FALSE or -1,
      signaling that there was an error, GetLastErrorText will
      return a more-or-less descriptive error message (text). }
    function GetLastErrorText: String;

    { Local Address to which this socket is connected. }
    function GetLocalAddr: RtcString;

    { Local Port to which this socket is connected. }
    function GetLocalPort: RtcString;

    { Peer (remote) Address to which this socket is connected.
      Does NOT apply to Listening sockets (server).  }
    function GetPeerAddr: RtcString;

    { Peer (remote) Port to which this socket is connected.
      Does NOT apply to Listening sockets (server).  }
    function GetPeerPort: RtcString;
    end;

implementation

// Declare missing functions and types
{$IFDEF WINDOWS}               //{$I synsock\winapi.inc}
{$ELSE} {$IFDEF FPSOCK}        {$I synsock\fpcapi.inc}
{$ELSE} {$IFDEF POSIX}         {$I synsock\posapi.inc}
{$ELSE} {$IFDEF RTC_NIX_SOCK}  {$I synsock\nixapi.inc}
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}

constructor TRtcSocket.Create;
  begin
  inherited;
{$IFDEF WINDOWS}
  LoadWinSock;
{$ELSE}{$IFDEF POSIX}
  SetLength(FTempBuffer,65000);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  LoadNixSock;
  SetLength(FTempBuffer,65000);
{$ENDIF}{$ENDIF}{$ENDIF}
  FSocket:=INVALID_SOCKET;
  FOSocket:=FSocket;
  NewSockID:=FSocket;
  end;

destructor TRtcSocket.Destroy;
  begin
{$IFDEF POSIX}
  SetLength(FTempBuffer,0);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  SetLength(FTempBuffer,0);
{$ENDIF}{$ENDIF}
  Sock_Close;
  inherited;
  end;

function TRtcSocket.Listen(const FAddr,FPort:RtcString; const TOA:TRtcTimeoutsOfAPI; PreferIP4, PreferIPDef:boolean): boolean;
  begin
  Sock_ResetError;

  Sock_Listen(FAddr,FPort,TOA,PreferIP4,PreferIPDef);
  Result:= not Sock_CheckError;
  if not Result then
    Sock_Close;
  end;

function TRtcSocket.Connect(const FAddr,FPort:RtcString; const TOA:TRtcTimeoutsOfAPI; PreferIP4, PreferIPDef:boolean): boolean;
  begin
  Sock_ResetError;

  Sock_Connect(FAddr,FPort,TOA,PreferIP4,PreferIPDef);
  Result:= not Sock_CheckError;

  if not Result then
    Sock_Close;
  end;

function TRtcSocket.WaitingSockets(vTimeout:integer): integer;
  begin
  Result:=-1;
  Sock_ResetError;

  if Sock_CanRead(vTimeout) then
    Result:=1
  else if not Sock_CheckError then
    Result:=0;
  end;

function TRtcSocket.GetNewSocket: TRtcSocket;
  var
    Sck:TSocket;
  begin
  Result:=nil;
  Sock_ResetError;

  Sck:=Sock_Accept;
  if Sock_CheckError then Exit;

  Result:=TRtcSocket.Create;
  Result.NewSockID:=Sck;
  end;

function TRtcSocket.StartNewSocket(PreferIP4:boolean): boolean;
  begin
  Sock_ResetError;

  Sock_SetSocket(NewSockID,PreferIP4);
  Result:= not Sock_CheckError;
  end;

function TRtcSocket.Close: boolean;
  begin
  Result:=False;
  Sock_ResetError;
  if Sock_Close then
    Result:=True;
  end;

function TRtcSocket.Shut_down:boolean;
  begin
  Result:=Sock_Shutdown;
  end;

function TRtcSocket.ReceiveEx(var Str: RtcByteArray; vTimeout:integer): boolean;
  var
    r,l: integer;
  begin
  Sock_ResetError;

  l:=Sock_WaitingData;
  if l<0 then
    begin
    SetLength(Str,0);
    Result:=False;
    end
  else
    begin
    if l=0 then // nothing to read yet?
      if not Sock_CanRead(vTimeout) then // wait for new data
        begin
        SetLength(Str,0);
        Result:=not Sock_CheckError;
        Exit;
        end
      else
        l:=Sock_WaitingData;

    if l>0 then
      begin
      if l>SOCK_MAX_READ_SIZE then
        l:=SOCK_MAX_READ_SIZE;
      SetLength(Str,l);
      r:=Sock_RecvBuffer(Str[0],l);
      if r<>l then // received size has to be equal to "WaitingData"
        begin
        if r>=0 then
          begin
          FErrCode:=-1;
          FErr:='Reading error';
          end;
        SetLength(Str,0);
        Result:=False;
        end
      else
        Result:=not Sock_CheckError;
      end
    else // can read but nothing to read? error!
      begin
      SetLength(Str,0);
      FErrCode:=-1;
      FErr:='Connection error';
      Result:=False;
      end;
    end;
  end;

function TRtcSocket.SendEx(var Str: RtcByteArray; at: integer; vTimeout:integer): Integer;
  begin
  Sock_ResetError;

{ Sock_SendBuffer() is a blocking call.
  If the output is not ready, it would block infinitely. }
  if Sock_CanWrite(vTimeout) then
    begin
    Result:=Sock_SendBuffer(Str[at-1],length(Str)-at+1);
    if Result=0 then
      Result:=-1; // error!
    end
  else if Sock_CheckError then
    Result:=-1 // error!
  else
    Result:=0;

  if Result>=0 then
    if Sock_CheckError then
      Result:=-1;
  end;

function TRtcSocket.GetLastErrorText: String;
  begin
  if FErrCode=0 then
    Result:=''
  else
    Result:='#'+IntToStr(FErrCode)+': '+FErr;
  end;

function TRtcSocket.GetLocalAddr: RtcString;
  begin
  if not Sock_Invalid then
    Result:=Sock_GetLocalSinIP
  else
    Result:='';
  end;

function TRtcSocket.GetLocalPort: RtcString;
  begin
  if not Sock_Invalid then
    Result:=Sock_GetLocalSinPort
  else
    Result:='';
  end;

function TRtcSocket.GetPeerAddr: RtcString;
  begin
  if not Sock_Invalid then
    Result:=Sock_GetRemoteSinIP
  else
    Result:='';
  end;

function TRtcSocket.GetPeerPort: RtcString;
  begin
  if not Sock_Invalid then
    Result:=Sock_GetRemoteSinPort
  else
    Result:='';
  end;

function TRtcSocket.Sock_Err(res: Integer):boolean;
  begin
  if res>=0 then
    Result:=False
  else
    begin
    Result:=True;
    Sock_CheckLastError;
    end;
  end;

function TRtcSocket.Sock_Invalid: boolean;
  begin
  Result := FOSocket=INVALID_SOCKET;
  end;

(*** SOCKET-SPECIFIC METHODS ***)

function TRtcSocket.Sock_CheckError: boolean;
  begin
{$IFDEF WINDOWS}
  Result := (FErrCode <> 0) and
            (FErrCode <> WSAEINPROGRESS) and
            (FErrCode <> WSAEWOULDBLOCK);
{$ELSE}{$IFDEF FPSOCK}
  Result := (FErrCode <> 0) and
            (FErrCode <> ESysEINPROGRESS) and
            (FErrCode <> ESysEWOULDBLOCK);
{$ELSE}{$IFDEF POSIX}
  Result := (FErrCode <> 0) and
            (FErrCode <> EINPROGRESS) and
            (FErrCode <> EWOULDBLOCK);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  Result := (FErrCode <> 0) and
            (FErrCode <> WSAEINPROGRESS) and
            (FErrCode <> WSAEWOULDBLOCK);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

procedure TRtcSocket.Sock_CheckLastErrorDesc;
  begin
{$IFDEF WINDOWS}
  FErr := WSocket_ErrorDesc(FErrCode);
{$ELSE}{$IFDEF FPSOCK}
  FErr := WSA_ErrorDesc(FErrCode);
{$ELSE}{$IFDEF POSIX}
  FErr := WSA_ErrorDesc(FErrCode);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  FErr := WSA_ErrorDesc(FErrCode);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  if FErr<>'' then
    FErr:=FErr+' '+Sock_GetConnInfo;
  end;

procedure TRtcSocket.Sock_CheckLastError;
  begin
{$IFDEF WINDOWS}
  FErrCode:=_WSAGetLastError;
{$ELSE}{$IFDEF FPSOCK}
  FErrCode:=fpgeterrno;
{$ELSE}{$IFDEF POSIX}
  FErrCode:=GetLastError;
  if FErrCode=0 then FErr:='' else
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  FErrCode:=WSA_GetLastError;
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  Sock_CheckLastErrorDesc;
  end;

procedure TRtcSocket.Sock_SetSin(var Sin: TSockAddr; const vAddr,vPort:RtcString; PreferIP4, PreferIPDef:boolean);
  begin
  FillChar(FSin,SizeOf(FSin),0);
{$IFDEF WINDOWS}
  FErrCode := WSocket_SetVarSin(sin, vAddr, vPort, AF_UNSPEC, IPPROTO_TCP, SOCK_STREAM, PreferIP4, PreferIPDef);
{$ELSE}{$IFDEF FPSOCK}
  FErrCode := WSA_SetVarSin(sin, vAddr, vPort, AF_UNSPEC, IPPROTO_TCP, SOCK_STREAM, PreferIP4, PreferIPDef);
{$ELSE}{$IFDEF POSIX}
  FErrCode := WSA_SetVarSin(sin, vAddr, vPort, AF_UNSPEC, IPPROTO_TCP, SOCK_STREAM, PreferIP4, PreferIPDef);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  FErrCode := WSA_SetVarSin(sin, vAddr, vPort, AF_UNSPEC, IPPROTO_TCP, SOCK_STREAM, PreferIP4, PreferIPDef);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  FSin:=Sin;
  Sock_CheckLastErrorDesc;
  end;

procedure TRtcSocket.Sock_CreateSocket(Sin: TSockAddr);
  begin
  FSocket:=INVALID_SOCKET;
{$IFDEF WINDOWS}
  FOSocket := _Socket(Sin.sin_family, SOCK_STREAM, IPPROTO_TCP);
  if FOSocket = INVALID_SOCKET then
    Sock_CheckLastError
  else
    begin
    FSocket:=FOSocket;
    FD_ZERO(FFDSet);
    FD_SET(FSocket, FFDSet);
    end;
{$ELSE}{$IFDEF FPSOCK}
  FOSocket := fpSocket(integer(Sin.sin_family), SOCK_STREAM, IPPROTO_TCP);
  if FOSocket = INVALID_SOCKET then
    Sock_CheckLastError
  else
    begin
    FSocket:=FOSocket;
    fpFD_ZERO(FFDSet);
    fpFD_SET(FSocket, FFDSet);
    end;
{$ELSE}{$IFDEF POSIX}
  FOSocket := socket(Sin.sa_family, SOCK_STREAM, IPPROTO_TCP);
  if FOSocket = INVALID_SOCKET then
    Sock_CheckLastError
  else
    begin
    FSocket:=FOSocket;
    __FD_ZERO(FFDSet);
    __FD_SET(FSocket, FFDSet);
    end;
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  FOSocket := WSA_Socket(integer(Sin.AddressFamily), SOCK_STREAM, IPPROTO_TCP);
  if FOSocket = INVALID_SOCKET then
    Sock_CheckLastError
  else
    begin
    FSocket:=FOSocket;
    FD_ZERO(FFDSet);
    FD_SET(FSocket, FFDSet);
    end;
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

procedure TRtcSocket.Sock_SetLinger(vEnable: Boolean; vLinger: Integer);
  var
    li: TLinger;
    buf: pointer;
  begin
  if FOSocket=INVALID_SOCKET then Exit;
  if vEnable then
    li.l_onoff := 1
  else
    li.l_onoff := 0;
  li.l_linger := vLinger;
  buf := @li;
{$IFDEF WINDOWS}
  Sock_Err(_SetSockOpt(FSocket, SOL_SOCKET, SO_LINGER, buf, SizeOf(li)));
{$ELSE}{$IFDEF FPSOCK}
  Sock_Err(fpSetSockOpt(FSocket, integer(SOL_SOCKET), integer(SO_LINGER), buf, SizeOf(li)));
{$ELSE}{$IFDEF POSIX}
  Sock_Err(SetSockOpt(FSocket, integer(SOL_SOCKET), integer(SO_LINGER), buf, SizeOf(li)));
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  {$IFNDEF DARWIN} // SetLinger does NOT work on iOS
    Sock_Err(WSA_SetSockOpt(FSocket, integer(SOL_SOCKET), integer(SO_LINGER), buf, SizeOf(li)));
  {$ENDIF}
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

procedure TRtcSocket.Sock_SetDelay;
  var
    optval: integer;
    buf: pointer;
  begin
  if FOSocket=INVALID_SOCKET then Exit;
  buf := @optval;
{$IFDEF WINDOWS}
  // NO DELAY
  optval := -1; { -1=true, 0=false }
  _SetSockOpt(FSocket, IPPROTO_TCP, TCP_NODELAY, buf, SizeOf(optval));
  // KEEP-ALIVE
  optval  := -1;
  _SetSockOpt(FSocket, SOL_SOCKET, SO_KEEPALIVE, buf, SizeOf(optval));
  // REUSE ADDR.
  optval  := -1;
  _SetSockOpt(FSocket, SOL_SOCKET, SO_REUSEADDR, buf, SizeOf(optval));
  // Set READ Buffer
  optval := SOCK_READ_BUFFER_SIZE;
  _SetSockOpt(FSocket, SOL_SOCKET, SO_RCVBUF, buf, SizeOf(optval));
  // Set SEND Buffer
  optval := SOCK_SEND_BUFFER_SIZE;
  _SetSockOpt(FSocket, SOL_SOCKET, SO_SNDBUF, buf, SizeOf(optval));
{$ELSE}{$IFDEF FPSOCK}
  // NO DELAY
  optval := -1; { -1=true, 0=false }
  fpSetSockOpt(FSocket, IPPROTO_TCP, TCP_NODELAY, buf, SizeOf(optval));
  // KEEP-ALIVE
  optval  := -1;
  fpSetSockOpt(FSocket, SOL_SOCKET, SO_KEEPALIVE, buf, SizeOf(optval));
  // REUSE ADDR.
  optval  := -1;
  fpSetSockOpt(FSocket, SOL_SOCKET, SO_REUSEADDR, buf, SizeOf(optval));
  // Set READ Buffer
  optval := SOCK_READ_BUFFER_SIZE;
  fpSetSockOpt(FSocket, SOL_SOCKET, SO_RCVBUF, buf, SizeOf(optval));
  // Set SEND Buffer
  optval := SOCK_SEND_BUFFER_SIZE;
  fpSetSockOpt(FSocket, SOL_SOCKET, SO_SNDBUF, buf, SizeOf(optval));
{$ELSE}{$IFDEF POSIX}
  // NO SEND DELAY
  optval := 1;
  SetSockOpt(FSocket, SOL_SOCKET, SO_SNDLOWAT, buf, SizeOf(optval));
  // KEEP-ALIVE
  optval  := -1;
  SetSockOpt(FSocket, SOL_SOCKET, SO_KEEPALIVE, buf, SizeOf(optval));
  // REUSE ADDR.
  optval  := -1;
  SetSockOpt(FSocket, SOL_SOCKET, SO_REUSEADDR, buf, SizeOf(optval));
  // Set READ Buffer
  optval := SOCK_READ_BUFFER_SIZE;
  SetSockOpt(FSocket, SOL_SOCKET, SO_RCVBUF, buf, SizeOf(optval));
  // Set SEND Buffer
  optval := SOCK_SEND_BUFFER_SIZE;
  SetSockOpt(FSocket, SOL_SOCKET, SO_SNDBUF, buf, SizeOf(optval));
  // Do NOT generate SIGPIPE
  optval := -1;
  SetSockOpt(FSocket, SOL_SOCKET, SO_NOSIGPIPE, buf, SizeOf(optval));
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  // NO DELAY
  optval := -1; { -1=true, 0=false }
  WSA_SetSockOpt(FSocket, IPPROTO_TCP, TCP_NODELAY, buf, SizeOf(optval));
  // KEEP-ALIVE
  optval  := -1;
  WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_KEEPALIVE, buf, SizeOf(optval));
  // REUSE ADDR.
  optval  := -1;
  WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_REUSEADDR, buf, SizeOf(optval));
  // Set READ Buffer
  optval := SOCK_READ_BUFFER_SIZE;
  WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_RCVBUF, buf, SizeOf(optval));
  // Set SEND Buffer
  optval := SOCK_SEND_BUFFER_SIZE;
  WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_SNDBUF, buf, SizeOf(optval));
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

procedure TRtcSocket.Sock_SetTimeouts(const TOA:TRtcTimeoutsOfAPI);
  var
    optval: integer;
    buf: pointer;
  begin
  if FOSocket=INVALID_SOCKET then Exit;
  buf:=@optval;
{$IFDEF WINDOWS}
  {$IFDEF RTC_USESETTIMEOUTS}
  if assigned(TOA) then
    begin
    // Set RECV_TIMEO
    if TOA.ReceiveTimeout>0 then
      begin
      optval := TOA.ReceiveTimeout*1000;
      _SetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, buf, SizeOf(optval));
      end;
    // Set SND_TIMEO
    if TOA.SendTimeout>0 then
      begin
      optval := TOA.SendTimeout*1000;
      _SetSockOpt(FSocket, SOL_SOCKET, SO_SNDTIMEO, buf, SizeOf(optval));
      end;
    end;
  {$ELSE}
  // Set RECV_TIMEO
  optval := SOCK_RECV_TIMEOUT;
  _SetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, buf, SizeOf(optval));
  // Set SND_TIMEO
  optval := SOCK_SEND_TIMEOUT;
  _SetSockOpt(FSocket, SOL_SOCKET, SO_SNDTIMEO, buf, SizeOf(optval));
  {$ENDIF}
{$ELSE}{$IFDEF FPSOCK}
  {$IFDEF RTC_USESETTIMEOUTS}
  if assigned(TOA) then
    begin
    // Set RECV_TIMEO
    if TOA.ReceiveTimeout>0 then
      begin
      optval := TOA.ReceiveTimeout*1000;
      fpSetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, buf, SizeOf(optval));
      end;
    // Set SND_TIMEO
    if TOA.SendTimeout>0 then
      begin
      optval := TOA.SendTimeout*1000;
      fpSetSockOpt(FSocket, SOL_SOCKET, SO_SNDTIMEO, buf, SizeOf(optval));
      end;
    end;
  {$ELSE}
  // Set RECV_TIMEO
  optval := SOCK_RECV_TIMEOUT;
  fpSetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, buf, SizeOf(optval));
  // Set SND_TIMEO
  optval := SOCK_SEND_TIMEOUT;
  fpSetSockOpt(FSocket, SOL_SOCKET, SO_SNDTIMEO, buf, SizeOf(optval));
  {$ENDIF}
{$ELSE}{$IFDEF POSIX}
  {$IFDEF RTC_USESETTIMEOUTS}
  if assigned(TOA) then
    begin
    // Set RECV_TIMEO
    if TOA.ReceiveTimeout>0 then
      begin
      optval := TOA.ReceiveTimeout*1000;
      SetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, buf, SizeOf(optval));
      end;
    // Set SND_TIMEO
    if TOA.SendTimeout>0 then
      begin
      optval := TOA.SendTimeout*1000;
      SetSockOpt(FSocket, SOL_SOCKET, SO_SNDTIMEO, buf, SizeOf(optval));
      end;
    end;
  {$ELSE}
  // Set RECV_TIMEO
  optval := SOCK_RECV_TIMEOUT;
  WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, buf, SizeOf(optval));
  // Set SND_TIMEO
  optval := SOCK_SEND_TIMEOUT;
  WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_SNDTIMEO, buf, SizeOf(optval));
  {$ENDIF}
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  {$IFDEF RTC_USESETTIMEOUTS}
  if assigned(TOA) then
    begin
    // Set RECV_TIMEO
    if TOA.ReceiveTimeout>0 then
      begin
      optval := TOA.ReceiveTimeout*1000;
      WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, buf, SizeOf(optval));
      end;
    // Set SND_TIMEO
    if TOA.SendTimeout>0 then
      begin
      optval := TOA.SendTimeout*1000;
      WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_SNDTIMEO, buf, SizeOf(optval));
      end;
    end;
  {$ELSE}
  // Set RECV_TIMEO
  optval := SOCK_RECV_TIMEOUT;
  WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_RCVTIMEO, buf, SizeOf(optval));
  // Set SND_TIMEO
  optval := SOCK_SEND_TIMEOUT;
  WSA_SetSockOpt(FSocket, SOL_SOCKET, SO_SNDTIMEO, buf, SizeOf(optval));
  {$ENDIF}
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

function TRtcSocket.Sock_GetLocalSinIP: RtcString;
  begin
{$IFDEF WINDOWS}
  Result := WSocket_GetSinIP(FLocalSin);
{$ELSE}{$IFDEF FPSOCK}
  Result := WSA_GetSinIP(FLocalSin);
{$ELSE}{$IFDEF POSIX}
  Result := WSA_GetSinIP(FLocalSin);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  Result := WSA_GetSinIP(FLocalSin);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

function TRtcSocket.Sock_GetLocalSinPort: RtcString;
  begin
{$IFDEF WINDOWS}
  Result := Int2Str(WSocket_GetSinPort(FLocalSin));
{$ELSE}{$IFDEF FPSOCK}
  Result := Int2Str(WSA_GetSinPort(FLocalSin));
{$ELSE}{$IFDEF POSIX}
  Result := Int2Str(WSA_GetSinPort(FLocalSin));
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  Result := Int2Str(WSA_GetSinPort(FLocalSin));
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

function TRtcSocket.Sock_GetConnInfo: String;
  begin
{$IFDEF WINDOWS}
  case FSin.sin_family of
    AF_INET:Result:='v4';
    AF_INET6:Result:='v6';
    else Result:='v#'+IntToStr(FSin.sin_family)+'?';
    end;
  Result := '['+String(WSocket_GetSinIP(FSin))+'@'+IntToStr(WSocket_GetSinPort(FSin))+']'+Result;
{$ELSE}{$IFDEF FPSOCK}
  case FSin.sin_family of
    AF_INET:Result:='v4';
    AF_INET6:Result:='v6';
    else Result:='v#'+IntToStr(FSin.sin_family)+'?';
    end;
  Result := '['+String(WSA_GetSinIP(FSin))+'@'+IntToStr(WSA_GetSinPort(FSin))+']'+Result;
{$ELSE}{$IFDEF POSIX}
  case FSin.sa_family of
    AF_INET:Result:='v4';
    AF_INET6:Result:='v6';
    else Result:='v#'+IntToStr(FSin.sa_family)+'?';
    end;
  Result := '['+String(WSA_GetSinIP(FSin))+'@'+IntToStr(WSA_GetSinPort(FSin))+']'+Result;
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  case FSin.sin_family of
    AF_INET:Result:='v4';
    AF_INET6:Result:='v6';
    else Result:='v#'+IntToStr(FSin.sin_family)+'?';
    end;
  Result := '['+String(WSA_GetSinIP(FSin))+'@'+IntToStr(WSA_GetSinPort(FSin))+']'+Result;
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

function TRtcSocket.Sock_GetRemoteSinIP: RtcString;
  begin
{$IFDEF WINDOWS}
  Result := WSocket_GetSinIP(FRemoteSin);
{$ELSE}{$IFDEF FPSOCK}
  Result := WSA_GetSinIP(FRemoteSin);
{$ELSE}{$IFDEF POSIX}
  Result := WSA_GetSinIP(FRemoteSin);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  Result := WSA_GetSinIP(FRemoteSin);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

function TRtcSocket.Sock_GetRemoteSinPort: RtcString;
  begin
{$IFDEF WINDOWS}
  Result := Int2Str(WSocket_GetSinPort(FRemoteSin));
{$ELSE}{$IFDEF FPSOCK}
  Result := Int2Str(WSA_GetSinPort(FRemoteSin));
{$ELSE}{$IFDEF POSIX}
  Result := Int2Str(WSA_GetSinPort(FRemoteSin));
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  Result := Int2Str(WSA_GetSinPort(FRemoteSin));
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

procedure TRtcSocket.Sock_Listen(const vAddr, vPort: RtcString; const TOA:TRtcTimeoutsOfAPI; PreferIP4, PreferIPDef:boolean);
  var
    Sin: TSockAddr;
  {$IFDEF POSIX}
    vSin: TAPISockAddr absolute Sin;
    LocSin: TSockAddr;
    vLocSin: TAPISockAddr absolute LocSin;
  {$ENDIF}
    blog:integer;
  begin
  Sock_SetSin(Sin,vAddr,vPort,PreferIP4,PreferIPDef);
  if FErrCode<>0 then Exit;
  if FOSocket = INVALID_SOCKET then
    begin
    Sock_CreateSocket(Sin);
    if FErrCode<>0 then Exit;
    end;
  Sock_SetDelay;
  Sock_SetTimeouts(TOA);
  Sock_SetLinger(False,0);

  // BIND socket ...

{$IFDEF WINDOWS}
  if Sock_Err(_Bind(FSocket, Sin, SizeOfSockAddr(Sin))) then Exit;
  FLocalSinLen:=SizeOf(FLocalSin);
  Sock_Err(_GetSockName(FSocket, FLocalSin, FLocalSinLen));
{$ELSE}{$IFDEF FPSOCK}
  if Sock_Err(fpBind(FSocket, @Sin, SizeOfVarSin(Sin))) then Exit;
  Sock_Err(WSA_GetSockName(FSocket, FLocalSin, PreferIP4));
{$ELSE}{$IFDEF POSIX}
  {$IFDEF MACOS}
    if Sock_Err(Bind(FSocket, vSin, sin.sa_len)) then Exit;
  {$ELSE}
    if sin.sa_family=AF_INET6 then
      begin
      if Sock_Err(Bind(FSocket, vSin, SizeOf(SockAddr_In6))) then Exit;
      end
    else
      begin
      if Sock_Err(Bind(FSocket, vSin, SizeOf(SockAddr_In))) then Exit;
      end;
  {$ENDIF}
  FLocalSinLen:=SizeOf(FLocalSin);
  Sock_Err(GetSockName(FSocket, vLocSin, FLocalSinLen));
  FLocalSin:=LocSin;
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  if Sock_Err(WSA_Bind(FSocket, Sin)) then Exit;
  Sock_Err(WSA_GetSockName(FSocket, FLocalSin, PreferIP4));
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}

  // Start socket Listener ...

  blog:=LISTEN_BACKLOG;
  if blog>SOMAXCONN then blog:=SOMAXCONN;
{$IFDEF WINDOWS}
  if Sock_Err(_Listen(FSocket, blog)) then Exit;
  FLocalSinLen:=SizeOf(FLocalSin);
  if Sock_Err(_GetSockName(FSocket, FLocalSin, FLocalSinLen)) then Exit;
{$ELSE}{$IFDEF FPSOCK}
  if Sock_Err(fpListen(FSocket, blog)) then Exit;
  if Sock_Err(WSA_GetSockName(FSocket, FLocalSin, PreferIP4)) then Exit;
{$ELSE}{$IFDEF POSIX}
  if Sock_Err(Posix.SysSocket.Listen(FSocket, blog)) then Exit;

  FLocalSinLen:=SizeOf(FLocalSin);
  if Sock_Err(GetSockName(FSocket, vLocSin, FLocalSinLen)) then Exit;
  FLocalSin:=LocSin;
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  if Sock_Err(WSA_Listen(FSocket, blog)) then Exit;
  if Sock_Err(WSA_GetSockName(FSocket, FLocalSin, PreferIP4)) then Exit;
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

procedure TRtcSocket.Sock_Connect(const vAddr, vPort: RtcString; const TOA:TRtcTimeoutsOfAPI; PreferIP4, PreferIPDef:boolean);
  var
    Sin: TSockAddr;
  {$IFDEF POSIX}
    vSin: TAPISockAddr absolute Sin;
    LocSin, RemSin: TSockAddr;
    vLocSin: TAPISockAddr absolute LocSin;
    vRemSin: TAPISockAddr absolute RemSin;
  {$ENDIF}
  begin
  Sock_SetSin(Sin, vAddr, vPort, PreferIP4, PreferIPDef);
  if FErrCode<>0 then Exit;
  if FOSocket = INVALID_SOCKET then
    begin
    Sock_CreateSocket(Sin);
    if FErrCode<>0 then Exit;
    end;
  Sock_SetDelay;
  Sock_SetTimeouts(TOA);
  Sock_SetLinger(False,0);

{$IFDEF WINDOWS}
  if Sock_Err(_Connect(FSocket, Sin, SizeOfSockAddr(Sin))) then Exit;
  FLocalSinLen:=SizeOf(FLocalSin);
  if Sock_Err(_GetSockName(FSocket, FLocalSin, FLocalSinLen)) then Exit;
  FRemoteSinLen:=SizeOf(FRemoteSin);
  if Sock_Err(_GetPeerName(FSocket, FRemoteSin, FRemoteSinLen)) then Exit;
{$ELSE}{$IFDEF FPSOCK}
  if Sock_Err(fpConnect(FSocket, @Sin, SizeOfVarSin(Sin))) then Exit;
  if Sock_Err(WSA_GetSockName(FSocket, FLocalSin, PreferIP4)) then Exit;
  if Sock_Err(WSA_GetPeerName(FSocket, FRemoteSin, PreferIP4)) then Exit;
{$ELSE}{$IFDEF POSIX}
  {$IFDEF MACOS}
    if Sock_Err(Posix.SysSocket.Connect(FSocket, vSin, sin.sa_len)) then Exit;
  {$ELSE}
    if sin.sa_family=AF_INET6 then
      begin
      if Sock_Err(Posix.SysSocket.Connect(FSocket, vSin, SizeOf(SockAddr_In6))) then Exit;
      end
    else
      begin
      if Sock_Err(Posix.SysSocket.Connect(FSocket, vSin, SizeOf(SockAddr_In))) then Exit;
      end;
  {$ENDIF}
  FLocalSinLen:=SizeOf(FLocalSin);
  if Sock_Err(GetSockName(FSocket, vLocSin, FLocalSinLen)) then Exit;
  FLocalSin:=LocSin;

  FRemoteSinLen:=SizeOf(FRemoteSin);
  if Sock_Err(GetPeerName(FSocket, vRemSin, FRemoteSinLen)) then Exit;
  FRemoteSin:=RemSin;
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  if Sock_Err(WSA_Connect(FSocket, Sin)) then Exit;
  if Sock_Err(WSA_GetSockName(FSocket, FLocalSin, PreferIP4)) then Exit;
  if Sock_Err(WSA_GetPeerName(FSocket, FRemoteSin, PreferIP4)) then Exit;
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

function TRtcSocket.Sock_Accept: TSocket;
{$IFDEF POSIX}
  var
    RemSin:TSockAddr;
    vRemSin:TAPISockAddr absolute RemSin;
{$ENDIF}
  begin
  if FOSocket=INVALID_SOCKET then
    begin
    Result:=INVALID_SOCKET;
    FErrCode:=-1;
    FErr:='Socket not listening';
    Exit;
    end;
{$IFDEF WINDOWS}
  FRemoteSinLen:=SizeOf(FRemoteSin);
  Result := _Accept(FSocket, FRemoteSin, FRemoteSinLen);
{$ELSE}{$IFDEF FPSOCK}
  Result := WSA_Accept(FSocket, FRemoteSin);
{$ELSE}{$IFDEF POSIX}
  FRemoteSinLen:=SizeOf(FRemoteSin);
  Result := Accept(FSocket, vRemSin, FRemoteSinLen);
  FRemoteSin:=RemSin;
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  Result := WSA_Accept(FSocket, FRemoteSin);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  if Result=INVALID_SOCKET then
    begin
    Sock_CheckLastError;
    if FErrCode=0 then
      begin
      FErrCode:=-1;
      FErr:='No socket waiting';
      end;
    end;
  end;

procedure TRtcSocket.Sock_SetSocket(sid: TSocket; PreferIP4:boolean);
{$IFDEF POSIX}
  var
    LocSin,RemSin:TSockAddr;
    vLocSin:TAPISockAddr absolute LocSin;
    vRemSin:TAPISockAddr absolute RemSin;
{$ENDIF}
  begin
  FOSocket := sid;
  FSocket := sid;
{$IFDEF WINDOWS}
  FD_ZERO(FFDSet);
  FD_SET(FSocket, FFDSet);
  FLocalSinLen:=SizeOf(FLocalSin);
  if Sock_Err(_GetSockName(FSocket, FLocalSin, FLocalSinLen)) then Exit;
  FRemoteSinLen:=SizeOf(FRemoteSin);
  if Sock_Err(_GetPeerName(FSocket, FRemoteSin, FRemoteSinLen)) then Exit;
{$ELSE}{$IFDEF FPSOCK}
  fpFD_ZERO(FFDSet);
  fpFD_SET(FSocket, FFDSet);
  if Sock_Err(WSA_GetSockName(FSocket, FLocalSin, PreferIP4)) then Exit;
  if Sock_Err(WSA_GetPeerName(FSocket, FRemoteSin, PreferIP4)) then Exit;
{$ELSE}{$IFDEF POSIX}
  __FD_ZERO(FFDSet);
  __FD_SET(FSocket, FFDSet);

  FLocalSinLen:=SizeOf(FLocalSin);
  if Sock_Err(GetSockName(FSocket, vLocSin, FLocalSinLen)) then Exit;
  FLocalSin:=LocSin;

  FRemoteSinLen:=SizeOf(FRemoteSin);
  if Sock_Err(GetPeerName(FSocket, vRemSin, FRemoteSinLen)) then Exit;
  FRemoteSin:=RemSin;
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  FD_ZERO(FFDSet);
  FD_SET(FSocket, FFDSet);
  if Sock_Err(WSA_GetSockName(FSocket, FLocalSin, PreferIP4)) then Exit;
  if Sock_Err(WSA_GetPeerName(FSocket, FRemoteSin, PreferIP4)) then Exit;
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  Sock_SetLinger(False,0);
  end;

function TRtcSocket.Sock_Shutdown:boolean;
  begin
  if FOSocket=INVALID_SOCKET then
    Result:=False
  else
    begin
{$IFDEF WINDOWS}
    _Shutdown(FOSocket,SD_BOTH);
{$ELSE}{$IFDEF FPSOCK}
    fpShutdown(FOSocket,SHUT_RDWR);
{$ELSE} {$IFDEF POSIX}
    Shutdown(FOSocket,SHUT_RDWR);
{$ELSE} {$IFDEF RTC_NIX_SOCK}
    WSA_Shutdown(FOSocket,SHUT_RDWR);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
    Result:=True;
    end;
  end;

function TRtcSocket.Sock_Close:boolean;
  begin
  if Sock_Shutdown then
    begin
{$IFDEF WINDOWS}
    _CloseSocket(FOSocket);
{$ELSE}{$IFDEF FPSOCK}
    fpClose(FOSocket);
{$ELSE} {$IFDEF POSIX}
    __close(FOSocket);
{$ELSE} {$IFDEF RTC_NIX_SOCK}
    WSA_CloseSocket(FOSocket);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
    FOSocket := INVALID_SOCKET;
    Result:=True;
    end
  else
    Result:=False;
  end;

function TRtcSocket.Sock_CanRead(vTimeout: integer): boolean;
  var
    TimeP: PTimeVal;
    TimeV: TTimeVal;
    x: Integer;
    FDSet: TFDSet;
  begin
  if FOSocket=INVALID_SOCKET then
    begin
    FErrCode := -1;
    FErr := 'Socket closed';
    Result:=False;
    Exit;
    end;
  if vTimeout = -1 then
    TimeP := nil
  else
    begin
    TimeV.tv_usec := (vTimeout mod 1000) * 1000;
    TimeV.tv_sec := vTimeout div 1000;
    TimeP := @TimeV;
    end;
  FDSet := FFdSet;
{$IFDEF WINDOWS}
  x := _Select(FSocket + 1, @FDSet, nil, nil, TimeP);
{$ELSE}{$IFDEF FPSOCK}
  x := fpSelect(FSocket + 1, @FDSet, nil, nil, TimeP);
{$ELSE}{$IFDEF POSIX}
  x := Select(FSocket + 1, @FDSet, nil, nil, TimeP);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  x := WSA_Select(FSocket + 1, @FDSet, nil, nil, TimeP);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  if x>0 then
    Result:=True
  else
    begin
    Sock_Err(x);
    Result:=False;
    end;
  end;

function TRtcSocket.Sock_CanWrite(vTimeout: integer): boolean;
  var
    TimeP: PTimeVal;
    TimeV: TTimeVal;
    x: Integer;
    FDSet: TFDSet;
  begin
  if FOSocket=INVALID_SOCKET then
    begin
    FErrCode := -1;
    FErr := 'Socket closed';
    Result:=False;
    Exit;
    end;
  if vTimeout = -1 then
    TimeP := nil
  else
    begin
    TimeV.tv_usec := (vTimeout mod 1000) * 1000;
    TimeV.tv_sec := vTimeout div 1000;
    TimeP := @TimeV;
    end;
  FDSet := FFdSet;
{$IFDEF WINDOWS}
  x := _Select(FSocket + 1, nil, @FDSet, nil, TimeP);
{$ELSE}{$IFDEF FPSOCK}
  x := fpSelect(FSocket + 1, nil, @FDSet, nil, TimeP);
{$ELSE}{$IFDEF POSIX}
  x := Select(FSocket + 1, nil, @FDSet, nil, TimeP);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  x := WSA_Select(FSocket + 1, nil, @FDSet, nil, TimeP);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  if x>0 then
    Result:=True
  else
    begin
    Sock_Err(x);
    Result:=False;
    end;
  end;

function TRtcSocket.Sock_WaitingData: integer;
  var
    x: Integer;
  begin
  if FOSocket=INVALID_SOCKET then
    begin
    FErrCode := -1;
    FErr := 'Socket closed';
    Result:=-1;
    Exit;
    end;
  Result := 0;
{$IFDEF WINDOWS}
  if not Sock_Err(_IoctlSocket(FSocket, FIONREAD, x)) then
    Result := x;
{$ELSE}{$IFDEF FPSOCK}
  if not Sock_Err(fpIoctl(FSocket, FIONREAD, @x)) then
    Result := x;
{$ELSE}{$IFDEF POSIX}
  if Sock_CanRead(1) then
    begin
    x := Recv(FSocket, FTempBuffer[0], length(FTempBuffer), MSG_PEEK);
    if x>0 then
      Result:=x
    else if x=0 then
      begin
      Result:=-1;
      FErrCode := WSAECONNRESET;
      Sock_CheckLastErrorDesc;
      end
    else
      begin
      Result:=-1;
      Sock_CheckLastError;
      end;
    end;
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  {$IFDEF DARWIN}
    if Sock_CanRead(1) then
      begin
      x := WSA_Recv(FSocket, FTempBuffer[0], length(FTempBuffer), MSG_PEEK);
      if x>0 then
        Result:=x
      else if x=0 then
        begin
        Result:=-1;
        FErrCode := WSAECONNRESET;
        Sock_CheckLastErrorDesc;
        end
      else
        begin
        Result:=-1;
        Sock_CheckLastError;
        end;
      end;
  {$ELSE}
    if not Sock_Err(WSA_IoctlSocket(FSocket, FIONREAD, x)) then
      Result := x;
  {$ENDIF}
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

function TRtcSocket.Sock_RecvBuffer(var Buffer; Len: Integer): Integer;
  begin
  if FOSocket=INVALID_SOCKET then
    begin
    FErrCode := -1;
    FErr := 'Socket closed';
    Result := -1;
    Exit;
    end;
{$IFDEF WINDOWS}
  Result := _Recv(FSocket, Buffer, Len, 0);
{$ELSE}{$IFDEF FPSOCK}
  Result := fpRecv(FSocket, @Buffer, Len, MSG_NOSIGNAL);
{$ELSE} {$IFDEF POSIX}
  Result := Recv(FSocket, Buffer, Len, 0); // MSG_WAITALL);
{$ELSE} {$IFDEF RTC_NIX_SOCK}
  Result := WSA_Recv(FSocket, Buffer, Len, MSG_NOSIGNAL);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  if Result<=0 then
    if Result<0 then
      Sock_CheckLastError
    else
      begin
      Result:=-1;
      FErrCode := WSAECONNRESET;
      Sock_CheckLastErrorDesc;
      end;
  end;

function TRtcSocket.Sock_SendBuffer(var Buffer; Len: Integer): Integer;
  begin
  if FOSocket=INVALID_SOCKET then
    begin
    FErrCode := -1;
    FErr := 'Socket closed';
    Result:=-1;
    Exit;
    end;
  if Len>SOCK_MAX_SEND_SIZE then
    Len:=SOCK_MAX_SEND_SIZE;
{$IFDEF WINDOWS}
  Result := _Send(FSocket, Buffer, Len, 0);
{$ELSE}{$IFDEF FPSOCK}
  Result := fpSend(FSocket, @Buffer, Len, MSG_NOSIGNAL);
{$ELSE}{$IFDEF POSIX}
  Result := Send(FSocket, Buffer, Len, 0);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  Result := WSA_Send(FSocket, Buffer, Len, MSG_NOSIGNAL);
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  if Result<=0 then
    if Result<0 then
      Sock_CheckLastError
    else
      begin
      Result:=-1;
      FErrCode := WSAECONNRESET;
      Sock_CheckLastErrorDesc;
      end;
  end;

procedure TRtcSocket.Sock_ResetError;
  begin
{$IFDEF WINDOWS}
  FErrCode:=0; FErr:='';
{$ELSE}{$IFDEF FPSOCK}
  FErrCode:=0; FErr:='';
{$ELSE}{$IFDEF POSIX}
  FErrCode:=0; SetLength(FErr,0);
{$ELSE}{$IFDEF RTC_NIX_SOCK}
  FErrCode:=0; FErr:='';
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}
  end;

end.
