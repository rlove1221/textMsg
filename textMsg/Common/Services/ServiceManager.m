//
//  ServiceManager.m
//  CountryGrocer
//
//  Created by Jacky Nguyen on 5/13/13.
//  Copyright (c) 2013 teamios. All rights reserved.
//

#import "ServiceManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "define.h"
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"
#import <AdSupport/AdSupport.h>

@implementation ServiceManager
+ (BOOL)registUser:(NSDictionary *)dict
{
    if (!dict) {
        return NO;
    }
    //NSString *post = [dict JSONRepresentation];
    
    //NSString *urlEncode = [Util urlencode:post];
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",kServer_Post_RegistUser]];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[dict objectForKey:@"username"] forKey:@"username"];
    [request setPostValue:[dict objectForKey:@"fullname"] forKey:@"fullname"];
    [request setPostValue:[dict objectForKey:@"password"] forKey:@"password"];
    [request setPostValue:[dict objectForKey:@"email"] forKey:@"email"];
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            if ([userdict count] > 0 && [[userdict objectForKey:@"success"] isEqualToString:@"true"])
            {
                //{"id":"2031","gcm_regid":"8020BF8C-C7FA-41D1-B071-B9AA500F5923,","name":"test6","email":"test6@gmail.com","image":"noimage.jpg","latitude":"37.785834","longitude":"-122.406417","update_time":"3 days ago","phone":"01264239226","sex":"0","age":"11","status":"1","is_liked":"","is_following":"","friend_status":null,"distance":0}}
                
                //[[NSUserDefaults standardUserDefaults] setObject:[userdict objectForKey:@"profile"] forKey:kUser_Info];
                [[NSUserDefaults standardUserDefaults] synchronize];
//                if (data) {
//                    NSDictionary *userDict2 = [[NSUserDefaults standardUserDefaults] objectForKey:kUser_Info];
//                    NSString *imagePath = [[Util imageDirectoryPath] stringByAppendingFormat:@"/%@_%@_%@.jpg",[userDict2 objectForKey:@"id"],[userDict2 objectForKey:@"image"],@"normal"];
//                    [data writeToURL:[NSURL fileURLWithPath:imagePath] atomically:YES];
//                }
                return YES;
            }
            else
            {
                [Util showAlertWithString:[userdict objectForKey:@"message"]];
            }
        }        
    }
    else
    {
        [Util showAlertWithString:@"Can't connect to server!"];
    }
    
    return NO;
}


+ (BOOL)loginWithUsername:(NSString *)username password:(NSString *)password
{
    
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:kServer_Post_Login];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken]) {
        [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken] forKey:@"device_token"];
    }
    
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSString *result = [request.responseString stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
        NSDictionary *userdict = [result JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            NSArray *array = [userdict objectForKey:@"users"];
            if (array != nil && [array count] > 0)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[array objectAtIndex:0] forKey:kUser_Info];
                NSArray *friendarray = [userdict objectForKey:@"friends"];
                if (friendarray != nil )
                {
                    if ([friendarray count] > 0) {
                        [[NSUserDefaults standardUserDefaults] setObject:friendarray forKey:kFriends_Info];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey: kFriends_Info];
                    }
                }
                NSArray *groups = [userdict objectForKey:@"groups"];
                if (groups)
                {
                    if ([groups count]>0) {
                        [[NSUserDefaults standardUserDefaults] setObject:groups forKey:kGroups_Info];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGroups_Info];
                    }
                }

                [[NSUserDefaults standardUserDefaults] synchronize];
                return YES;
            }
            else
            {
                [Util showAlertWithString:[userdict objectForKey:@"message"]];
            }
        }
    }
    return NO;
}

+ (BOOL)logoutWithUserId:(NSString *)user_id
{
    
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:kServer_Post_Logout];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:user_id forKey:@"user_id"];
    
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            if ([userdict count] > 0 && [[userdict objectForKey:@"success"] isEqualToString:@"true"])
            {
                return YES;
            }
            else
            {
                NSLog(@"%@",[userdict objectForKey:@"message"]);
            }
        }
    }
    return NO;
}

+ (BOOL)updateStatusForUserId:(NSString *)user_id status:(NSString*)status
{
    
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:kServer_Post_UpdateStatus];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:user_id forKey:@"user_id"];
    [request setPostValue:status forKey:@"status"];
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            if ([userdict count] > 0 && [[userdict objectForKey:@"success"] isEqualToString:@"true"])
            {
                return YES;
            }
            else
            {
                NSLog(@"%@",[userdict objectForKey:@"message"]);
            }
        }
    }
    return NO;
}

