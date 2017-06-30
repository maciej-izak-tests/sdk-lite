{
  "Server Socket Connection Provider wrapper"
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)

  @exclude
}
unit rtcSockBaseSrvProv;

{$INCLUDE rtcDefs.inc}

interface

uses
  SysUtils,

  rtcTypes,
  rtcLog,
  rtcFastStrings,
  rtcSyncObjs,

  rtcPlugins,
  rtcThrConnProv, // Threaded connection provider wrapper

  rtcConn,
  rtcConnProv; // Basic connection provider wrapper

const
  LOG_REFUSED_CONNECTIONS:boolean={$IFDEF RTC_DEBUG}True{$ELSE}False{$ENDIF};

type
  TRtcBaseSockServerProvider = class(TRtcThrServerProvider)
  private
    FCryptPlugin: TRtcCryptPlugin;
    FTimeoutsOfAPI: TRtcTimeoutsOfAPI;

  protected
    FCryptObject:TObject;

    procedure CleanUp; override;

    procedure CopyFrom(Dup:TRtcConnectionProvider); virtual;

  public
    constructor Create; override;

    property CryptPlugin        : TRtcCryptPlugin   read FCryptPlugin
                                                    write FCryptPlugin;
    property TimeoutsOfAPI:TRtcTimeoutsOfAPI read FTimeoutsOfAPI write FTimeoutsOfAPI;

    property CryptObject:TObject read FCryptObject;
    end;

implementation

{ TRtcBaseSockServerProvider }

constructor TRtcBaseSockServerProvider.Create;
  begin
  inherited;

  FCryptObject:=nil;

  FPeerPort:='';
  FPeerAddr:='';
  FLocalPort:='';
  FLocalAddr:='';
  end;

procedure TRtcBaseSockServerProvider.CleanUp;
  begin
  try
    try
      FPeerPort:='';
      FPeerAddr:='';
      FLocalPort:='';
      FLocalAddr:='';
    finally
      inherited;
      end;
  except
    on E:Exception do
      begin
      if LOG_AV_ERRORS then
        Log('TRtcBaseSockServerProvider.CleanUp',E,'ERROR');
      raise;
      end;
    end;
  end;

procedure TRtcBaseSockServerProvider.CopyFrom(Dup: TRtcConnectionProvider);
  begin
  FCryptPlugin:=TRtcBaseSockServerProvider(Dup).CryptPlugin;
  end;

end.
