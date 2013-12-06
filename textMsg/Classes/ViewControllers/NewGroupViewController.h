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
#import "WYPopoverController.h"



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
    IBOutlet UIButton *saveBTN;
    IBOutlet UIButton *addBTN;
    IBOutlet UIBarButtonItem *blockBTn;
    BOOL isBack;
    IBOutlet UIBarButtonItem *backButton;
}
- (IBAction)create_Click:(id)sender;
- (IBAction)addContact_Click:(id)sender;
@property(nonatomic,strong)GroupItem *groupItem;
@property(nonatomic)BOOL isAddNew;

@property (nonatomic, retain) WYPopoverController *popGroup;

@property(nonatomic, assign)WYPopoverController *popoverController;
- (IBAction)save_click:(id)sender;
- (IBAction)block_click:(id)sender;
- (IBAction)back_click:(id)sender;


- (void)newGroupBack:(NewGroupViewController *)controller;




@end
