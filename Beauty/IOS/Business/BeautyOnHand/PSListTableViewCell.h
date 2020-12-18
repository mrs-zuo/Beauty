//
//  PSListTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MidLineLabel.h"
#import "DEFINE.h"

@protocol PSListTableViewCellDelegate;

@interface PSListTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *newbrandImgView;
@property (strong, nonatomic) UIImageView *recommendImgView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *favoriteImageView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *priceCategoryImageView;
@property (strong, nonatomic) MidLineLabel *unitePriceLabel;
@property (strong, nonatomic) UILabel *promotionPriceLabel;

@property (strong, nonatomic) UIButton *selectedButton;

@property (assign, nonatomic) id<PSListTableViewCellDelegate> delegate;
@end


@protocol PSListTableViewCellDelegate <NSObject>
- (void)didSelectedButtonInCell:(PSListTableViewCell *)cell;
@end
