//
//  IndexTopView.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/1/14.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "IndexTopView.h"

@interface IndexTopView () <UIScrollViewDelegate>
{
    UIScrollView *myScrollView;
    UIPageControl *pageControl;
    NSTimer *timer;
}
@end

@implementation IndexTopView
-(void)dealloc {
    [self removeTimer];
}
- (void)removeTimer {
    if (timer == nil) return;
    [timer invalidate];
    timer = nil;
}
- (void)scrollPages:(NSTimer *)timer
{
   CGPoint point =  myScrollView.contentOffset;
    point.x += kSCREN_BOUNDS.size.width;
    if (point.x >= kSCREN_BOUNDS.size.width *_datas.count) {
        point.x = 0;
    }
    
    [UIView animateWithDuration:2.0 animations:^{
        [myScrollView setContentOffset:point animated:NO];
    } completion:^(BOOL finished){
        
    }];

}


- (void)setUpTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scrollPages:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpTimer];
        self.userInteractionEnabled = YES;
        myScrollView = [[UIScrollView alloc]initWithFrame:frame];
        myScrollView.delegate = self;
        myScrollView.backgroundColor = [UIColor clearColor];
        myScrollView.scrollEnabled = YES;
        myScrollView.pagingEnabled = YES;
        [self addSubview:myScrollView];
        
        pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, (kSCREN_BOUNDS.size.width *0.75) - 40, kSCREN_BOUNDS.size.width,20)];
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor =  [UIColor grayColor];
        pageControl.currentPage = 0;
        [pageControl addTarget:self action:@selector(pageControlEvent:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
        [self bringSubviewToFront:pageControl];
    }
    return self;
}

-(void)setDatas:(NSMutableArray *)datas
{
    _datas = datas;
    pageControl.numberOfPages = datas.count;
    for (int i = 0; i < datas.count ; i ++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width * i, 0, kSCREN_BOUNDS.size.width, (kSCREN_BOUNDS.size.width *0.75))];
        imageView.tag = 100 + i;
        imageView.userInteractionEnabled = YES;
        [imageView setImageWithURL:[NSURL URLWithString:datas[i]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
        }];
        [myScrollView addSubview:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer  alloc]initWithTarget:self action:@selector(tapImageVeiw:)];
        [imageView addGestureRecognizer:tap];
    }
    myScrollView.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width * datas.count, kSCREN_BOUNDS.size.width *0.75);
}

#pragma mark - 
- (void)tapImageVeiw:(UITapGestureRecognizer *)ges
{
    if ([ges.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)ges.view;
        if ([self.delegate respondsToSelector:@selector(IndexTopView:tapImageView:)]) {
            [self.delegate IndexTopView:self tapImageView:imageView];
        }
    }
}
#pragma mark - pageControlEvent
- (void)pageControlEvent:(UIPageControl *)page
{

    myScrollView.contentOffset = CGPointMake(kSCREN_BOUNDS.size.width * page.currentPage, 0);
 
}

#pragma mark -  UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
    pageControl.currentPage = page;
    
    CGPoint point=scrollView.contentOffset;
    if ((int)point.x==0) {
        [scrollView setContentOffset:CGPointMake(kSCREN_BOUNDS.size.width*_datas.count, 0) animated:NO];
    }else if ((int)point.x==kSCREN_BOUNDS.size.width*(_datas.count+1))
    {
        [scrollView setContentOffset:CGPointMake(kSCREN_BOUNDS.size.width, 0) animated:NO];
    }
    
}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [self setUpTimer];
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self removeTimer];
//}


@end
