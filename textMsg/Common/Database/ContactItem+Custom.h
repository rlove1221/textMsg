//
//  Channel+Custom.h
//  ChannelBuster
//
//  Created by Jacky Nguyen on 4/9/13.
//  Copyright (c) 2013 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactItem.h"
@interface ContactItem(Custom)
+ (NSArray *)getAllCGItems;

+ (NSArray *)getAllCGItemByGroupUUID:(NSString *)groupUUID;
+ (ContactItem *)getCGItemByName:(NSString *)name;
+ (ContactItem *)getCGItemById:(NSInteger )recordId groupUUID:(NSString *)groupUUID;

+ (ContactItem *)newCGItem;

+ (BOOL)updateCGItem:(ContactItem *)itemObj;

+ (BOOL)deleteCGItem:(ContactItem *)itemObj;

+ (ContactItem *)checkCGItemByName:(NSString *)name groupUUID:(NSString *)groupUUID;
@end
