//
//  ShoppingCartCell.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-15.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol ShoppingCartCellDelegate;

@class CommodityDoc;
@class ShoppingCartViewController;
@class UILabelStrikeThrough;
@class noCopyTextField;

@interface ShoppingCartCell : UITableViewCell<UITextFieldDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) noCopyTextField *quantityTextField;
@property (strong, nonatomic) UILabel *promotionPriceLabel;
@property (strong, nonatomic) UILabelStrikeThrough *priceLabel;
@property (strong, nonatomic) UIButton *stateButton;
@property (assign, nonatomic) id<ShoppingCartCellDelegate> delegate;
@property (weak  , nonatomic) ShoppingCartViewController *shoppingCartViewController;

- (void)updateData:(CommodityDoc *)commodityDoc;
@end

@protocol ShoppingCartCellDelegate <NSObject>
- (void)changeQuantityWithShoppingCartCell:(ShoppingCartCell *)cell;
- (void)whenQuantityOfEmptyWithShoppingCartCell:(ShoppingCartCell *)cell;
@end
