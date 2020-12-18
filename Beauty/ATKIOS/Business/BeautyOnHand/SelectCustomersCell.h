//
//  SelectCustomersCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEIGHT_SELECT_CUSTOMERS_CELL 46.0f

@protocol SelectCustomersCellDelegate;

@class UserDoc;
@interface SelectCustomersCell : UITableViewCell
@property (assign, nonatomic) id<SelectCustomersCellDelegate> delegate;
@property (nonatomic) UIImageView *headImageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *accessoryLabel;
@property (nonatomic) UIButton *selectButton;


- (void)updateData:(UserDoc *)userDoc;
@end

@protocol SelectCustomersCellDelegate <NSObject>
- (void)selectCustomersCell:(SelectCustomersCell *)cell touchTheSelectButton:(UIButton *)selectButton;
@end

