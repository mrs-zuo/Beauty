//
//  SurplusTableViewCell.m
//      
//
//  Created by scs_zhouyt on 2021/02/08.
//  Copyright © 2021 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurplusTableViewCell.h"

@implementation SurplusTableViewCell

- (void)setFrame:(CGRect)frame
{
    static CGFloat margin = -10;
    frame.origin.x = margin;
    frame.size.width -= 2 * frame.origin.x;
//    frame.origin.y += margin;
//    frame.size.height -= margin;
    [super setFrame:frame];
}

@end
