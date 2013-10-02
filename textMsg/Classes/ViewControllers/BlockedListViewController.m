//
//  BlockedListViewController.m
//  textMsg
//
//  Created by Richard Morena on 9/15/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import "BlockedListViewController.h"
#import "GroupItem+Custom.h"
#import "NewGroupViewController.h"
#import "NSManagedObjectContext+Custom.h"
#import "UIColor+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import <MessageUI/MessageUI.h>
#import "ContactItem+Custom.h"
#import "Util.h"

@interface BlockedListViewController ()

@end

@implementation BlockedListViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [[NSManagedObjectContext managedObjectContext] reset];
    groupList = [GroupItem getGroupByStatus:@"1"];
    [groupTableView reloadData];
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
    return [groupList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    
    GroupItem *group = [groupList objectAtIndex:indexPath.row];
    UILabel *name = (UILabel*)[cell viewWithTag:1];
    UILabel *status = (UILabel*)[cell viewWithTag:2];
    name.text = group.groupName;
    if ([group.groupStatus isEqualToString:@"0"]) {
        
        status.text = @"Not blocked";
        status.textColor = [UIColor greenColor];
    }
    else
    {
        cell.backgroundColor = [UIColor pomegranateColor];
        status.text = @"Blocked";
        status.textColor = [UIColor cloudsColor];
    }
    
    
    //groupItem.blockTime = [NSString stringWithFormat:@"%.0f",timeInterval/1000];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
//    
//        NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
//        groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
//        [self.navigationController pushViewController:groupDetail animated:YES];
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    selectedItem = [groupList objectAtIndex:indexPath.row];
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if([MFMessageComposeViewController canSendText])
    {
        NSArray *contactList = [ContactItem getAllCGItemByGroupUUID:selectedItem.groupUUID];
        NSMutableArray *phoneList = [[NSMutableArray alloc] initWithCapacity:0];
        for (ContactItem *item in contactList) {
            [phoneList addObject:item.contactNumber];
            if (item.contactINumber != nil &&item.contactINumber.length > 0) {
                [phoneList addObject:item.contactINumber];
            }
        }
        if ([phoneList count] == 0) {
            [Util showAlertWithString:@"No contact to send message"];
        }
        else{
            //controller.body = @"SMS message here";
            //isShowMessage = YES;
            controller.recipients = phoneList;
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:NO completion:nil];
        }
        
    }
}
- (IBAction)edit_click:(id)sender {
    UIButton *button = (UIButton*)sender;
    UITableViewCell *cell = (UITableViewCell*)button.superview.superview.superview;
    if(cell)
    {
        NSIndexPath *indexPath = [groupTableView indexPathForCell:cell];
        selectedItem = [groupList objectAtIndex:indexPath.row];
        
        
            NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
            groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:groupDetail animated:NO];
        
        
    }
}
@end
