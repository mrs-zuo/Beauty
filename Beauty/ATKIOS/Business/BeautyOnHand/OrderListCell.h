//
//  OrderListCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-14.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderListCellDelete;

@class OrderDoc;
@interface OrderListCell : UITableViewCell
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *ProductNameLabel;
@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UILabel *numberLabel;
//@property (strong, nonatomic) UILabel *UserNameLabel;
@property (strong, nonatomic) UILabel *PersonNameLabel;
@property (strong, nonatomic) UILabel *totalPriceLabel;
@property (strong, nonatomic) UIButton *selectButton;

@property (assign, nonatomic) id<OrderListCellDelete> delegate;

- (id)initWithStyleAlignRight:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)updateData:(OrderDoc *)orderDoc;
@end

@protocol OrderListCellDelete <NSObject>
- (void)selectedTheOrderListCell:(OrderListCell *)cell;
@end
