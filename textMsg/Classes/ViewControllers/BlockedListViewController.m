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
#import "define.h"
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface BlockedListViewController ()< WYPopoverControllerDelegate>
{
    WYPopoverController *popGroup;

}

@end

@implementation BlockedListViewController
@synthesize blockGroup,popoverController;


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
   /* self.view.layer.shadowOpacity = 1.75f;
    self.view.layer.shadowRadius = 100.0f;
    self.view.layer.shadowColor = [UIColor pomegranateColor].CGColor;*/
    
    if (IS_OS_7_OR_LATER) {
        
    }else
    {
        backButton.tintColor = [UIColor turquoiseColor ];
        
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSManagedObjectContext managedObjectContext] reset];
    groupList1 = [GroupItem getGroupByStatus:@"1"];
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
    return [groupList1 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    
    GroupItem *group = [groupList1 objectAtIndex:indexPath.row];
    UILabel *name = (UILabel*)[cell viewWithTag:1];
    UILabel *status = (UILabel*)[cell viewWithTag:2];
       UILabel *count = (UILabel*)[cell viewWithTag:5];
    name.text = group.groupName;
    NSArray *contactList = [ContactItem getAllCGItemByGroupUUID:group.groupUUID];

    count.text = [NSString stringWithFormat:@"%i",[contactList count]];

    if ([group.groupStatus isEqualToString:@"0"]) {
        
        status.text = @"Not blocked";
        status.textColor = [UIColor greenColor];
    }
    else
    {
        cell.backgroundColor = [UIColor clearColor];
        status.text = @"hidden";
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
    selectedItem = [groupList1 objectAtIndex:indexPath.row];
    
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
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        cell = (UITableViewCell*)button.superview.superview;
    }
    if(cell)
    {
        NSIndexPath *indexPath = [groupTableView indexPathForCell:cell];
        selectedItem = [groupList1 objectAtIndex:indexPath.row];
        
        WYPopoverBackgroundView* appearance = [WYPopoverBackgroundView appearance];
        appearance.fillTopColor = [UIColor colorWithRed:0 green:.9 blue:0.9 alpha:.75];

        
        if ([selectedItem.groupStatus isEqualToString:@"1"]) {
//            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
//                UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Confirm Your Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//                [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
//                alert1.tag = 400;
//                [alert1 show];
//            }
//            else
//            {
            
                UINavigationController* contentViewController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"]];
                NewGroupViewController *groupDetail = ((NewGroupViewController*)[contentViewController.viewControllers objectAtIndex:0]);
                groupDetail.groupItem = [groupList1 objectAtIndex:indexPath.row];
                popGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
                popGroup.delegate = self;
                groupDetail.popGroup = popGroup;
                //[popoverController presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
                
                [popGroup presentPopoverFromRect:CGRectZero inView:nil permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES];
            
         
                
                //  NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
                // groupDetail.groupItem = [groupList1 objectAtIndex:indexPath.row];
                //[self.navigationController pushViewController:groupDetail animated:NO];
                
            //}
        }
        else
        {
            
            UINavigationController* contentViewController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"]];
            NewGroupViewController *groupDetail = ((NewGroupViewController*)[contentViewController.viewControllers objectAtIndex:0]);
            groupDetail.groupItem = [groupList1 objectAtIndex:indexPath.row];
            
            popGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
            popGroup.delegate = self;
            groupDetail.popGroup = popGroup;
            
            
            
            //((NewGroupViewController*)[contentViewController.viewControllers objectAtIndex:0]).popGroup = popGroup;
            //[popoverController presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
            
            [popGroup presentPopoverFromRect:CGRectZero inView:nil permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES];
            

            
            //  NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
            // groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
            //[self.navigationController pushViewController:groupDetail animated:NO];
            
            // NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
            //  groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
            // [self.navigationController pushViewController:groupDetail animated:NO];
        }
        
    }}

- (IBAction)back_click:(id)sender {
    
        //[self.delegate newGroupBack.self];
    [blockGroup dismissPopoverAnimated:YES];
                                      


}
@end
