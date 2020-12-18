//
//  MidLineLabel.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-9.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "MidLineLabel.h"

@implementation MidLineLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
    
    CGSize textSize = [self.text sizeWithFont:self.font];
    CGFloat strikeWidth = textSize.width;
    
    CGRect lineRect;
    if (self.textAlignment == NSTextAlignmentRight) {
        lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2, strikeWidth, 1);
    } else if (self.textAlignment == NSTextAlignmentCenter) {
        lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2, strikeWidth, 1);
    } else {
        lineRect = CGRectMake(0, rect.size.height/2, strikeWidth, 1);
    }
    
    if (_isShowMidLine) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 0.5f, 0.5f, 0.5f, 1.0f);
        CGContextFillRect(context, lineRect);
    }
}

//- (void)setIsShowMidLine:(BOOL)isShowMidLine {
//    
//    _isShowMidLine = isShowMidLine;
//    
////    NSString *tempText = [self.text copy];
////    self.text = @"";
////    self.text = tempText;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
