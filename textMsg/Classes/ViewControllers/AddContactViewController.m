//
//  GroupDetailViewController.m
//  textMsg
//
//  Created by Jacky on 9/4/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import "AddContactViewController.h"

#import "define.h"
#import "ContactItem+Custom.h"
@interface AddContactViewController ()

@end

@implementation AddContactViewController

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
    addressBook = ABAddressBookCreate();
    
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
    if (accessGranted) {
        
        arrayOfPeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        // Do whatever you need with thePeople...
        
    }
    
    NSUInteger index = 0;
    allContactsPhoneNumber = [[NSMutableArray alloc] init];
    actualContactList =[[NSMutableArray alloc] init];
    selectedContactList =[[NSMutableArray alloc] init];
    for(index = 0; index<[arrayOfPeople count]; index++){
        
        ABRecordRef currentPerson =
        (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:index];
        
        
        NSString *name = [self getName:currentPerson];
        //NSArray *phones =        (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(  ABRecordCopyValue(currentPerson, kABPersonPhoneProperty));
        ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(currentPerson, kABPersonPhoneProperty);
        NSString* mobile=@"";
        NSString* imobile=@"";
        NSString* mobileLabel;
        for (int i=0; i < ABMultiValueGetCount(phones); i++) {
            //NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            //NSLog(@"%@", phone);
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if ([mobileLabel isEqualToString:(NSString*)kABPersonPhonePagerLabel]) {
                NSLog(@"pager:");
            }else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMainLabel])
            {
                mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABOtherLabel])
            {
                mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            }else
            if ([mobileLabel isEqualToString:(NSString*)kABHomeLabel])
            {
                mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABWorkLabel])
            {
                mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            }
            	else if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
                NSLog(@"iphone:");
                mobile =(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);;
                imobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                break;
            }
            
            
            
            NSLog(@"%@", mobile);
        }
        NSDictionary *additionDict = [self dictionaryRepresentationForABPerson:currentPerson];
        NSInteger recordID = ABRecordGetRecordID(currentPerson);
        //[[NSUserDefaults standardUserDefaults] setObject:testdict forKey:@"test"];
       // [[NSUserDefaults standardUserDefaults] synchronize];
        // Make sure that the selected contact has one phone at least filled in.
        if (mobile.length > 0) {
            // We'll use the first phone number only here.
            // In a real app, it's up to you to play around with the returned values and pick the necessary value.
            //NSData *contactData = [NSKeyedArchiver archivedDataWithRootObject:(__bridge id)(currentPerson)];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",mobile,@"phone",additionDict,@"additioninfo",[NSNumber numberWithInteger:recordID],@"contactId",[NSNumber numberWithInteger:index],@"index", nil];
            if (imobile.length > 0) {
                dict = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",mobile,@"phone",imobile,@"iphone",additionDict,@"additioninfo",[NSNumber numberWithInteger:recordID],@"contactId",[NSNumber numberWithInteger:index],@"index",nil];
            }
            [allContactsPhoneNumber addObject:dict];
            //[actualContactList addObject:(__bridge id)(currentPerson)];
        }
        else{
            //[allContactsPhoneNumber addObject:@"No phone number was set."];
        }
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    allContactsPhoneNumber = [[allContactsPhoneNumber sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(NSDictionary*) dictionaryRepresentationForABPerson:(ABRecordRef)person
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    for ( int32_t propertyIndex = kABPersonFirstNameProperty; propertyIndex <= kABPersonSocialProfileProperty; propertyIndex ++ )
    {
        NSString* propertyName = (__bridge NSString *)ABPersonCopyLocalizedPropertyName(propertyIndex);
        id value = (__bridge id)(ABRecordCopyValue(person, propertyIndex));
        
        if ( value )
        {
            
            ABMutableMultiValueRef multi = ABRecordCopyValue(person, propertyIndex);
            NSString *stringvalue = (__bridge NSString *)ABRecordCopyValue(person, propertyIndex);
            if ([stringvalue isKindOfClass:[NSString class]] ||[stringvalue isKindOfClass:[NSDate class]] ||[stringvalue isKindOfClass:[NSNumber class]])
            {
                
                [dictionary setObject:value forKey:[NSString stringWithFormat:@"%i",propertyIndex]];
            }

            else
            {
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                
                for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
                    NSString *valueRef = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multi, i);
                    NSString *keyRef = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(multi, i);
                    if (valueRef  && keyRef ) {
                        NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:valueRef,keyRef, nil];
                        [tempArray addObject:tempDict];
                    }
                    else{
                        NSLog(@"nil");
                    }
                    
                    
                }
                if ([tempArray count] > 0) {
                     [dictionary setObject:tempArray forKey:[NSString stringWithFormat:@"%i",propertyIndex]];
                }
             
            }
            
        }
    }
    
    return dictionary;
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
    //self.title = self.groupItem.groupName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allContactsPhoneNumber count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    NSDictionary *contact = [allContactsPhoneNumber objectAtIndex:indexPath.row];
    UILabel *name = (UILabel*)[cell viewWithTag:1];
    UILabel *phone = (UILabel*)[cell viewWithTag:2];
    name.text = [contact objectForKey:@"name"];
    phone.text = [contact objectForKey:@"phone"];
    if ([selectedContactList indexOfObject:contact] != NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //[selectedContactList addObject:[allContactsPhoneNumber objectAtIndex:indexPath.row]];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedContactList addObject:[allContactsPhoneNumber objectAtIndex:indexPath.row]];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedContactList removeObject:[allContactsPhoneNumber objectAtIndex:indexPath.row]];
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)save_click:(id)sender {
    //NSArray *contactList = [ContactItem getAllCGItemByGroupUUID:self.groupItem.groupUUID];
    for (NSDictionary *dict in selectedContactList) {
        NSInteger recordId = [[dict objectForKey:@"contactId"] integerValue];
        int index = [[dict objectForKey:@"index"] intValue];
        ABRecordRef currentPerson =
        (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:index];
        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(currentPerson);
        ContactItem *item = [ContactItem getCGItemById:recordId groupUUID:self.groupItem.groupUUID];
        if (!item) {
            item = [ContactItem newCGItem];
            item.contactName = [dict objectForKey:@"name"];
        }
        item.imageData = imgData;
        item.contactNumber = [dict objectForKey:@"phone"];
        
        item.contactINumber = [dict objectForKey:@"iphone"];
        item.contactId = [dict objectForKey:@"contactId"];
        item.groupUUID = self.groupItem.groupUUID;
        NSDictionary *tempdict = [dict objectForKey:@"additioninfo"];
        NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:tempdict];
        item.contactData = myData;
        //[self deleteContact:item.contactName];
        //item.contactData = [dict objectForKey:@"contactData"];
        [ContactItem updateCGItem:item];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
@end
