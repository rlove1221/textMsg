//
//  ViewController.m
//  textMsg
//
//  Created by Richard Morena on 8/31/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import "MainViewController.h"
#import "AddContactViewController.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import "GroupItem+Custom.h"
#import "NewGroupViewController.h"
#import "Util.h"
#import "NSManagedObjectContext+Custom.h"
#import "BlockedListViewController.h"
#import "UIColor+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
@interface MainViewController ()< WYPopoverControllerDelegate>
{
    WYPopoverController *popGroup;
    
    WYPopoverController *blockGroup;
    
    UIPopoverController* standardPopoverController;

}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkExpiredGroup) userInfo:nil repeats:YES];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    NSArray *arrayOfPeople = nil;
    if (accessGranted) {
        
        arrayOfPeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        // Do whatever you need with thePeople...
        
    }
    
    NSUInteger index = 0;
    allContactsPhoneNumber = [[NSMutableArray alloc] init];
    
    for(index = 0; index<[arrayOfPeople count]; index++){
        
        ABRecordRef currentPerson =
        (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:index];
        NSString *name = [self getName:currentPerson];
        NSArray *phones =
        (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(
                                                             ABRecordCopyValue(currentPerson, kABPersonPhoneProperty));
        
        // Make sure that the selected contact has one phone at least filled in.
        if ([phones count] > 0) {
            // We'll use the first phone number only here.
            // In a real app, it's up to you to play around with the returned values and pick the necessary value.
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",[phones objectAtIndex:0],@"phone", nil];
            [allContactsPhoneNumber addObject:dict];
        }
        else{
            //[allContactsPhoneNumber addObject:@"No phone number was set."];
        }
    }
	// Do any additional setup after loading the view, typically from a nib.
  //  self.title = @"Group Table View";
    
    //Set the separator color
  //  groupTableView.separatorColor = [UIColor cloudsColor];
    
    //Set the background color
   // groupTableView.backgroundColor = [UIColor cloudsColor];
   // groupTableView.backgroundView = nil;
    
    

}

- (void)checkExpiredGroup
{
    NSArray *expiredList =  [GroupItem getExpiredGroup];
    for (GroupItem *groupitem in expiredList) {
        if ([groupitem.blockTime floatValue] == 0) {
            continue;
        }
        groupitem.blockTime = @"0";
        [GroupItem updateGroupItem:groupitem];
        NSArray *contactList = [ContactItem getAllCGItemByGroupUUID:groupitem.groupUUID];
        for (ContactItem *contactItem in contactList) {
            [self creatContact:contactItem];
        }
    }
}

- (void)creatContact:(ContactItem *)contactitem
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreate(); // create address book record
    ABRecordRef person = ABPersonCreate(); // create a person
    
    NSString *phone = contactitem.contactNumber; // the phone number to add
    NSArray *splitArray = [contactitem.contactName componentsSeparatedByString:@" "];
    NSString *firstname=@"";
    NSString *lastname=@"";
    if ([splitArray count] > 1) {
        firstname = [splitArray objectAtIndex:0];
        lastname = [splitArray objectAtIndex:1];
    }
    
    //Phone number is a list of phone number, so create a multivalue
    ABMutableMultiValueRef phoneNumberMultiValue =
    ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)(phone),kABPersonPhoneMobileLabel, NULL);
    
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstname) , nil); // first name of the new person
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastname), nil); // his last name
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, &error); // set the phone number property
    ABAddressBookAddRecord(addressBook, person, nil); //add the new person to the record
    
    ABRecordRef group = ABGroupCreate(); //create a group
    ABRecordSetValue(group, kABGroupNameProperty,@"My Group", &error); // set group's name
    ABGroupAddMember(group, person, &error); // add the person to the group
    ABAddressBookAddRecord(addressBook, group, &error); // add the group
    
    
    ABAddressBookSave(addressBook, nil); //save the record
    
    
    
    CFRelease(person); // relase the ABRecordRef  variable
}

