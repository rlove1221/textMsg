//
//  AutoSyncHelper.m
//  EYoLo
//
//  Created by Jacky Nguyen on 3/17/13.
//  Copyright (c) 2013 teamios. All rights reserved.
//

#import "GlobalObject.h"
static GlobalObject *sharedInstance = nil;
@implementation GlobalObject
+ (GlobalObject *)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[GlobalObject alloc] init];
    }
    return sharedInstance;
}

@end
