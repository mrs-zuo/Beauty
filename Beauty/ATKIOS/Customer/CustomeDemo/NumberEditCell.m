//
//  NumberEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-13.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "NumberEditCell.h"
#import "UILabel+InitLabel.h"

@implementation NumberEditCell
@synthesize titleLabel, numberLabel, leftButton, rightButton;
@synthesize delegate;
@synthesize maxNum, minNum;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        maxNum = 30;
        minNum = 0;
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, kTableView_HeightOfRow/2 - 18.0f/2, 100, 18.0f) title:@"title"];
        titleLabel.textColor = kColor_TitlePink;
        [self.contentView addSubview:titleLabel];
        
        numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(230.0f, kTableView_HeightOfRow/2 - 18.0f/2, 40, 18.0f) title:@"0"];
        numberLabel.textColor = kColor_Editable;
        numberLabel.font = kFont_Light_16;
        numberLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:numberLabel];
        
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [leftButton setFrame:CGRectMake(200.0f, kTableView_HeightOfRow/2 - 30.0f/2, 30, 30.0f)];
        [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:leftButton];
        
        rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
        [rightButton setFrame:CGRectMake(270.0f, kTableView_HeightOfRow/2 - 30.0f/2, 30, 30.0f)];
        [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:rightButton];
    }
    return self;
}

- (void)leftButtonAction
{
    NSInteger num = [numberLabel.text integerValue];
    if (num <= minNum) return;
    num --;
    numberLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
    
    if ([delegate respondsToSelector:@selector(chickLeftButton:)]) {
        [delegate chickLeftButton:self];
    }
}

- (void)rightButtonAction
{
    NSInteger num = [numberLabel.text integerValue];
    if (num >= maxNum) return;
    num ++;
    numberLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
    
    if ([delegate respondsToSelector:@selector(chickRightButton:)]) {
        [delegate chickRightButton:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
