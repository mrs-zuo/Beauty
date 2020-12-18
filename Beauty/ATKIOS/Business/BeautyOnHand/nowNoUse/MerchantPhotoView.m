//
//  MerchantPhotoCell.m
//  merNew
//
//  Created by MAC_Lion on 13-7-26.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "MerchantPhotoView.h"
#import "MerchantInfoViewController.h"
#import "PictureDisplayView.h"

#define IMG_SCROLL_LEFT_0 [UIImage imageNamed:@"imgScroll_L0"]
#define IMG_SCROLL_LEFT_1 [UIImage imageNamed:@"imgScroll_L1"]
#define IMG_SCROLL_RIGHT_0 [UIImage imageNamed:@"imgScroll_R0"]
#define IMG_SCROLL_RIGHT_1 [UIImage imageNamed:@"imgScroll_R1"]

@interface MerchantPhotoView ()
@end

@implementation MerchantPhotoView
@synthesize prevBtn, nextBtn;
@synthesize pictureDisplayView;
@synthesize viewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewLayer];
    }
    return self;
}

- (void)initViewLayer
{
    prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevBtn setFrame:CGRectMake(0.0f, 40.0f, 14.0f, 20.0f)];
    [prevBtn setBackgroundImage:IMG_SCROLL_LEFT_1 forState:UIControlStateNormal];
    [prevBtn setBackgroundImage:IMG_SCROLL_LEFT_0 forState:UIControlStateSelected];
    [prevBtn addTarget:self action:@selector(previousPictureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prevBtn];
    [prevBtn setSelected:YES];
    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setFrame:CGRectMake(310.0f - 14.0f, 40.0f, 14.0f, 20.0f)];
    [nextBtn setBackgroundImage:IMG_SCROLL_RIGHT_1 forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:IMG_SCROLL_RIGHT_0 forState:UIControlStateSelected];
    [nextBtn addTarget:self action:@selector(nextPictureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
    
    pictureDisplayView = [[PictureDisplayView alloc] initWithFrame:CGRectMake(25.0f, 0.0f, 260.0f, 100.0f) picSize:CGSizeMake(80.0f, 80.0f) spacing:10.0f];
    [pictureDisplayView setDelegate:self];
    [pictureDisplayView setIsEditing:YES];
    
    NSLog(@"viewController:%@", viewController);
    [pictureDisplayView setImgEditViewController:viewController];
    [self addSubview:pictureDisplayView];
}

- (void)setViewController:(MerchantInfoViewController *)theViewController
{
    viewController = theViewController;
    [pictureDisplayView setImgEditViewController:viewController];
}

- (void)previousPictureAction:(id)sender
{
    [pictureDisplayView scrollToPreviouPicture];
}

- (void)nextPictureAction:(id)sender
{
    [pictureDisplayView scrollToNextPicture];
}


- (void)updatePhotos:(NSArray *)imageURLs
{
    [pictureDisplayView setPicturesWithURLs:imageURLs];
}


#pragma mark - PictureDisplayViewDelegate

- (void)pictureDisplayView:(PictureDisplayView *)pictureDisplayView leftmost:(BOOL)isLeftmost rightmost:(BOOL)isRightmost
{
        [prevBtn setSelected:isLeftmost];
        [nextBtn setSelected:isRightmost];
}



@end
