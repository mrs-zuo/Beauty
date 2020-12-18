//
//  SectionView.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/21.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//


#import "SectionView.h"
#import "UIButton+InitButton.h"
#import "SalesPromotionNewViewController.h"

@interface SectionView ()
{
    UILabel *nameLable;
}
@end

@implementation SectionView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}
-(void)setName:(NSString *)name
{
    nameLable.text = name;
}
-(void)setIsMore:(BOOL)isMore
{
    if (isMore) {
        UIButton *btn = [UIButton buttonWithTitle:@"更多>>" target:self selector:@selector(moreClick:) frame:CGRectMake(self.frame.size.width - 60, 8, 60, 30) backgroundImg:nil highlightedImage:nil];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btn.titleLabel.font = kNormalFont_14;
        [self addSubview:btn];
    }
}
- (void)initView
{
    nameLable  = [[UILabel alloc]initWithFrame:CGRectMake(10, 8, 200, 30)];
    nameLable.font = kNormalFont_14;
    [self addSubview:nameLable];
    
}
#pragma mark - 按钮事件
- (void)moreClick:(UIButton *)sender
{
    _moreClick(sender);
}





@end
