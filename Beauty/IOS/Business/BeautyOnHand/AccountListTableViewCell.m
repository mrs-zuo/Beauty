//
//  AccountListTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/3.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AccountListTableViewCell.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"
@implementation AccountListTableViewCell
@synthesize titleNameLabel,contentText,priceLable,imageNext;
- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(30.0f, 15.0f, 130.0f, 20.0f) title:@" "];
        titleNameLabel.textColor = [UIColor whiteColor];
        titleNameLabel.font = kFont_Medium_18;
        [[self contentView] addSubview:titleNameLabel];
        
        priceLable = [UILabel initNormalLabelWithFrame:CGRectMake(30.0f, 45.0f, 180.0f, 20.0f) title:@""];
        priceLable.textColor = [UIColor whiteColor];
        priceLable.font = kFont_Light_16;
        [[self contentView]addSubview:priceLable];
        
        
        contentText = [UILabel initNormalLabelWithFrame:CGRectMake(160.0f, 15.0f, 140.0f, 20.0f) title:@" "];
        contentText.textColor = [UIColor whiteColor];
        contentText.font = kFont_Medium_14;
        [contentText setTextAlignment:NSTextAlignmentRight];
        [[self contentView] addSubview:contentText];
        
        imageNext = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-33, 50, 15, 18)];
        imageNext.image = [UIImage imageNamed:@"whiteArrows"];
        [[self contentView]addSubview:imageNext];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
