//
//  NormalEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-9-6.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "NormalEditCell.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"


@interface NormalEditCell ()

@end

@implementation NormalEditCell
@synthesize titleLabel, valueText, accessoryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
            if ([reuseIdentifier  isEqual: @"CellNew"]) {
                titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, (kTableView_DefaultCellHeight - kLabel_DefaultHeight) / 2 , 120, kLabel_DefaultHeight) title:@"title"];
                valueText = [UITextField initNormalTextViewWithFrame:CGRectMake(130, (kTableView_DefaultCellHeight - kLabel_DefaultHeight) / 2, kSCREN_BOUNDS.size.width - 120 - 10 - 10 - 10, kLabel_DefaultHeight) text:@"" placeHolder:@""];
                
                }else{
                    titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f,(kTableView_DefaultCellHeight - kLabel_DefaultHeight) / 2 , 120, kLabel_DefaultHeight) title:@"title"];
                    valueText = [UITextField initNormalTextViewWithFrame:CGRectMake(140,(kTableView_DefaultCellHeight - kLabel_DefaultHeight) / 2, kSCREN_BOUNDS.size.width - 120 - 10 - 10 - 10, kLabel_DefaultHeight) text:@"" placeHolder:@""];
                }
        titleLabel.font = kNormalFont_14;
        titleLabel.textColor = kColor_TitlePink;
        [self.contentView addSubview:titleLabel];
        
        valueText.font = kNormalFont_14;
        valueText.textColor = kColor_Editable;
        valueText.textAlignment = NSTextAlignmentRight;
        valueText.borderStyle = UITextBorderStyleNone;
        valueText.tintColor=[UIColor blueColor];
        valueText.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:valueText];
        
        accessoryLabel.font = kNormalFont_14;
        accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(270.0f, (kTableView_DefaultCellHeight - kLabel_DefaultHeight) / 2, 55.0f, kLabel_DefaultHeight) title:@"单位"];
        accessoryLabel.textColor = kColor_Black;
        accessoryLabel.textAlignment = NSTextAlignmentRight;
        accessoryLabel.hidden = YES;
        [self.contentView addSubview:accessoryLabel];
        
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
            valueText.textColor = [UIColor blackColor];
            valueText.userInteractionEnabled = NO;
        }
    }
}

- (void)setAccessoryText:(NSString *)accessoryText
{
    if ([accessoryText length] == 0) {
        accessoryLabel.hidden = YES;
        valueText.frame = CGRectMake(130.0f, (kTableView_DefaultCellHeight - kLabel_DefaultHeight) / 2, kSCREN_BOUNDS.size.width - 130 - 10 - 10 - 10, kLabel_DefaultHeight);
        accessoryLabel.frame = CGRectZero;
    } else {
        accessoryLabel.hidden = NO;
        accessoryLabel.text = accessoryText;
        
        CGSize size = [accessoryText sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(80.0f, 20.0f) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat width = size.width + 4;
        CGFloat x = 300.0f - width;
        CGRect acc_rect = accessoryLabel.frame;
        acc_rect.origin.x = x;
        acc_rect.size.width = width;
        accessoryLabel.frame = acc_rect;
        
        CGRect valueText_Rect = valueText.frame;
        valueText_Rect.size.width = 180.0f - width;
        valueText.frame = valueText_Rect;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
