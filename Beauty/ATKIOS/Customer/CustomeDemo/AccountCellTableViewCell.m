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
@synthesize titleNameLabel,contentText,arrowsImage;

- (void)awakeFromNib {
    // Initialization code
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 15.0, 130.0f, kLabel_DefaultHeight) title:@" "];
        titleNameLabel.textColor = kColor_TitlePink;
        titleNameLabel.font = kNormalFont_14;
        [[self contentView] addSubview:titleNameLabel];
        
        contentText = [UILabel initNormalLabelWithFrame:CGRectMake(145.0f, 15.0, 150.0f, kLabel_DefaultHeight) title:@" "];
        contentText.textColor = [UIColor blackColor];
        contentText.font = kNormalFont_14;
        [contentText setTextAlignment:NSTextAlignmentRight];
        [[self contentView] addSubview:contentText];
        
        arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(300,18, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [[self contentView] addSubview:arrowsImage];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
