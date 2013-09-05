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
    
    if ([timeTextField.text integerValue] != 0) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        timeInterval +=[timeTextField.text integerValue];
        groupItem.blockTime = [NSString stringWithFormat:@"%f",timeInterval];
    }
    
    groupItem.groupName = groupname;
    groupItem.groupStatus = @"0";
    [GroupItem updateGroupItem:groupItem];
    for (ContactItem *contactItem in contactList) {
        [self deleteContact:contactItem.contactName];
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


@end
