//
//  NewGroupViewController.m
//  textMsg
//
//  Created by Jacky on 9/4/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import "NewGroupViewController.h"
#import "AddContactViewController.h"
#import "GroupItem+Custom.h"
#import "ContactItem+Custom.h"
#import "define.h"
@interface NewGroupViewController ()

@end

@implementation NewGroupViewController
@synthesize groupItem,isAddNew;
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
    if (!groupItem) {
        isAddNew = YES;
        tempUUID = [Util GetUUID];
    }
    if (isAddNew) {
        groupItem = [GroupItem newGroupItem];
        groupItem.groupUUID = tempUUID;
        groupItem.groupStatus = @"0";
        saveBTN.hidden = YES;
    }
    else
    {
        if ([groupItem.groupStatus isEqualToString:@"0"]) {
            [blockBTn setTitle:@"Block"];
        }
        else
        {
            [blockBTn setTitle:@"Unblock"];
        }
        addBTN.hidden = YES;
    }
    
    
    addressBook = ABAddressBookCreate();
    
     accessGranted = NO;
    
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
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!isAddNew) {
        [createBarButton setTitle:@"Save"];
        nameTF.text = groupItem.groupName;
        if ([groupItem.blockTime floatValue] != 0) {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
            timeInterval =[groupItem.blockTime floatValue] - timeInterval;
            
            //groupItem.blockTime = [NSString stringWithFormat:@"%.0f",timeInterval/1000];
            timeTextField.text = [NSString stringWithFormat:@"%.0f",timeInterval];
        }
        else
        {
            timeTextField.text = @"0";
        }
        
    }
    
    //self.title = self.groupItem.groupName;
    if (groupItem) {
        contactList = [ContactItem getAllCGItemByGroupUUID:groupItem.groupUUID];
        [contactTableView reloadData];
    }
    if (accessGranted) {
        
        arrayOfPeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        // Do whatever you need with thePeople...
        
    }
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contactList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    ContactItem *contact = [contactList objectAtIndex:indexPath.row];
    UILabel *name = (UILabel*)[cell viewWithTag:1];
    UILabel *phone = (UILabel*)[cell viewWithTag:2];
    name.text = contact.contactName;
    phone.text = contact.contactNumber;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    //    GroupDetailViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
    //    groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
    //    [self.navigationController pushViewController:groupDetail animated:YES];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ContactItem deleteCGItem:[contactList objectAtIndex:indexPath.row]];
    [self viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)create_Click:(id)sender {
    if (nameTF.text.length == 0 || [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [Util showAlertWithString:@"Please enter group name!"];
        return;
    }
    
    NSString *groupname = [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (isAddNew||(!isAddNew && ![nameTF.text isEqualToString:groupItem.groupName])) {
        GroupItem *group = [GroupItem getGroupItemByName:groupname];
        if (group) {
            [Util showAlertWithString:@"This group is existed"];
            return;
        }
    }
    
    
    
    groupItem.groupName = groupname;
    
    [GroupItem updateGroupItem:groupItem];
    if ([groupItem.groupStatus isEqualToString:@"1"]) {
        for (ContactItem *contactItem in contactList) {
            [self deleteContact:contactItem.contactName];
        }
    }
    else
    {
        for (ContactItem *contactItem in contactList) {
            [self creatContact:contactItem];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addContact_Click:(id)sender {
    
    AddContactViewController *contactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
    contactViewController.groupItem = groupItem;
    [self.navigationController pushViewController:contactViewController animated:YES];
    
}

- (void)deleteContact:(NSString *)name
{
    CFErrorRef error = nil;
    
    //ABAddressBookRef addressBook = ABAddressBookCreate();
    for(int index = 0; index<[arrayOfPeople count]; index++){
        
        ABRecordRef currentPerson =
        (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:index];
        NSString *contactname = [self getName:currentPerson];
        if ([contactname isEqualToString:name]) {
            bool removed = ABAddressBookRemoveRecord(addressBook, currentPerson, &error);
            bool saved = ABAddressBookSave(addressBook, &error);
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


- (IBAction)save_click:(id)sender {
    if (nameTF.text.length == 0 || [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [Util showAlertWithString:@"Please enter group name!"];
        return;
    }
    
    NSString *groupname = [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (isAddNew||(!isAddNew && ![nameTF.text isEqualToString:groupItem.groupName])) {
        GroupItem *group = [GroupItem getGroupItemByName:groupname];
        if (group) {
            [Util showAlertWithString:@"This group is existed"];
            return;
        }
    }    
    
    groupItem.groupName = groupname;
    
    [GroupItem updateGroupItem:groupItem];
    if ([groupItem.groupStatus isEqualToString:@"1"]) {
        for (ContactItem *contactItem in contactList) {
            [self deleteContact:contactItem.contactName];
        }
    }
    else
    {
        for (ContactItem *contactItem in contactList) {
            [self creatContact:contactItem];
        }
    }
    //[Util showAlertWithString:@"Saved"];
    
    //[self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)block_click:(id)sender {
    if ([groupItem.groupStatus isEqualToString:@"0"]) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please confirm your passcode to block all contact in this group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
            alert1.tag = 100;
            [alert1 show];
        }
        else
        {
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to block all contacts in this group?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            alert1.tag = 300;
            [alert1 show];
        }
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Please confirm your passcode to unblock all contacts in this group " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert1 setAlertViewStyle:UIAlertViewStylePlainTextInput];
        alert1.tag = 200;
        [alert1 show];
        }
        else
        {
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to unblock all contacts in this group?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            alert1.tag = 400;
            [alert1 show];
        }
    }
    
}

- (IBAction)back_click:(id)sender {
    [self save_click:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
        if ([passcode isEqualToString:[alertView textFieldAtIndex:0].text]) {
            groupItem.groupStatus = @"1";
            if (!isAddNew) {
                [self save_click:nil];
            }
        }
        else
        {
            [Util showAlertWithString:@"Passcode not correct"];
        }
        
    }
    if (alertView.tag == 200 && buttonIndex == 1) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
        if ([passcode isEqualToString:[alertView textFieldAtIndex:0].text]) {
            groupItem.groupStatus = @"0";
            if (!isAddNew) {
                [self save_click:nil];
            }
        }
        else
        {
            [Util showAlertWithString:@"Passcode not correct"];
        }
        
    }
    if (alertView.tag == 300 && buttonIndex == 1) {
        groupItem.groupStatus = @"1";
        if (!isAddNew) {
            [self save_click:nil];
        }
    }
    if (alertView.tag == 400 && buttonIndex == 1) {
        groupItem.groupStatus = @"0";
        if (!isAddNew) {
            [self save_click:nil];
        }
    }
    if ([groupItem.groupStatus isEqualToString:@"0"]) {
        [blockBTn setTitle:@"Block"];
    }
    else
    {
        [blockBTn setTitle:@"Unblock"];
    }
    
}


@end
