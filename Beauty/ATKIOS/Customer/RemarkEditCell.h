//
//  RemarkEditCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/1.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

#define CONTENT_EDIT_CELL_HEIGHT 400

@protocol ContentEditCellDelegate;

@interface RemarkEditCell : UITableViewCell<UITextViewDelegate>

@property (nonatomic) UIPlaceHolderTextView *contentEditText;

@property (assign, nonatomic) id<ContentEditCellDelegate> delegate;

- (void)setContentText:(NSString *)contentText;

@end

@protocol ContentEditCellDelegate<NSObject>

@optional
- (BOOL)contentEditCell:(RemarkEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText;
- (void)contentEditCell:(RemarkEditCell *)cell textViewDidBeginEditing:(UITextView *)textView;
- (BOOL)contentEditCell:(RemarkEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText;
- (void)contentEditCell:(RemarkEditCell *)cell textViewDidEndEditing:(UITextView *)textView;
- (BOOL)contentEditCell:(RemarkEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)contentEditCell:(RemarkEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height;


@end
