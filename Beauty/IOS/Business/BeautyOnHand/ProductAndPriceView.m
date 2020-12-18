//
//  ProductAndPriceView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ProductAndPriceView.h"
#import "NSString+Additional.h"
#import "NormalEditCell.h"
#import "NumberEditCell.h"
#import "ContentEditCell.h"
#import "DEFINE.h"

@class ProductAndPriceDoc;

@interface ProductAndPriceView ()
@property (strong, nonatomic) UITextField *textField_Editing;
@end

@implementation ProductAndPriceView
@synthesize theProductAndPriceDoc;
@synthesize canEditeQuantityAndPrice;
@synthesize textField_Editing;
@synthesize delegate;
@synthesize canEditPriceInOrderDetail;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView = nil;
        _tableView.scrollEnabled = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = kTableView_LineColor;
        
         if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
        
        [self addSubview:_tableView];
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}

- (NSIndexPath *)indexPathForTextField:(UITextField *)textField
{
    if (IOS7) {
        UITableViewCell *cell = (UITableViewCell *)textField.superview.superview.superview;
        return [_tableView indexPathForCell:cell];
    } else {
        UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
        return [_tableView indexPathForCell:cell];
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([theProductAndPriceDoc.productArray count] == 1) {
        return 1;
    } else {
        return [theProductAndPriceDoc.productArray count] + 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [theProductAndPriceDoc.productArray count]) {
        return 2;
    } else {
        ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:section];
        //增加一行显示未支付价格
        int num = (productDoc.pro_IsShowDiscountMoney ? 4 : 3);
        if (productDoc.pro_Status == 1) {
            num++;
        }
        return num;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([theProductAndPriceDoc.productArray count] == indexPath.section) {
        switch (indexPath.row) {
            case 0:
            {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"总价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theProductAndPriceDoc.totalMoney];
                return cell;
            }
            case 1:
            {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"总优惠价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theProductAndPriceDoc.discountMoney];
                return cell;
            }
        }
    } else {
        ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
        switch (indexPath.row) {
            case 0:
            {
                NSString *identity = @"cell_ProductName";
                ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
                if (cell == nil) {
                    cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identity];
                    cell.backgroundColor = [UIColor whiteColor];
                }
                [cell setContentText:productDoc.pro_Name];
                cell.contentEditText.textColor = [UIColor blackColor];
                cell.userInteractionEnabled = NO;
                
                /*
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.valueText.userInteractionEnabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                [cell setAccessoryText:@""];
                UITableViewCell *cell = [self configTableViewCell:tableView indexPath:indexPath];
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.text = productDoc.pro_Name;
                
                CGRect rect = cell.textLabel.frame;
                rect.size.height = productDoc.pro_HeightOfProductName;
                // rect.origin.x = 0.0f;
                cell.textLabel.frame = rect;
                 */
                
                return cell;
            }
            case 1:
            {
                if (canEditeQuantityAndPrice) {
                    NumberEditCell *cell = [self configNumberEditCell:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"数量";
                    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)productDoc.pro_quantity];
                    return cell;
                } else {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"数量";
                    cell.valueText.text = [NSString stringWithFormat:@"%ld", (long)productDoc.pro_quantity];
                    return cell;
                }
            }
            case 2:
            {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"小计";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalMoney];
                return cell;
            }
            case 3:
            {
                if (productDoc.pro_IsShowDiscountMoney) {
                    if (canEditeQuantityAndPrice) {
                        NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                        cell.titleLabel.text = @"优惠价";
                        cell.nocopyText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalSaleMoney];
                        cell.hidden = NO;
                        return cell;
                    } else if (canEditPriceInOrderDetail) {
                        NormalEditCell *cell = [self configNormalEditCell3:tableView indexPath:indexPath];
                        cell.titleLabel.text = @"优惠价";
                        cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalSaleMoney];
                        return cell;

                    } else {
                        NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                        cell.titleLabel.text = @"优惠价";
                        cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalSaleMoney];
                        return cell;
                    }
                }
            }
            case 4:
            {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"未付余额";
                    cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon,
                                           productDoc.pro_UnPaidPrice];
                    return cell;

            }
        }
    }
    return nil;
}

