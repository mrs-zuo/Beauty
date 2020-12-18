//
//  TwoLabelCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 13-12-20.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "TwoLabelCell.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"

@implementation TwoLabelCell
@synthesize titleLabel;
@synthesize valueText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5, (kTableView_HeightOfRow - 20)/2, 100, 20) title:@"title"];
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        
        valueText = [UITextField initNormalTextViewWithFrame:CGRectMake(120.0f, (kTableView_HeightOfRow - 20)/2, 185, 20) text:@"" placeHolder:@""];
        valueText.textColor = [UIColor blackColor];
        valueText.textAlignment = NSTextAlignmentRight;
        valueText.borderStyle = UITextBorderStyleNone;
        valueText.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:valueText];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setValue:(NSString *)value isEditing:(BOOL)isEdit
{
    if ([value length] == 0) {
        valueText.hidden = YES;
    } else {
        valueText.hidden = NO;
        valueText.text = value;
        if (isEdit) {
            valueText.textColor = kColor_Editable;
            valueText.userInteractionEnabled = YES;
        } else {
            valueText.textColor = kColor_Black;
            valueText.userInteractionEnabled = NO;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
