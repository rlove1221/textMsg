//
//  BlockedListViewController.h
//  textMsg
//
//  Created by Richard Morena on 9/15/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockedListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *groupList;
    IBOutlet UITableView *groupTableView;
}

@end
