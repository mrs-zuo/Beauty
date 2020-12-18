//
//  LoginViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-1.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
+(void)initView;
@end