- (NSString *) getName: (ABRecordRef) person
{
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *biz = (__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
    
    
    if ((!firstName) && !(lastName))
    {
        if (biz) return biz;
        return @"[No name supplied]";
    }
    
    if (!lastName) lastName = @"";
    if (!firstName) firstName = @"";

    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSManagedObjectContext managedObjectContext] reset];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
        groupList = [GroupItem getGroupByStatus:@"0"];
        groupList1 = [GroupItem getGroupByStatus:@"1"];
    
    }
    else{
        groupList = [GroupItem getAllGroupItems];
    }
            if ([groupList1 count] > 0 && [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
        [lockbutton setImage:[UIImage imageNamed:@"lock1.png"] forState:UIControlStateNormal];
    }
    else if
     ([groupList1 count]== 0) {
        [lockbutton setImage:[UIImage imageNamed:@"lockUn2.png"] forState:UIControlStateNormal];
    }
    [groupTableView reloadData];
    
    self.navigationController.navigationBarHidden = YES;

}
- (void)viewWillDisappear:(BOOL)animated
{
    if (!isShowMessage) {
        self.navigationController.navigationBarHidden = NO;
    }
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendMessage:(id)sender {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        isShowMessage = YES;
        controller.body = @"";
        //        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    NSLog(@"%d", result);
    [controller dismissViewControllerAnimated:NO completion:nil];
    isShowMessage = NO;
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
    UILabel *name2 = (UILabel*)[cell viewWithTag:3];
    UILabel *status = (UILabel*)[cell viewWithTag:2];
    UILabel *count = (UILabel*)[cell viewWithTag:4];
    //UIImageView *imageView = (UIImageView*)[cell viewWithTag:3];
    name.text = group.groupName;
    name2.text = group.groupName;
    NSArray *contactList = [ContactItem getAllCGItemByGroupUUID:group.groupUUID];
    count.text = [NSString stringWithFormat:@"%i",[contactList count]];
    if ([group.groupStatus isEqualToString:@"0"]) {
        
    //cell background
        cell.backgroundColor = [UIColor clearColor];
        name2.textColor = [UIColor turquoiseColor];
        status.text = @"";
        status.textColor = [UIColor emerlandColor];
        //imageView.hidden = NO;
        name.hidden = YES;
        name2.hidden = NO;
        }
    else
    {
        cell.backgroundColor = [UIColor clearColor];
        name2.textColor = [UIColor pomegranateColor];
        status.text = @"";
        status.textColor = [UIColor cloudsColor];
        //imageView.hidden = YES;
        name.hidden = YES;
        name2.hidden = NO;
    }
    //groupItem.blockTime = [NSString stringWithFormat:@"%.0f",timeInterval/1000];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
            isShowMessage = YES;
            controller.recipients = phoneList;
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:NO completion:nil];
        }
        
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItem = [groupList objectAtIndex:indexPath.row];
    if ([selectedItem.groupStatus isEqualToString:@"1"]) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Confirm Your Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alert1.tag = 300;
            [alert1 show];
        }
    }
    else
    {
        [GroupItem deleteGroupItem:selectedItem];
        [self viewWillAppear:YES];
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
        selectedItem = [groupList objectAtIndex:indexPath.row];
        
        WYPopoverBackgroundView* appearance = [WYPopoverBackgroundView appearance];
        appearance.fillTopColor = [UIColor colorWithRed:0 green:.9 blue:0.9 alpha:.75];
        appearance.outerShadowColor = [UIColor colorWithRed:0 green:.9 blue:0.7 alpha:.75];


        
        if ([selectedItem.groupStatus isEqualToString:@"1"]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
                UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Confirm Your Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
                alert1.tag = 400;
                [alert1 show];
            }
            else
            {
                
                UINavigationController* contentViewController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"]];
                NewGroupViewController *groupDetail = ((NewGroupViewController*)[contentViewController.viewControllers objectAtIndex:0]);
                groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
                popGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
                popGroup.delegate = self;
                groupDetail.popGroup = popGroup;
                //[popoverController presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
                
                [popGroup presentPopoverFromRect:CGRectZero inView:nil permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES];
                appearance.fillTopColor = [UIColor colorWithRed:0 green:.9 blue:0.7 alpha:.75];
                appearance.outerShadowColor = [UIColor colorWithRed:0 green:.9 blue:0.7 alpha:.75];

                
                
              //  NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
               // groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
                //[self.navigationController pushViewController:groupDetail animated:NO];

            }
        }
        else
        {
            
            UINavigationController* contentViewController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"]];
            NewGroupViewController *groupDetail = ((NewGroupViewController*)[contentViewController.viewControllers objectAtIndex:0]);
            groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
            
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

    }
}


