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
    NSString *post = [dict JSONRepresentation];
    
    NSString *urlEncode = [Util urlencode:post];
    ASIFormDataRequest * request;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kServer_Post_RegistUser,urlEncode]];
    request = [ASIFormDataRequest requestWithURL:url];
    
    
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
    [request startSynchronous];
    
    if ([request responseStatusCode] == 200) {
        NSLog(@"%@",request.responseString);
        NSDictionary *userdict = [request.responseString JSONValue];
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
    return NO;
}


@end
