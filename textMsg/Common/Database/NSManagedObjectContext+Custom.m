//
//  NSManagedObjectContext+custom.m


#import "NSManagedObjectContext+custom.h"
#import "Util.h"
#import "define.h"
static NSManagedObjectContext *managedObjectContext_ = nil;
static NSManagedObjectModel *managedObjectModel_;
static NSPersistentStoreCoordinator *persistentStoreCoordinator_;

@implementation NSManagedObjectContext(Custom)

+ (NSManagedObjectContext *)inMemoryMOCFromBundle{
	// get model from app bundle passed into method
	NSArray *bundleArray = [NSArray arrayWithObject:[Util getBundle]];
	NSAssert([bundleArray count] == (unsigned)1, @"1 object in bundle array");
	NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:bundleArray];
	
	NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	if (coordinator == nil) {
		return nil;
	}
	
	// Add an in-memory persistent store to the coordinator.
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];	
	
	NSError *addStoreError = nil;
	if (![coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&addStoreError]) {
		return nil;
	}
	
	// Now we can set up the managed object context and assign it to persistent store coordinator.
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator: coordinator];
	NSAssert( context != nil, @"Can't set up managed object context for unit test.");
	
	return context;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
+ (NSManagedObjectContext *)managedObjectContext{
    
    @synchronized(self){
		if (managedObjectContext_ != nil) {
			return managedObjectContext_;
		}
		
		NSPersistentStoreCoordinator *coordinator = [NSManagedObjectContext persistentStoreCoordinator];
		if (coordinator != nil) {
			managedObjectContext_ = [[NSManagedObjectContext alloc] init];
			[managedObjectContext_ setPersistentStoreCoordinator:coordinator];
		}
	}
    return managedObjectContext_;
}
#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
+ (NSString *)applicationDocumentsDirectory {
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString *pathFinal = [path stringByReplacingOccurrencesOfString:@"Library/Application Support/iPhone Simulator/Documents" withString:@"Documents"];
	NSLog(@"pathFinal:%@", pathFinal);
	return pathFinal;
}
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
+ (NSManagedObjectModel *)managedObjectModel{
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [HOMEDIRECTORY stringByAppendingPathComponent:@"TextData.momd"];
	NSLog(@"modelPath=%@", modelPath);
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    NSURL *storeURL = [NSURL fileURLWithPath:[LIBRARY_CATCHES_DIRECTORY stringByAppendingPathComponent: @"TextData.sqlite"]];
    NSLog(@"urlstring:%@", [LIBRARY_CATCHES_DIRECTORY stringByAppendingPathComponent: @"TextData.sqlite"]);
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectContext managedObjectModel]];
	
	if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        if(![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return persistentStoreCoordinator_;
}

@end

