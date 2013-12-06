//
//  BlockedListViewController.h
//  textMsg
//
//  Created by Richard Morena on 9/15/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupItem+Custom.h"
#import "WYPopoverController.h"




@interface BlockedListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
    NSArray *groupList1;
    GroupItem *selectedItem;
    IBOutlet UITableView *groupTableView;
    BOOL isBack;

    IBOutlet UIBarButtonItem *backButton;
}
@property (nonatomic, retain) WYPopoverController *blockGroup;
@property(nonatomic, assign)WYPopoverController *popoverController;






- (IBAction)edit_click:(id)sender;

- (IBAction)back_click:(id)sender;

//- (void)blockBack:(BlockedListViewController *)controller;

@end
