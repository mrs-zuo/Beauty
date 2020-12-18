//
//  RechargeCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-14.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RechargeCell.h"
#import "UITextField+InitTextField.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"

@implementation RechargeCell
@synthesize titleNameLabel, contentText, yuanLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(13.0f, 13.0f, 80.0f, 20.0f) title:@""];
        [titleNameLabel setTextColor:kColor_DarkBlue];
        [titleNameLabel setTextAlignment:NSTextAlignmentLeft];
        [[self contentView] addSubview:titleNameLabel];
        
        contentText = [UITextField initNormalTextViewWithFrame:CGRectMake(155.0f, 4.0f, 120.0f, 30.0f) text:@"" placeHolder:@""];
        [contentText setBorderStyle:UITextBorderStyleRoundedRect];
        [contentText setKeyboardType:UIKeyboardTypeDecimalPad];
        [contentText setTextAlignment:NSTextAlignmentRight];
        [[self contentView] addSubview:contentText];
        
        yuanLabel = [UILabel initNormalLabelWithFrame:CGRectMake(280.0f, 9.0f, 40.0f, 20.0f) title:@"元"];
        [[self contentView] addSubview:yuanLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
