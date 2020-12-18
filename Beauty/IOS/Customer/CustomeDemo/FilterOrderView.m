//
//  FilterOrderView.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/5/19.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "FilterOrderView.h"


@interface FilterOrderView ()


@end

static CGFloat const kSecView_Height = 50;
static CGFloat const kTypeViewTag = 100;
static CGFloat const kStateViewTag = 200;
static CGFloat const kPayViewTag = 300;

@implementation FilterOrderView


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = kDefaultBackgroundColor;
        
        UIView *vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSecView_Height)];
        vi.backgroundColor = kColor_White;
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, kSCREN_BOUNDS.size.width - 40, kLabel_DefaultHeight)];
        lab.text = @"订单筛选";
        lab.font = kNormalFont_14;
        lab.textColor = kColor_Editable;
        [vi addSubview:lab];
        [self addSubview:vi];
        
        CGFloat btnWidth = (kSCREN_BOUNDS.size.width - 60) / 5;
        CGFloat btnHeight = 30;
        
        UIView *typeView = [[UIView alloc]initWithFrame:CGRectMake(0, 1 + vi.frame.origin.y +vi.frame.size.height, kSCREN_BOUNDS.size.width,  80)];
        typeView.tag = kTypeViewTag;
        typeView.backgroundColor = kColor_White;
        UILabel *typelab = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, kSCREN_BOUNDS.size.width - 20, kLabel_DefaultHeight)];
        typelab.text = @"订单分类";
        typelab.font = kNormalFont_14;
        typelab.textColor = kColor_Black;
        [typeView addSubview:typelab];
        
        NSArray *typeArrs = @[@"全部",@"服务",@"商品"];
        for (int i  = 0; i < typeArrs.count; i ++) {
            UIButton *button = [UIButton buttonWithTitle:typeArrs[i] target:self selector:@selector(typeClick:) frame:CGRectMake(20 + btnWidth * i + i * 5 , 50, btnWidth, btnHeight) backgroundImg:nil highlightedImage:nil];
            button.titleLabel.font = kNormalFont_14;
            button.tag =  100 + i;
            [button setTitleColor:kMainLightGrayColor forState:UIControlStateNormal];
            [button setTitleColor:kColor_White forState:UIControlStateSelected];
            [typeView addSubview:button];
        }
        [self addSubview:typeView];

        
        UIView *stateView = [[UIView alloc]initWithFrame:CGRectMake(0, typeView.frame.origin.y +typeView.frame.size.height, kSCREN_BOUNDS.size.width, 80)];
        stateView.backgroundColor = kColor_White;
        stateView.tag = kStateViewTag;
        UILabel *statelab = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, kSCREN_BOUNDS.size.width - 20, kLabel_DefaultHeight)];
        statelab.text = @"订单状态";
        statelab.font = kNormalFont_14;
        statelab.textColor = kColor_Black;
        [stateView addSubview:statelab];

        NSArray *stateArrs = @[@"全部",@"未完成",@"已完成",@"已终止",@"已取消"];
        for (int i  = 0; i < stateArrs.count; i ++) {
            UIButton *button = [UIButton buttonWithTitle:stateArrs[i] target:self selector:@selector(stateClick:) frame:CGRectMake(20 + btnWidth * i  + i * 5,50, btnWidth , btnHeight) backgroundImg:nil highlightedImage:nil];
            button.titleLabel.font = kNormalFont_14;
            button.tag = 200 + i;
            [button setTitleColor:kMainLightGrayColor forState:UIControlStateNormal];
            [button setTitleColor:kColor_White forState:UIControlStateSelected];
            [stateView addSubview:button];
        }
        [self addSubview:stateView];
        
        UIView *payView = [[UIView alloc]initWithFrame:CGRectMake(0,stateView.frame.origin.y +stateView.frame.size.height, kSCREN_BOUNDS.size.width, 80 + 15)];
        payView.backgroundColor = kColor_White;
        payView.tag = kPayViewTag;
        UILabel *paylab = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, kSCREN_BOUNDS.size.width - 20, kLabel_DefaultHeight)];
        paylab.text = @"支付状态";
        paylab.font = kNormalFont_14;
        paylab.textColor = kColor_Black;
        [payView addSubview:paylab];
        
        NSArray *payArrs = @[@"全部",@"未支付",@"部分付",@"已支付",@"免支付"];
        for (int i  = 0; i < payArrs.count; i ++) {
            UIButton *button = [UIButton buttonWithTitle:payArrs[i] target:self selector:@selector(payClick:) frame:CGRectMake(20 + btnWidth * i + i * 5, 50, btnWidth, btnHeight) backgroundImg:nil highlightedImage:nil];
            button.titleLabel.font = kNormalFont_14;
            button.tag = 300 + i;
            [button setTitleColor:kMainLightGrayColor forState:UIControlStateNormal];
            [button setTitleColor:kColor_White forState:UIControlStateSelected];
            [payView addSubview:button];
        }
        [self addSubview:payView];

        UIView *btnView  = [[UIView alloc]initWithFrame:CGRectMake(0, 1 + payView.frame.origin.y + payView.frame.size.height, kSCREN_BOUNDS.size.width, 50)];
        btnView.backgroundColor = kColor_Clear;
        
        CGFloat tempWidth = (kSCREN_BOUNDS.size.width - 1) / 2;
        UIButton *cance = [UIButton buttonWithTitle:@"取消" target:self selector:@selector(canceClick:) frame:CGRectMake(0, 0, tempWidth, 50) backgroundImg:nil highlightedImage:nil];
        cance.backgroundColor = kColor_White;
        [cance setTitleColor:kColor_Black forState:UIControlStateNormal];
        cance.titleLabel.font = kNormalFont_14;
        [btnView addSubview:cance];
        UIButton *confirm = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(confirmClick:) frame:CGRectMake(0.5 +tempWidth, 0, tempWidth, 50) backgroundImg:nil highlightedImage:nil];
        confirm.backgroundColor = kColor_White;
        [confirm setTitleColor:kColor_Black forState:UIControlStateNormal];
        confirm.titleLabel.font = kNormalFont_14;
        [btnView addSubview:confirm];

        [self addSubview:btnView];
    }
    return self;
}

