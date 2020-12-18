//
//  NavigationView.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-15.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationView : UIView
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *pageLabel;

- (id)initWithPosition:(CGPoint)position title:(NSString *)title;

- (void)addButtonWithTarget:(id)target backgroundImage:(UIImage *)image selector:(SEL)selector;
- (void)addButton1WithTarget:(id)target backgroundImage:(UIImage *)image selector:(SEL)selector;


- (void)addButtonWithFrameWithTarget:(id)target backgroundImage:(UIImage *)image backGroundColor:(UIColor *)color title:(NSString*)title frame:(CGRect)frame tag:(NSInteger)tag selector:(SEL)selector;
//
//- (void)addButtonWithFrameWithTarget1:(id)target backgroundImage:(UIImage *)image backGroundColor:(UIColor *)color title:(NSString*)title frame:(CGRect)frame selector:(SEL)selector;

- (void)removeButton;
-(void)setSecondLabelText:(NSString *)text;
@end
