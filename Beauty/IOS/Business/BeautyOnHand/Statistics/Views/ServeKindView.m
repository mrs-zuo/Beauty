//
//  ServeKindView.m
//  GlamourPromise.Beauty.Business
//
//  Created by Bizapper VM MacOS  on 15/11/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#define kPercentageView_Width 10
#define kPercentageView_Hight 10


#import "ServeKindView.h"

@interface ServeKindView ()
{
    UILabel *nameLab;
    UILabel *percentageLab;
    UIView  *percentageView;
}
@end


@implementation ServeKindView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
       
        percentageView = [[UIView alloc]initWithFrame:CGRectMake(5, 0, kPercentageView_Width, kPercentageView_Hight)];
        [self addSubview:percentageView];
        
        percentageLab = [[UILabel alloc]initWithFrame:CGRectMake(5 + kPercentageView_Width + 5, 0,50, kPercentageView_Hight)];
        percentageLab.font = kFont_Light_12;
        [self addSubview:percentageLab];
        
        nameLab = [[UILabel alloc]initWithFrame:CGRectMake(5 +kPercentageView_Width + percentageLab.bounds.size.width + 5 , 0, self.frame.size.width - (percentageLab.frame.origin.x + percentageLab.frame.size.width + 5), kPercentageView_Hight)];
        nameLab.font = kFont_Light_12;
        [self addSubview:nameLab];
    }
    return self;
}
- (void)kindViewWithPercentageTitle:(NSString *)percentageTitle  nameTitle:(NSString *)nameTitle viewColor:(UIColor *)color value:(float)value
{
    percentageLab.text = percentageTitle;
    nameLab.text = nameTitle;
    percentageView.backgroundColor = color;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
