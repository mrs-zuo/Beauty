//
//  OrderContactCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-12.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderEditViewController.h"

@class ContactDoc;
@class OrderEditViewController;
@interface OrderContactCell : UITableViewCell<UITextFieldDelegate>
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextField *dateText;
@property (nonatomic) UIButton *deleteBtn;

@property (weak, nonatomic) id <OrderDateCellDelete> delegate;
@property (weak, nonatomic) OrderEditViewController *orderEditViewController;

- (void)updateData:(ContactDoc *)contactDoc canEdited:(BOOL)edited;
@end

