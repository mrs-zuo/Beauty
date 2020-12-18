//
//  AppointmentFilter_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCustomersViewController.h"
#import "AppointmentFilterDoc.h"

@protocol  appointmentFilterViewControllerDelegate<NSObject>
- (void)dismissViewControllerWithDoc:(AppointmentFilterDoc *)orderFilter;
@end

@interface AppointmentFilter_ViewController : BaseViewController<SelectCustomersViewControllerDelegate>
@property (strong, nonatomic) AppointmentFilterDoc * filterDoc ;
@property (assign, nonatomic) id<appointmentFilterViewControllerDelegate> delegate;

@end
