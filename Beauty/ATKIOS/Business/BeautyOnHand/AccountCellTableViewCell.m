//
//  AccountCellTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AccountCellTableViewCell.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"

@implementation AccountCellTableViewCell
@synthesize titleNameLabel,contentText;

- (void)awakeFromNib {
    // Initialization code
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 9.0f, 130.0f, 20.0f) title:@" "];
        titleNameLabel.textColor = kColor_DarkBlue;
        titleNameLabel.font = kFont_Medium_16;
        [[self contentView] addSubview:titleNameLabel];
        
        contentText = [UILabel initNormalLabelWithFrame:CGRectMake(140.0f, 3.0f, 150.0f, 32.0f) title:@" "];
        contentText.textColor = [UIColor blackColor];
        contentText.font = kFont_Light_16;
        [contentText setTextAlignment:NSTextAlignmentRight];
        [[self contentView] addSubview:contentText];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
