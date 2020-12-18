//
//  NormalEditCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-9-6.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

//cell格式为: titleLabel + textField + [accessoryLabel]

#import <UIKit/UIKit.h>

@interface NormalEditCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *valueText;
@property (strong, nonatomic) UILabel *accessoryLabel;


- (void)setTitle:(NSString *)title;
- (void)setValue:(NSString *)value isEditing:(BOOL)isEdit;
- (void)setAccessoryText:(NSString *)accessoryText;
@end
