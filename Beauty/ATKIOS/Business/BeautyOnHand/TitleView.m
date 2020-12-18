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
        [self setFrame:CGRectMake(4, 5, 312, 36)];
        self.autoresizingMask = UIViewAutoresizingNone;
        
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitleBar"]];
        backgroundImageView.frame = CGRectMake(0.0f, 0.0f, 312, 36);
        [self addSubview:backgroundImageView];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5, 0.0f, 305.0f, 36) title:@""];
        [titleLabel setTextColor:kColor_DarkBlue];
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
