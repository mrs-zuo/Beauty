//
//  NumTextField.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-2-2.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "NumTextField.h"

@implementation NumTextField
@synthesize startBlock;
@synthesize endBlock;
@synthesize textLength;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.textLength = 11;
        [self addTarget:self action:@selector(textFieldViewDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.textLength = 11;
        self.keyboardType = UIKeyboardTypeDecimalPad;
        [self addTarget:self action:@selector(textFieldViewDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    }
    return  self;
}



#pragma mark NumTextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.startBlock) {
        self.startBlock((NumTextField*)textField);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    static NSCharacterSet *characterSet = nil;
    if (characterSet == nil) {
        characterSet = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
    }

    const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    
    __block BOOL result = YES;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring rangeOfCharacterFromSet:characterSet].location == NSNotFound) {
            result = NO;
            *stop = YES;
        }
    }];
    
    NSRange dotRange = [textField.text rangeOfString:@"." ];
    
    [string rangeOfString:@"."];
    if (dotRange.location != NSNotFound && (textField.text.length - dotRange.location > 2 || [string isEqualToString:@"."])) {
        return NO;
    }
    return result;
}

- (void)textFieldViewDidChange:(UITextField *)sender
{
    if (sender.text.length > self.textLength && (NumTextField *)sender.markedTextRange == nil) {
        sender.text = [sender.text substringToIndex:self.textLength];
    }

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.endBlock) {
        endBlock((NumTextField *)textField);
    }
}
@end
