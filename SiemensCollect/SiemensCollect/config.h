//
//  config.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 19.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#ifndef SiemensCollect_config_h
#define SiemensCollect_config_h

/******************************************************************
 *
 * WebDavCredentials
 *
 *****************************************************************/

#define scWebDAVURL                 @"http://10.0.0.1:8080/SierraWebdav/images/buildings"
#define scWebDAVURLPresent          @"https://1270773026.webdav.cloudsafe.com/images/buildings"



#define scWebDAVBaseURL             @"http://10.0.0.1:8080/SierraWebdav"
#define scWebDAVBaseURLPresent      @"https://1270773026.webdav.cloudsafe.com/"

#define scWebDAVUser                @"a.catalucci@gmail.com"
#define scWebDAVPassword            @"QH4JAO-EWIL2D-56PV5H-LJDVUC"

/******************************************************************
 *
 * Rasp Credentials
 *
 *****************************************************************/
//#define LOCALHOST
//#define scRaspPIWifiURL         @"http://localhost:8888/SierraCollect/rest/wifinetworks/"
//#define scRaspPIMeasURL         @"http://localhost:8888/SierraCollect/rest/measurements/"
//#define scRaspBaseURL           @"http://localhost:8888/"

//#define scRaspPIWifiURL         @"http://localhost/SierraCollect/rest/wifinetworks/"
//#define scRaspPIMeasURL         @"http://localhost/SierraCollect/rest/measurements/"
//#define scRaspBaseURL           @"http://localhost/"

#define scRaspPIWifiURL         @"http://10.0.0.1:8080/SierraCollect/rest/wifinetworks/"
#define scRaspPIMeasURL         @"http://10.0.0.1:8080/SierraCollect/rest/measurements/"
#define scRaspPIDHCPURL         @"http://10.0.0.1:8080/SierraCollect/rest/dhcpclients/"//woody
#define scRaspPIContinuousURL   @"http://10.0.0.1:8080/SierraCollect/rest/continuousMeasurements/"//woody
#define scRaspBaseURL           @"http://10.0.0.1:8080/"

#define scRaspWifiPattern       @"SierraCollect/rest/wifinetworks/"
#define scRaspMeasPattern       @"SierraCollect/rest/measurements/"
#define scRaspDHCPPattern       @"SierraCollect/rest/dhcpclients/"//woody
#define scRaspContinuousPattern @"SierraCollect/rest/continuousMeasurements/"//woody

#ifdef LOCALHOST
#define scRaspPIWifiURLDemo         @"http://localhost/SierraCollect/rest/wifinetworks/"
#define scRaspPIMeasURLDemo         @"http://localhost/SierraCollect/rest/measurements/"
#define scRaspPIDHCPURLDemo         @"http://localhost/SierraCollect/rest/dhcpclients/"//woody
#define scRaspPIContinuousURLDemo   @"http://localhost/SierraCollect/rest/continuousMeasurements/"//woody
#define scRaspBaseURLDemo           @"http://localhost/"
#define scRaspWifiPatternDemo       @"SierraCollect/rest/wifinetworks/"
#define scRaspMeasPatternDemo       @"SierraCollect/rest/measurements/"
#define scRaspDHCPPatternDemo       @"SierraCollect/rest/dhcpclients/"//woody
#define scRaspContinuousPatternDemo @"SierraCollect/rest/continuousMeasurements/"//woody
#else
#define scRaspPIWifiURLDemo         @"http://sierra.oischnak.de/rest/wifinetworks/"
#define scRaspPIMeasURLDemo         @"http://sierra.oischnak.de/rest/measurements/"
#define scRaspPIDHCPURLDemo         @"http://sierra.oischnak.de/rest/dhcpclients/"//woody
#define scRaspPIContinuousURLDemo   @"http://sierra.oischnak.de/rest/continuousMeasurements/"//woody
#define scRaspBaseURLDemo           @"http://sierra.oischnak.de/"
#define scRaspWifiPatternDemo       @"rest/wifinetworks/"
#define scRaspMeasPatternDemo       @"rest/measurements/"
#define scRaspDHCPPatternDemo       @"rest/dhcpclients/"//woody
#define scRaspContinuousPatternDemo @"rest/continuousMeasurements/"//woody
#endif

#define scRaspPIWifiURLPresent         @"http://present.de:8080/SierraCollect/rest/wifinetworks/"
#define scRaspPIMeasURLPresent         @"http://present.de:8080/SierraCollect/rest/measurements/"
#define scRaspPIDHCPURLPresent         @"http://present.de:8080/SierraCollect/rest/dhcpclients/"//woody
#define scRaspPIContinuousURLPresent   @"http://present.de:8080/SierraCollect/rest/continuousMeasurements/"//woody
#define scRaspBaseURLPresent           @"http://present.de:8080/"
#define scRaspWifiPatternPresent       @"SierraCollect/rest/wifinetworks/"
#define scRaspMeasPatternPresent       @"SierraCollect/rest/measurements/"
#define scRaspDHCPPatternPresent       @"SierraCollect/rest/dhcpclients/"//woody
#define scRaspContinuousPatternPresent @"SierraCollect/rest/continuousMeasurements/"//woody


/******************************************************************
 *
 * User Defaults Key
 *
 *****************************************************************/

#define scDemoMode              @"scDemoMode"

#endif
