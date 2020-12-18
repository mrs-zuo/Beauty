//
//  ContentEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-6.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ContentEditCell.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "DEFINE.h"

@implementation ContentEditCell
@synthesize contentEditText;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        contentEditText = [UIPlaceHolderTextView initNormalTextViewWithFrame:CGRectMake(0, 0.0f, 310.0f, CONTENT_EDIT_CELL_HEIGHT) text:@"" placeHolder:@""];
        contentEditText.textAlignment = NSTextAlignmentLeft;
        contentEditText.textColor = kColor_Editable;
        contentEditText.showsHorizontalScrollIndicator = NO;
        contentEditText.showsVerticalScrollIndicator = NO;
        contentEditText.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
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
    if (currentHeight < kTableView_HeightOfRow) {
        rect.origin.y = (kTableView_HeightOfRow - currentHeight)/2;
        currentHeight = kTableView_HeightOfRow;
    } else {
        rect.origin.y = 0.0f;
    }
    
    rect.size.height = currentHeight;
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

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(contentEditCell:textViewDidEndEditing:)]) {
        return [delegate contentEditCell:self textViewDidEndEditing:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //const char *ch = [text cStringUsingEncoding:NSUTF8StringEncoding];
    //if (*ch == 0) return YES;
    
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
    
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
        if (currentHeight < kTableView_HeightOfRow) {
            rect.origin.y = (kTableView_HeightOfRow - currentHeight)/2;
            currentHeight = kTableView_HeightOfRow;
        } else {
            rect.origin.y = 0.0f;
        }
        rect.size.height = currentHeight;
        contentEditText.frame = rect;
        
        [delegate contentEditCell:self textView:textView textViewCurrentHeight:currentHeight];
    }
}


@end
