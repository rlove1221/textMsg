//
//  LoginViewController.m
//  Group Lock
//
//  Created by Jacky on 1/9/14.
//  Copyright (c) 2014 Richard Morena. All rights reserved.
//

#import "LoginViewController.h"
#import "ServiceManager.h"
#import "Util.h"
#import "SVProgressHUD.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login_click:(id)sender {
    if (username.text == nil || [username.text length] == 0 ||
        [[username.text stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]] length] == 0 ) {
        
        [Util showAlertWithString:@"Please enter your username!"];
        
        return;
        
    }
   
    if (password.text == nil || [password.text length] == 0 ||
        [[password.text stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]] length] == 0 ) {
        
        [Util showAlertWithString:@"Please enter your password!"];
        
        return;
        
    }
    [self performSelectorInBackground:@selector(showProcess) withObject:nil];

    if([ServiceManager loginWithUsername:username.text password:password.text])
    {
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [SVProgressHUD dismiss];

    }
}

- (IBAction)back_Click:(id)sender {
    self.mainController.isShowingMessage = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showProcess
{
    [SVProgressHUD showWithStatus:@"Loading"];
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

@end
