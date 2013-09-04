//
//  define.h
//  EYoLo
//
//  Created by Jacky Nguyen on 3/13/13.
//  Copyright (c) 2013 teamios. All rights reserved.
//
#import "Util.h"
#import "NetworkActivityIndicator.h"

#define kServer_Post_UserInfo @"http://www.cgapp.net.au/apis/account_info"
#define kServer_Post_AddAccount @"http://www.cgapp.net.au/apis/new_account"
#define kServer_Post_DeviceInfo @"http://www.cgapp.net.au/apis/push_info"
#define kServer_Get_Policy @"http://www.cgapp.net.au/privacy-policy.pdf"
#define kServer_Get_List @"http://www.cgapp.net.au/apis/getlist?type="
#define kServer_Get_CheckAccount @"http://www.cgapp.net.au/apis/account_exist?email="
#define kServer_Get_CheckLogin @"http://www.cgapp.net.au/apis/check_login?email=%@&password=%@"
//#define kServer_Get_DealList @"http://server.teamios.info/apis/deallist"
#define kServer_ImageURL @"http://www.cgapp.net.au/img/"

#define mainAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define IMAGESPATH [NSHomeDirectory() stringByAppendingString:@"/Documents/"]

#define HOMEDIRECTORY [[NSBundle mainBundle] resourcePath]

#define DOCUMENTDIRECTORY [NSHomeDirectory() stringByAppendingString:@"/Documents/"]

#define LIBRARY_CATCHES_DIRECTORY [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/"]

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define PORTRAIT_KEYBOARD_HEIGHT 216
#define LANDSCAPE_KEYBOARD_HEIGHT  162
#else
#define IS_IPAD() (false)
#define PORTRAIT_KEYBOARD_HEIGHT 216
#define LANDSCAPE_KEYBOARD_HEIGHT  162
#endif
#define kUserInfo @"UserInfo"
#define kUserInfoRegist @"UserInfoRegist"
#define kDeviceInfo @"DeviceInfo"
#define kFirstLaunch @"FirstLaunch"
#define kPrivacyStatmentAccepted @"PrivacyStatementAccepted"
#define kRegistUser @"kRegistUser"
#define kDeviceId @"DeviceId"
#define kDeviceToken @"devicetoken"
#define kDeviceType @"devidetype"
#define kPostToken @"PostToken"

#define kUser_Id @"id"
#define kUser_DeviceID @"device_id"
#define kUser_Name @"name"
#define kUser_Email @"email"
#define kUser_Age @"age"
#define kUser_Sex @"sex"
#define kUser_Password @"password"
#define kUser_Postcode @"postcode"


