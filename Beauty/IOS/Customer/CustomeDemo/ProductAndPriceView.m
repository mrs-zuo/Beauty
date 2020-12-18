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

@class ProductAndPriceDoc;

@interface ProductAndPriceView ()
@property (strong, nonatomic) UITextField *textField_Editing;
@end

@implementation ProductAndPriceView
@synthesize theProductAndPriceDoc;
@synthesize canEditeQuantityAndPrice;
@synthesize textField_Editing;
@synthesize delegate;

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
        
        [self addSubview:_tableView];
    }
    return self;
}

- (NSIndexPath *)indexPathForTextField:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    return [_tableView indexPathForCell:cell];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (theProductAndPriceDoc.flag == 0) {
        if ([theProductAndPriceDoc.serviceArray count] == 1) {
            return 1;
        } else {
          return [theProductAndPriceDoc.serviceArray count] + 1;
        }
    } else {
        if ([theProductAndPriceDoc.commodityArray count] == 1) {
            return 1;
        } else {
            return [theProductAndPriceDoc.commodityArray count] + 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (theProductAndPriceDoc.flag == 0) {
        if ([theProductAndPriceDoc.serviceArray count] == section) {
           return theProductAndPriceDoc.isShowDiscountMoney ? 2 : 1;
        } else {
            ServiceDoc *serviceDoc = [theProductAndPriceDoc.serviceArray objectAtIndex:section];
            if (canEditeQuantityAndPrice) {
                return serviceDoc.service_isShowDiscountMoney ? 4 : 3;
            } else {
                return 3;
            }
        }
    } else {
        if ([theProductAndPriceDoc.commodityArray count] == section) {
            return theProductAndPriceDoc.isShowDiscountMoney ? 2 : 1;
        } else {
            CommodityDoc *commodityDoc = [theProductAndPriceDoc.commodityArray objectAtIndex:section];
            if (canEditeQuantityAndPrice) {
                return commodityDoc.comm_isShowDiscountMoney ? 4 : 3;
            } else {
                return 3;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (theProductAndPriceDoc.flag == 0) { // Service
        if ([theProductAndPriceDoc.serviceArray count] == indexPath.section) {
            if (indexPath.row == 0) {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"总价";
                cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN, theProductAndPriceDoc.totalMoney];
                return cell;
            } else if (indexPath.row == 1) {
                if (canEditeQuantityAndPrice) {
                    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"总优惠价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , theProductAndPriceDoc.discountMoney];
                    return cell;
                } else {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"总优惠价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , theProductAndPriceDoc.discountMoney];
                    return cell;
                }
            }
        } else {
            ServiceDoc *serviceDoc = [theProductAndPriceDoc.serviceArray objectAtIndex:indexPath.section];
            if (indexPath.row == 0) {
                UITableViewCell *cell = [self configTableViewCell:tableView indexPath:indexPath];
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.text = serviceDoc.service_ProductName;
                
                CGRect rect = cell.textLabel.frame;
                rect.size.height = serviceDoc.service_HeightForProductName;
                cell.textLabel.frame = rect;
                return cell;
            } else if (indexPath.row == 1) {
                if (canEditeQuantityAndPrice) {
                    NumberEditCell *cell = [self configNumberEditCell:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"数量";
                    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)serviceDoc.service_Quantity];
                    return cell;
                } else {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"数量";
                    cell.valueText.text = [NSString stringWithFormat:@"%ld", (long)serviceDoc.service_Quantity];
                    return cell;
                }
            } else if (indexPath.row == 2) {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"小计";
                cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , theProductAndPriceDoc.totalMoney];
                return cell;
            } else if (indexPath.row == 3) {
                if (canEditeQuantityAndPrice) {
                    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"优惠价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , theProductAndPriceDoc.discountMoney];
                    return cell;
                } else {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"优惠价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , theProductAndPriceDoc.discountMoney];
                    return cell;
                }
            }
        }
    } else { // Commodity
        if ([theProductAndPriceDoc.commodityArray count] == indexPath.section) {
            if (indexPath.row == 0) {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"总价";
                cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , theProductAndPriceDoc.totalMoney];
                return cell;
            } else if (indexPath.row == 1) {
                if (canEditeQuantityAndPrice) {
                    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"总优惠价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , theProductAndPriceDoc.discountMoney];
                    return cell;
                } else {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"总优惠价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , theProductAndPriceDoc.discountMoney];
                    return cell;
                }
            }
        } else {
            CommodityDoc *commodity = [theProductAndPriceDoc.commodityArray objectAtIndex:indexPath.section];
            if (indexPath.row == 0) {
                UITableViewCell *cell = [self configTableViewCell:tableView indexPath:indexPath];
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.text = commodity.comm_CommodityName;
                
                CGRect rect = cell.textLabel.frame;
                rect.size.height = commodity.comm_HeightForName;
                cell.textLabel.frame = rect;
                return cell;
            } else if (indexPath.row == 1) {
                if (canEditeQuantityAndPrice) {
                    NumberEditCell *cell = [self configNumberEditCell:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"数量";
                    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)commodity.comm_Quantity];
                    return cell;
                } else {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"数量";
                    cell.valueText.text = [NSString stringWithFormat:@"%ld", (long)commodity.comm_Quantity];
                    return cell;
                }
            } else if (indexPath.row == 2) {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"小计";
                cell.valueText.text = [NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN , commodity.comm_TotalMoney];
                return cell;
            }  else if (indexPath.row == 3) {
                if (canEditeQuantityAndPrice) {
                    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"优惠价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN , commodity.comm_DiscountMoney];
                    return cell;
                } else {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"优惠价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN , commodity.comm_DiscountMoney];
                    return cell;
                }
            }
        }
    }
    return nil;
}

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
    return cell;
}

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
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.userInteractionEnabled = NO;
    cell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
    cell.valueText.textColor = [UIColor blackColor];
    cell.valueText.delegate = self;
    cell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
    [cell setAccessoryText:@""];
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
    cell.leftButton.hidden = YES;
    cell.rightButton.hidden = YES;
    cell.numberLabel.frame = CGRectMake(260.0f, kTableView_HeightOfRow/2 - 18.0f/2, 40, 18.0f);
    cell.numberLabel.textAlignment = NSTextAlignmentRight;
    cell.numberLabel.textColor = [UIColor blackColor];
    cell.delegate = self;
    cell.minNum = 1;
    cell.maxNum = 100;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (theProductAndPriceDoc.flag == 0) {
        if ([theProductAndPriceDoc.serviceArray count] != indexPath.section && indexPath.row == 0) {
            ServiceDoc *service = [theProductAndPriceDoc.serviceArray objectAtIndex:indexPath.section];
            return service.service_HeightForProductName;
        }
    } else {
        if ([theProductAndPriceDoc.commodityArray count] != indexPath.section && indexPath.row == 0) {
            CommodityDoc *commodity = [theProductAndPriceDoc.commodityArray objectAtIndex:indexPath.section];
            return commodity.comm_HeightForName ;
        }
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (canEditeQuantityAndPrice) {
        
        // 点击小计后触发事件
        if (theProductAndPriceDoc.flag == 0 && indexPath.row == 2) {
            ServiceDoc *serviceDoc = [theProductAndPriceDoc.serviceArray objectAtIndex:indexPath.section];
            if (serviceDoc.service_isShowDiscountMoney) {
                serviceDoc.service_isShowDiscountMoney = NO;
                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                serviceDoc.service_isShowDiscountMoney = YES;
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
        } else if (theProductAndPriceDoc.flag == 1 && indexPath.row == 2) {
            CommodityDoc *commodityDoc = [theProductAndPriceDoc.commodityArray objectAtIndex:indexPath.section];
            if (commodityDoc.comm_isShowDiscountMoney) {
                commodityDoc.comm_isShowDiscountMoney = NO;
                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                commodityDoc.comm_isShowDiscountMoney = YES;
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
        
        // 点击 总价后的事件
        if (theProductAndPriceDoc.flag == 0 && indexPath.section == [theProductAndPriceDoc.serviceArray count] && indexPath.row == 0) {
            if (theProductAndPriceDoc.isShowDiscountMoney) {
                theProductAndPriceDoc.isShowDiscountMoney = NO;
                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:[theProductAndPriceDoc.serviceArray count]]] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                theProductAndPriceDoc.isShowDiscountMoney = YES;
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:[theProductAndPriceDoc.serviceArray count]]] withRowAnimation:UITableViewRowAnimationFade];
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
        } else if (theProductAndPriceDoc.flag == 1 && indexPath.section == [theProductAndPriceDoc.commodityArray count] && indexPath.row == 0) {
            if (theProductAndPriceDoc.isShowDiscountMoney) {
                theProductAndPriceDoc.isShowDiscountMoney = NO;
                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:[theProductAndPriceDoc.commodityArray count]]] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                theProductAndPriceDoc.isShowDiscountMoney = YES;
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:[theProductAndPriceDoc.commodityArray count]]] withRowAnimation:UITableViewRowAnimationFade];
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
}
*/
#pragma - NumberEditCellDelegate