- (BOOL)popGroupShouldDismissPopover:(WYPopoverController *)aPopoverController
{
    
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController
{
    [self viewWillAppear:YES];
    
}
- (IBAction)setpass_click:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
        
        
//        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Enter Your Current Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//        [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
//        alert1.tag = 100;
//        [alert1 show];
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Passcode" otherButtonTitles:@"Change Passcode", nil];
        actionsheet.tag = 100;
     
        
        [actionsheet showInView:self.view];
    }
    else{
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Enter Your New Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
        alert1.tag = 200;
       
    [alert1 show];
      
        

    }
                }



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Enter Your Current Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
        alert1.tag = 600;
        
        [alert1 show];
    }
    else if(buttonIndex == 1)
    {
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Enter Your Current Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
        alert1.tag = 100;
        [alert1 show];

        
    }
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        
        NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
        if ([passcode isEqualToString:[alertView textFieldAtIndex:0].text]) {
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Enter Your New Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alert1.tag = 200;
        
            
            [alert1 show];
        }
        else
        {
            [Util showAlertWithString:@"Passcode not correct"];
        }
        
    }
    if (alertView.tag == 200 && buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[alertView textFieldAtIndex:0].text forKey:@"passcode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (buttonIndex == 1) {
            [passCode setImage:[UIImage imageNamed:@"pssCode.png"] forState:UIControlStateNormal];
    }
    }
    if (alertView.tag == 300 && buttonIndex == 1) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
        if ([passcode isEqualToString:[alertView textFieldAtIndex:0].text]) {
            NSArray *contactList = [ContactItem getAllCGItemByGroupUUID:selectedItem.groupUUID];
            for (ContactItem *contactItem in contactList) {
                [self creatContact:contactItem];
            }
       

            [GroupItem deleteGroupItem:selectedItem];
            [self viewWillAppear:YES];
        }
        else
        {
            [Util showAlertWithString:@"Passcode not correct"];
        }
        
    }
    
    if (alertView.tag == 400 && buttonIndex == 1) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
        if ([passcode isEqualToString:[alertView textFieldAtIndex:0].text]) {
            NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
            groupDetail.groupItem = selectedItem;
            [self.navigationController pushViewController:groupDetail animated:YES];
        }
        else
        {
            [Util showAlertWithString:@"Passcode not correct"];
        }
        
    }
    
    if (alertView.tag == 500 && buttonIndex == 1) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
        if ([passcode isEqualToString:[alertView textFieldAtIndex:0].text]) {
            BlockedListViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"BlockedListViewController"];
            
           // [self.navigationController pushViewController:groupDetail animated:YES];
            
            
            if ([groupDetail respondsToSelector:@selector(setPreferredContentSize:)]) {
                groupDetail.preferredContentSize = CGSizeMake(280, 200);             // iOS 7
            }
            else {
                groupDetail.contentSizeForViewInPopover = CGSizeMake(280, 200);      // iOS < 7
            }
            
            UINavigationController* contentViewController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"BlockedListViewController"]];
            
            
            WYPopoverBackgroundView* appearance = [WYPopoverBackgroundView appearance];
            appearance.fillTopColor = [UIColor colorWithRed:1 green:0.2 blue:0 alpha:.75];
            appearance.outerShadowColor = [UIColor pomegranateColor];


            
            
            //    groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
            
            blockGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
            blockGroup.delegate = self;
            ((BlockedListViewController*)[contentViewController.viewControllers objectAtIndex:0]).blockGroup = blockGroup;
            //[popoverController presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
            
            [blockGroup presentPopoverFromRect:CGRectZero inView:nil permittedArrowDirections:WYPopoverArrowDirectionNone
                                      animated:YES
                                       options:WYPopoverAnimationOptionFadeWithScale];
            blockGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
            blockGroup.delegate = self;
            blockGroup.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
            blockGroup.wantsDefaultContentAppearance = NO;
            
        }
        else
        {
            [Util showAlertWithString:@"Passcode not correct"];
        }
        
    }
    if (alertView.tag == 600 && buttonIndex == 1) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
        if ([passcode isEqualToString:[alertView textFieldAtIndex:0].text]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passcode"];
            [[NSUserDefaults standardUserDefaults] synchronize];
           
            [passCode setImage:[UIImage imageNamed:@"pssCde1.png"] forState:UIControlStateNormal];
            [lockbutton setImage:[UIImage imageNamed:@"lockUn2.png"] forState:UIControlStateNormal];
                
           
        }
        else
        {
            [Util showAlertWithString:@"Passcode not correct"];
        }
       // NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
        
    }
    
    groupTableView.editing = NO;
    [self viewWillAppear:YES];
}



