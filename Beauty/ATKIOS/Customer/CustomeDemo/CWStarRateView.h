//
//  CWStarRateView.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/17.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CWStarRateView;
@protocol CWStarRateViewDelegate <NSObject>
@optional
- (void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent;
- (void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent tap:(UITapGestureRecognizer*)tapping;
@end

@interface CWStarRateView : UIView

@property (nonatomic, assign) CGFloat scorePercent;//得分值，范围为0--1，默认为1
@property (nonatomic, assign) BOOL hasAnimation;//是否允许动画，默认为NO
@property (nonatomic, assign) BOOL allowIncompleteStar;//评分时是否允许不是整星，默认为NO

@property (nonatomic, weak) id<CWStarRateViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars;

@end
