//
//  PhotosListViewController.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-7.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ZXBaseViewController.h"
static int a = 1;
@interface PhotosListViewController : ZXBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
