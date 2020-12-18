/*
 *  UIExpandingTextView.m
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

/*
 *  This class is based on growingTextView by Hans Pickaers
 *  http://www.hanspinckaers.com/multi-line-uitextview-similar-to-sms
 */

#import "UIExpandingTextView.h"
#import "DEFINE.h"

#define kTextInsetX 4
#define kTextInsetBottom 0

@interface UIExpandingTextView ()

@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, assign) int minimumHeight;
@property (nonatomic, assign) int maximumHeight;

@property (nonatomic, assign) BOOL forceSizeUpdate;

@end

@implementation UIExpandingTextView

- (void)setPlaceholder:(NSString *)placeholders
{
    _placeholder = placeholders;
    self.placeholderLabel.text = placeholders;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
    
        self.forceSizeUpdate = NO;
           // self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		CGRect backgroundFrame = frame;
        backgroundFrame.origin.y = 0;
		backgroundFrame.origin.x = 0;

        CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, 0);
        //textViewFrame.size.height -= 8.0f;
        
        /* Internal Text View component */
		self.internalTextView = [[UIExpandingTextViewInternal alloc] initWithFrame:textViewFrame];
		self.internalTextView.delegate        = self;
		self.internalTextView.font            = [UIFont systemFontOfSize:15.0];
		self.internalTextView.contentInset    = UIEdgeInsetsMake(-4,0,-4,0);
        self.internalTextView.text            = @"-";
		self.internalTextView.scrollEnabled   = NO;
        self.internalTextView.opaque          = NO;
        self.internalTextView.backgroundColor = [UIColor clearColor];
        self.internalTextView.showsHorizontalScrollIndicator = NO;
        [self.internalTextView sizeToFit];
        //self.internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        /* set placeholder */
        self.placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,3,self.bounds.size.width - 16,self.bounds.size.height)];
        self.placeholderLabel.text = self.placeholder;
        self.placeholderLabel.font = self.internalTextView.font;
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.textColor = [UIColor grayColor];
        [self.internalTextView addSubview:self.placeholderLabel];

        /* Custom Background image */
        UIImage *textImage = [UIImage imageNamed:@"textbg"];
        self.textViewBackgroundImage = [[UIImageView alloc] initWithFrame:backgroundFrame];
        self.textViewBackgroundImage.image          = [textImage stretchableImageWithLeftCapWidth:floorf(textImage.size.width/2)
                                                                                     topCapHeight:floorf(textImage.size.height/2)];
       // [self.textViewBackgroundImage setImage: [textImage]]
        self.textViewBackgroundImage.contentMode    = UIViewContentModeScaleToFill;
        [self addSubview:self.textViewBackgroundImage];
        [self addSubview:self.internalTextView];

        /* Calculate the text view height */
		UIView *internal = (UIView*)[[self.internalTextView subviews] objectAtIndex:0];
		self.minimumHeight = internal.frame.size.height;
		[self setMinimumNumberOfLines:1];
		self.animateHeightChange = YES;
		self.internalTextView.text = @"";
		[self setMaximumNumberOfLines:13];
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordCountCheck:) name:UITextViewTextDidChangeNotification object:self.internalTextView];
        [self sizeToFit];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self.internalTextView];
}
-(void)sizeToFit
{
    CGRect r = self.frame;
    if ([self.text length] > 0)
    {
        /* No need to resize is text is not empty */
        return;
    }
    r.size.height = self.minimumHeight + kTextInsetBottom;
    self.frame = r;
}

-(void)setFrame:(CGRect)aframe
{
    CGRect backgroundFrame   = aframe;
    backgroundFrame.origin.y = 0;
    backgroundFrame.origin.x = 0;
    
    CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, 0);
	self.internalTextView.frame   = textViewFrame;
    
    backgroundFrame.size.height  -= 8;
    self.textViewBackgroundImage.frame = backgroundFrame;
    
    self.forceSizeUpdate = YES;
	[super setFrame:aframe];
}

-(void)clearText:(UITextView *)textView;
{
    [self textViewDidChange:textView];
}
-(void)clearText
{
    self.text = @"";
    [self textViewDidChange:self.internalTextView];
}

