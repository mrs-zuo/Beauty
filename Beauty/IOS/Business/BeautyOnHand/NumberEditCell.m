//
//  NumberEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-13.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "NumberEditCell.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"
#import "DEFINE.h"

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
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, kTableView_HeightOfRow/2 - 18.0f/2, 100, 18.0f) title:@"title"];
        titleLabel.textColor = kColor_DarkBlue;
        [self.contentView addSubview:titleLabel];
        
        numberLabel = [[noCopyTextField alloc] init];
        numberLabel.frame = CGRectMake(220.0f, kTableView_HeightOfRow/2 - 18.0f/2, 50, 18.0f);
        numberLabel.textColor = kColor_Editable;
        numberLabel.font = kFont_Light_16;
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.layer.masksToBounds = YES;
        numberLabel.layer.cornerRadius = 5.0f;
        numberLabel.layer.borderColor = [kTableView_LineColor CGColor];
        numberLabel.layer.borderWidth = .5f;
        numberLabel.keyboardType = UIKeyboardTypeNumberPad;
        [self.contentView addSubview:numberLabel];
        
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [leftButton setFrame:CGRectMake(185.0f, kTableView_HeightOfRow/2 - 30.0f/2, 30, 30.0f)];
        [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:leftButton];
        
        rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
        [rightButton setFrame:CGRectMake(275.0f, kTableView_HeightOfRow/2 - 30.0f/2, 30, 30.0f)];
        [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:rightButton];
        
    }
    return self;
}

- (void)leftButtonAction
{
    NSInteger num = [numberLabel.text integerValue];
    if (num < 0) { //num <= 0
        return;
    }
//    if (num < minNum) return; //GPB-922
//    num --;
//    if(num >= 1) //GPB-922
//        numberLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
    
    if ([delegate respondsToSelector:@selector(chickLeftButton:)]) {
        [delegate chickLeftButton:self];
    }
}

- (void)rightButtonAction
{
    NSInteger num = [numberLabel.text integerValue];
    if (num < 0) { //num <= 0
        return;
    }
    
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
