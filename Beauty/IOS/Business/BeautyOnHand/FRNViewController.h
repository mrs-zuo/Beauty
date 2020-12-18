//
//  FRNViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFFilterSet;
@protocol FRNViewDelegate;

@interface FRNViewController : UIViewController
@property (nonatomic, strong) DFFilterSet *supFilter;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy)   NSString *filterTitle;
@property (nonatomic, assign) id<FRNViewDelegate>  delegate;
@end
@protocol FRNViewDelegate <NSObject>
- (void)didnotRefresh;
@end