//
//  CustomNavigationController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-1.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPNavigationController : UINavigationController

// Enable the drag to back interaction, Defalt is YES.
@property (nonatomic,assign) BOOL canDragBack;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)cleanScreenShotsFromeVC:(Class)currentVCClass ViewController:(Class)skipVCClass;
@end
