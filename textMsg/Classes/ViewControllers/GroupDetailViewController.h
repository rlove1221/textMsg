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
@interface GroupDetailViewController : UIViewController
{
    IBOutlet UIBarButtonItem *addContactBarButton;
    
}
@property(nonatomic,strong)GroupItem *groupItem;
@end