- (void)chickLeftButton:(NumberEditCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (theProductAndPriceDoc.flag == 0) {
        ServiceDoc *service = [theProductAndPriceDoc.serviceArray objectAtIndex:indexPath.section];
        service.service_Quantity --;
        service.service_DiscountMoney = service.service_TotalMoney;
       
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:indexPath.section];
        if ([theProductAndPriceDoc.serviceArray count] > 1) {
             theProductAndPriceDoc.discountMoney = theProductAndPriceDoc.totalMoney;
            [indexSet addIndex:[theProductAndPriceDoc.serviceArray count]];
        }
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
    } else if (theProductAndPriceDoc.flag == 1) {
        CommodityDoc *commodity = [theProductAndPriceDoc.commodityArray objectAtIndex:indexPath.section];
        commodity.comm_Quantity --;
        commodity.comm_DiscountMoney = commodity.comm_TotalMoney;
        
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:indexPath.section];
        if ([theProductAndPriceDoc.commodityArray count] > 1) {
             theProductAndPriceDoc.discountMoney = theProductAndPriceDoc.totalMoney;
            [indexSet addIndex:[theProductAndPriceDoc.commodityArray count]];
        }
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if ([delegate respondsToSelector:@selector(reduceOneProductInProductAndPriceView:)]) {
        [delegate reduceOneProductInProductAndPriceView:self];
    }
}

