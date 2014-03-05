//
//  define.h
//  EYoLo
//
//  Created by Jacky Nguyen on 3/13/13.
//  Copyright (c) 2013 teamios. All rights reserved.
//
#import "Util.h"
#import "NetworkActivityIndicator.h"
#import "SVProgressHUD.h"

#define kServer_Post_RegistUser @"http://richiemorena.com/grouplock/apis.php?api=regist&content="
#define kServer_Post_Login @"http://richiemorena.com/grouplock/apis.php?api=login"
#define kServer_Post_Logout @"http://richiemorena.com/grouplock/apis.php?api=logout"
#define kServer_Post_UpdateStatus @"http://richiemorena.com/grouplock/apis.php?api=update_status"
#define kServer_Post_sendMessage @"http://richiemorena.com/grouplock/apis.php?api=send_message"
#define kServer_Post_Addfriend @"http://richiemorena.com/grouplock/apis.php?api=add_friend"
#define kServer_Post_Getfriend @"http://richiemorena.com/grouplock/apis.php?api=get_friends"
#define kServer_Post_GetMessages @"http://richiemorena.com/grouplock/apis.php?api=get_messages"
#define kServer_Post_sendMessage @"http://richiemorena.com/grouplock/apis.php?api=send_message"
#define kServer_Post_GetGroup @"http://richiemorena.com/grouplock/apis.php?api=get_groups"


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
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define kUser_Info @"UserInfo"
#define kFriends_Info @"kFriends_Info"
#define kGroups_Info @"kGroups_Info"
#define kDeviceToken @"kDeviceToken"
