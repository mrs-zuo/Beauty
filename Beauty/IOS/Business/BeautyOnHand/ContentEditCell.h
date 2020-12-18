//
//  ContentEditCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-6.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

#define CONTENT_EDIT_CELL_HEIGHT 400

@protocol ContentEditCellDelegate;

@interface ContentEditCell : UITableViewCell<UITextViewDelegate>
@property (nonatomic) UIPlaceHolderTextView *contentEditText;
@property (assign, nonatomic) id<ContentEditCellDelegate> delegate;

- (void)setContentText:(NSString *)contentText;
@end

@protocol ContentEditCellDelegate<NSObject>
@optional
- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText;
- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView;
- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText;
- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView;
- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height;
@end
