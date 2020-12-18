//
//  ComplexEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-13.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CusEditComplexCell.h"
#import "CustomerDoc.h"
#import "PhoneDoc.h"
#import "EmailDoc.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"
#import "DEFINE.h"
#import "UIButton+InitButton.h"
#import "noCopyTextField.h"

@implementation CusEditComplexCell
@synthesize typeText;
@synthesize titleLabel;
@synthesize contentText;
@synthesize deleteButton;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f ,0.0f, 40.0f, kTableView_HeightOfRow) title:@"--"];
        titleLabel.font = kFont_Light_16;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = kColor_DarkBlue;
        [self.contentView addSubview:titleLabel];

        contentText = [UITextField initNormalTextViewWithFrame:CGRectMake(40.0f ,0.0f, 190.0f, kTableView_HeightOfRow) text:@"" placeHolder:@"输入电话号码"];
        contentText.textAlignment = NSTextAlignmentRight;
        contentText.font = kFont_Light_16;
        [self.contentView addSubview:contentText];
        
        //typeText = [noCopyTextField initNormalTextViewWithFrame:CGRectMake(220.0f, 0.0f, 50.0f, kTableView_HeightOfRow) text:@"" placeHolder:@"--"];
        typeText = [[noCopyTextField alloc] initWithFrame:CGRectMake(220.0f, 0.0f, 50.0f, kTableView_HeightOfRow)];
        typeText.textAlignment = NSTextAlignmentRight;
        typeText.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        typeText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        typeText.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        typeText.font = kFont_Light_16;
        typeText.textColor = kColor_DarkBlue;
        if ((IOS7 || IOS8)) {
            typeText.tintColor = [UIColor clearColor];
        }
        [self.contentView addSubview:typeText];
        
        
        deleteButton = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(deleteAction)
                                           frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                   backgroundImg:[UIImage imageNamed:@"icon_delete"]
                                highlightedImage:nil];
        [self.contentView addSubview:deleteButton];
        
        
        contentText.tag = 99;
        typeText.tag = 102;
        deleteButton.tag = 103;
    }
    return self;
}

#pragma mark - Be called outside

- (void)canEdit:(BOOL)editable
{
    if (!editable) {
        [self.deleteButton setHidden:YES];
        CGRect contentTextRect = self.contentText.frame;
        contentTextRect.origin.x = contentTextRect.origin.x + 30;
        self.contentText.frame = contentTextRect;
        
        CGRect typeTextRect = self.typeText.frame;
        typeTextRect.origin.x = typeTextRect.origin.x + 30;
        self.typeText.frame = typeTextRect;
    
        [contentText setEnabled:NO];
        [typeText setEnabled:NO];
        contentText.delegate = nil;
        typeText.delegate = nil;
    }
}

#pragma mark - Action

- (void)deleteAction
{
    if ([delegate respondsToSelector:@selector(deleteCellWithCell:)]) {
        [delegate deleteCellWithCell:self];
    }
}

//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    [customerEditViewController editedTextField:textField cell:self];
//    theIndexPath = [customerEditViewController indexPathForCell:self];
//    
//    if (textField == typeText) {
//        [customerEditViewController setCustomKeyboardWithSection:theIndexPath.section textField:typeText selectedText:typeText.text];
//    }
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (textField == contentText) {
//        const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
//        if (*ch == 0) return YES;
//        if (*ch == 32) return NO;
//        
//        int maxLength = 0;
//        switch (theIndexPath.section) {
//            case 0: maxLength = 20; break;
//            case 1: maxLength = 50; break;
//        }
//        if ([textField.text length] >maxLength )
//            return NO;
//    }
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (textField == contentText) {
//        switch (theIndexPath.section) {
//            case 0:
//            {
//                PhoneDoc *phone = [[customerEditViewController phoneArray] objectAtIndex:theIndexPath.row];
//                if (![phone.ph_PhoneNum isEqualToString:textField.text]) {
//                    if (phone.ph_ID == 0) {
//                        [phone setCtlFlag:1];
//                    } else {
//                        [phone setCtlFlag:2];
//                    }
//                    [phone setPh_PhoneNum:textField.text];
//                }
//            } break;
//            case 1:
//            {
//                EmailDoc *email = [[customerEditViewController emailArray] objectAtIndex:theIndexPath.row];
//                if (![email.email_Email isEqualToString:textField.text]) {
//                    if (email.email_ID == 0) {
//                        [email setCtlFlag:1];
//                    } else {
//                        [email setCtlFlag:2];
//                    }
//                  //  [email setCtlFlag:2];
//                    [email setEmail_Email:textField.text];
//                }
//            
//            } break;
//        }
//    }
//    return YES;
//}
@end
