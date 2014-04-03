//
//  MessageViewController.h
//  Group Lock
//
//  Created by Jacky on 1/19/14.
//  Copyright (c) 2014 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    
    IBOutlet UILabel *nameLB;
    IBOutlet UILabel *statusLB;
    NSDictionary *userInfo;
    NSArray *friendArray;
    NSArray *messageArray;
    int viewIndex;
    NSTimer *timer;
}
@property (strong, nonatomic) IBOutlet UITableView *messageTableView;
- (IBAction)home_click:(id)sender;
- (IBAction)signout_click:(id)sender;
- (IBAction)addfriend_click:(id)sender;
- (IBAction)list_Click:(UIButton *)sender;

@end
