//
//  UILabelStrikeThrough.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "UILabelStrikeThrough.h"

@implementation UILabelStrikeThrough
@synthesize isWithStrikeThrough;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (isWithStrikeThrough){
        CGContextRef c = UIGraphicsGetCurrentContext();
        
        CGFloat gray[4] = {0.0f,0.0f, 0.0f,0.2f};
        
        CGContextSetStrokeColor(c, gray);
        CGContextSetLineWidth(c, 1);
        CGContextBeginPath(c);
        
        //画直线
        CGFloat halfWayUp = rect.size.height/2 + rect.origin.y;
        CGContextMoveToPoint(c, rect.origin.x, halfWayUp );//开始点
        CGContextAddLineToPoint(c, rect.origin.x + rect.size.width, halfWayUp);//结束点

//        画斜线
//        CGContextMoveToPoint(c, rect.origin.x, rect.origin.y+5 );
//        CGContextAddLineToPoint(c, (rect.origin.x + rect.size.width)*0.5, rect.origin.y+rect.size.height-5); //斜线
        CGContextStrokePath(c);
    }
    [super drawRect:rect];
}

@end
