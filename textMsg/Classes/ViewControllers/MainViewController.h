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
@interface MainViewController : UIViewController<MFMessageComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *allContactsPhoneNumber;
    NSArray *groupList;
    IBOutlet UITableView *groupTableView;
    
    
}
- (IBAction)setpass_click:(id)sender;
- (IBAction)creategroup_click:(id)sender;
@end
