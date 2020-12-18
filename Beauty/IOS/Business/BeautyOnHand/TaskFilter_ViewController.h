//
//  TaskFilter_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskFilterDoc.h"

@protocol  TaskFilterViewControllerDelegate<NSObject>
- (void)dismissViewControllerWithDoc:(TaskFilterDoc *)taskFilter;
@end

@interface TaskFilter_ViewController : BaseViewController

@property (assign, nonatomic) id<TaskFilterViewControllerDelegate> delegate;
@property (strong ,nonatomic) TaskFilterDoc * filterDoc;
@end
