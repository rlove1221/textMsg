//
//  Channel+Custom.h
//  ChannelBuster
//
//  Created by Jacky Nguyen on 4/9/13.
//  Copyright (c) 2013 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupItem.h"
@interface GroupItem(Custom)
+ (NSArray *)getAllGroupItems;

+ (GroupItem *)getGroupItemByName:(NSString *)name;
+ (NSArray *)getGroupByStatus:(NSString *)status;

+ (GroupItem *)newGroupItem;

+ (BOOL)updateGroupItem:(GroupItem *)itemObj;

+ (BOOL)deleteGroupItem:(GroupItem *)itemObj;
+ (NSArray *)getExpiredGroup;
@end
