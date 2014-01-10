//
//  RegistViewController.h
//  Group Lock
//
//  Created by Jacky on 1/9/14.
//  Copyright (c) 2014 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistViewController : UIViewController
{
    NSInteger distance;
    BOOL keyboardIsShowing;
    UITextField *selectedTextField;
    IBOutlet UITextField *fullnameTF;
    IBOutlet UITextField *usernameTF;
    IBOutlet UITextField *passwordTF;
    IBOutlet UITextField *confirmPassTF;
    IBOutlet UITextField *EmailTF;
    IBOutlet UIScrollView *scrollview;
    
}
- (IBAction)create_clicked:(id)sender;
- (IBAction)back_clicked:(id)sender;
@end
