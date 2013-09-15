//
//  BlockedListViewController.m
//  textMsg
//
//  Created by Richard Morena on 9/15/13.
//  Copyright (c) 2013 Richard Morena. All rights reserved.
//

#import "BlockedListViewController.h"
#import "GroupItem+Custom.h"
#import "NewGroupViewController.h"
#import "NSManagedObjectContext+Custom.h"
@interface BlockedListViewController ()

@end

@implementation BlockedListViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [[NSManagedObjectContext managedObjectContext] reset];
    groupList = [GroupItem getGroupByStatus:@"1"];
    [groupTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    
    GroupItem *group = [groupList objectAtIndex:indexPath.row];
    UILabel *name = (UILabel*)[cell viewWithTag:1];
    UILabel *status = (UILabel*)[cell viewWithTag:2];
    name.text = group.groupName;
    if ([group.groupStatus isEqualToString:@"0"]) {
        
        status.text = @"Not blocked";
        status.textColor = [UIColor greenColor];
    }
    else
    {
        status.text = @"Blocked";
        status.textColor = [UIColor redColor];
    }
    
    
    //groupItem.blockTime = [NSString stringWithFormat:@"%.0f",timeInterval/1000];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
        NewGroupViewController *groupDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
        groupDetail.groupItem = [groupList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:groupDetail animated:YES];
    
    
}
@end
