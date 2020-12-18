//
//  FooterView.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-10-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSInteger, FooterType) {
//    FooterTypeStandard,
//    FooterTypeSinge,
//    FooterTypeCustom
//};

@interface FooterView : UIView
@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UIButton *deleteButton;

- (id)initWithTarget:(id)target submitImg:(UIImage *)submitImg submitAction:(SEL)submitAction deleteImg:(UIImage *)deleteImg deleteAction:(SEL)deleteAction;

- (id)initWithTarget:(id)target subTitle:(NSString *)subTitle submitAction:(SEL)submitAction deleteTitle:(NSString *)deleTitle deleteAction:(SEL)deleteAction;

/**
 *submitImg != nil --》ButtonStyleBlue
 */
- (id)initWithTarget:(id)target submitImg:(UIImage *)submitImg submitTitle:(NSString *)title submitAction:(SEL)submitAction;
- (id)initWithTarget:(id)target submitTitle:(NSString *)titile submitAction:(SEL)submitAction;
- (void)showInTableView:(UITableView *)tableView;
@end
