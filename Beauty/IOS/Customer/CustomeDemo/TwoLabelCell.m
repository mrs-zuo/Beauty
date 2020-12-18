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
        if ([reuseIdentifier isEqualToString:@"twoNewCell"] ) {
            titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f,15.0f, 160, kCell_LabelHeight) title:@""];
        }else{
            titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f,15.0f, 100, kCell_LabelHeight) title:@""];
        }
        
        self.backgroundColor = [UIColor whiteColor];
        titleLabel.font = kNormalFont_14;
        titleLabel.textColor = kColor_TitlePink;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        
        valueText = [UITextField initNormalTextViewWithFrame:CGRectMake(120.0f, 15.0f, 190, kCell_LabelHeight) text:@"" placeHolder:@""];
        valueText.font = kNormalFont_14;
        valueText.textColor = kColor_Black;
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
