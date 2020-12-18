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

#import "BHInputToolbar.h"
#import "FaceBoard.h"

@interface BHInputToolbar  ()<FaceBoardDelegate>
{
    FaceBoard *faceBoard;
    BOOL isSystemBoardShow;
}

@end

@implementation BHInputToolbar
- (void)emoInputButtonPressed:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    if (isSystemBoardShow) {
        isSystemBoardShow = !isSystemBoardShow;
        [btn setImage:[UIImage imageNamed:@"emoBtn"] forState:UIControlStateNormal];
        self.textView.internalTextView.inputView = nil;
    } else {
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

    /* Remove the keyboard and clear the text */
    [self.textView resignFirstResponder];
    [self.textView clearText];
}

-(void)setupToolbar:(NSString *)buttonLabel
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    self.tintColor = [UIColor lightGrayColor];

    /* Create custom send button*/
    UIImage *buttonImage = [UIImage imageNamed:@"GroupMessageButtonClient"];
    buttonImage          = [buttonImage stretchableImageWithLeftCapWidth:floorf(buttonImage.size.width/2) topCapHeight:floorf(buttonImage.size.height/2)];

    UIButton *button               = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font         = [UIFont boldSystemFontOfSize:15.0f];
    button.titleLabel.shadowOffset = CGSizeMake(4,4);
    
    button.titleEdgeInsets         = UIEdgeInsetsMake(10, -10, 10, 2);
    //button.contentStretch          = CGRectMake(0.5, 0.5, 0, 0);
    //button.contentMode             = UIViewContentModeScaleToFill;

    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:buttonLabel forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchDown];
    [button sizeToFit];
    
    
    
    self.inputButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.inputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    /* Disable button initially */
    self.inputButton.enabled = NO;
    
    //表情键盘
    UIImage *emoButtonImage = [UIImage imageNamed:@"emoBtn"];
    UIButton *emoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emoButton setBackgroundImage:emoButtonImage forState:UIControlStateNormal];
    [emoButton addTarget:self action:@selector(emoInputButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [emoButton sizeToFit];
    
    self.emoInputButton = [[UIBarButtonItem alloc] initWithCustomView:emoButton];
    self.emoInputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    

    /* Create UIExpandingTextView input */
    self.textView = [[BHExpandingTextView alloc] initWithFrame:CGRectMake(7, 7, self.bounds.size.width - 110, 26)];
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.textView.delegate = self;
    [self addSubview:self.textView];

    /* Right align the toolbar button */
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    NSArray *items = [NSArray arrayWithObjects: flexItem,self.emoInputButton, self.inputButton, nil];
    [self setItems:items animated:NO];
    if (!faceBoard) {
        faceBoard = [[FaceBoard alloc] init];
        faceBoard.delegate = self;
        faceBoard.inputTextView = self.textView.internalTextView;
    }
}

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:@""];
    }
    return self;
}

-(id)init
{
    if ((self = [super init])) {
        [self setupToolbar:@""];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    /* Draw custon toolbar background */
    UIImage *backgroundImage = [UIImage imageNamed:@"Message_inputbg"];
    
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
    [backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
   
    //表情按钮位置
    CGRect emo_i = self.emoInputButton.customView.frame;
    emo_i.origin.y = self.frame.size.height - emo_i.size.height - 5;
    emo_i.origin.x = self.frame.size.width -  self.inputButton.customView.frame.size.width - 50 ;
    
    self.emoInputButton.customView.frame = emo_i;

    CGRect i = self.inputButton.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 5;
    i.origin.x = self.frame.size.width - 53;
    self.inputButton.customView.frame = i;
}
#pragma mark - faceBoardDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //点击了非删除键
    if ([text length] == 0) {
        if (range.length  > 1) {
            return YES;
        } else {
            [faceBoard backFace];
            return NO;
        }
    }
    else {
        return YES;
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    [self.textView clearText:textView];
}

#pragma mark -
#pragma mark UIExpandingTextView delegate

-(void)expandingTextView:(BHExpandingTextView *)expandingTextView willChangeHeight:(float)height
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

-(void)expandingTextViewDidChange:(BHExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
    if ([expandingTextView.text length] > 0)
        self.inputButton.enabled = YES;
    else
        self.inputButton.enabled = NO;
    if ([self.inputDelegate respondsToSelector:@selector(expandingTextViewDidChange:)])
        [self.inputDelegate expandingTextViewDidChange:expandingTextView];
}

- (BOOL)expandingTextViewShouldReturn:(BHExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        return [self.inputDelegate expandingTextViewShouldReturn:expandingTextView];
    }
    
    return YES;
}

- (BOOL)expandingTextViewShouldBeginEditing:(BHExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        return [self.inputDelegate expandingTextViewShouldBeginEditing:expandingTextView];
    }
    return YES;
}

- (BOOL)expandingTextViewShouldEndEditing:(BHExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        return [self.inputDelegate expandingTextViewShouldEndEditing:expandingTextView];
    }
    return YES;
}

- (void)expandingTextViewDidBeginEditing:(BHExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextViewDidBeginEditing:expandingTextView];
    }
}

- (void)expandingTextViewDidEndEditing:(BHExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextViewDidEndEditing:expandingTextView];
    }
}

- (BOOL)expandingTextView:(BHExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        return [self.inputDelegate expandingTextView:expandingTextView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)expandingTextView:(BHExpandingTextView *)expandingTextView didChangeHeight:(float)height
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextView:expandingTextView didChangeHeight:height];
    }
}

- (void)expandingTextViewDidChangeSelection:(BHExpandingTextView *)expandingTextView
{
    if ([self.inputDelegate respondsToSelector:_cmd]) {
        [self.inputDelegate expandingTextViewDidChangeSelection:expandingTextView];
    }
}

@end
