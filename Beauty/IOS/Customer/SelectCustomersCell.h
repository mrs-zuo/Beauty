//
//  SelectCustomersCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEIGHT_SELECT_CUSTOMERS_CELL 46.0f

@class UserDoc;

@interface SelectCustomersCell : UITableViewCell
@property (nonatomic) UIImageView *headImageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *accessoryLabel;


- (void)updateData:(UserDoc *)userDoc;

@end

