//
//  GroupDetailViewController.m
//  textMsg
//
//  Created by Jacky on 9/4/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import "GroupDetailViewController.h"
#import <AddressBook/AddressBook.h>
#import "define.h"
@interface GroupDetailViewController ()

@end

@implementation GroupDetailViewController

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
	[super viewDidLoad];
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
    self.title = self.groupItem.groupName;
    contactList = [ContactItem getAllCGItemByGroupUUID:self.groupItem.groupUUID];
    [contactTableView reloadData];
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

- (IBAction)addcontact_Click:(id)sender {
    
    NSMutableArray *menuList = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *subMenulist = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSDictionary *dict in allContactsPhoneNumber) {
        [menuList addObject:[dict objectForKey:@"name"]];
        [subMenulist addObject:[dict objectForKey:@"phone"]];
    }
    WEPopoverContentViewController *contentViewController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
    contentViewController.delegate = self;
    contentViewController.menuList = menuList;
    contentViewController.subtitleList = subMenulist;
    contentViewController.width = 250;
    popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController] ;
    [contentViewController.tableView setScrollEnabled:YES];
    [contentViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [contentViewController.tableView setShowsVerticalScrollIndicator:NO];
    popoverController.delegate = self;
    popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
    
    //		[popoverController presentPopoverFromBarButtonItem:sender
    //                                  permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
    //                                                  animated:YES];
    [popoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}
- (void)didSelectMenuAtIndex:(int)index
{
    NSDictionary *dict = [allContactsPhoneNumber objectAtIndex:index];
    ContactItem *contact = [ContactItem checkCGItemByName:[dict objectForKey:@"name"] groupUUID:self.groupItem.groupUUID];
    if (contact) {
        [Util showAlertWithString:@"This contact is existed"];
        return;
    }
    contact = [ContactItem newCGItem];

    contact.contactName = [dict objectForKey:@"name"];
    contact.contactNumber = [dict objectForKey:@"phone"];
    contact.groupUUID = self.groupItem.groupUUID;
    [ContactItem updateCGItem:contact];
    [popoverController dismissPopoverAnimated:YES];
    [self viewWillAppear:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}


@end