+ (BOOL)addfriendWithUsername:(NSString*)username user_id:(NSString *)user_id
{
    
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:kServer_Post_Addfriend];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:user_id forKey:@"user_id"];
    [request setPostValue:username forKey:@"username"];
    
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            if ([userdict isKindOfClass:[NSDictionary class]]) {
                NSArray *array = [userdict objectForKey:@"users"];
                if (array != nil && [array count] > 0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[array objectAtIndex:0] forKey:kUser_Info];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return YES;
                }
                else
                {
                    [Util showAlertWithString:[userdict objectForKey:@"message"]];
                }
            }
        }
    }
    return NO;
}

+ (BOOL)getFriendsforUser_id:(NSString *)user_id
{
    
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:kServer_Post_Getfriend];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:user_id forKey:@"user_id"];
    
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            if ([userdict isKindOfClass:[NSDictionary class]]) {
                NSArray *array = [userdict objectForKey:@"friends"];
                if (array != nil )
                {
                    if ([array count] > 0) {
                        [[NSUserDefaults standardUserDefaults] setObject:array forKey:kFriends_Info];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey: kFriends_Info];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return YES;
                }
                else
                {
                    [Util showAlertWithString:[userdict objectForKey:@"message"]];
                }
            }
        }
    }
    return NO;
}
+ (BOOL)getGroupsforUser_id:(NSString *)user_id
{
    
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:kServer_Post_GetGroup];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:user_id forKey:@"user_id"];
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            if ([userdict isKindOfClass:[NSDictionary class]]) {
                
                NSArray *groups = [userdict objectForKey:@"groups"];
                if (groups)
                {
                    if ([groups count]>0) {
                        [[NSUserDefaults standardUserDefaults] setObject:groups forKey:kGroups_Info];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGroups_Info];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return YES;
                }
                else
                {
                    [Util showAlertWithString:[userdict objectForKey:@"message"]];
                }
            }
        }
    }
    return NO;
}

+ (BOOL)getMessageforUser_id:(NSString *)user_id andFriend_id:(NSString *)friend_id
{
    
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:kServer_Post_GetMessages];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:user_id forKey:@"user_id"];
    [request setPostValue:friend_id forKey:@"friend_id"];
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            if ([userdict isKindOfClass:[NSDictionary class]]) {
                
                if ([userdict objectForKey:@"group_id"] != nil)
                {
                    NSMutableArray *groupList = [[[NSUserDefaults standardUserDefaults] objectForKey:kGroups_Info] mutableCopy];
                    if (groupList) {

                        NSArray *tempArray = [groupList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"group_id = %@",[userdict objectForKey:@"group_id"]]];
                        if ([tempArray count] == 0) {
                            [groupList addObject:userdict];
                        }
                    }
                    else
                    {
                        groupList = [[NSMutableArray alloc] initWithCapacity:0];
                        [groupList addObject:userdict];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:groupList forKey:kGroups_Info];

                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return YES;
                }
                else
                {
                    [Util showAlertWithString:[userdict objectForKey:@"message"]];
                }
            }
        }
    }
    return NO;
}

+ (BOOL)sendMessageforUser_id:(NSString *)user_id group_id:(NSString *)group_id friend_id:(NSString *)friend_id message:(NSString *)message
{
    
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:kServer_Post_sendMessage];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:user_id forKey:@"user_id"];
    [request setPostValue:group_id forKey:@"group_id"];
    [request setPostValue:friend_id forKey:@"friend_id"];
    [request setPostValue:message forKey:@"message"];
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
        if ([userdict isKindOfClass:[NSDictionary class]]) {
            if ([userdict isKindOfClass:[NSDictionary class]]) {
                
                if ([userdict objectForKey:@"group_id"] != nil)
                {
                    NSMutableArray *groupList = [[[NSUserDefaults standardUserDefaults] objectForKey:kGroups_Info] mutableCopy];
                    if (groupList) {
                        
                        NSArray *tempArray = [groupList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"group_id = %@",[userdict objectForKey:@"group_id"]]];
                        if ([tempArray count] == 0) {
                            [groupList addObject:userdict];
                        }
                        else{
                            int index = [groupList indexOfObject:[tempArray objectAtIndex:0]];
                            [groupList replaceObjectAtIndex:index withObject:userdict];
                        }
                    }
                    else
                    {
                        groupList = [[NSMutableArray alloc] initWithCapacity:0];
                        [groupList addObject:userdict];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:groupList forKey:kGroups_Info];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return YES;
                }
                else
                {
                    [Util showAlertWithString:[userdict objectForKey:@"message"]];
                }
            }
        }
    }
    return NO;
}



@end
