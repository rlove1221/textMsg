//
//  Util.m
//  AirLiquide


#import "Util.h"

@implementation Util

+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    NSString *string = (__bridge_transfer NSString*)CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return string ;
}

+ (NSString*)getBundle
{
    return [[NSBundle mainBundle] resourcePath];
}

+ (NSString*)stringFromDate:(NSDate*)date
{
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy/MM/dd "];
    return [dateFormat stringFromDate:date];
}

+ (void)showAlertWithString:(NSString *)string
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (NSString *)urlencode:(NSString *)string
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (BOOL) NSStringIsValidNumber:(NSString *)checkString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:checkString];
    return !!number;
}

+ (BOOL) NSStringIsValidPhoneNumber:(NSString *)checkString
{
    NSString *phoneRegex = @"^((0[0-9]))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:checkString];
}

+ (NSString *)imageDirectoryPath
{
   return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (BOOL)checkFile:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
