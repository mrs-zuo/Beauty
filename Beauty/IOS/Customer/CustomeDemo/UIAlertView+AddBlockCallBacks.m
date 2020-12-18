//
//  UIAlertView+AddBlockCallBacks.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "UIAlertView+AddBlockCallBacks.h"
#import <objc/runtime.h>

@implementation UIAlertView (AddBlockCallBacks)
static NSString *handlerRunTimeAccosiationKey = @"alertViewCreateByGuanHOn20131017";

- (void)showAlertViewWithHandler:(UIActionAlertViewCallBackHandler)handler
{
    objc_setAssociatedObject(self, (__bridge const void *)(handlerRunTimeAccosiationKey), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setDelegate:self];
    [self show];
}

#pragma mark - UIAlertViewDelegate 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   UIActionAlertViewCallBackHandler completionHandler = objc_getAssociatedObject(self, (__bridge const void *)(handlerRunTimeAccosiationKey));
 
    if (completionHandler != nil)
    {
        completionHandler(alertView, buttonIndex);
    }

}

@end
