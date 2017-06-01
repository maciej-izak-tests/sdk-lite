{
  @html(<b>)
  RealThinClient SDK *LITE* Component Registration
  @html(</b>)
  - Copyright 2004-2017 (c) RealThinClient.com (http://www.realthinclient.com)
  @html(<br><br>)

  RealThinClient SDK *LITE* components are being
  registered to Delphi component palette.
  
  @exclude
}
unit rtcRegisterLite;

{$INCLUDE rtcDefs.inc}

interface

// This procedure is being called by Delphi to register the components.
procedure Register;

implementation

uses
  Classes,

  rtcTypes,

  rtcDataCli, rtcDataSrv,
  rtcHttpSrv, rtcHttpCli,

  rtcCliModule, rtcSrvModule, rtcFunction,

  rtcLink, rtcThrPool;

procedure Register;
  begin
  RegisterComponents('RTC Server',[TRtcHttpServer,
                                   TRtcDataServerLink, TRtcDualDataServerLink,
                                   TRtcDataProvider,
                                   TRtcServerModule,
                                   TRtcFunctionGroup, TRtcFunction,
                                   TRtcQuickJob]);

  RegisterComponents('RTC Client',[TRtcHttpClient,
                                   TRtcDataClientLink, TRtcDualDataClientLink,
                                   TRtcDataRequest,
                                   TRtcClientModule,
                                   TRtcResult]);
  end;

end.