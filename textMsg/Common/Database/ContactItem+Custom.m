//
//  Channel+Custom.m
//  ChannelBuster
//
//  Created by Jacky Nguyen on 4/9/13.
//  Copyright (c) 2013 com. All rights reserved.
//

#import "ContactItem+Custom.h"
#import "NSManagedObjectContext+Custom.h"
#import "CoreDataHelper.h"
#import "Define.h"
#define kEntityName @"ContactItem"
@implementation ContactItem(Custom)
+ (ContactItem *)newCGItem
{
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        ContactItem * cgItem = [NSEntityDescription insertNewObjectForEntityForName:kEntityName
                                                            inManagedObjectContext:managedObjectContext];
        return cgItem;
    }
    @catch (NSException *exception)
    {
        
    }
    return nil;
}

+ (NSArray *)getAllCGItems
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

+ (NSArray *)getAllCGItemByGroupUUID:(NSString *)groupUUID;
{
    NSArray *lists;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupUUID = %@", groupUUID];
        lists = [CoreDataHelper searchObjectsInContext:managedObjectContext
                                            entityName:kEntityName
                                             predicate:predicate
                                               sortKey:nil
                                         sortAscending:NO];

    }
    @catch (NSException *exception)
    {
        NSLog(@"__ERROR__%@__", exception.reason);
    }
    
    return lists;
}



+ (ContactItem *)getCGItemByName:(NSString *)name
{
    ContactItem *cgItem = nil;
    NSArray *lists;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactName LIKE[c] %@", name];
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

+ (ContactItem *)getCGItemById:(NSInteger )recordId groupUUID:(NSString *)groupUUID
{
    ContactItem *cgItem = nil;
    NSArray *lists;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %i AND groupUUID=%@", recordId,groupUUID];
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

+ (ContactItem *)checkCGItemByName:(NSString *)name groupUUID:(NSString *)groupUUID
{
    ContactItem *cgItem = nil;
    NSArray *lists;
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext managedObjectContext];
    if (managedObjectContext == nil)
    {
        return nil;
    }
    @try
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactName LIKE[c] %@ AND groupUUID = %@", name,groupUUID];
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

+ (BOOL)updateCGItem:(ContactItem *)itemObj
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



+ (BOOL)deleteCGItem:(ContactItem *)itemObj
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

