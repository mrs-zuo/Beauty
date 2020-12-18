//
//  WSRightTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "WSRightTableViewCell.h"
#import "WorkSheet.h"
#import "DEFINE.h"

@interface WSRightTableViewCell ()
@property (strong, nonatomic) UserDoc *userDoc;
@end

@implementation WSRightTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ((IOS7 || IOS8)) {
             self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline-point"]];
        } else {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWSPrecision * 24.0f, 44)];
            [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline-point"]]];
            [self.contentView addSubview:view];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGRect bgRect = CGRectMake(0.0f, 10.0f, kWSPrecision * 24.0f + 1.0f, 24.0f);
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextAddRect(ref, bgRect);
    CGContextSetRGBFillColor(ref,   198.0f/255.0f, 229.0f/255.0f, 238.0f/255.0f, 1.0f);
    CGContextSetRGBStrokeColor(ref, 198.0f/255.0f, 229.0f/255.0f, 238.0f/255.0f, 1.0f);
    CGContextFillRect(ref, bgRect);
    CGContextStrokePath(ref);
    CGContextFillPath(ref);
    
    for (NSValue *value in _userDoc.worktimeArray) {
        workTime work;
        [value getValue:&work];
        NSLog(@"starttime =%d   endtime =%d",work.startTime,work.duration);
        float x = ((float)work.startTime) / 60 * 24;
        float w = ((float)work.duration) / 60 * 24;
        CGRect rec = CGRectMake(x, 10.0f, w, 24.0f);
        CGContextRef re = UIGraphicsGetCurrentContext();
        CGContextAddRect(re, rec);
        CGContextSetRGBFillColor(re,   255.0f/255.0f, 68.0f/255.0f, 68.0f/255.0f, 1.0f);
        CGContextSetRGBStrokeColor(re, 255.0f/255.0f, 68.0f/255.0f, 68.0f/255.0f, 1.0f);
        CGContextFillRect(re, rec);
        CGContextStrokePath(re);
        CGContextFillPath(re);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateData:(UserDoc *)userDoc
{
    
    _userDoc = userDoc;
    DLOG(@"---------------------------------userid:%ld  name:%@", (long)userDoc.user_Id, userDoc.user_Name);
    NSArray *arry = [userDoc worktimeArray];
    for (int i = 0 ; i < [arry count]; i++) {
        NSValue *value = [arry objectAtIndex:i];
        workTime w;
        [value getValue:&w];
        
        DLOG(@"start:%d  len:%d", w.startTime, w.duration);
    }
    
    [self setNeedsDisplay];
}

@end
