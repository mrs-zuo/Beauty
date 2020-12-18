//
//  CusEditAddressCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CusEditAddressCell.h"
#import "UIPlaceHolderTextView.h"
#import "AddressDoc.h"
#import "UITextField+InitTextField.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "DEFINE.h"
#import "noCopyTextField.h"

@implementation CusEditAddressCell
@synthesize zipText;
@synthesize adrsText;
@synthesize typeText;
@synthesize deleteButton;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        zipText  = [UITextField initNormalTextViewWithFrame:CGRectMake(10.0f, 2.0f, 220.0f, 34.0f) text:@"" placeHolder:@"输入邮政编号"];
        [self.contentView addSubview:zipText];
        
        adrsText = [UIPlaceHolderTextView initNormalTextViewWithFrame:CGRectMake(2.0f, 25.0f, 290.0f, 34.0f) text:@"" placeHolder:@"输入地址"];
        adrsText.placeholderColor = [UIColor colorWithWhite:0.6 alpha:0.8f];
        adrsText.leftMargin = 8.0f;
        adrsText.scrollEnabled = NO;
        [self.contentView addSubview:adrsText];
        
        //typeText = [noCopyTextField initNormalTextViewWithFrame:CGRectMake(220.0f, 2.0f, 50.0f, 34.0f) text:@"" placeHolder:@"输入电话号码"];
        typeText = [[noCopyTextField alloc] initWithFrame:CGRectMake(220.0f, 2.0f, 50.0f, 34.0f)];
        typeText.placeholder = @"输入电话号码";
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
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(275.0f, 2.0f, 30.0f, 30.0f)];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteButton];
        
        
        zipText.tag = 100;
        adrsText.tag = 101;
        typeText.tag = 102;
        deleteButton.tag = 103;
    }
    return self;
}

- (void)deleteAction
{
    if ([delegate respondsToSelector:@selector(deleteCellWithCell:)]) {
        [delegate deleteCellWithCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)updateData:(AddressDoc *)address
{
    self.typeText.text = address.adrsType;
    self.zipText.text = address.adrs_ZipCode;
    self.adrsText.text = address.adrs_Address;
    
    CGRect rect = self.adrsText.frame;
    rect.size.height = address.cell_Address_Height;
    self.adrsText.frame = rect;
}

- (void)canEdit:(BOOL)editable
{
    if (!editable) {
        [self.deleteButton setHidden:YES];
        CGRect typeTextRect = self.typeText.frame;
        typeTextRect.origin.x = typeTextRect.origin.x + 30;
        self.typeText.frame = typeTextRect;
        
        [adrsText setEditable:NO];
        [typeText setEnabled:NO];
        adrsText.delegate = nil;
        typeText.delegate = nil;
    }
}

//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    [customerEditController editedTextField:textField cell:self];
//    
//    if (textField == typeText) {
//        NSIndexPath *indexPath = [customerEditController indexPathForCell:self];
//        [customerEditController setCustomKeyboardWithSection:indexPath.section textField:typeText selectedText:typeText.text];
//    }
//    
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (textField == zipText) {
//        const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
//        if (*ch == 0) return YES;
//        if (*ch == 32) return NO;
//        
//        if ([textField.text length] > 10)
//            return NO;
//    }
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (textField == zipText) {
//        NSIndexPath *theIndexPath = [customerEditController indexPathForCell:self];
//        AddressDoc *theAddress = [customerEditController.addressArray objectAtIndex:theIndexPath.row -1];
//        if (![theAddress.adrs_ZipCode isEqualToString:textField.text]) {
//            if (theAddress.adrs_Id == 0) {
//                [theAddress setCtlFlag:1];
//            } else {
//                 [theAddress setCtlFlag:2];
//            }
//            [theAddress setAdrs_ZipCode:textField.text];
//        }
//    }
//    return YES;
//}
//
//#pragma mark - UITextViewDelegate
//
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    [customerEditController editedTextView:textView cell:self];
//    return YES;
//}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    NSIndexPath *theIndexPath = [customerEditController indexPathForCell:self];
//    AddressDoc *theAddress = [customerEditController.addressArray objectAtIndex:theIndexPath.row -1];
//    if (![theAddress.adrs_Address isEqualToString:textView.text]) {
//        if (theAddress.adrs_Id == 0) {
//            [theAddress setCtlFlag:1];
//        } else {
//            [theAddress setCtlFlag:2];
//        }
//        [theAddress setAdrs_Address:textView.text];
//    }
//
//    const char * ch=[text cStringUsingEncoding:NSUTF8StringEncoding];
//    if (*ch == 0) return YES;
//    if (*ch == 32) return NO;
//    
//    if ([textView.text length] > 100)
//        return NO;
//    return YES;
//}
//
@end
