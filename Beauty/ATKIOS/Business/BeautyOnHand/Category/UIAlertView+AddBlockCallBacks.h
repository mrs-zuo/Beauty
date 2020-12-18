//
//  UIAlertView+AddBlockCallBacks.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^UIActionAlertViewCallBackHandler)(UIAlertView * alertView, NSInteger buttonIndex);

@interface UIAlertView (AddBlockCallBacks)<UIAlertViewDelegate>
- (void)showAlertViewWithHandler:(UIActionAlertViewCallBackHandler)handler;
@end
