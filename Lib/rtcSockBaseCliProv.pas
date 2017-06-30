{
  "Client Socket Connection Provider wrapper"
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)

  @exclude
}
unit rtcSockBaseCliProv;

{$INCLUDE rtcDefs.inc}

interface

uses
  SysUtils,

  rtcTypes,
  rtcSyncObjs,

  rtcLog,
  rtcConn,
  rtcConnProv, // Basic connection provider wrapper

  rtcPlugins,
  rtcThrConnProv; // Threaded connection provider wrapper

type
  TRtcBaseSockClientProvider = class(TRtcThrClientProvider)
  private
    FCryptPlugin: TRtcCryptPlugin;
    FTimeoutsOfAPI: TRtcTimeoutsOfAPI;

  protected
    FCryptObject:TObject;

    procedure CleanUp; override;

  public
    constructor Create; override;

    property CryptPlugin        : TRtcCryptPlugin   read FCryptPlugin
                                                    write FCryptPlugin;

    property TimeoutsOfAPI:TRtcTimeoutsOfAPI read FTimeoutsOfAPI write FTimeoutsOfAPI;

    property CryptObject:TObject read FCryptObject;
    end;

implementation

{ TRtcBaseSockClientProvider }

constructor TRtcBaseSockClientProvider.Create;
  begin
  inherited;

  FCryptObject:=nil;

  FPeerPort:='';
  FPeerAddr:='';
  FLocalPort:='';
  FLocalAddr:='';
  end;

procedure TRtcBaseSockClientProvider.CleanUp;
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
        Log('TRtcBaseSockClientProvider.CleanUp',E,'ERROR');
      raise;
      end;
    end;
  end;

end.
