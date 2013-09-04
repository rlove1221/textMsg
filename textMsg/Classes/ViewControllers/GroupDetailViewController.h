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
@interface GroupDetailViewController : UIViewController<WEPopoverControllerDelegate,WEPopoverContentViewControllerDelegate>
{
    WEPopoverController *popoverController;
    IBOutlet UIBarButtonItem *addContactBarButton;
    NSMutableArray *allContactsPhoneNumber;
    NSArray *contactList;
    IBOutlet UITableView *contactTableView;
}

- (IBAction)addcontact_Click:(id)sender;
@property(nonatomic,strong)GroupItem *groupItem;
@end
