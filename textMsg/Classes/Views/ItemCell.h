//
//  ItemCell.h
//  CountryGrocer
//
//  Created by Jacky Nguyen on 5/13/13.
//  Copyright (c) 2013 teamios. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ItemCellDelegate;
@interface ItemCell : UITableViewCell
- (IBAction)viewDetail_Click:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *itemImageView;
@property (nonatomic, assign) id <ItemCellDelegate> delegate;
@end

@protocol ItemCellDelegate <NSObject>
@optional


- (void)viewItemAtCell:(UITableViewCell *)cell;
@end
