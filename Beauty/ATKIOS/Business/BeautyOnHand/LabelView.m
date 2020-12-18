//
//  LabelView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-11.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "LabelView.h"

#define WHITH  300.0
#define HEIGHT 25.0


@interface LabelView ()


@end


@implementation LabelView




- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)addLabel:(NSArray *)array
{
    for (int i = 0; i < [array count]; i ++) {
        CGRect lastFrame = ((UIButton *)[self.subviews lastObject]).frame;
        CGPoint point = CGPointMake(lastFrame.origin.x + lastFrame.size.width, lastFrame.origin.y);
        CGSize size = [array[i] sizeWithFont:kFont_Light_16];
        size.width += 10;
        if (point.x + size.width > WHITH) {
            point.y += HEIGHT;
            point.x = 0;
        }
        CGRect newFrame = CGRectMake(point.x, point.y ,size.width ,size.height );
        UIButton *label = [[UIButton alloc] initWithFrame:newFrame];
        label.titleLabel.font = kFont_Light_16;
        [label setBackgroundColor:[UIColor redColor]];
        [label setTintColor:[UIColor blackColor]];
        [label setTitle:array[i] forState:UIControlStateNormal];
        label.tintColor = [UIColor redColor];
        label.tag = i;
        [label addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self addSubview:label];
        
    }
    
}


- (void)click:(id)sender
{
    
    NSLog(@"the click label Tag is %ld", (long)((UIButton *)sender).tag);
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
