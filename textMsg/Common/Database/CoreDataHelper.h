//
//  CoreDataHelper.h
//  Jacky


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

//Search Objects from Database by entityName, predicate & sort by SortKey
+ (NSMutableArray*)searchObjectsInContext:(NSManagedObjectContext*)managedObjectContext 
                               entityName:(NSString*)entityName 
                                predicate:(NSPredicate*)predicate 
                                  sortKey:(NSString*)sortKey
                            sortAscending:(BOOL)sortAscending;

//Get Objects from Database by entityName & sort by sortKey
+ (NSMutableArray*)getObjectsFromcontext:(NSManagedObjectContext*)managedObjectContext 
                              entityName:(NSString*)entityName 
                                 sortKey:(NSString*)sortKey 
                           sortAscending:(BOOL)sortAscending;

@end