- (void)chickRightButton:(NumberEditCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (theProductAndPriceDoc.flag == 0) {
        ServiceDoc *service = [theProductAndPriceDoc.serviceArray objectAtIndex:indexPath.section];
        service.service_Quantity ++;
        service.service_DiscountMoney = service.service_TotalMoney;
    
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:indexPath.section];
        if ([theProductAndPriceDoc.serviceArray count] > 1) {
            theProductAndPriceDoc.discountMoney = theProductAndPriceDoc.totalMoney;
              [indexSet addIndex:[theProductAndPriceDoc.serviceArray count]];
        }
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
    } else if (theProductAndPriceDoc.flag == 1) {
        CommodityDoc *commodity = [theProductAndPriceDoc.commodityArray objectAtIndex:indexPath.section];
        commodity.comm_Quantity ++;
        commodity.comm_DiscountMoney = commodity.comm_TotalMoney;
       
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:indexPath.section];
        if ([theProductAndPriceDoc.commodityArray count] > 1) {
            theProductAndPriceDoc.discountMoney = theProductAndPriceDoc.totalMoney;
            [indexSet addIndex:[theProductAndPriceDoc.commodityArray count]];
        }
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if ([delegate respondsToSelector:@selector(addOneProductInProductAndPriceView:)]) {
        [delegate addOneProductInProductAndPriceView:self];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField_Editing = textField;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForTextField:textField];
    if (theProductAndPriceDoc.flag == 0) {
        if ([theProductAndPriceDoc.serviceArray count] == 1) {
            ServiceDoc *serviceDoc = [theProductAndPriceDoc.serviceArray objectAtIndex:indexPath.section];
            serviceDoc.service_DiscountMoney = [textField.text doubleValue];
        } else if ([theProductAndPriceDoc.serviceArray count] > 1) {
            if ([theProductAndPriceDoc.serviceArray count] == indexPath.section) {
                theProductAndPriceDoc.discountMoney = [textField.text doubleValue];
            } else {
                ServiceDoc *serviceDoc = [theProductAndPriceDoc.serviceArray objectAtIndex:indexPath.section];
                serviceDoc.service_DiscountMoney = [textField.text doubleValue];
                theProductAndPriceDoc.discountMoney = [theProductAndPriceDoc retDiscountMoney];
            }
        }
    } else if (theProductAndPriceDoc.flag == 1) {
        if ([theProductAndPriceDoc.commodityArray count] == 1) {
            CommodityDoc *commodityDoc = [theProductAndPriceDoc.commodityArray objectAtIndex:indexPath.section];
            commodityDoc.comm_DiscountMoney = [textField.text doubleValue];
        } else if ([theProductAndPriceDoc.commodityArray count] > 1) {
            if ([theProductAndPriceDoc.commodityArray count] == indexPath.section) {
                theProductAndPriceDoc.discountMoney = [textField.text doubleValue];
            } else {
                CommodityDoc *commdityDoc = [theProductAndPriceDoc.commodityArray objectAtIndex:indexPath.section];
                commdityDoc.comm_DiscountMoney = [textField.text doubleValue];
                theProductAndPriceDoc.discountMoney = [theProductAndPriceDoc retDiscountMoney];
            }
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0 ) return YES;
    if (*ch == 32) return NO;
    
    NSRange decRange = [textField.text rangeOfString:@"."];
    if (decRange.location != NSNotFound && (textField.text.length - decRange.location > 2)) {
        textField.text = @"0";
    }
    
    if ([textField.text length] > 12) {
        return NO;
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
