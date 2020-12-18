//
//  UIButton+InitButton.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (InitButton)

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame backgroundImg:(UIImage *)image highlightedImage:(UIImage *)lightedImage;

@end
