//
//  ViewController.h
//  textMsg
//
//  Created by Richard Morena on 8/31/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import "GroupItem+Custom.h"
@interface MainViewController : UIViewController<MFMessageComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *allContactsPhoneNumber;
    NSArray *groupList;
    IBOutlet UITableView *groupTableView;
    GroupItem *selectedItem;
    BOOL isRemovePass;
}
- (IBAction)edit_click:(id)sender;
- (IBAction)setpass_click:(id)sender;
- (IBAction)creategroup_click:(id)sender;
- (IBAction)viewBlockedList_Click:(id)sender;
@end
