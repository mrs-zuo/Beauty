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
        
        UIView * redView = [[UIView alloc] initWithFrame:CGRectMake(0, 17, 308, 85)];
        redView.backgroundColor = [UIColor colorWithRed:239/255. green:19/255. blue:98/255. alpha:1.];
        redView.layer.cornerRadius = 8 ;
        [self.contentView addSubview:redView];
        
        UIView * whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 308, 100)];
        whiteView.backgroundColor = [UIColor whiteColor];
        whiteView.layer.cornerRadius = 8 ;
        [self.contentView addSubview:whiteView];
        
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 12.0f, 130.0f, 20.0f) title:@""];
        titleNameLabel.font = kNormalFont_14;
        titleNameLabel.textColor = [UIColor blackColor];
        [titleNameLabel setTextAlignment:NSTextAlignmentLeft];
        [[self contentView] addSubview:titleNameLabel];
        
        priceLable = [UILabel initNormalLabelWithFrame:CGRectMake(90.0f, 70.0f, 200.0f, 20.0f) title:@""];
        priceLable.font = kNormalFont_14;
        priceLable.textAlignment = NSTextAlignmentRight;
        priceLable.textColor = [UIColor colorWithRed:254/255. green:133/255. blue:0/255. alpha:1.];
        [[self contentView]addSubview:priceLable];
        
        
        contentText = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 45.0f, 140.0f, 20.0f) title:@" "];
        contentText.font = kNormalFont_14;
        [contentText setTextAlignment:NSTextAlignmentLeft];
        contentText.textColor =kColor_Editable;
        [[self contentView] addSubview:contentText];
        
//        imageNext = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-33, 50, 15, 18)];
//        imageNext.image = [UIImage imageNamed:@"arrows_bg"];
//        [[self contentView]addSubview:imageNext];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
