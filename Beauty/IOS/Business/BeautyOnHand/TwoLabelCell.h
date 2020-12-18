//
//  TwoLabelCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 13-12-20.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoLabelCell : UITableViewCell
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextField *valueText;

- (void)setTitle:(NSString *)title;
- (void)setValue:(NSString *)value isEditing:(BOOL)isEdit;
@end
