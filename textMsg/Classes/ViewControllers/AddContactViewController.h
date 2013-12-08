//
//  GroupDetailViewController.h
//  textMsg
//
//  Created by Jacky on 9/4/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"
#import "WEPopoverContentViewController.h"
#import "GroupItem+Custom.h"
#import "ContactItem+Custom.h"
#import <AddressBook/AddressBook.h>
@interface AddContactViewController : UIViewController<WEPopoverControllerDelegate,WEPopoverContentViewControllerDelegate>
{
    WEPopoverController *popoverController;
    IBOutlet UIBarButtonItem *addContactBarButton;
    NSMutableArray *allContactsPhoneNumber;
    NSArray *contactList;
    IBOutlet UITableView *contactTableView;
    NSMutableArray *actualContactList;
    NSMutableArray *selectedContactList;
    NSArray *arrayOfPeople;
    ABAddressBookRef addressBook;
}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveClick;

- (IBAction)addcontact_Click:(id)sender;
- (IBAction)save_click:(id)sender;
@property(nonatomic,strong)GroupItem *groupItem;
@end
