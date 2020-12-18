//
//  RemarkEditCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/1.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "RemarkEditCell.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "DEFINE.h"

@implementation RemarkEditCell
@synthesize contentEditText;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        contentEditText = [UIPlaceHolderTextView initNormalTextViewWithFrame:CGRectMake(10.0f, 10.0f, 310.0f, CONTENT_EDIT_CELL_HEIGHT) text:@"" placeHolder:@""];
        contentEditText.textAlignment = NSTextAlignmentLeft;
        contentEditText.textColor = kColor_Editable;
        contentEditText.font=kNormalFont_14;
        contentEditText.showsHorizontalScrollIndicator = NO;
        contentEditText.showsVerticalScrollIndicator = NO;
//        contentEditText.contentInset = UIEdgeInsetsMake(10.0f, 10.0f, 0.0f, 0.0f);
        contentEditText.scrollEnabled = NO;
        contentEditText.returnKeyType = UIReturnKeyDone;
        contentEditText.delegate = self;
        [self.contentView addSubview:contentEditText];
    }
    return self;
}

- (void)setContentText:(NSString *)contentText
{
    contentEditText.text = contentText;
    
    CGFloat currentHeight = 0.0f;
    if ((IOS7 || IOS8)) {
        CGSize size = [contentEditText sizeThatFits:CGSizeMake(310.0f, FLT_MAX)];
        currentHeight = size.height;
    } else {
        CGSize size = [contentEditText contentSize];
        currentHeight = size.height;
    }
    
    CGRect rect = contentEditText.frame;
    if (self.tag == 1088) {
        if (currentHeight < 100) {
            rect.origin.y = (100 - currentHeight)/2;
            currentHeight = 100;
        } else {
            
            rect.origin.y = 0.0f;
        }
    }else{
        if (currentHeight < kTableView_DefaultCellHeight) {
            rect.origin.y = (kTableView_DefaultCellHeight - currentHeight)/2;
            currentHeight = kTableView_DefaultCellHeight;
        } else {
            rect.origin.y = 0.0f;
        }
    }
    
    rect.size.height = currentHeight +10 ;
    contentEditText.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(contentEditCell:textViewShouldBeginEditing:)]) {
        return [delegate contentEditCell:self textViewShouldBeginEditing:textView];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(contentEditCell:textViewDidBeginEditing:)]) {
        return [delegate contentEditCell:self textViewDidBeginEditing:textView];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(contentEditCell:textViewShouldEndEditing:)]) {
        return  [delegate contentEditCell:self textViewShouldEndEditing:contentEditText];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(contentEditCell:textViewDidEndEditing:)]) {
        return [delegate contentEditCell:self textViewDidEndEditing:textView];
    }
    
}

- (void)contentEditCell:(RemarkEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(contentEditCell:textViewDidEndEditing:)]) {
        return [delegate contentEditCell:self textViewDidEndEditing:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([delegate respondsToSelector:@selector(contentEditCell:textView:shouldChangeTextInRange:replacementText:)]) {
        return [delegate contentEditCell:self textView:contentEditText shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(contentEditCell:textView:textViewCurrentHeight:)]) {
        
        CGFloat currentHeight = [textView sizeThatFits:CGSizeMake(310.0f, FLT_MAX)].height;
        CGRect rect = contentEditText.frame;
        if (self.tag == 1088) {
            if (currentHeight < 100) {
                rect.origin.y = (100 - currentHeight)/2;
                currentHeight = 100;
            } else {
                
                rect.origin.y = 0.0f;
            }
        }else{
            if (currentHeight < kTableView_DefaultCellHeight) {
                rect.origin.y = (kTableView_DefaultCellHeight - currentHeight)/2;
                currentHeight = kTableView_DefaultCellHeight;
            } else {
                
                rect.origin.y = 0.0f;
            }
        }
        rect.size.height = currentHeight +10;
        contentEditText.frame = rect;
        
        [delegate contentEditCell:self textView:textView textViewCurrentHeight:currentHeight];
    }
}


@end