-(void)setMaximumNumberOfLines:(int)n
{
    BOOL didChange            = NO;
    self.internalTextView.hidden   = YES;
    self.internalTextView.delegate = nil;
   
    CGSize contentSize = self.internalTextView.contentSize;
    contentSize.height = 18.0f * n;
    self.internalTextView.contentSize = contentSize;
    
    didChange = (self.maximumHeight != self.internalTextView.contentSize.height);
    self.maximumHeight             = self.internalTextView.contentSize.height;
    
    contentSize.height = 35.0f;
    self.internalTextView.contentSize = contentSize;
    
    CGRect rect = self.internalTextView.frame;
    rect.size.height = 35.0f;
    self.internalTextView.frame = rect;
    
    _maximumNumberOfLines      = n;
    self.internalTextView.hidden   = NO;
    self.internalTextView.delegate = self;
    if (didChange) {
        self.forceSizeUpdate = YES;
        [self textViewDidChange:self.internalTextView];
    }
}

-(void)setMinimumNumberOfLines:(int)m
{
    self.internalTextView.hidden   = YES;
    self.internalTextView.delegate = nil;

    CGSize contentSize = self.internalTextView.contentSize;
    contentSize.height = 35.0f;
    self.internalTextView.contentSize = contentSize;
    
    self.minimumHeight             = self.internalTextView.contentSize.height;
    self.internalTextView.hidden   = NO;
    self.internalTextView.delegate = self;
    [self sizeToFit];
    _minimumNumberOfLines = m;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    if(textView.text.length == 0)
        self.placeholderLabel.alpha = 1;
    else
        self.placeholderLabel.alpha = 0;

    float newHeight = 0.0f;
    if (IOS6) {
        newHeight = self.internalTextView.contentSize.height;
    } else if ((IOS7 || IOS8)) {
        CGSize size = [self.internalTextView.text sizeWithFont:kFont_Light_18 constrainedToSize:CGSizeMake(199.439987, 300)];
        if (size.height > 18.0f) {
            newHeight = size.height + 24.0f;
        } else {
            newHeight = self.minimumHeight;
        }
    }

	if(newHeight < self.minimumHeight || !self.internalTextView.hasText)
    {
        newHeight = self.minimumHeight;
    }

	if (self.internalTextView.frame.size.height != newHeight || self.forceSizeUpdate)
	{
        self.forceSizeUpdate = NO;
    
        if (newHeight > self.maximumHeight && self.internalTextView.frame.size.height <= self.maximumHeight)
        {
            newHeight = self.maximumHeight;
        }
        
		if (newHeight <= self.maximumHeight)
		{
			if(self.animateHeightChange)
            {
				[UIView beginAnimations:@"" context:nil];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(growDidStop)]; // didChangeHeight
				[UIView setAnimationBeginsFromCurrentState:YES];
			}

			if ([self.delegate respondsToSelector:@selector(expandingTextView:willChangeHeight:)])
            {
				[self.delegate expandingTextView:self willChangeHeight:(newHeight+ kTextInsetBottom)];
			}

			CGRect r = self.frame;
			r.size.height = newHeight + kTextInsetBottom;
			self.frame = r;
			r.origin.y = 0;
			r.origin.x = 0;
             r.size.height -= 8;
            self.internalTextView.frame = CGRectInset(r, kTextInsetX, 0);
           

            self.textViewBackgroundImage.frame = r;

			if(self.animateHeightChange)
            {
				[UIView commitAnimations];
			}
            else if ([self.delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)])
            {
                [self.delegate expandingTextView:self didChangeHeight:(newHeight+ kTextInsetBottom)];
            }
		}

		if (newHeight >= self.maximumHeight)
		{
            /* Enable vertical scrolling */
			if(!self.internalTextView.scrollEnabled)
            {
				self.internalTextView.scrollEnabled = YES;
				[self.internalTextView flashScrollIndicators];
			}
		}
        else
        {
            /* Disable vertical scrolling */
			self.internalTextView.scrollEnabled = NO;
		}
	}

    
    
	if ([self.delegate respondsToSelector:@selector(expandingTextViewDidChange:)])
    {
		[self.delegate expandingTextViewDidChange:self];
	}
}

-(void)growDidStop
{
	if ([self.delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)])
    {
		[self.delegate expandingTextView:self didChangeHeight:self.frame.size.height];
	}
}

-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	return [self.internalTextView resignFirstResponder];
}

#pragma mark UITextView properties

-(void)setText:(NSString *)atext
{
	self.internalTextView.text = atext;
    [self performSelector:@selector(textViewDidChange:) withObject:self.internalTextView];
}

-(NSString*)text
{
	return self.internalTextView.text;
}

