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
+ (BOOL)logoutWithUserId:(NSString *)user_id;
+ (BOOL)loginWithUsername:(NSString *)username password:(NSString *)password;
+ (BOOL)addfriendWithUsername:(NSString*)username user_id:(NSString *)user_id;
+ (BOOL)getFriendsforUser_id:(NSString *)user_id;
+ (BOOL)getMessageforUser_id:(NSString *)user_id andFriend_id:(NSString *)friend_id;
+ (BOOL)getGroupsforUser_id:(NSString *)user_id;
+ (BOOL)sendMessageforUser_id:(NSString *)user_id group_id:(NSString *)group_id friend_id:(NSString *)friend_id message:(NSString *)message;
+ (BOOL)updateStatusForUserId:(NSString *)user_id status:(NSString*)status;
@end
