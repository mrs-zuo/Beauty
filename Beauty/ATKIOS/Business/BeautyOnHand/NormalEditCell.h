//
//  NormalEditCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-6.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

//cell格式为: titleLabel + textField + [accessoryLabel]

#import <UIKit/UIKit.h>
#import "noCopyTextField.h"
//#import "NumTextField.h"
@class NumTextField;

@interface NormalEditCell : UITableViewCell <UITextFieldDelegate>

@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UITextField *valueText;
@property (strong,nonatomic) UILabel *accessoryLabel;
@property (strong, nonatomic) noCopyTextField *nocopyText;
@property (nonatomic, strong) NumTextField *numText;
@property (nonatomic,strong) UIView * tableViewLine;
@property (nonatomic,strong) UIView * tableViewTopLine;

- (id)initWithStyleNocopy:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithStyleEditNum:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setAccessoryText:(NSString *)accessoryText;
@end