-(void)setFont:(UIFont *)afont
{
	self.internalTextView.font= afont;
	[self setMaximumNumberOfLines:self.maximumNumberOfLines];
	[self setMinimumNumberOfLines:self.minimumNumberOfLines];
}

-(UIFont *)font
{
	return self.internalTextView.font;
}

-(void)setTextColor:(UIColor *)color
{
	self.internalTextView.textColor = color;
}

-(UIColor*)textColor
{
	return self.internalTextView.textColor;
}

-(void)setTextAlignment:(NSTextAlignment)aligment
{
	self.internalTextView.textAlignment = aligment;
}

-(NSTextAlignment)textAlignment
{
	return self.internalTextView.textAlignment;
}

-(void)setSelectedRange:(NSRange)range
{
	self.internalTextView.selectedRange = range;
}

-(NSRange)selectedRange
{
	return self.internalTextView.selectedRange;
}

-(void)setEditable:(BOOL)beditable
{
	self.internalTextView.editable = beditable;
}

-(BOOL)isEditable
{
	return self.internalTextView.editable;
}

-(void)setReturnKeyType:(UIReturnKeyType)keyType
{
	self.internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType
{
	return self.internalTextView.returnKeyType;
}

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
	self.internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes
{
	return self.internalTextView.dataDetectorTypes;
}

- (BOOL)hasText
{
	return [self.internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
	[self.internalTextView scrollRangeToVisible:range];
}

#pragma mark -
#pragma mark UIExpandingTextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	if ([self.delegate respondsToSelector:@selector(expandingTextViewShouldBeginEditing:)])
    {
		return [self.delegate expandingTextViewShouldBeginEditing:self];
	}
    else
    {
		return YES;
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	if ([self.delegate respondsToSelector:@selector(expandingTextViewShouldEndEditing:)])
    {
		return [self.delegate expandingTextViewShouldEndEditing:self];
	}
    else
    {
		return YES;
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if ([self.delegate respondsToSelector:@selector(expandingTextViewDidBeginEditing:)])
    {
		[self.delegate expandingTextViewDidBeginEditing:self];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if ([self.delegate respondsToSelector:@selector(expandingTextViewDidEndEditing:)])
    {
		[self.delegate expandingTextViewDidEndEditing:self];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext
{
 
//   NSLog(@"%@  %ld %ld  %@",textView.text,range.length,range.location,atext);
//    // add by zhangwei map "输入三百个字符不在让其输入"
//    if(textView.text.length >= 300 && atext.length > 0)
//        return  NO;
//    const char *ch = [atext cStringUsingEncoding:NSUTF8StringEncoding];
//    if (*ch == 0) return YES;
//    if (*ch == 32) return NO;
//    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
//    if([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"])
//    {
//        UITextRange *range =  [textView markedTextRange];
//        UITextPosition *pos = [textView positionFromPosition:range.start offset:0];
//        if (!pos) {
//            if (textView.text.length >= 300) {
//                return NO;
//            }
//        }
//    }else
//    {
//        if (textView.text.length >= 300) {
//            return NO;
//        }
//    }
//	if ([atext isEqualToString:@"\n"])
//    {
//		if ([self.delegate respondsToSelector:@selector(expandingTextViewShouldReturn:)])
//        {
//			if (![self.delegate performSelector:@selector(expandingTextViewShouldReturn:) withObject:self])
//            {
//				return YES;
//			}
//            else
//            {
//				[textView resignFirstResponder];
//				return NO;
//			}
//		}
//	}
//	return YES;
    
    const char *ch = [atext cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    //if (*ch == 32) return NO;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (!position) {
            if (textView.text.length >= 300) {
                return NO;
            }
        }
    } else {
        if (textView.text.length >= 300) {
            return NO;
        }
    }
    if ([atext isEqualToString:@""]) {
        return YES;
    }
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
	if ([self.delegate respondsToSelector:@selector(expandingTextViewDidChangeSelection:)])
    {
		[self.delegate expandingTextViewDidChangeSelection:self];
	}
}
#pragma mark -WordCheck

- (void)wordCountCheck:(NSNotification *)notiFi
{
    UITextView *textView = (UITextView *)notiFi.object;
    NSString *textContext = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (!position) {
            if (textView.text.length >= 300) {
                textView.text = [textContext substringToIndex:300];
            }
        }
    } else {
        if (textView.text.length >= 300) {
            textView.text = [textContext substringToIndex:300];
        }
    }
}
@end
