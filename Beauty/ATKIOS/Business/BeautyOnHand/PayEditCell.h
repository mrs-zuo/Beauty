//
//  PayEditCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-12.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PayEditCellDelete <NSObject>
- (void)chickSelectionBtnWithCell:(UITableViewCell *)cell;
@end

@interface PayEditCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleNameLabel;
@property (strong, nonatomic) UITextField *contentText;
@property (strong, nonatomic) UIButton *payButton;
@property (assign, nonatomic) id<PayEditCellDelete> delegate;

@end
