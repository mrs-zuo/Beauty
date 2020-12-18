//
//  RecordView.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/5/20.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "RecordView.h"
#import "UIButton+InitButton.h"

static CGFloat const kButton_Height = 50;
@implementation RecordView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
 
        self.backgroundColor = kDefaultBackgroundColor;
        UIButton *indexBtn = [UIButton buttonWithTitle:@"首页" target:self selector:@selector(indexClick:) frame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kButton_Height) backgroundImg:nil highlightedImage:nil];
        [indexBtn setTitleColor:kColor_Black forState:UIControlStateNormal];
        indexBtn.tag = 100;
        indexBtn.titleLabel.font =kNormalFont_14;
        indexBtn.backgroundColor = kColor_White;
        [self addSubview:indexBtn];
        
        UIButton *expandBtn = [UIButton buttonWithTitle:@"全部展开" target:self selector:@selector(expandClick:) frame:CGRectMake(0, 51, kSCREN_BOUNDS.size.width, kButton_Height) backgroundImg:nil highlightedImage:nil];
        expandBtn.tag = 101;
        expandBtn.titleLabel.font =kNormalFont_14;
        [expandBtn setTitleColor:kColor_Black forState:UIControlStateNormal];
        expandBtn.backgroundColor = kColor_White;
        [self addSubview:expandBtn];
        
        UIButton *canceBtn = [UIButton buttonWithTitle:@"取消" target:self selector:@selector(canceClick:) frame:CGRectMake(0, 102, kSCREN_BOUNDS.size.width, kButton_Height) backgroundImg:nil highlightedImage:nil];
        [canceBtn setTitleColor:kColor_Editable forState:UIControlStateNormal];
        canceBtn.tag = 102;
        canceBtn.titleLabel.font =kNormalFont_14;
        canceBtn.backgroundColor = kColor_White;
        [self addSubview:canceBtn];
    }
    return self;
}
-(void)setIsShowAll:(BOOL)isShowAll
{
    UIButton *expandBtn = [self viewWithTag:101];
    if (isShowAll) {
        [expandBtn setTitle:@"全部收缩" forState:UIControlStateNormal];
    }else {
        [expandBtn setTitle:@"全部展开" forState:UIControlStateNormal];
    }
}
#pragma mark -  按钮事件
- (void)indexClick:(UIButton *)sender
{
    self.indexBlock();
}
- (void)expandClick:(UIButton *)sender
{
    _isShowAll = !_isShowAll;
    self.expandBlock(sender,_isShowAll);

}
- (void)canceClick:(UIButton *)sender
{
    self.canceBlock();
}

@end
