//
//  ShoppingCartViewController.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-15.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingCartCell.h"
#import "CommodityDoc.h"
#import "ZXBaseViewController.h"

@interface ShoppingCartViewController : ZXBaseViewController<ShoppingCartCellDelegate,UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)dismissKeyBoard;
- (void)editedTextField:(UITextField *)textField cell:(UITableViewCell *)cell;
- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell;
- (void)setCustomKeyboardWithSection:(NSInteger)type textField:(UITextField *)textField selectedText:(NSString *)selectedText;
@end
