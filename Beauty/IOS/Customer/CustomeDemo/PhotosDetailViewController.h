//
//  PhotosDetailViewController.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-7.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ZXBaseViewController.h"

@interface PhotosDetailViewController : ZXBaseViewController<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *dateStr;
@end
