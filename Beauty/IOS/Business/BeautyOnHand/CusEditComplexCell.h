//
//  ComplexEditCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-13.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerEditDelegate.h"

@class noCopyTextField;
@interface CusEditComplexCell : UITableViewCell
@property (weak, nonatomic) id<CustomerEditDelegate> delegate;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) noCopyTextField *typeText;
@property (strong, nonatomic) UITextField *contentText;
@property (strong, nonatomic) UIButton *deleteButton;

- (void)canEdit:(BOOL)editable;
@end
