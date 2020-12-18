//
//  noCopyTextField.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-4-16.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "noCopyTextField.h"

@implementation noCopyTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithText:(NSString *)text
              frame:(CGRect)frame
                tag:(NSInteger)tag
          textColor:(UIColor*)color
        placeHolder:(NSString *)placeHolderText
      textAlignment:(NSTextAlignment)textAlignment
           delegate:(id)delegate

{
    self = [super initWithFrame:frame];
    if (self) {
        self.text = text;
        self.textColor = color;
        self.placeholder = placeHolderText;
        self.textAlignment = textAlignment;
        self.delegate = delegate;
        self.tag = tag;
    }
    return self;
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}
@end
