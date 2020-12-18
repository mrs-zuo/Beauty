//
//  RechargeEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RechargeEditCell.h"
#import "UITextField+InitTextField.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"

@implementation RechargeEditCell

@synthesize titleNameLabel,contentText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 9.0f, 140.0f, 20.0f) title:@"--"];
        [titleNameLabel setFont:kFont_Light_16];
        [[self contentView] addSubview:titleNameLabel];
        
        contentText = [UITextField initNormalTextViewWithFrame:CGRectMake(160.0f, 3.0f, 140.0f, 32.0f) text:@"" placeHolder:@""];
        [contentText setTextAlignment:NSTextAlignmentRight];
        [[self contentView] addSubview:contentText];
        
        _arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
        _arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        _arrowsImage.hidden = YES;
        [[self contentView]  addSubview:_arrowsImage];
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
