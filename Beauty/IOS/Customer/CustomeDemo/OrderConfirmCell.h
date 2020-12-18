//
//  OrderConfirmCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-6.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderDoc;
@class OrderConfirmCell;

@protocol OrderConfirmCellDelegate <NSObject>
- (void)selectedTheOrderConfirmListCell:(OrderConfirmCell *)cell;
@end

@interface OrderConfirmCell : UITableViewCell
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *accounNameLabel;
@property (strong, nonatomic) UILabel *numberLabel;
@property (strong, nonatomic) UILabel *totalNumberLabel;
@property (strong, nonatomic) UIButton *selectButton;
@property (assign, nonatomic) id<OrderConfirmCellDelegate> delegate;

- (void)updateData:(OrderDoc *)orderDoc;
@end
