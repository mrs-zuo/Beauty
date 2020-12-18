//
//  BaseViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController <UIGestureRecognizerDelegate>
@property (assign, nonatomic) BOOL baseEditing;
@property (strong, nonatomic) UITextView  *textView_Selected;
@property (strong, nonatomic) UITextField *textField_Selected;

- (void)dismissKeyBoard;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
@end
