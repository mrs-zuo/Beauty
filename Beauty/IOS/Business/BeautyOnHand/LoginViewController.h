//
//  LoginViewController.h
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class noCopyTextField;

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet noCopyTextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIImageView *userNameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImageView;
@property (weak, nonatomic) IBOutlet UILabel *statementLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)login:(id)sender;

@end
