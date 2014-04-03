//
//  MessageDetailViewController.m
//  Group Lock
//
//  Created by Jacky on 2014/03/03.
//  Copyright (c) 2014年 Richard Morena. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "define.h"
#import "define.h"
#import "ServiceManager.h"
@interface MessageDetailViewController ()

@end

@implementation MessageDetailViewController
@synthesize messageTableView,selectedGroup;
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
     userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kUser_Info];;
    messageList = [[selectedGroup objectForKey:@"messages"] mutableCopy];
    messageTableView.bubbleDataSource = self;
    messageTableView.snapInterval = 180;
    NSArray * friendArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFriends_Info];
    NSArray *tempArray = [friendArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user_id = %@",[selectedGroup objectForKey:@"friend_id"]]];
    if ([tempArray count] >0) {
        name.text = [[tempArray objectAtIndex:0] objectForKey:@"fullname"];
        NSString *user_status =[[tempArray objectAtIndex:0] objectForKey:@"user_status"];
        
        switch ([user_status intValue]) {
            case 0:
                statusLB.text = @"Offline";
                break;
            case 1:
                statusLB.text = @"Available";
                break;
            case 2:
                statusLB.text = @"Moving";
                break;
            default:
                break;
        }
    }

	// Do any additional setup after loading the view.
    [self generateMessageData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
}

- (void)timerTask
{
    [self performSelectorInBackground:@selector(reloadDataInBackground) withObject:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (timer.isValid) {
        [timer invalidate];
    }
    timer = nil;
}

- (void)reloadDataInBackground
{
    if([ServiceManager getMessageforUser_id:[userInfo objectForKey:@"user_id"] andFriend_id:[selectedGroup objectForKey:@"friend_id"]])
    {
        NSString *friendId = [selectedGroup objectForKey:@"user_id1"];
        if ([friendId isEqualToString:[userInfo objectForKey:@"user_id"]]) {
            friendId = [selectedGroup objectForKey:@"user_id2"];
        }
        //[SVProgressHUD dismiss];
        NSArray * messageArray = [[NSUserDefaults standardUserDefaults] objectForKey:kGroups_Info];
        NSArray *tempArray = [messageArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"friend_id = %@",friendId]];
        
        if ([tempArray count] >0) {
            selectedGroup = [tempArray objectAtIndex:0];
        }
       NSMutableArray  *tempmessageList = [[selectedGroup objectForKey:@"messages"] mutableCopy];
        [tempmessageList removeObjectsInArray:messageList];
        if ([tempmessageList count] > 0) {
            messageList = [[selectedGroup objectForKey:@"messages"] mutableCopy];
            [self generateMessageData];
        }
        
        NSArray * friendArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFriends_Info];
        tempArray = [friendArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user_id = %@",[selectedGroup objectForKey:@"friend_id"]]];
        if ([tempArray count] >0) {
            name.text = [[tempArray objectAtIndex:0] objectForKey:@"fullname"];
            NSString *user_status =[[tempArray objectAtIndex:0] objectForKey:@"user_status"];
            
            switch ([user_status intValue]) {
                case 0:
                    statusLB.text = @"Offline";
                    break;
                case 1:
                    statusLB.text = @"Available";
                    break;
                case 2:
                    statusLB.text = @"Moving";
                    break;
                default:
                    break;
            }
        }
        
        // Do any additional setup after loading the view.
        
        
        
        
    }
}

- (void)generateMessageData
{
    messageDataList = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *user_id = [userInfo objectForKey:@"user_id"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"y-MM-dd HH:mm:ss"];
    for (NSDictionary *messageDict in messageList) {
        NSString *posted_id = [messageDict objectForKey:@"user_id"];
        NSString *message = [messageDict objectForKey:@"message_detail"];
        NSDate *date = [formatter dateFromString:[messageDict objectForKey:@"created_on"]];
        int type = BubbleTypeSomeoneElse;
        if ([user_id isEqual:posted_id]) {
            type = BubbleTypeMine;
        }
        NSBubbleData *messageData = [NSBubbleData dataWithText:message date:date type:type];
        messageData.avatar = nil;
        [messageDataList addObject:messageData];
    }
    [messageTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [messageDataList count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [messageDataList objectAtIndex:row];
}


- (IBAction)back_clicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)send_clicked:(id)sender {
    if (textField.text == nil || textField.text.length == 0) {
        return;
    }
    
    [self performSelectorInBackground:@selector(showProcess:) withObject:@"Sending"];
    
    if([ServiceManager sendMessageforUser_id:[userInfo objectForKey:@"user_id"] group_id:[selectedGroup objectForKey:@"group_id"] friend_id:[selectedGroup objectForKey:@"friend_id"] message:textField.text])
    {
        [SVProgressHUD dismiss];
        NSArray *groupList = [[NSUserDefaults standardUserDefaults] objectForKey:kGroups_Info];
        NSArray *tempArray = [groupList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"group_id = %@",[selectedGroup objectForKey:@"group_id"]]];
        if ([tempArray count] > 0) {
           selectedGroup = [tempArray objectAtIndex:0];
        }
        messageList = [[selectedGroup objectForKey:@"messages"] mutableCopy];
        [self generateMessageData];
        
    }
    else
    {
        [SVProgressHUD dismiss];
        
    }
//    NSBubbleData *messageData = [NSBubbleData dataWithText:textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
//    [messageDataList addObject:messageData];
//    [messageTableView reloadData];
    textField.text = @"";
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)atextField
{
    [atextField resignFirstResponder];
    return YES;
}



#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = messageTableView.frame;
        frame.size.height -= kbSize.height;
        messageTableView.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = messageTableView.frame;
        frame.size.height += kbSize.height;
        messageTableView.frame = frame;
    }];
}

- (void)showProcess:(NSString *)message
{
    [SVProgressHUD showWithStatus:message];
}

@end
