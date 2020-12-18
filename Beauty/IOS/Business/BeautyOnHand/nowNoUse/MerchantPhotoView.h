//
//  MerchantPhotoCell.h
//  merNew
//
//  Created by MAC_Lion on 13-7-26.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureDisplayView.h"

@class MerchantInfoViewController;
@interface MerchantPhotoView : UIView<PictureDisplayViewDelegate>
@property (weak, nonatomic) MerchantInfoViewController *viewController;
@property (strong, nonatomic) PictureDisplayView *pictureDisplayView;
@property (strong, nonatomic) UIButton *prevBtn;
@property (strong, nonatomic) UIButton *nextBtn;

- (void)updatePhotos:(NSArray *)imageURLs;

@end
