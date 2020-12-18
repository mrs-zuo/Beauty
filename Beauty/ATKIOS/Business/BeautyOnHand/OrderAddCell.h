//
//  OrderAddCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-6.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderAddCellDelegate <NSObject>
- (void)chickAddButton:(UITableViewCell *)cell;
@end

@interface OrderAddCell : UITableViewCell
@property (weak, nonatomic) id<OrderAddCellDelegate> delegate;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *promptLabel;
@property (strong, nonatomic) UIButton *addButton;
@end
