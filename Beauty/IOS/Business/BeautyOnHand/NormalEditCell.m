//
//  NormalEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-6.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "NormalEditCell.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"
#import "DEFINE.h"
#import "NumTextField.h"

@interface NormalEditCell ()

@end

@implementation NormalEditCell
@synthesize titleLabel, valueText, accessoryLabel, nocopyText;
@synthesize numText,tableViewLine,tableViewTopLine;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, kTableView_HeightOfRow/2 - 20.0f/2, 200, 20.0f) title:@"title"];
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.font = kFont_Light_16;
        [self.contentView addSubview:titleLabel];
        
        valueText = [UITextField initNormalTextViewWithFrame:CGRectMake(105.0f, kTableView_HeightOfRow/2 - 30.0f/2, 200, 30.0f) text:@"" placeHolder:@""];
        valueText.textColor = kColor_Editable;
        valueText.font = kFont_Light_16;
        valueText.textAlignment = NSTextAlignmentRight;
        valueText.borderStyle = UITextBorderStyleNone;
        valueText.returnKeyType = UIReturnKeyDone;
        valueText.delegate = self;
        [self.contentView addSubview:valueText];
        
        accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(270.0f, kTableView_HeightOfRow/2 - 20.0f/2, 50.0f, 20.0f) title:@"单位"];
        accessoryLabel.font = kFont_Light_16;
        accessoryLabel.textColor = [UIColor blackColor];
        accessoryLabel.textAlignment = NSTextAlignmentRight;
        accessoryLabel.hidden = YES;
        [self.contentView addSubview:accessoryLabel];
        
        tableViewLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, kTableView_HeightOfRow-0.5, 310, 0.5)];
        tableViewLine.backgroundColor = kTableView_LineColor;
        tableViewLine.hidden = YES;
        [self.contentView addSubview:tableViewLine];
        
        tableViewTopLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310, 0.5)];
        tableViewTopLine.backgroundColor = kTableView_LineColor;
        tableViewTopLine.hidden = YES;
        [self.contentView addSubview:tableViewTopLine];
    }
    return self;
}

- (id)initWithStyleNocopy:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, kTableView_HeightOfRow/2 - 20.0f/2, 200, 20.0f) title:@"title"];
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.font = kFont_Light_16;
        [self.contentView addSubview:titleLabel];
        
        nocopyText = [[noCopyTextField alloc] initWithFrame:CGRectMake(105.0f, kTableView_HeightOfRow/2 - 30.0f/2, 200, 30.0f)];
        [nocopyText setBorderStyle:UITextBorderStyleNone];
        [nocopyText setFont:kFont_Light_16];
        [nocopyText setTextColor:kColor_Editable];
        [nocopyText setText:@""];
        [nocopyText setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [nocopyText setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [nocopyText setPlaceholder:@""];
        [nocopyText setAutoresizingMask:UIViewAutoresizingNone];
        [nocopyText setTextAlignment:NSTextAlignmentRight];
        [nocopyText setBackgroundColor:[UIColor clearColor]];
        nocopyText.returnKeyType = UIReturnKeyDone;
        nocopyText.delegate = self;
        [self.contentView addSubview:nocopyText];
        
        accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(270.0f, kTableView_HeightOfRow/2 - 20.0f/2, 50.0f, 20.0f) title:@"单位"];
        accessoryLabel.font = kFont_Light_16;
        accessoryLabel.textColor = [UIColor blackColor];
        accessoryLabel.textAlignment = NSTextAlignmentRight;
        accessoryLabel.hidden = YES;
        [self.contentView addSubview:accessoryLabel];
    }
    return self;
}

- (id)initWithStyleEditNum:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, kTableView_HeightOfRow/2 - 20.0f/2, 200, 20.0f) title:@"title"];
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.font = kFont_Light_16;
        [self.contentView addSubview:titleLabel];
        
        numText = [[NumTextField alloc] initWithFrame:CGRectMake(105.0f, kTableView_HeightOfRow/2 - 30.0f/2, 200, 30.0f)];
        numText.textColor = kColor_Editable;
        numText.font = kFont_Light_16;
        numText.textAlignment = NSTextAlignmentRight;
        numText.borderStyle = UITextBorderStyleNone;
        numText.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:numText];
        
        accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(270.0f, kTableView_HeightOfRow/2 - 20.0f/2, 50.0f, 20.0f) title:@"单位"];
        accessoryLabel.font = kFont_Light_16;
        accessoryLabel.textColor = [UIColor blackColor];
        accessoryLabel.textAlignment = NSTextAlignmentRight;
        accessoryLabel.hidden = YES;
        [self.contentView addSubview:accessoryLabel];
    }
    return self;
}
- (void)setAccessoryText:(NSString *)accessoryText
{
    if ([accessoryText length] == 0) {
        accessoryLabel.hidden = YES;
        valueText.frame = CGRectMake(105.0f, kTableView_HeightOfRow/2 - 30.0f/2, 200, 30.0f);
        accessoryLabel.frame = CGRectZero;
    } else {
        accessoryLabel.hidden = NO;
        accessoryLabel.text = accessoryText;
        
        CGSize size = [accessoryText sizeWithFont:kFont_Medium_16 constrainedToSize:CGSizeMake(80.0f, 20.0f) lineBreakMode:NSLineBreakByWordWrapping];
        float width = size.width + 4;
        float x = 300.0f - width;
        CGRect acc_rect = accessoryLabel.frame;
        acc_rect.origin.x = x;
        acc_rect.size.width = width;
        accessoryLabel.frame = acc_rect;
        
        CGRect valueText_Rect = valueText.frame;
        valueText_Rect.size.width = 200.0f - width;
        valueText.frame = valueText_Rect;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
