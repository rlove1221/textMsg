//
//  NewGroupViewController.h
//  textMsg
//
//  Created by Jacky on 9/4/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupItem.h"
#import <AddressBook/AddressBook.h>
@interface NewGroupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *contactList;
    IBOutlet UITextField *nameTF;
    IBOutlet UITextField *timeTextField;
    IBOutlet UIBarButtonItem *createBarButton;
    IBOutlet UITableView *contactTableView;
    GroupItem *groupItem;
    NSString *tempUUID;
    
    NSArray *arrayOfPeople;
    ABAddressBookRef addressBook;
    NSMutableArray *allContactsPhoneNumber;
    BOOL accessGranted;
}
- (IBAction)create_Click:(id)sender;
- (IBAction)addContact_Click:(id)sender;
@property(nonatomic,strong)GroupItem *groupItem;
@property(nonatomic)BOOL isAddNew;

@end
