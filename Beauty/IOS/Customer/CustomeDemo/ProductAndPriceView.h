//
//  ProductAndPriceView.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberEditCell.h"
#import "ProductAndPriceDoc.h"

@protocol ProductAndPriceViewDelegate;

@class ProductAndPriceDoc;
@interface ProductAndPriceView : UIView <UITableViewDataSource, UITableViewDelegate, NumberEditCellDelegate, UITextFieldDelegate>
@property (assign, nonatomic) id <ProductAndPriceViewDelegate> delegate;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) ProductAndPriceDoc *theProductAndPriceDoc;
@property (assign, nonatomic) BOOL canEditeQuantityAndPrice;

- (void)dismissKeyboard;
@end

@protocol ProductAndPriceViewDelegate <NSObject>
- (void)changeHeightOfProductAndPriceView;
- (void)addOneProductInProductAndPriceView:(ProductAndPriceView *)productAndPriceView;
- (void)reduceOneProductInProductAndPriceView:(ProductAndPriceView *)productAndPriceView;
- (void)changeQuantity:(int)changedQuantity productAndPriceView:(ProductAndPriceView *)productAndPriceView;
@end