- (IBAction)creategroup_click:(id)sender
{
 
 //   NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
  //  [self.navigationController pushViewController:groupDetail animated:YES];
    NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];

   
    if ([groupDetail respondsToSelector:@selector(setPreferredContentSize:)]) {
        groupDetail.preferredContentSize = CGSizeMake(280, 200);             // iOS 7
    }
    else {
        groupDetail.contentSizeForViewInPopover = CGSizeMake(280, 200);      // iOS < 7
    }
     
    UINavigationController* contentViewController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"]];

    
    //    groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
    
    WYPopoverBackgroundView* appearance = [WYPopoverBackgroundView appearance];
    appearance.fillTopColor = [UIColor colorWithRed:0 green:.9 blue:0.7 alpha:.75];
    appearance.outerShadowColor = [UIColor turquoiseColor];
    


    popGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
    popGroup.delegate = self;
    ((NewGroupViewController*)[contentViewController.viewControllers objectAtIndex:0]).popGroup = popGroup;
    //[popoverController presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    
    [popGroup presentPopoverFromRect:CGRectZero inView:nil permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES];
    popGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
    popGroup.delegate = self;
   popGroup.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
   popGroup.wantsDefaultContentAppearance = NO;
    
    
  
}

- (IBAction)viewBlockedList_Click:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Confirm Your Current Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
        alert1.tag = 500;
        [alert1 show];
    }
    else{
        BlockedListViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"BlockedListViewController"];
        
       // [self.navigationController pushViewController:groupDetail animated:YES];
       
        
        if ([groupDetail respondsToSelector:@selector(setPreferredContentSize:)]) {
            groupDetail.preferredContentSize = CGSizeMake(280, 200);             // iOS 7
        }
        else {
            groupDetail.contentSizeForViewInPopover = CGSizeMake(280, 200);      // iOS < 7
        }
        
        UINavigationController* contentViewController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"BlockedListViewController"]];
        
        
        //    groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
        
        blockGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
        blockGroup.delegate = self;
        
        
      WYPopoverBackgroundView* appearance = [WYPopoverBackgroundView appearance];
        appearance.fillTopColor = [UIColor colorWithRed:1 green:0.2 blue:0 alpha:.75];
        appearance.outerShadowColor = [UIColor pomegranateColor];

        
       ((BlockedListViewController*)[contentViewController.viewControllers objectAtIndex:0]).blockGroup = blockGroup;
        //[popoverController presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        
        [blockGroup presentPopoverFromRect:CGRectZero inView:nil permittedArrowDirections:WYPopoverArrowDirectionNone
                                  animated:YES
         options:WYPopoverAnimationOptionFadeWithScale];
        blockGroup = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
        
        blockGroup.delegate = self;
        blockGroup.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        blockGroup.wantsDefaultContentAppearance = NO;
        

    }
    
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)newGroupBack:(NewGroupViewController *)controller{
    //controller.delegate = nil;
    [popGroup dismissPopoverAnimated:YES];
    popGroup.delegate = nil;
    popGroup = nil;

    
    
}


- (void)blockBack:(BlockedListViewController *)controller{
    //controller.delegate = nil;
    [blockGroup dismissPopoverAnimated:YES];
    blockGroup.delegate = nil;
    blockGroup = nil;
    
    
    
}


@end
