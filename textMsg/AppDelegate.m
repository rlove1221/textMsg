//
//  AppDelegate.m
//  textMsg
//
//  Created by Richard Morena on 8/31/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import "AppDelegate.h"
#import "iRate.h"
#import "define.h"
#import "iRate.h"
#import "ServiceManager.h"
@implementation AppDelegate
@synthesize speedDict;


+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 6;
  //  [iRate sharedInstance].applicationBundleID = @"com.richard.grouplock";
	[iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable preview mode
  //  [iRate sharedInstance].previewMode = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    speedDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [speedDict setObject:[NSNumber numberWithBool:NO] forKey:@"moving"];
    [speedDict setObject:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"updatedate"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application

{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [locationManager startUpdatingLocation];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    if(newLocation.speed > 20)
    {
        NSTimeInterval update = [[speedDict objectForKey:@"updatedate"] integerValue];
        
        if ([[speedDict objectForKey:@"moving"] boolValue] == NO) {
            [speedDict setObject:[NSNumber numberWithBool:YES] forKey:@"moving"];
            [speedDict setObject:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"updatedate"];
        }
        else
        {
            if (([[NSDate date] timeIntervalSince1970] - update)>=1000*60*3) {
                self.isMoving = YES;
                NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kUser_Info];
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kUser_Info]) {
                    [ServiceManager updateStatusForUserId:[userInfo objectForKey:@"user_id" ] status:@"2"];
                }
            }
        }
    }
    else
    {
        NSTimeInterval update = [[speedDict objectForKey:@"updatedate"] integerValue];
        
        if ([[speedDict objectForKey:@"moving"] boolValue] == YES) {
            [speedDict setObject:[NSNumber numberWithBool:NO] forKey:@"moving"];
            [speedDict setObject:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"updatedate"];
        }
        else
        {
            if (([[NSDate date] timeIntervalSince1970] - update)>=1000*60*3) {
                self.isMoving = NO;
                NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kUser_Info];
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kUser_Info]) {
                    [ServiceManager updateStatusForUserId:[userInfo objectForKey:@"user_id" ] status:@"1"];
                }
            }
        }

    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // User location has been found/updated, load map data now.
    NSDate* time = newLocation.timestamp;
    NSTimeInterval timePeriod = [time timeIntervalSinceNow];
    if(timePeriod < 2.0 ) { //usually it take less than 0.5 sec to get a new location but you can use any value greater than 0.5 but i recommend 1.0 or 2.0
        
        if (newLocation.coordinate.latitude != 0 && newLocation.coordinate.longitude != 0) {
            [manager stopUpdatingLocation];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MapChange"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        // process the location
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *tokenStr = [deviceToken description];
    NSString *hexStr = [[[tokenStr
                          stringByReplacingOccurrencesOfString:@"<" withString:@""]
                         stringByReplacingOccurrencesOfString:@">" withString:@""]
                        stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    [userDefault setObject:hexStr forKey:kDeviceToken];
    [userDefault synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *message = nil;
    id alert = [userInfo objectForKey:@"alert"];
    if ([alert isKindOfClass:[NSString class]]) {
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        message = [alert objectForKey:@"body"];
    }
    if (alert) {
        [Util showAlertWithString:message];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"didReceiveNotification" object:nil];
    }
    
}

@end
