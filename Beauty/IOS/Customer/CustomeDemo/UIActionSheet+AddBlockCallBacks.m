//
//  UIActionSheet+AddBlockCallBacks.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "UIActionSheet+AddBlockCallBacks.h"
#import <objc/runtime.h>

@implementation UIActionSheet (AddBlockCallBacks)

static NSString *handlerRunTimeAccosiationKey = @"actionSheetCreateByGuanHuiOn201301017";

- (void)showActionSheetWithInView:(UIView *)view handler:(UIActionSheetCallBackHandler)handler;
{
    objc_setAssociatedObject(self, (__bridge const void *)(handlerRunTimeAccosiationKey), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setDelegate:self];
    [self showInView:view];
}

#pragma mark - UIActionSheetDelegate 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIActionSheetCallBackHandler completionHandler = objc_getAssociatedObject(self, (__bridge const void *)(handlerRunTimeAccosiationKey));
    
    if (completionHandler != nil)
    {
        completionHandler(actionSheet, buttonIndex);
    }

}
@end
