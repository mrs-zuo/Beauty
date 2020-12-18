//
//  GPActivityAction.m
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "GPActivityActionView.h"
#import "GPPanelView.h"
#import "GPActivity.h"

@interface GPActivityActionView ()
@property (assign, nonatomic, readonly) CGFloat activityWith;
@property (assign, nonatomic, readonly) CGFloat activityHeight;
@property (assign, nonatomic, readonly) NSUInteger numberOfActivitiesInRow;
@end

@implementation GPActivityActionView

const CGFloat kTitleHeight = 45.0f;
const CGFloat kPanelViewBottomMargin = 5.0f;
const CGFloat kPanelViewSideMargin = 20.0f;

- (CGFloat)activityWidth
{
    return GPImageSize + 1.0f + 30.0f;
}

- (CGFloat)rowHeight
{
    return self.activityWidth + 10.0f;
}

- (NSUInteger)numberOfActivitiesInRow
{
    if (_panelView)
        return (_panelView.frame.size.width - 2 * kPanelViewSideMargin) / self.activityWidth;
    return (self.bounds.size.height - 2 * kPanelViewSideMargin) / self.activityWidth;
}

- (NSUInteger)numberOfRowFromCount:(NSUInteger)count
{
    NSUInteger rowsCount = (NSUInteger)(count / self.numberOfActivitiesInRow);
    rowsCount += (count % self.numberOfActivitiesInRow > 0) ? 1 : 0;
    return rowsCount;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithActivityViewItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities
{
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _activities = applicationActivities;
        _activityItems =  activityItems;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setAutoresizesSubviews:YES];
        
        UIControl *baseView = [[UIControl alloc] initWithFrame:self.frame];
        baseView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3];
        baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [baseView addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:baseView];
        
        NSUInteger rowsCount = [self numberOfRowFromCount:[_activities count]];
        CGFloat height = self.rowHeight * rowsCount + kTitleHeight;
        CGRect baseRect = CGRectMake(0, baseView.frame.size.height - height - kPanelViewBottomMargin, baseView.frame.size.width, height);
        
        _panelView = [[GPPanelView alloc] initWithFrame:baseRect];
        _panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _panelView.transform = CGAffineTransformMakeScale(1.0, 0.1);
        [baseView addSubview:_panelView];
        [UIView animateWithDuration:0.1 animations:^ {
            _panelView.transform = CGAffineTransformIdentity;
        }];
        
        [self addActivities:_activities];
    }
    return self;
}

- (void)addActivities:(NSArray *)activities
{
    CGFloat x = 0;
    CGFloat y = 0;
    NSUInteger count = 0;
    CGFloat activityWidth = self.activityWidth;
    for (GPActivity *activity in activities) {
        count++;
     
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, activityWidth, activityWidth)];
        button.tag = count - 1;
        [button addTarget:self action:@selector(invokeActivity:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:activity.image forState:UIControlStateNormal];
        CGFloat sideWidth = activityWidth - activity.image.size.height;
        CGFloat leftInset = roundf(sideWidth / 2.0f);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, leftInset, sideWidth, sideWidth - leftInset);
        button.accessibilityLabel = activity.title;
        button.showsTouchWhenHighlighted = NO;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, activity.image.size.height + 2.0f, activityWidth, 10.0f)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        label.shadowOffset = CGSizeMake(0, 1);
        label.text = activity.title;
        CGFloat fontSize = 12.0f;
        
        label.font = [UIFont systemFontOfSize:fontSize];
        label.numberOfLines = 0;
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.origin.x = roundf((button.frame.size.width - frame.size.width) / 2.0f);
        label.frame = frame;
        [button addSubview:label];
        
        [_panelView addSubview:button];
    }
}

#pragma mark - Action

- (void)invokeActivity:(UIButton *)button
{
    GPActivity *activity = [_activities objectAtIndex:button.tag];
    if (activity.activityHander)
        activity.activityHander(activity, _activityItems);
    [self dismissActionSheet];
}

#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutActivities];
    [_panelView setNeedsDisplay];
}

- (void)layoutActivities
{
    // re-layouting panelView.
    NSUInteger rowsCount = [self numberOfRowFromCount:[_activities count]];
    CGFloat height = self.rowHeight * rowsCount + kTitleHeight;
    _panelView.frame = CGRectMake(0, _panelView.superview.frame.size.height - height - kPanelViewBottomMargin, _panelView.superview.frame.size.width, height);

    CGFloat x = 0;
    CGFloat y = 0;
    NSUInteger count = 0;
    CGFloat activityWidth = self.activityWidth;
    CGFloat spaceWidth = (_panelView.frame.size.width - (activityWidth * self.numberOfActivitiesInRow) - (2 * kPanelViewSideMargin)) / (self.numberOfActivitiesInRow - 1);
    for (UIButton *button in _panelView.subviews) {
        count++;
        x = kPanelViewSideMargin + (activityWidth + spaceWidth) * (CGFloat)(count % self.numberOfActivitiesInRow == 0 ? self.numberOfActivitiesInRow - 1 : count % self.numberOfActivitiesInRow - 1);
        y = kPanelViewSideMargin + self.rowHeight * ([self numberOfRowFromCount:count] - 1);
        
        button.frame = CGRectMake(x, y, activityWidth, activityWidth);
    }
}

#pragma mark Appearence

- (void)show
{
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [UIApplication sharedApplication].windows) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    UIView *topView = [[UIApplication sharedApplication].keyWindow.subviews objectAtIndex:0];
    [self showInView:keyboardWindow ? : topView];
}

- (void)showInView:(UIView *)view
{
    _panelView.title = self.title;
    self.frame = view.bounds;
    [view addSubview:self];
    _isShowing = YES;
}

- (void)dismissActionSheet
{
    if (self.isShowing) {
        [UIView animateWithDuration:0.1 animations:^ {
            _panelView.transform = CGAffineTransformMakeScale(1.0, 0.2);
        } completion:^ (BOOL finished){
            [self removeFromSuperview];
        }];
        _isShowing = NO;
    }
}

@end
