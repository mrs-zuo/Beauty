//
//  SalesProcessCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "SalesProgressCell.h"
#import "OpportunityDoc.h"
#import "DEFINE.h"

@interface SalesProgressCell ()
@property (assign, nonatomic) NSInteger progress_Previous;
@property (assign, nonatomic) NSInteger progress_Total;
@end

@implementation SalesProgressCell
@synthesize progress_Previous;
@synthesize progress_Total;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 11.0f, 40.0f, 21.0f)];
        [titleLabel setText:@"进度"];
        [titleLabel setFont:kFont_Light_16];
        [titleLabel setTextColor:kColor_DarkBlue];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:titleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateData:(OpportunityDoc *)opportunityDoc
{
    float _wigth = 140.0f;
    float _height = 40.0f;
    float _y = 30.0f;
    float _x = 90.0f;
    
    NSArray *stepArray = [opportunityDoc.opp_StepContent componentsSeparatedByString:@"|"];
    progress_Previous = opportunityDoc.opp_Progress;
    progress_Total = [stepArray count];
    
    for (int i=0; i< [stepArray count]; i++)
    {
        float y = _y + _height * i;
        UIButton *tempBtn = nil;
        NSString *content = [stepArray objectAtIndex:i];
        
        tempBtn = [self addStepButtonWithTitle:content rect:CGRectMake(_x, y, _wigth, _height)];
        tempBtn.tag = i + 1;
        
        int index = i + 1;
        if (index <= opportunityDoc.opp_Progress) {
            [tempBtn setSelected:YES];
            [self setBackgroundImageWhenButtonIsSelected:index];
        } else if (index > opportunityDoc.opp_Progress) {
            [self setBackgroundImageWhenButtonIsDisSelected:index];
        }
    }
}

- (void)setBackgroundImageWhenButtonIsSelected:(NSInteger)index
{
    UIButton *button = (UIButton *)[self viewWithTag:index];
    if (index == 1) {
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Blue_Start"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Blue_Start"] forState:UIControlStateSelected];
    } else if (index == progress_Total) {
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Blue_End"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Blue_End"] forState:UIControlStateSelected];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Blue_Normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Blue_Normal"] forState:UIControlStateSelected];
    }
}

- (void)setBackgroundImageWhenButtonIsDisSelected:(NSInteger)index
{
    UIButton *button = (UIButton *)[self viewWithTag:index];
    if (index == 1) {
    } else if (index == progress_Total) {
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Gray_End"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Gray_End"] forState:UIControlStateSelected];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Gray_Normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"progress_Gray_Normal"] forState:UIControlStateSelected];
    }
}

- (UIButton *)addStepButtonWithTitle:(NSString *)title rect:(CGRect)rect
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:rect];
    [button setTitle:nil forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:NSTextAlignmentRight];
    [button addTarget:self action:@selector(chickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 10.0f, 80.0f, 20.0f)];
    [titleLabel setText:title];
    [titleLabel setFont:kFont_Light_16];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [button addSubview:titleLabel];
    return button;
}

- (void)chickButton:(id)sender
{
    UIButton *selectedBtn = (UIButton *)sender;
    NSInteger tag = selectedBtn.tag;
    
    //  修改Button背景
    [self changeButtonBackgroundImageWithPrevious:progress_Previous newIndex:tag];
    
    // 点击后的事件
    [self performSelector:@selector(chickStepButtonEventWithIndex:) withObject:[NSString stringWithFormat:@"%ld", (long)tag] afterDelay:0.3];
    progress_Previous = tag;
}

- (void)changeButtonBackgroundImageWithPrevious:(NSInteger)previous newIndex:(NSInteger)newIndex
{
    if (previous > newIndex) {
        for (NSInteger i = previous; i > newIndex; i--){
            [self setBackgroundImageWhenButtonIsDisSelected:i];
        }
    } else if (previous == newIndex) {
    
    } else {
        for (NSInteger i=previous; i <=newIndex; i++){
             [self setBackgroundImageWhenButtonIsSelected:i];
        }
    }
}

- (void)chickStepButtonEventWithIndex:(NSString *)index
{
    if ([delegate respondsToSelector:@selector(chickStepButtonWithIndex:)]) {
        [delegate chickStepButtonWithIndex:[index intValue]];
    }
}

@end
