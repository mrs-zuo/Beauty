//
//  NavigationView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-15.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "NavigationView.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"

@interface NavigationView ()
@property (nonatomic) UIImageView *bgImageView;
@property (nonatomic) UIButton *button;
@property (nonatomic) UIButton *button1;
//@property (nonatomic) UIButton *frameButton;
//@property (nonatomic) UIButton *frameButton1;
@end

@implementation NavigationView
@synthesize bgImageView;
@synthesize button;
@synthesize titleLabel,pageLabel;
@synthesize button1;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 320.0f, HEIGHT_NAVIGATION_VIEW)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitleBar"]];
        bgImageView.frame = CGRectMake(4.0f, 0.0f, 312.0f, HEIGHT_NAVIGATION_VIEW);
        bgImageView.tag = 100;
        [self addSubview:bgImageView];
        [bgImageView sendSubviewToBack:self];
        
        pageLabel = [UILabel initNormalLabelWithFrame:CGRectMake(CGRectGetMinX(bgImageView.frame) + 5.0f, 0.0f, 70.0f, HEIGHT_NAVIGATION_VIEW) title:@""];
        pageLabel.textColor = kColor_DarkBlue;
        pageLabel.font = kFont_Light_16;
        [self addSubview:pageLabel];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(CGRectGetMinX(bgImageView.frame) + 5.0f, 0.0f, 200.0f, HEIGHT_NAVIGATION_VIEW) title:@""];
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.font = kFont_Light_16;
        
        [self addSubview:titleLabel];
    }
    return self;
}

- (id)initWithPosition:(CGPoint)position title:(NSString *)title;
{
    self = [self initWithFrame:CGRectMake(position.x, position.y, 0, 0)];
    if (self) {
        titleLabel.text = title;
    }
    return self;
}

- (void)addButtonWithTarget:(id)target backgroundImage:(UIImage *)image selector:(SEL)selector
{
    if (button == nil) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(315 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

//addButton1 订单时间筛选
- (void)addButton1WithTarget:(id)target backgroundImage:(UIImage *)image selector:(SEL)selector
{
    if (button1 == nil) {
        button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button1 setFrame:CGRectMake(315 - HEIGHT_NAVIGATION_VIEW * 2, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)];
        [button1 setBackgroundImage:image forState:UIControlStateNormal];
        [button1 addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button1];
    }
}

- (void)addButtonWithFrameWithTarget:(id)target backgroundImage:(UIImage *)image backGroundColor:(UIColor *)color title:(NSString*)title frame:(CGRect)frame tag:(NSInteger)tag selector:(SEL)selector{
//    if (frameButton == nil) {
       UIButton *  frameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [frameButton setFrame:frame];
        frameButton.tag = tag;
        [frameButton setBackgroundColor:color];
        [frameButton setBackgroundImage:image forState:UIControlStateNormal];
        [frameButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        frameButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        [frameButton setTitle:title forState:UIControlStateNormal];
        [frameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [frameButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:frameButton];
//    }
}

//- (void)addButtonWithFrameWithTarget1:(id)target backgroundImage:(UIImage *)image backGroundColor:(UIColor *)color title:(NSString*)title frame:(CGRect)frame selector:(SEL)selector{
//    if (frameButton1 == nil) {
//        frameButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
//        [frameButton1 setFrame:frame];
//        [frameButton1 setBackgroundColor:color];
//        [frameButton1 setBackgroundImage:image forState:UIControlStateNormal];
//        [frameButton1 addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//        frameButton1.titleLabel.font = [UIFont systemFontOfSize:14.];
//        [frameButton1 setTitle:title forState:UIControlStateNormal];
//        [frameButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [frameButton1 addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:frameButton1];
//    }
//}


- (void)removeButton
{
    [button removeFromSuperview];
    button = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setSecondLabelText:(NSString *)text
{
    CGSize pageSize = [text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 20)];
    pageLabel.text = text;

    CGSize titleSize = [titleLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 20)];
    if (titleSize.width > 310 - pageSize.width -36) {
        pageLabel.frame = CGRectMake(310 - 36 - pageSize.width, 0, pageSize.width, HEIGHT_NAVIGATION_VIEW);
        titleLabel.frame =  CGRectMake(CGRectGetMinX(bgImageView.frame) + 5.0f, 0, 310 - pageSize.width -36, HEIGHT_NAVIGATION_VIEW);
    } else {
        titleLabel.frame =  CGRectMake(CGRectGetMinX(bgImageView.frame) + 5.0f, 0, titleSize.width, HEIGHT_NAVIGATION_VIEW);
        pageLabel.frame = CGRectMake(titleSize.width, 0, pageSize.width, HEIGHT_NAVIGATION_VIEW);
    }
}
@end
