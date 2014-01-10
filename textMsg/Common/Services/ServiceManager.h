//
//  ServiceManager.h
//  CountryGrocer
//
//  Created by Jacky Nguyen on 5/13/13.
//  Copyright (c) 2013 teamios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceManager : NSObject
+ (BOOL)registUser:(NSDictionary *)dict;

+ (BOOL)loginWithUsername:(NSString *)username password:(NSString *)password;
@end
