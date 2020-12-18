//
//  RechargeAndPayCell.h
//  test1
//
//  Created by macmini on 13-8-15.
//  Copyright (c) 2013年 macmini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PayAndRechargeDoc;;
@interface RechargeAndPayCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *payLabel;
@property (strong, nonatomic) UILabel *balanceLabel;

- (void)updateData:(PayAndRechargeDoc *)payDoc;
@end
