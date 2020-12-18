//
//  FooterView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-10-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "FooterView.h"
#import "UIButton+InitButton.h"
#import "DEFINE.h"

@interface FooterView ()
@end

#define MARGIN_TOP 5.0f
#define MARGIN_Bottom 5.0f


// 前 中 后 自动分为5 4 5 等分

@implementation FooterView
@synthesize submitButton;
@synthesize deleteButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (id)initWithTarget:(id)target subTitle:(NSString *)subTitle submitAction:(SEL)submitAction deleteTitle:(NSString *)deleTitle deleteAction:(SEL)deleteAction
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        if (submitAction) {
            submitButton = [UIButton buttonWithTitle:subTitle target:target selector:submitAction frame:CGRectMake(0.0f, MARGIN_TOP, 152.5f , 39.0f) backgroundImg:ButtonStyleBlue];
            submitButton.tag = 801;
            [self addSubview:submitButton];
        }
        
        if (deleteAction) {
            deleteButton = [UIButton buttonWithTitle:deleTitle target:target selector:deleteAction frame:CGRectMake(0.0f, MARGIN_TOP, 152.5f, 39.0f)backgroundImg:ButtonStyleRed];
            deleteButton.tag = 802;
            [self addSubview:deleteButton];
        }
    }
    return self;

}
- (id)initWithTarget:(id)target submitImg:(UIImage *)submitImg submitAction:(SEL)submitAction deleteImg:(UIImage *)deleteImg deleteAction:(SEL)deleteAction
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        if (submitAction) {
          submitButton = [UIButton buttonWithTitle:@""
                                            target:target
                                          selector:submitAction
                                             frame:CGRectMake(0.0f, MARGIN_TOP, 152.5f , 39.0f)
                                     backgroundImg:submitImg ? : [UIImage imageNamed:@"button_Confirm"]  
                                  highlightedImage:nil];
            submitButton.tag = 801;
            [self addSubview:submitButton];
        }
        
        if (deleteAction) {
            deleteButton = [UIButton buttonWithTitle:@""
                                              target:target
                                            selector:deleteAction
                                               frame:CGRectMake(0.0f, MARGIN_TOP, 152.5f, 39.0f)
                                       backgroundImg:deleteImg ? : [UIImage imageNamed:@"button_Delete"]
                                    highlightedImage:nil];
            deleteButton.tag = 802;
            [self addSubview:deleteButton];
        }
    }
    return self;
}

/**
 *submitImg != nil --》ButtonStyleBlue
 */
- (id)initWithTarget:(id)target submitImg:(UIImage *)submitImg submitTitle:(NSString *)title submitAction:(SEL)submitAction
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        if (submitAction) {
            submitButton = [UIButton buttonWithTitle:title target:target selector:submitAction frame:CGRectMake(0.0f, MARGIN_TOP, 310.0f , 39.0f) backgroundImg:(submitImg ? ButtonStyleBlue:ButtonStyleRed)];
            submitButton.tag = 801;
            [self addSubview:submitButton];
        }
    }
    
    return self;
}

- (id)initWithTarget:(id)target submitTitle:(NSString *)titile submitAction:(SEL)submitAction
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        if (submitAction) {
            
            submitButton = [UIButton buttonWithTitle:titile target:target selector:submitAction frame:CGRectMake(0.0f, 5.0, 310.0f , 39.0f) backgroundImg:ButtonStyleBlue];
            submitButton.tag = 801;
            [self addSubview:submitButton];
        }
    }
    
    return self;
}


- (void)showInTableView:(UITableView *)tableView
{
    if ((IOS7 || IOS8) || tableView.style == UITableViewStylePlain) {
        self.frame = CGRectMake(0.0f, 0.0f, 310.0f, MARGIN_TOP + 39.0f + MARGIN_Bottom);
        if (submitButton && deleteButton) {
            float margin = 310.0f - 152.5f * 2;
            self.deleteButton.frame = CGRectMake(0.0f,  MARGIN_TOP, 152.5f, 39.0f);
            self.submitButton.frame = CGRectMake(0.0f + deleteButton.frame.size.width + margin, MARGIN_TOP, 152.5f, 39.0f);
        } else if (submitButton) {
            self.submitButton.frame = CGRectMake(0.0f, MARGIN_TOP, 310.0f , 39.0f);
        }
    } else if (IOS6) {
        self.frame = CGRectMake(0.0f, 0.0f, 330.0f, MARGIN_TOP + 39.0f + MARGIN_Bottom);
        if (submitButton && deleteButton) {
            float margin = 320.0f - 152.5f * 2;
            self.deleteButton.frame = CGRectMake(margin / 14 * 5 + 5.0f,  MARGIN_TOP, 152.5f, 39.0f);
            self.submitButton.frame = CGRectMake(deleteButton.frame.origin.x + deleteButton.frame.size.width + margin/14 * 4, MARGIN_TOP, 152.5f, 39.0f);
        } else if (submitButton) {
            self.submitButton.frame = CGRectMake(10.0f, MARGIN_TOP, 310.0f , 39.0f);
        }
    }
    [tableView setTableFooterView:self];
}

@end
