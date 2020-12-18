//
//  ZXAppointmentFilterViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/18.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import "TaskFilterDoc.h"
@class ZXAppointmentFilterViewController;
@protocol ZXAppointmentFilterViewControllerDelegate<NSObject>
- (void)dismissViewControllerWithDoc:(TaskFilterDoc *)taskFilter;
@end

@interface ZXAppointmentFilterViewController : BaseViewController

@property (assign, nonatomic) id<ZXAppointmentFilterViewControllerDelegate> delegate;
@property (strong ,nonatomic) TaskFilterDoc * filterDoc;
@end




