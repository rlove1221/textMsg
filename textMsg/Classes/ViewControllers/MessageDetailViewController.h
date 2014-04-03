//
//  MessageDetailViewController.h
//  Group Lock
//
//  Created by Jacky on 2014/03/03.
//  Copyright (c) 2014年 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
@interface MessageDetailViewController : UIViewController<UIBubbleTableViewDataSource,UITextFieldDelegate>
{
    IBOutlet UILabel *name;
    NSMutableArray *messageList;
    NSMutableArray *messageDataList;
    NSDictionary *userInfo;
    IBOutlet UIView *textInputView;
    IBOutlet UITextField *textField;
    IBOutlet UILabel *statusLB;
    NSTimer *timer;
}

@property (strong, nonatomic) IBOutlet UIBubbleTableView *messageTableView;
@property (retain, nonatomic) NSDictionary *selectedGroup;
- (IBAction)back_clicked:(id)sender;
- (IBAction)send_clicked:(id)sender;

@end
