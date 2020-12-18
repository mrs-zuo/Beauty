//
//  TDArrow.m
//  TDRatingControl
//
//  Created by Thavasidurai on 14/02/13.
//  Copyright (c) 2013 JEMS All rights reserved.
//

#import "TDArrow.h"
#import "DEFINE.h"

#define kLINE_COLOR [UIColor colorWithRed:253.0f/ 255.0f green:109.0f/ 255.0f blue:61.0f/255.0f alpha:1.0f]

@implementation TDArrow
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.width)];
        imageView.image = [UIImage imageNamed:@"icon_clock"];
        [self addSubview:imageView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    
    CGContextMoveToPoint(ctx, imageView.bounds.size.width / 2 , imageView.bounds.size.width);
    CGContextAddLineToPoint(ctx, imageView.bounds.size.width / 2, rect.size.height );
    CGContextClosePath(ctx);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetStrokeColorWithColor(ctx, kLINE_COLOR.CGColor);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}


@end
