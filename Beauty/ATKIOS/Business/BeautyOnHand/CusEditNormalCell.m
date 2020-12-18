//
//  CustomerEditCell.m
//  GlamourPromise
//
//  Created by GuanHui on 13-6-27.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CusEditNormalCell.h"
#import "CustomerDoc.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"
#import "DEFINE.h"

@implementation CusEditNormalCell
@synthesize titleNameLabel;
@synthesize contentText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 0.0f, 150.0f, kTableView_HeightOfRow) title:@"--"];
        titleNameLabel.font = kFont_Light_16;
        titleNameLabel.textColor = kColor_DarkBlue;
        [[self contentView] addSubview:titleNameLabel];
        
        contentText = [UITextField initNormalTextViewWithFrame:CGRectMake(100.0f, 0.0f, 202.0f, kTableView_HeightOfRow) text:@"无" placeHolder:@""];
        contentText.textAlignment = NSTextAlignmentRight;
        [[self contentView] addSubview:contentText];
        
        
        contentText.tag = 99;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//- (void)setCustomerDoc:(CustomerDoc *)customerDoc
//{
//    theCustomerDoc = customerDoc;
//}

//#pragma mark - UITextFieldDelegate
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    NSIndexPath *indext = [customerEditController indexPathForCell:self];
//    
//    if (customerEditController.isEditing && indext.section == 3) {
//       [customerEditController setCustomKeyboardWithSection:3 textField:contentText selectedText:contentText.text];
//    } else if (!customerEditController.isEditing && indext.section == 4) {
//       [customerEditController setCustomKeyboardWithSection:3 textField:contentText selectedText:contentText.text];
//    }
//
//    if (textField == contentText) {
//        [customerEditController editedTextField:textField cell:self];
//        return YES;
//    } else {
//        return YES;
//    }
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    
//    if (textField == contentText) {
//        const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
//        if (*ch == 0) return YES;
//        if (*ch == 32) return NO;
//        
//        if ([textField.text length] > 15) {
//            return NO;
//        }
//        return YES;
//        
//    } else {
//        return YES;
//    }
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    NSIndexPath *indexPath = [customerEditController indexPathForCell:self];
//    if (indexPath.section == 3) {
//        [theCustomerDoc setCus_LoginMobile:textField.text];
//    }
//    
//    if (customerEditController.isEditing && indexPath.section == 3) {
//        [theCustomerDoc setCus_LoginMobile:textField.text];
//    } else if (!customerEditController.isEditing && indexPath.section == 4) {
//         [theCustomerDoc setCus_LoginMobile:textField.text];
//    }
//    
//    return YES;
//}


@end
