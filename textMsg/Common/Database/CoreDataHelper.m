//
//  CoreDataHelper.m
//  Jacky


#import "CoreDataHelper.h"

@implementation CoreDataHelper

+ (NSMutableArray*)searchObjectsInContext:(NSManagedObjectContext*)managedObjectContext 
                               entityName:(NSString*)entityName 
                                predicate:(NSPredicate*)predicate 
                                  sortKey:(NSString*)sortKey
                            sortAscending:(BOOL)sortAscending
{
    //NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
    //                                          inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (predicate != nil) 
    {
        [request setPredicate:predicate];
    }
    if (sortKey != nil) 
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey
                                                                       ascending:sortAscending];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
    }
    
    NSError *error = nil;
    NSMutableArray *resultLists = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    return resultLists;
}

+ (NSMutableArray*)getObjectsFromcontext:(NSManagedObjectContext*)managedObjectContext 
                              entityName:(NSString*)entityName 
                                 sortKey:(NSString*)sortKey 
                           sortAscending:(BOOL)sortAscending
{
    return [self searchObjectsInContext:managedObjectContext
                             entityName:entityName
                              predicate:nil
                                sortKey:sortKey
                          sortAscending:sortAscending];
}

@end