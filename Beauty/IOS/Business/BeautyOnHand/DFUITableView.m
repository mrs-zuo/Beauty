//
//  DFUITableView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-12-26.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "DFUITableView.h"
#import "DEFINE.h"

@implementation DFUITableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    self.autoresizingMask = UIViewAutoresizingNone;
    
    self.sectionHeaderHeight = 0.0;
    self.sectionFooterHeight = 5.0;
    if ((IOS7 || IOS8)) self.separatorInset = UIEdgeInsetsZero;

    return self;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self endEditing:YES];
}
@end
