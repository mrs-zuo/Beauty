//
//  ZXVisitFilterViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/18.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import "TaskFilterDoc.h"
@class ZXVisitViewController;
@protocol  ZXVisitViewControllerDelegate<NSObject>
- (void)dismissViewControllerWithDoc:(TaskFilterDoc *)taskFilter;
@end


@interface ZXVisitFilterViewController : BaseViewController

@property (assign, nonatomic) id<ZXVisitViewControllerDelegate> delegate;
@property (strong ,nonatomic) TaskFilterDoc * filterDoc;
@end