/*
- (UITableViewCell *)configTableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"tableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = kFont_Light_16;
    
//    CGRect rect = cell.textLabel.frame;
//    rect.origin.x = 5.0f;
//    cell.textLabel.frame = rect;
    return cell;
}
*/

- (NormalEditCell *)configNormalEditCell1:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"Product_NormalEditCell_NotEditing";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.userInteractionEnabled = NO;
    cell.valueText.textColor = [UIColor blackColor];
    [cell setAccessoryText:@""];
    return cell;
}

- (NormalEditCell *)configNormalEditCell2:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"Product_NormalEditCell_Editing";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyleNocopy:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.nocopyText.userInteractionEnabled = YES;
    cell.nocopyText.keyboardType = UIKeyboardTypeDecimalPad;
    cell.nocopyText.textColor = kColor_Editable;
    cell.nocopyText.delegate = self;
    [cell setAccessoryText:@""];
    return cell;
}

- (NormalEditCell *)configNormalEditCell3:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"Product_NormalEditCell_EditingAndPic";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"change_price"]];
        image.frame = CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
        if (IOS6) {
            image.frame = CGRectMake(285.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
        }
        [cell.contentView addSubview:image];
    }
    cell.valueText.userInteractionEnabled = NO;
    cell.valueText.textColor = [UIColor blackColor];
    [cell setAccessoryText:@"      "];
    return cell;
}

- (NumberEditCell *)configNumberEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"Product_NumberEditCell";
    NumberEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[NumberEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    cell.minNum = 1;
    cell.maxNum = 100;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([theProductAndPriceDoc.productArray count] != indexPath.section && indexPath.row == 0) {
        ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
        return productDoc.pro_HeightOfProductName;
    } else {
        return kTableView_HeightOfRow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (canEditPriceInOrderDetail && (indexPath.section != [theProductAndPriceDoc.productArray count]) && indexPath.row == 3) {
        if ([delegate respondsToSelector:@selector(changeOrderPrice)]) {
            [delegate changeOrderPrice];
        }
    }
    
    if (canEditeQuantityAndPrice && (indexPath.section != [theProductAndPriceDoc.productArray count])  && indexPath.row == 2) {
        ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
        if (productDoc.pro_IsShowDiscountMoney) {
            productDoc.pro_IsShowDiscountMoney = NO;
           [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            productDoc.pro_IsShowDiscountMoney = YES;
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDelay:0.1f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        CGRect rect = self.tableView.frame;
        rect.size.height = theProductAndPriceDoc.table_Height;
        self.tableView.frame = rect;
        [UIView commitAnimations];
        
        if ([delegate respondsToSelector:@selector(changeHeightOfProductAndPriceView)]) {
            [delegate changeHeightOfProductAndPriceView];
        }
    }
}

#pragma - NumberEditCellDelegate

// 数量减少
- (void)chickLeftButton:(NumberEditCell *)cell
{
    if (textField_Editing)
        [textField_Editing resignFirstResponder];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
    if (productDoc.pro_quantity <= 1) {
        return;
    }
    productDoc.pro_quantity --;
    productDoc.pro_TotalMoney     = productDoc.pro_quantity * productDoc.pro_Unitprice;
    productDoc.pro_TotalSaleMoney = productDoc.pro_quantity * productDoc.pro_CalculatePrice;
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:indexPath.section];
    if ([theProductAndPriceDoc.productArray count] > 1) {
        theProductAndPriceDoc.totalMoney = [theProductAndPriceDoc retTotalMoney];
        theProductAndPriceDoc.discountMoney = [theProductAndPriceDoc retDiscountMoney];
        [indexSet addIndex:[theProductAndPriceDoc.productArray count]];
    }
    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    
    if ([delegate respondsToSelector:@selector(reduceOneProductInProductAndPriceView:)]) {
        [delegate reduceOneProductInProductAndPriceView:self];
    }
}

// 数量增加
- (void)chickRightButton:(NumberEditCell *)cell
{
    if (textField_Editing)
        [textField_Editing resignFirstResponder];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
    productDoc.pro_quantity ++;
    productDoc.pro_TotalMoney     = productDoc.pro_quantity * productDoc.pro_Unitprice;
    productDoc.pro_TotalSaleMoney = productDoc.pro_quantity * productDoc.pro_CalculatePrice;
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:indexPath.section];
    if ([theProductAndPriceDoc.productArray count] > 1) {
        theProductAndPriceDoc.totalMoney = [theProductAndPriceDoc retTotalMoney];
        theProductAndPriceDoc.discountMoney = [theProductAndPriceDoc retDiscountMoney];
        [indexSet addIndex:[theProductAndPriceDoc.productArray count]];
    }
    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    if ([delegate respondsToSelector:@selector(addOneProductInProductAndPriceView:)]) {
        [delegate addOneProductInProductAndPriceView:self];
    }
}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    textField_Editing = textField;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    /*
    NSIndexPath *indexPath = [self indexPathForTextField:textField_Editing];
    ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
    textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, productDoc.pro_TotalSaleMoney];
    
    NSIndexPath *indexPath = [self indexPathForTextField:textField];
    ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
    productDoc.pro_TotalSaleMoney = [textField.text floatValue];
    
    theProductAndPriceDoc.discountMoney = [theProductAndPriceDoc retDiscountMoney];
    theProductAndPriceDoc.totalMoney    = [theProductAndPriceDoc retTotalMoney];
    
    if ([theProductAndPriceDoc.productArray count] > 1) {
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:theProductAndPriceDoc.productArray.count] withRowAnimation:UITableViewRowAnimationNone];
    }
     */
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    double money;
    NSIndexPath *indexPath = [self indexPathForTextField:textField_Editing];
    ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
    if ([textField.text isEqual:@""]) {
        textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon,
                          productDoc.pro_TotalSaleMoney];
    } else {
        money = [textField.text doubleValue];
        textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, money];
        productDoc.pro_TotalSaleMoney = money;
        
