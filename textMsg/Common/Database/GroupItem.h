//
//  GroupItem.h
//  textMsg
//
//  Created by Jacky on 9/4/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GroupItem : NSManagedObject

@property (nonatomic, retain) NSString * groupUUID;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * groupStatus;
@property (nonatomic, retain) NSString * blockTime;

@end
