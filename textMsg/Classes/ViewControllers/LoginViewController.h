//
//  LoginViewController.h
//  Group Lock
//
//  Created by Jacky on 1/9/14.
//  Copyright (c) 2014 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
@interface LoginViewController : UIViewController
{
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    
}
@property (strong,nonatomic) MainViewController *mainController;
- (IBAction)login_click:(id)sender;
- (IBAction)back_Click:(id)sender;
@end
