//
//  NSManagedObjectContext+custom.h


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObjectContext(Custom)

// Currently not used.  Used to get a Managed Object Context from an in-memory database.  Could be useful for unit tests later on.
+ (NSManagedObjectContext *) inMemoryMOCFromBundle;

// Gets the managed object context singleton
+ (NSManagedObjectContext *) managedObjectContext;

// Gets the persistantStoreCoordinator
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

// Gets the Managed Object Model
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSString *)applicationDocumentsDirectory;

@end
