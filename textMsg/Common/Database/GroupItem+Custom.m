//
//  Channel+Custom.m
//  ChannelBuster
//
//  Created by Jacky Nguyen on 4/9/13.
//  Copyright (c) 2013 com. All rights reserved.
//

#import "GroupItem+Custom.h"
#import "NSManagedObjectContext+Custom.h"
#import "CoreDataHelper.h"
#import "Define.h"
#define kEntityName @"GroupItem"
@implementation GroupItem(Custom)
+ (GroupItem *)newGroupItem
{
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        GroupItem * cgItem = [NSEntityDescription insertNewObjectForEntityForName:kEntityName
                                                            inManagedObjectContext:managedObjectContext];
        return cgItem;
    }
    @catch (NSException *exception)
    {
        
    }
    return nil;
}

+ (NSArray *)getAllGroupItems
{
    NSArray *lists;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        lists = [CoreDataHelper getObjectsFromcontext:managedObjectContext
                                           entityName:kEntityName
                                              sortKey:nil
                                        sortAscending:NO];
    }
    @catch (NSException *exception)
    {
        NSLog(@"__ERROR__%@__", exception.reason);
    }
    
    return lists;
}

+ (NSArray *)getExpiredGroup
{
    NSArray *lists;
    NSMutableArray *resultList = [[NSMutableArray alloc] initWithCapacity:0];
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        NSTimeInterval timeinterval = [[NSDate date] timeIntervalSince1970];
        lists = [CoreDataHelper getObjectsFromcontext:managedObjectContext
                                           entityName:kEntityName
                                              sortKey:nil
                                        sortAscending:NO];
        for (GroupItem *groupItem in lists) {
            if ([groupItem.blockTime floatValue] == 0) {
                continue;
            }
            NSTimeInterval tempInterval = [groupItem.blockTime floatValue] - timeinterval;
            if (tempInterval <= 0) {
                [resultList addObject:groupItem];
            }
        }
        

    }
    @catch (NSException *exception)
    {
        NSLog(@"__ERROR__%@__", exception.reason);
    }
    
    return resultList;
}




+ (GroupItem *)getGroupItemByName:(NSString *)name
{
    GroupItem *cgItem = nil;
    NSArray *lists;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupName LIKE[c] %@", name];
        lists = [CoreDataHelper searchObjectsInContext:managedObjectContext
                                            entityName:kEntityName
                                             predicate:predicate
                                               sortKey:nil
                                         sortAscending:NO];
        if ([lists count] > 0)
        {
            cgItem = [lists objectAtIndex:0];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"__ERROR__%@__", exception.reason);
    }
    return cgItem;
}



+ (BOOL)updateGroupItem:(GroupItem *)itemObj
{
    BOOL success = YES;
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        success = NO;
    }
    [managedObjectContext save:&error];
    return success;
    
}



+ (BOOL)deleteGroupItem:(GroupItem *)itemObj
{
    NSError *error = nil;
    BOOL success = YES;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    
    if (managedObjectContext == nil)
    {
        success = NO;
        return success;
    }
    @try
    {
        [managedObjectContext deleteObject:itemObj];
        [managedObjectContext save:&error];
    }
    @catch (NSException* ex) {
        success = NO;
    }
    
    return success;
}
@end

