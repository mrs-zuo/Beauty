//
//  AppointmentExecutingOrderList_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/13.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectServiceControllerDelegate <NSObject>
@optional
- (void)dismissServiceViewControllerWithSelectedExecutingOrder:(NSString *)serviceName userID:(NSDictionary *)serviceIdDic;
@end

@interface AppointmentExecutingOrderList_ViewController : BaseViewController
@property (assign, nonatomic) id<SelectServiceControllerDelegate> delegate;
@property (assign, nonatomic) NSInteger customerID;
@property (strong, nonatomic) NSString * customerName;
@end
