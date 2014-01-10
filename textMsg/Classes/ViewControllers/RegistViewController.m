//
//  RegistViewController.m
//  Group Lock
//
//  Created by Jacky on 1/9/14.
//  Copyright (c) 2014 Richard Morena. All rights reserved.
//

#import "RegistViewController.h"
#import "Util.h"
#import "SVProgressHUD.h"
#import "ServiceManager.h"
@interface RegistViewController ()

@end

@implementation RegistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)create_clicked:(id)sender {
    if (usernameTF.text == nil || [usernameTF.text length] == 0 ||
        [[usernameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]] length] == 0 ) {
        
        [Util showAlertWithString:@"Please enter your username!"];
        
        return;
        
    }
    if (fullnameTF.text == nil || [fullnameTF.text length] == 0 ||
        [[fullnameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]] length] == 0 ) {
        
        [Util showAlertWithString:@"Please enter your name!"];
        
        return;
        
    }
    if (![Util NSStringIsValidEmail:EmailTF.text] ) {
        
        [Util showAlertWithString:@"Your email invalid!"];
        
        return;
        
    }
    if (passwordTF.text == nil || [passwordTF.text length] == 0 ||
        [[passwordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]] length] == 0 ) {
        
        [Util showAlertWithString:@"Please enter your password!"];
        
        return;
        
    }
    
    
    
    if (![passwordTF.text isEqualToString:confirmPassTF.text]) {
        
        [Util showAlertWithString:@"Your password not match!"];
        return;
    }
    
    
    
//    NSString *device_token = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
//    if (!device_token)
//    {
//        device_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUUID"];
//        [[NSUserDefaults standardUserDefaults] setObject:device_token forKey:kDeviceToken];
//        [[NSUserDefaults standardUserDefaults]  synchronize];
//    }

    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:fullnameTF.text,@"fullname",usernameTF.text,@"username",passwordTF.text,@"password",EmailTF.text,@"email", nil];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSelectorInBackground:@selector(showProcess) withObject:nil];
    if ([ServiceManager registUser:userDict]) {
        [SVProgressHUD dismiss];
        [Util showAlertWithString:@"Successful!"];
        //[[NSUserDefaults standardUserDefaults] setObject:userDict forKey:kUser_Info];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstLaunch];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DidRegist"];
//        [[NSUserDefaults standardUserDefaults] setObject:passwordTF.text  forKey:@"user_password"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [SVProgressHUD dismiss];
    }

}

- (void)showProcess
{
    [SVProgressHUD showWithStatus:@"Creating"];
}


- (IBAction)back_clicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    
    return NO; // We do not want UITextField to insert line-breaks.
}

#pragma mark -
#pragma mark TextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int height = PORTRAIT_KEYBOARD_HEIGHT;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        height = LANDSCAPE_KEYBOARD_HEIGHT;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        screenHeight = screenRect.size.width;
    }
    NSLog(@"%f - %f - %f - %f : %f - %f",textField.frame.origin.y,textField.superview.frame.origin.y,screenHeight,textField.frame.size.height,textField.frame.origin.y + textField.superview.frame.origin.y + textField.frame.size.height,screenHeight - height);
    if (textField.frame.origin.y + textField.superview.frame.origin.y + textField.frame.size.height+self.navigationController.navigationBar.frame.size.height > screenHeight - height) {
        
        selectedTextField = textField;
        float currentDistance = textField.frame.origin.y + textField.superview.frame.origin.y + textField.frame.size.height + self.navigationController.navigationBar.frame.size.height - (screenHeight - height) + 25;
        distance += currentDistance;
        if (keyboardIsShowing) {
            UIView *parentView = selectedTextField.superview;
            CGRect frame = parentView.frame;
            frame.origin.y -= currentDistance;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.3f];
            parentView.frame = frame;
            [UIView commitAnimations];
        }
    }
}


- (void)keyboardWillShow:(NSNotification *)note
{
    
    scrollview.contentSize = CGSizeMake(320, 650);
    CGRect keyboardBounds;
    NSValue *aValue = [note.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    [aValue getValue:&keyboardBounds];
    if (!keyboardIsShowing)
    {
        keyboardIsShowing = YES;
        UIView *parentView = selectedTextField.superview;
        CGRect frame = parentView.frame;
        frame.origin.y -= distance;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        parentView.frame = frame;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    scrollview.contentSize = CGSizeMake(320, 480);
    if (IS_IPHONE5) {
        scrollview.contentSize = CGSizeMake(320, 568);
    }
    CGRect keyboardBounds;
    NSValue *aValue = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    [aValue getValue: &keyboardBounds];
    
    if (keyboardIsShowing)
    {
        keyboardIsShowing = NO;
        UIView *parentView = selectedTextField.superview;
        CGRect frame = parentView.frame;
        frame.origin.y += distance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        parentView.frame = frame;
        [UIView commitAnimations];
    }
    if (distance > 0) {
        distance = 0;
    }
}

- (void)dismissKeyboard {
    [self.view endEditing:TRUE];
}


@end
