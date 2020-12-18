//
//  LevelDateCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "LevelDateCell.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "UITextView+InitTextView.h"
//#import "CustomerLevelViewController.h"
#import "LevelDoc.h"
#import "DEFINE.h"

@interface LevelDateCell ()
@property (strong, nonatomic) LevelDoc *theLevelDoc;
@end

@implementation LevelDateCell
@synthesize nameText, discountText, deleteBtn;
@synthesize theLevelDoc, customerLevelViewController, delegate;

- (void)initialKeyboard
{
    self.nameText.keyboardType = UIKeyboardTypeDefault;
    self.nameText.returnKeyType=UIReturnKeyDone;
    self.discountText.keyboardType = UIKeyboardTypeDefault;
    self.discountText.returnKeyType=UIReturnKeyDone;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        nameText = [UITextView initNormalTextViewWithFrame:CGRectMake(10.0f, 7.0f, 150.0f, 30.0f) text:@"白金卡"];
        [nameText setTag:100];
        [nameText setFont:kFont_Light_16];
        [nameText setBackgroundColor:[UIColor clearColor]];
        nameText.textAlignment = NSTextAlignmentLeft;
        nameText.scrollEnabled = NO;
        nameText.delegate = self;
        [[self contentView] addSubview:nameText];
        
        
        discountText = [UITextView initNormalTextViewWithFrame:CGRectMake(170.0f, 7.0f, 105.0f, 30.0f) text:@"1折"];
        [discountText setTag:101];
        [discountText setFont:kFont_Light_16];
        [discountText setBackgroundColor:[UIColor clearColor]];
        discountText.textAlignment = NSTextAlignmentRight;
        discountText.scrollEnabled = NO;
        discountText.delegate = self;
        [[self contentView] addSubview:discountText];
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = deleteBtn;
        
        [self initialKeyboard];
    }
    return self;
}

- (void)updateData:(LevelDoc *)levelDoc {
    theLevelDoc = levelDoc;
    nameText.text = theLevelDoc.level_Name;
    discountText.text = [[NSString stringWithFormat:@"%.2lf",theLevelDoc.level_Discount] stringByAppendingString:@"折"];
}

- (void)deleteAction
{
    if ([delegate respondsToSelector:@selector(chickDeleteRowButton:)]) {
        [delegate chickDeleteRowButton:self];
    }
}

- (void)textChanged
{    
    theLevelDoc.level_Name = self.nameText.text;
    theLevelDoc.level_Discount = [self.discountText.text floatValue];
    [self updateLevel];
}

- (void)dismissKeyBoard
{
    if (customerLevelViewController.tableView.frame.origin.y != 0) {
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        CGRect tableFrame = customerLevelViewController.tableView.frame;
        tableFrame.origin.y = 0;
        customerLevelViewController.tableView.frame = tableFrame;
        
        [customerLevelViewController.tableView setFrame:CGRectMake(-5.0f, 35.0f, tableFrame.size.width, tableFrame.size.height)];
        [UIView commitAnimations];
    }
    [customerLevelViewController.textView_Selected resignFirstResponder];
}

// 更新Schedule
- (void)updateLevel
{
    [customerLevelViewController updateWithLevelDoc:theLevelDoc cell:self];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){        
        [self dismissKeyBoard];
        return NO;
    }
    
//    if ([self.nameText.text length] >= 6) return NO;
//    if ([self.discountText.text length] >= 6) return NO;
    
    return YES;
    
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    customerLevelViewController.textView_Selected = textView;
    customerLevelViewController.text_Height = textView.contentSize.height;
    
    CGRect textRect = [textView convertRect:textView.bounds toView:customerLevelViewController.tableView];
    customerLevelViewController.text_Y = textRect.origin.y + textView.contentSize.height  + 44.0f;
    
    [self keyboardWillShow];
    
    [customerLevelViewController setTextView_Selected:textView];
    return YES;
}

- (void)keyboardWillShow
{
    CGFloat keyboard_Hegith = 252.0f - 44.0f;
    CGFloat keyboard_Y = kSCREN_BOUNDS.size.height - 20.0f - keyboard_Hegith;
    CGFloat offSet = 0.0f;
    if (customerLevelViewController.text_Y > keyboard_Y) {
        offSet = - (customerLevelViewController.text_Y - keyboard_Y + 15.0f) ;
        
        if (offSet < - keyboard_Hegith) {
            offSet = - keyboard_Hegith;
        }
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        
        CGRect tableFrame = customerLevelViewController.tableView.frame;
        tableFrame.origin.y = offSet;
        customerLevelViewController.tableView.frame = tableFrame;
        [UIView commitAnimations];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self textChanged];
}

@end
