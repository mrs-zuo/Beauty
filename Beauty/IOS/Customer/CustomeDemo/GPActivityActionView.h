//
//  GPActivityAction.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GPImageSize 59.0f

@class GPPanelView;
@interface GPActivityActionView : UIView
@property (strong, nonatomic) GPPanelView *panelView;
@property (strong, nonatomic) NSArray *activityItems;
@property (strong, nonatomic) NSArray *activities;

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic, readonly) BOOL isShowing;

- (id)initWithActivityViewItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities;
- (void)show;
- (void)showInView:(UIView *)view;
- (void)dismissActionSheet;
@end
