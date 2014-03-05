//
//  AppDelegate.h
//  textMsg
//
//  Created by Richard Morena on 8/31/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableDictionary *speedDict;
@property (nonatomic) BOOL isMoving;
@end
