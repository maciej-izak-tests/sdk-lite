RealThinClient SDK *LITE*

http://www.realthinclient.com

Copyright 2004-2017 (c) RealThinClient.com

All rights reserved.

--------------------------------
********************************

1.) Install RTC SDK *LITE* components in Delphi

2.) Update RTC SDK *LITE* components in Delphi

3.) *LITE* version LIMITATIONS

********************************
--------------------------------

--------------------------------
1.) INSTALL RTC SDK *LITE* components in Delphi
--------------------------------

After you have unpacked the files in a folder of your choice and started Delphi,
you should add the path to the RTC SDK's "Lib" folder to "Library paths" in Delphi.

In older Delphi versions, the Library Path is located in the "Tools / Environment Options" menu.
Select the "Library" tab and add the full path to the RTC SDK's "Lib" folder to "Library path".

In newer Delphi versions, Library Paths are located in the "Tools / Options" menu. 
Select the "Environment Options / Delphi Options / Library" tree branch, where you will 
find the "Library Path" field. There, you should click the "..." button next to 
the "Library path" and add the path to the RTC SDK's "Lib" folder.

In Delphi XE2 and later, you will also see a "Selected Platform" drop-down menu. 
There, all the settings are separated by platforms, so you  will need to 
repeat the process for every platform you want to use the "RTC SDK" with.

Once you have configured the "Library path" (so the IDE can find RTC SDK files), open the
"SDKPackages_Lite" Project Group, containing 1 runtime and 1 design-time package:
 
  rtcSDK.dpk       -> The main runtime Package, contains all Client and Server components. 
  rtcSDKD.dpk      -> The main design-time Package, registers all Client and Server components.

Install the components in Delphi by using the "Install" button, or the "Install" menu option.
In older Delphi versions, you will see the "Install" button in the Project Manager window.
In newer Delphi versions, you will find the "Install" option if you right-click the package
file in the Project Manager accessed in the "View" drop-down menu.

When compiled and installed, you will see a message listing all components installed.

NOTE: You should ONLY compile and install RTC packages for the Win32 platform, because the 
Delphi IDE is a Win32 Application. First compile and install runtime packages, then desig-time.

NOTE: When switching Projects or changing the active target platform on a Project, 
always use BUILD (not COMPILE) to "compile" your Project(s), because RTC uses 
compiler directives to build the same source code for different platforms.

-------------------------------
2.) UPDATE RTC SDK *LITE* components in Delphi
-------------------------------

To update RTC SDK components, before installing new RTC packages, it is 
adviseable to uninstall old RTC packages and delete the old BPL and DCP files:

  - rtcSDK.bpl & rtcSDK.dcp
  - rtcSDKD.bpl & rtcSDKD.dcp

To uninstall RTC SDK components, after you start Delphi, 
open the menu "Component / Install Packages ..." where you 
will see a list of all packages currently installed in your Delphi. 

Scroll down to find "RealThinClient SDK" and click on it (single click). 
When you select it, click the button "Remove" and Delphi will ask you 
if you want to remove this package. Clicking "Yes" will uninstall the RTC SDK.

After that, *close* Delphi and follow step (1) to install the new RTC SDK package.

NOTE: Uninstalling the RTC SDK package will also uninstall all packages which 
are using the RTC SDK (for example "rtcSDK_DBA" and "RTC Portal" packages). 
So ... if you are using "RTC Portal" or any other product using the RTC SDK, you will 
need to Build and Install all related packages again, after you reinstall the RTC SDK.

-------------------------------
3.) *LITE* version LIMITATIONS
-------------------------------


A) *LITE* RTC SDK version ONLY has blocking WinSock API support. *LITE* RTC SDK version
   does NOT have multi-platform support (required to target iOS, OSX and Android platforms), 
   support for WinInet and WinHTTP APIs (Firewall/Proxy and SSL support on Windows), Async
   WinSock API support (higher load capacity and reduced resource usage for Windows Servers), 
   ISAPI support (compile Server-side code into an ISAPI DLL), Message-based Client/Server 
   support, UDP and TCP Client/Server support.

B) *LITE* RTC SDK version ONLY has basic HTTP Client/Server and Remote Function components.
   *LITE* RTC SDK version does NOT include more advanced features and components (like SSL 
   and RSA Encryption, Scripting, Data Routing, Load Balancing, general-purpose Gateway and 
   Multi-Gate Clients, in-memory DataSets and DataSet monitoring).

C) *LITE* RTC SDK version does NOT include support.

If you find the RealThinClient SDK useful and would like to unlock all of its features,
or if you simply want to support its continued development, you can order a commercial
RealThinClient SDK license from http://www.realthinclient.com/priceorder/
