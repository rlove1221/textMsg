//
//  MessageViewController.m
//  Group Lock
//
//  Created by Jacky on 1/19/14.
//  Copyright (c) 2014 Richard Morena. All rights reserved.
//

#import "MessageViewController.h"
#import "define.h"
#import "ServiceManager.h"
#import "MessageDetailViewController.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

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
    nameLB.text = [userInfo objectForKey:@"fullname"];
    NSString *user_status =[userInfo objectForKey:@"user_status"];
    
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
    friendArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFriends_Info];
    messageArray = [[NSUserDefaults standardUserDefaults] objectForKey:kGroups_Info];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadData];
}

- (void)reloadData
{
    if (segmentControl.selectedSegmentIndex == 1) {
        [self performSelectorInBackground:@selector(showProcess:) withObject:@"Loading"];
        
        if([ServiceManager getFriendsforUser_id:[userInfo objectForKey:@"user_id"]])
        {
            [SVProgressHUD dismiss];
            
        }
        else
        {
            [SVProgressHUD dismiss];
            
        }
        
    }
    else
    {
        [self performSelectorInBackground:@selector(showProcess:) withObject:@"Loading"];
        
        if([ServiceManager getGroupsforUser_id:[userInfo objectForKey:@"user_id"]])
        {
            [SVProgressHUD dismiss];
            
        }
        else
        {
            [SVProgressHUD dismiss];
            
        }
    }
    friendArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFriends_Info];
    messageArray = [[NSUserDefaults standardUserDefaults] objectForKey:kGroups_Info];
    [self.messageTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segmentControl.selectedSegmentIndex == 1)
    {
        return [friendArray count];
    }
    return [messageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (segmentControl.selectedSegmentIndex == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
        NSDictionary *friends = [friendArray objectAtIndex:indexPath.row];
        UILabel *name = (UILabel*)[cell viewWithTag:1];
        UILabel *status = (UILabel*)[cell viewWithTag:2];
        name.text = [friends objectForKey:@"fullname"];
        NSString *user_status =[friends objectForKey:@"user_status"];
        
        switch ([user_status intValue]) {
            case 0:
                status.text = @"Offline";
                break;
            case 1:
                status.text = @"Available";
                break;
            case 2:
                status.text = @"Moving";
                break;
            default:
                break;
        }
    }
    else
    {
        NSDictionary *group = [messageArray objectAtIndex:indexPath.row];
        
        
        UILabel *name = (UILabel*)[cell viewWithTag:1];
        UILabel *date = (UILabel*)[cell viewWithTag:2];
        NSArray *tempArray = [friendArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user_id = %@",[group objectForKey:@"friend_id"]]];
        if ([tempArray count] >0) {
            name.text = [[tempArray objectAtIndex:0] objectForKey:@"fullname"];
        }
        
        date.text = [group objectForKey:@"updated_on"];
    }
    
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (segmentControl.selectedSegmentIndex == 1)
    {
        NSDictionary *friends = [friendArray objectAtIndex:indexPath.row];
        NSString *friend_id = [friends objectForKey:@"user_id"];
        [self performSelectorInBackground:@selector(showProcess:) withObject:@"Loading"];
        
        if([ServiceManager getMessageforUser_id:[userInfo objectForKey:@"user_id"] andFriend_id:friend_id])
        {
            [SVProgressHUD dismiss];
            messageArray = [[NSUserDefaults standardUserDefaults] objectForKey:kGroups_Info];
            NSArray *tempArray = [messageArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"friend_id = %@",friend_id]];
            
            MessageDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailViewController"];
            if ([tempArray count] >0) {
                controller.selectedGroup = [tempArray objectAtIndex:0];
            }
            [self.navigationController pushViewController:controller animated:YES];
            

            
        }
        else
        {
            [SVProgressHUD dismiss];
            
        }
    }
    else
    {
        NSDictionary *group = [messageArray objectAtIndex:indexPath.row];
        MessageDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageDetailViewController"];
        controller.selectedGroup = group;
        [self.navigationController pushViewController:controller animated:YES];

    }
    
}

- (IBAction)home_click:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)signout_click:(id)sender {
    [self performSelectorInBackground:@selector(showProcess:) withObject:@"Signing out"];
    
    if([ServiceManager logoutWithUserId:[userInfo objectForKey:@"user_id"]])
    {
        [SVProgressHUD dismiss];
        
    }
    else
    {
        [SVProgressHUD dismiss];
        
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUser_Info];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGroups_Info];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFriends_Info];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)addfriend_click:(id)sender {
    
    UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Your friend's phone number" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert1.tag = 100;
    [alert1 show];
    
    
}

- (IBAction)segment_changed:(UISegmentedControl *)sender {
    NSLog(@"%i",sender.selectedSegmentIndex);
    [self reloadData];
}




- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1) {
        NSString *username = [alertView textFieldAtIndex:0].text;
        if (!username || username.length == 0) {
            [Util showAlertWithString:@"Please enter your friend's phone number"];
        }
        else
        {
            [self performSelectorInBackground:@selector(showProcess:) withObject:@"Adding"];
            
            if([ServiceManager addfriendWithUsername:username user_id:[userInfo objectForKey:@"user_id"]])
            {
                [SVProgressHUD dismiss];
                
            }
            else
            {
                [SVProgressHUD dismiss];
                
            }
            //[self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }
}
- (void)showProcess:(NSString *)message
{
    [SVProgressHUD showWithStatus:message];
}
@end
