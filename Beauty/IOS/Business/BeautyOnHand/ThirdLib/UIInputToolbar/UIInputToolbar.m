/*
 *  UIInputToolbar.m
 *
 *  Created by Brandon Hamilton on 2011/05/03.
 *  Copyright 2011 Brandon Hamilton.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "UIInputToolbar.h"
#import "FaceBoard.h"

@interface UIInputToolbar  ()<FaceBoardDelegate>
{
    FaceBoard *faceBoard;
    BOOL isSystemBoardShow;
}

@end
@implementation UIInputToolbar
- (void)emoInputButtonPressed:(UIButton *)sender{
    UIButton *btn = (UIButton *)sender;
    if (isSystemBoardShow) {
        isSystemBoardShow = !isSystemBoardShow;
        [btn setImage:[UIImage imageNamed:@"emoBtn"] forState:UIControlStateNormal];
        self.textView.internalTextView.inputView = nil;
    }else{
        isSystemBoardShow = !isSystemBoardShow;
        [btn setImage:[UIImage imageNamed:@"board_system"] forState:UIControlStateNormal];
        self.textView.internalTextView.inputView = faceBoard;
    }
    [self.textView.internalTextView reloadInputViews];
    [self.textView.internalTextView becomeFirstResponder];
    
}
-(void)inputButtonPressed
{
    if ([self.inputDelegate respondsToSelector:@selector(inputButtonPressed:)])
    {
        [self.inputDelegate inputButtonPressed:self.textView.text];
    }
    
    if (self.textView.text.length > 300) {
        [self.textView resignFirstResponder];
        return;
    }
    
    /* Remove the keyboard and clear the text */
    [self.textView resignFirstResponder];
    [self.textView clearText];
}

- (void)templateAction
{
    if ([self.inputDelegate respondsToSelector:@selector(chickTemplateButton)]) {
        [self.inputDelegate chickTemplateButton];
    }
}

-(void)setupToolbar:(NSString *)buttonLabel
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    self.tintColor = [UIColor lightGrayColor];
    
    /* Create custom send button*/
    //    UIImage *buttonImage = [UIImage imageNamed:@"chat_sendBtn_bg"];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    //    button.frame = CGRectMake(0, 0, 32, 32);
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:KColor_Blue];
    button.layer.cornerRadius = 8.0f;
    [button addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    self.inputButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.inputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    //表情键盘
    UIImage *emoButtonImage = [UIImage imageNamed:@"emoBtn"];
    
    UIButton *emoButton               = [UIButton buttonWithType:UIButtonTypeCustom];
    [emoButton setBackgroundImage:emoButtonImage forState:UIControlStateNormal];
    [emoButton addTarget:self action:@selector(emoInputButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [emoButton sizeToFit];
    
    self.emoInputButton = [[UIBarButtonItem alloc] initWithCustomView:emoButton];
    self.emoInputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    
    self.textView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(45 + 5, 7,215 - 50 - 5, 26)];
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(8.0f, 0.0f, 10.0f, 0.0f);
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.textView.maximumNumberOfLines = 10;
    self.textView.delegate = self;
    [self addSubview:self.textView];
    
    UIButton *templateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [templateBtn setImage:[UIImage imageNamed:@"chat_MsgTemplate"] forState:UIControlStateNormal];
    [templateBtn addTarget:self action:@selector(templateAction) forControlEvents:UIControlEventTouchUpInside];
    [templateBtn sizeToFit];
    
    self.templateButton = [[UIBarButtonItem alloc] initWithCustomView:templateBtn];
    self.templateButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *items = [NSArray arrayWithObjects:self.templateButton, flexItem,self.emoInputButton, self.inputButton, nil];
    [self setItems:items animated:NO];
    
    // 自定义键盘View
    if (!faceBoard) {
        faceBoard = [[FaceBoard alloc]init];
        faceBoard.delegate = self;
        faceBoard.inputTextView = self.textView.internalTextView;
    }
    
}

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:@"Send"];
    }
    return self;
}

-(id)init
{
    if ((self = [super init])) {
        [self setupToolbar:@"Send"];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    /* Draw custon toolbar background */
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIImage *backgroundImage = [UIImage imageNamed:@"toolbarbg.png"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
    [backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CGRect i = self.inputButton.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 5;
    i.origin.x = self.frame.size.width - 50;
    i.size.width = 44;
    i.size.height = 32;
    self.inputButton.customView.frame = i;
    
    //表情按钮位置
    CGRect emo_i = self.emoInputButton.customView.frame;
    // 如果是iPhone&&竖屏情况&&iphone5s
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        emo_i.origin.y = 0;
        emo_i.origin.x = -8;
    }
    else{
        emo_i.origin.y = self.frame.size.height - emo_i.size.height - 5;
        emo_i.origin.x = self.frame.size.width -  self.inputButton.customView.frame.size.width - 50 ;
    }
    self.emoInputButton.customView.frame = emo_i;
    
    CGRect j = self.templateButton.customView.frame;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        j.origin.x = 0;
        j.origin.y = 0;
    }
    else{
        j.origin.x = 5;
        j.origin.y = self.frame.size.height - j.size.height - 5;
    }
    self.templateButton.customView.frame = j;
}
#pragma mark -  faceBoardDelegate
/** ################################ UITextViewDelegate ################################ **/

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //点击了非删除键
    if( [text length] == 0 ) {
        
        if ( range.length > 1 ) {
            
            return YES;
        }
        else {
            
            [faceBoard backFace];
            
            return NO;
        }
    }
    else {
        
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self.textView clearText:textView];
}

#pragma mark -
#pragma mark UIExpandingTextView delegate

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (self.textView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    self.frame = r;
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextView:expandingTextView willChangeHeight:height];
    }
}

-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:@selector(expandingTextViewDidChange:)])
        [self.inputDelegate expandingTextViewDidChange:expandingTextView];
}

- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        return [self.inputDelegate expandingTextViewShouldReturn:expandingTextView];
    }
    
    return YES;
}

- (BOOL)expandingTextViewShouldBeginEditing:(UIExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        return [self.inputDelegate expandingTextViewShouldBeginEditing:expandingTextView];
    }
    return YES;
}

- (BOOL)expandingTextViewShouldEndEditing:(UIExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        return [self.inputDelegate expandingTextViewShouldEndEditing:expandingTextView];
    }
    return YES;
}

- (void)expandingTextViewDidBeginEditing:(UIExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextViewDidBeginEditing:expandingTextView];
    }
}

- (void)expandingTextViewDidEndEditing:(UIExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextViewDidEndEditing:expandingTextView];
    }
}

- (BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        return [self.inputDelegate expandingTextView:expandingTextView shouldChangeTextInRange:range replacementText:text];
    }
    
    //if ([expandingTextView.text length] > 300) return NO;
    return YES;
}

- (void)expandingTextView:(UIExpandingTextView *)expandingTextView didChangeHeight:(float)height
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextView:expandingTextView didChangeHeight:height];
    }
}

- (void)expandingTextViewDidChangeSelection:(UIExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextViewDidChangeSelection:expandingTextView];
    }
}

@end