#pragma mark - 参数 转化 对应的tag
//全部 -1 服务 0 商品 1
- (void)convertTypeWithType:(NSInteger)aType
{
    NSInteger type = 0;
    switch (aType) {
        case -1:
        {
            type = 100;
        }
            break;
        case 0:
        {
            type = 101;

        }
            break;
        case 1:
        {
            type = 102;
        }
            break;
        default:
            break;
    }
    UIView *typeView = [self viewWithTag:kTypeViewTag];
    [self setupStyleWithView:typeView type:type];
}
//全部 -1 未完成 1 已完成 2 已终止 3 已取消 4
- (void)convertTypeWithOrderState:(NSInteger)aOrderState
{
    NSInteger orderState = 0;
    switch (aOrderState) {
        case -1:
        {
            orderState = 200;
        }
            break;
        case 1:
        {
            orderState = 201;
            
        }
            break;
        case 2:
        {
            orderState = 202;
        }
            break;
        case 3:
        {
            orderState = 203;
        }
            break;
        case 4:
        {
            orderState = 204;
        }
            break;
        default:
            break;
    }
    UIView *orderView = [self viewWithTag:kStateViewTag];
    [self setupStyleWithView:orderView type:orderState];
}
//全部 -1 未支付 1 部分付 2 已支付 3 部分付 5
- (void)convertTypeWithPayState:(NSInteger)aPayState
{
    NSInteger payState = 0;
    switch (aPayState) {
        case -1:
        {
            payState = 300;
        }
            break;
        case 1:
        {
            payState = 301;
        }
            break;
        case 2:
        {
            payState = 302;
        }
            break;
        case 3:
        {
            payState = 303;
        }
            break;
        case 5:
        {
            payState = 304;
        }
            break;
        default:
            break;
    }
    UIView *payView = [self viewWithTag:kPayViewTag];
    [self setupStyleWithView:payView type:payState];
}
#pragma mark - setter 方法

-(void)setType:(NSInteger)type
{
    [self convertTypeWithType:type];
}
-(void)setOrderState:(NSInteger)orderState
{
    [self convertTypeWithOrderState:orderState];
}
-(void)setPayState:(NSInteger)payState
{
    [self convertTypeWithPayState:payState];
}

#pragma mark -  按钮事件
- (void)setupStyleWithView:(UIView *)aView type:(NSInteger)aType
{
    for (UIView *vi in aView.subviews) {
        if ([vi isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)vi;
            if (aType == btn.tag) {
                btn.selected = YES;
                btn.backgroundColor = KColor_NavBarTintColor;
            }else{
                btn.selected = NO;
                btn.backgroundColor = kColor_Clear;
            }
        }
    }
}
-(void)typeClick:(UIButton *)butt
{
   _type = butt.tag;
    UIView *typeView = [self viewWithTag:kTypeViewTag];
    [self setupStyleWithView:typeView type:_type];
}
-(void)stateClick:(UIButton *)butt
{
   _orderState = butt.tag;
    UIView *orderView = [self viewWithTag:kStateViewTag];
    [self setupStyleWithView:orderView type:_orderState];
}
-(void)payClick:(UIButton *)butt
{
    _payState = butt.tag;
    UIView *payView = [self viewWithTag:kPayViewTag];
    [self setupStyleWithView:payView type:_payState];
}
-(void)canceClick:(UIButton *)butt
{
    if ([self.delegate respondsToSelector:@selector(FilterOrderViewCance)]) {
        [self.delegate FilterOrderViewCance];
    }
}
-(void)confirmClick:(UIButton *)butt
{
    if ([self.delegate respondsToSelector:@selector(FilterOrderViewConfirmWithType:orderState:payState:)]) {
        [self.delegate FilterOrderViewConfirmWithType:self.type orderState:self.orderState payState:self.payState];
    }
    
}



@end
