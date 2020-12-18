//
//  CustomNavigationController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-2.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPNavigationController : UINavigationController

@property (nonatomic,assign) BOOL canDragBack;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end
