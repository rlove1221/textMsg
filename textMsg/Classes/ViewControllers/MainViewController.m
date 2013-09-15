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
@interface MainViewController ()

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
    groupList = [GroupItem getAllGroupItems];
    [groupTableView reloadData];
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
        controller.body = @"";
        //        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    NSLog(@"%d", result);
    [controller dismissViewControllerAnimated:YES completion:nil];
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
    UILabel *remaining = (UILabel*)[cell viewWithTag:2];
    name.text = group.groupName;
    if ([group.blockTime floatValue] != 0) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        timeInterval =[group.blockTime floatValue] - timeInterval;
        remaining.text = [NSString stringWithFormat:@"%.0f seconds",timeInterval];
    }
    else
    {
        remaining.text = @"expired";
    }
    
    
    //groupItem.blockTime = [NSString stringWithFormat:@"%.0f",timeInterval/1000];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
    groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:groupDetail animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [GroupItem deleteGroupItem:[groupList objectAtIndex:indexPath.row]];
    [self viewWillAppear:YES];
}

- (IBAction)setpass_click:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Enter Your Current Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
        alert1.tag = 100;
        [alert1 show];
    }
    else{
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Enter Your New Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
        alert1.tag = 200;
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
    }
    
}


- (IBAction)creategroup_click:(id)sender {
    NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
    [self.navigationController pushViewController:groupDetail animated:YES];
}
@end
