//
//  BlockedListViewController.h
//  textMsg
//
//  Created by Richard Morena on 9/15/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupItem+Custom.h"
@interface BlockedListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *groupList;
    GroupItem *selectedItem;
    IBOutlet UITableView *groupTableView;
}
- (IBAction)edit_click:(id)sender;

@end
