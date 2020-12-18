//
//  MerchantEditCell.m
//  merNew
//
//  Created by MAC_Lion on 13-7-25.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "MerchantEditCell.h"
#import "DEFINE.h"

@implementation MerchantEditCell
@synthesize titleNameLabel, contentText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 12.0f, 60.0f, 20.0f)];
        [titleNameLabel setText:@"titleName"];
        [titleNameLabel setFont:kFont_Light_16];
        [titleNameLabel setTextAlignment:NSTextAlignmentRight];
        [titleNameLabel setAutoresizingMask:UIViewAutoresizingNone];
        [titleNameLabel setBackgroundColor:[UIColor clearColor]];
        [[self contentView] addSubview:titleNameLabel];
        
        contentText = [[UITextView alloc] initWithFrame:CGRectMake(80.0f, 6.0f, 220.0f, 32.0f)];
        [contentText setFont:kFont_Light_16];
        [contentText setAutoresizingMask:UIViewAutoresizingNone];
        [contentText setTextAlignment:NSTextAlignmentLeft];
        [contentText setBackgroundColor:[UIColor clearColor]];
        [contentText setShowsHorizontalScrollIndicator:NO];
        [contentText setShowsVerticalScrollIndicator:NO];
        
        contentText.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        contentText.layer.borderWidth = 0.8f;
        contentText.layer.masksToBounds = YES;
        contentText.layer.cornerRadius = 5.0f;
        [[self contentView] addSubview:contentText];
    }
    return self;
}

- (void)setShowTextViewBoard
{
    [contentText setEditable:YES];
    contentText.layer.masksToBounds = YES;
    contentText.layer.cornerRadius = 3.0f;
    contentText.layer.borderWidth = 0.8f;
    contentText.layer.borderColor = [[UIColor colorWithRed:91.0f/255.0f green:195.0f/255.0f blue:255.0f/255.0f alpha:1.0f] CGColor];
    contentText.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    contentText.layer.shadowOpacity = 0.5f;
    contentText.layer.shadowRadius = 3.0f;
    contentText.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
