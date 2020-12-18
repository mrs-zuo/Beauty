//
//  TitleView.m
//  CustomeDemo
//
//  Created by macmini on 13-9-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//  2013.9.13 吴旭 可重用的页面头部

#import "TitleView.h"
#import "UILabel+InitLabel.h"

@implementation TitleView
@synthesize titleLabel;
@synthesize backgroundImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:CGRectMake(kTitle_X, kTitle_Y, kTitle_Width, kTitle_Height)];
        self.autoresizingMask = UIViewAutoresizingNone;
        
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CustomerBasicInfoTitle"]];
        backgroundImageView.frame = CGRectMake(0.0f, 0.0f, kTitle_Width, kTitle_Height);
        [self addSubview:backgroundImageView];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(kTitle_TitleLabelX, 0.0f, 305.0f, kTitle_Height) title:@""];
        [titleLabel setTextColor:kColor_TitlePink];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setFont:kFont_Light_16];
        [self addSubview:titleLabel];
    }
    return self;
}

- (UIView *)getTitleView:(NSString *)title
{
    self.titleLabel.text = title;
    return self;
}

@end
