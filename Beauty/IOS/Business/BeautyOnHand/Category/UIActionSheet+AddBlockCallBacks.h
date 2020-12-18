//
//  UIActionSheet+AddBlockCallBacks.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIActionSheetCallBackHandler)(UIActionSheet *actionSheet, NSInteger buttonIndex );

@interface UIActionSheet (AddBlockCallBacks)<UIActionSheetDelegate>
- (void)showActionSheetWithInView:(UIView *)view handler:(UIActionSheetCallBackHandler)handler;
@end