//        productDoc.pro_TotalSaleMoney = money;
//        productDoc.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2f",productDoc.pro_TotalSaleMoney/productDoc.pro_quantity] doubleValue];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0 ) return YES;
    if (*ch == 32) return NO;
    
    if ([textField.text length] == 0 && [string isEqualToString:@"."]) {
          textField.text = @"0.";
            return NO;
    }
    
    if ([textField.text isEqualToString:@"0"] && [string isEqualToString:@"0"]) {
       textField.text = @"0";
        return NO;
    }
    
    NSRange decRange = [textField.text rangeOfString:@"."];
    
    /*
    if (decRange.location != NSNotFound && (textField.text.length - decRange.location > 2)) {
        if ([string isEqualToString:@"."])
            textField.text = @"0";
        else
        textField.text = @"";
        
    } */
    
    if (decRange.length && [string isEqualToString:@"."]) {
        return NO;
    }

    
    if ([textField.text length] > 12) {
        return NO;
    }

    NSIndexPath *indexPath = [self indexPathForTextField:textField_Editing];
    ProductDoc *productDoc = [theProductAndPriceDoc.productArray objectAtIndex:indexPath.section];
    NSString *stringPrice = [textField_Editing.text stringByAppendingString:string] ;
    productDoc.pro_TotalSaleMoney = [stringPrice doubleValue];
    productDoc.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2Lf",productDoc.pro_TotalSaleMoney/productDoc.pro_quantity] doubleValue];
    
    theProductAndPriceDoc.discountMoney = [theProductAndPriceDoc retDiscountMoney];
    theProductAndPriceDoc.totalMoney    = [theProductAndPriceDoc retTotalMoney];
    
    if ([theProductAndPriceDoc.productArray count] > 1) {
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:theProductAndPriceDoc.productArray.count] withRowAnimation:UITableViewRowAnimationNone];
    }
    return YES;
}


#pragma mark -
#pragma mark - Call by Outside

- (void)dismissKeyboard
{
    [textField_Editing resignFirstResponder];
}

@end
