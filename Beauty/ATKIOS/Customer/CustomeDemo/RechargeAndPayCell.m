//
//  RechargeAndPayCell.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-20.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "RechargeAndPayCell.h"

@implementation RechargeAndPayCell

@synthesize titleNameLabel,contentText,dateLabelForChargeAndPay,dateLabel,balanceLabel;
@synthesize titleImage,contentImage,balabceImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        titleNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 1.0f, 203.0f, 30.0f)];
        [titleNameLabel setText:@"title_name"];
        [titleNameLabel setFont:kFont_Light_18];
        [titleNameLabel setTextAlignment:NSTextAlignmentLeft];
        [titleNameLabel setAutoresizingMask:UIViewAutoresizingNone];
        [titleNameLabel setBackgroundColor:[UIColor clearColor]];
        [titleNameLabel setContentMode:UIViewContentModeCenter];
        [[self contentView] addSubview:titleNameLabel];
        
        contentText = [[UILabel alloc] initWithFrame:CGRectMake(195.0f, 8.0f, 85.0f, 20.0f)];
        [contentText setFont:kFont_Light_16];
        [contentText setAutoresizingMask:UIViewAutoresizingNone];
        [contentText setTextAlignment:NSTextAlignmentRight];
        [contentText setBackgroundColor:[UIColor clearColor]];
        [[self contentView] addSubview:contentText];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 30.0f, 140.0f, 20.0f)];
        [dateLabel setText:@"2012-07-20 15:30"];
        [dateLabel setFont:kFont_Light_14];
        [dateLabel setTextAlignment:NSTextAlignmentLeft];
        [dateLabel setAutoresizingMask:UIViewAutoresizingNone];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setContentMode:UIViewContentModeCenter];
        [dateLabel setTextColor:kColor_Editable];
        [[self contentView] addSubview:dateLabel];
        
        balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 140.0f, 20.0f)];
        [balanceLabel setFont:kFont_Light_16];
        [balanceLabel setTextAlignment:NSTextAlignmentRight];
        [balanceLabel setAutoresizingMask:UIViewAutoresizingNone];
        [balanceLabel setBackgroundColor:[UIColor clearColor]];
        [balanceLabel setContentMode:UIViewContentModeCenter];
        [[self contentView] addSubview:balanceLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

