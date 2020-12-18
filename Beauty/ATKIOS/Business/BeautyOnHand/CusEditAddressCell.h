//
//  CusEditAddressCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerEditDelegate.h"

@class noCopyTextField;
@class AddressDoc;
@class UIPlaceHolderTextView;
@interface CusEditAddressCell : UITableViewCell

@property (weak, nonatomic) id<CustomerEditDelegate> delegate;

@property (strong, nonatomic) UITextField *zipText;
@property (strong, nonatomic) UIPlaceHolderTextView *adrsText;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) noCopyTextField *typeText;

- (void)updateData:(AddressDoc *)address;
- (void)canEdit:(BOOL)editable;

@end
