//
//  GPHookObject.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-24.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "GPHookObject.h"
#import <objc/runtime.h>

NSString * const GPHookObjectTouchEvnentNotification = @"GPHookObjectTouchEvnentNotification";

@implementation GPHookObject

+ (void)initialize
{
    Method sendEvent = class_getInstanceMethod([UIWindow class], @selector(sendEvent:));
    Method sendEventMySelf = class_getInstanceMethod([self class], @selector(sendEventHooked:));
    
    IMP sendEventImp = method_getImplementation(sendEvent);
    class_addMethod([UIWindow class], @selector(sendEventOriginal:), sendEventImp, method_getTypeEncoding(sendEvent));
    
    IMP sendEventByMySelfImp = method_getImplementation(sendEventMySelf);
    class_replaceMethod([UIWindow class], @selector(sendEvent:), sendEventByMySelfImp, method_getTypeEncoding(sendEventMySelf));
}

- (void)sendEventHooked:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GPHookObjectTouchEvnentNotification object:nil];
    
    [self performSelector:@selector(sendEventOriginal:) withObject:event];
}
@end
