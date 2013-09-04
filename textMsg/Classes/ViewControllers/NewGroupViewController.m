//
//  NewGroupViewController.m
//  textMsg
//
//  Created by Jacky on 9/4/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import "NewGroupViewController.h"

#import "GroupItem+Custom.h"
#import "define.h"
@interface NewGroupViewController ()

@end

@implementation NewGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)create_Click:(id)sender {
    if (nameTF.text.length == 0 || [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [Util showAlertWithString:@"Please enter group name!"];
        return;
    }
    NSString *groupname = [nameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    GroupItem *group = [GroupItem getGroupItemByName:groupname];
    if (group) {
        [Util showAlertWithString:@"This group is existed"];
        return;
    }
    group = [GroupItem newGroupItem];
    group.groupUUID = [Util GetUUID];
    group.groupName = groupname;
    group.groupStatus = @"0";
    [GroupItem updateGroupItem:group];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
