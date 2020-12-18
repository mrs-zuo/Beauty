//
//  UIPlaceHolderTextView.m
//  MLPark
//
//  Created by MLi-A-0002 on 12-11-20.
//  Copyright (c) 2012年 上海名立信息技术服务有限公司. All rights reserved.
//

#import "UIPlaceHolderTextView.h"

@interface UIPlaceHolderTextView()


// 1、placehoderTextAlignment 默认为NSTextAlignmentLeft
// 2、设置placehoder的textAlignment为NSTextAligmentCenter or NSTextAlignmentRight是 必须placeholder显示为一行  否则 "..."显示
@property (assign, nonatomic) NSTextAlignment placeholderTextAlignment;

-(void)textChanged:(NSNotification*)notification;
@end

@implementation UIPlaceHolderTextView
@synthesize placeHolderLabel;
@synthesize placeholder;
@synthesize placeholderColor;
@synthesize placeholderTextAlignment;
@synthesize leftMargin;

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        leftMargin = 8.0f;
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [self setPlaceholderTextAlignment:NSTextAlignmentLeft];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setPlaceholderTextAlignment:textAlignment];
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0) return;
    
    if([[self text] length] == 0) {
        [[self viewWithTag:999] setAlpha:1];
    } else {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 ) {
        
        if (placeholderTextAlignment == NSTextAlignmentLeft) {
            if ( placeHolderLabel == nil ) {
                placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin,(kTableView_DefaultCellHeight/2-8),self.bounds.size.width - 16,16)];
                placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
                placeHolderLabel.numberOfLines = 0;
                placeHolderLabel.font = self.font;
                placeHolderLabel.backgroundColor = [UIColor clearColor];
                placeHolderLabel.textColor = self.placeholderColor;
                placeHolderLabel.alpha = 0;
                placeHolderLabel.tag = 999;
                [self addSubview:placeHolderLabel];
            }
            placeHolderLabel.text = self.placeholder;
            [placeHolderLabel sizeToFit];
            [self sendSubviewToBack:placeHolderLabel];
        
        } else if (placeholderTextAlignment != NSTextAlignmentLeft) {
            if ( placeHolderLabel == nil ) {
                placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin,kTableView_DefaultCellHeight/2-8,self.bounds.size.width - 16,16)];
                placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
                placeHolderLabel.numberOfLines = 1;
                placeHolderLabel.font = self.font;
                placeHolderLabel.backgroundColor = [UIColor clearColor];
                placeHolderLabel.textColor = self.placeholderColor;
                placeHolderLabel.alpha = 0;
                placeHolderLabel.tag = 999;
                [self addSubview:placeHolderLabel];
            }
            placeHolderLabel.textAlignment = placeholderTextAlignment;
            placeHolderLabel.text = self.placeholder;
            [self sendSubviewToBack:placeHolderLabel];
        }
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 ) {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}



@end
