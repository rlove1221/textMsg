
#import "NetworkActivityIndicator.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation NetworkActivityIndicator

static NSInteger count = 0;

//-----------------------------------------------------------------------------------
+ (void)show
//-----------------------------------------------------------------------------------
{
    if (count++ == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

//-----------------------------------------------------------------------------------
+ (void)hide
//-----------------------------------------------------------------------------------
{
    if (count && --count == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

//-----------------------------------------------------------------------------------
+ (void)hideAll
//-----------------------------------------------------------------------------------
{
    count = 0;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
}
@end
