//
//  CGItem.h
//  CountryGrocer
//
//  Created by Jacky Nguyen on 5/14/13.
//  Copyright (c) 2013 teamios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ContactItem : NSManagedObject

@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString * contactNumber;
@property (nonatomic, retain) NSString * groupUUID;
@property (nonatomic, retain) NSNumber * contactId;

@property (nonatomic, retain) NSData * contactData;



@end
