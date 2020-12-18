//
//  OrderListCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-14.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderListCellDelete;
@class TGList;
@class OrderDoc;
@interface OrderListCell : UITableViewCell
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *accounNameLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *numberLabel;
@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UILabel *customerLabel;
@property (strong, nonatomic) UILabel *totalPriceLabel;
@property (strong, nonatomic) UIButton *selectButton;
@property (strong, nonatomic) UILabel *totalPriceLabel2;
@property (assign, nonatomic) id<OrderListCellDelete> delegate;
@property (strong, nonatomic) UILabel *shopName;
@property (strong, nonatomic) UILabel *stateCurrentLabel;
- (void)updateData:(OrderDoc *)orderDoc;
- (void)updateData:(OrderDoc *)orderDoc andTGList:(TGList*)tgList;
- (id)initWithStyleAlignRight:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end

@protocol OrderListCellDelete <NSObject>
- (void)selectedTheOrderListCell:(OrderListCell *)cell;
@end
