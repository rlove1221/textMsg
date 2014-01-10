//
//  Util.h
//  AirLiquide


#import <Foundation/Foundation.h>
#import "define.h"
@interface Util : NSObject
+ (NSString *)GetUUID;
+ (NSString*)getBundle;
+ (NSString*)stringFromDate:(NSDate*)date;
+ (void)showAlertWithString:(NSString *)string;
+ (NSString *)urlencode:(NSString *)string;
+ (BOOL) NSStringIsValidEmail:(NSString *)checkString;
+ (BOOL) NSStringIsValidNumber:(NSString *)checkString;
+ (BOOL) NSStringIsValidPhoneNumber:(NSString *)checkString;
+ (NSString *)imageDirectoryPath;
+ (BOOL)checkFile:(NSString *)path;
@end
