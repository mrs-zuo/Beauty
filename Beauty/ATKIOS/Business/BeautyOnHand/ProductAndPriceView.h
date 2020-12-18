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
@property (assign, nonatomic) id<ProductAndPriceViewDelegate> delegate;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) ProductAndPriceDoc *theProductAndPriceDoc;
@property (assign, nonatomic) BOOL canEditeQuantityAndPrice;
@property (nonatomic, assign) BOOL canEditPriceInOrderDetail;
- (void)dismissKeyboard;
@end

@protocol ProductAndPriceViewDelegate <NSObject>
- (void)changeHeightOfProductAndPriceView;

@optional
- (void)changeOrderPrice;
- (void)addOneProductInProductAndPriceView:(ProductAndPriceView *)productAndPriceView;
- (void)reduceOneProductInProductAndPriceView:(ProductAndPriceView *)productAndPriceView;
@end
