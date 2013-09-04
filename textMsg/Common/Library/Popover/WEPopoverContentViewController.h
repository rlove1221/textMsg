//
//  WEPopoverContentViewController.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WEPopoverContentViewControllerDelegate;

@interface WEPopoverContentViewController : UITableViewController
{

}

@property (nonatomic, assign) id <WEPopoverContentViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray *menuList;
@property (nonatomic, retain) NSArray *subtitleList;
@property (nonatomic, retain) NSArray *imageList;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic) float width;
- (void)refreshMenu;
@end

@protocol WEPopoverContentViewControllerDelegate <NSObject>
@optional

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)didSelectMenuAtIndex:(int)index;

@end
