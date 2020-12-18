//
//  CustomerEditViewController.h
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderAddCell.h"
#import "SelectCustomersViewController.h"
#import "CustomerEditDelegate.h"

@class CustomerDoc;
@interface CustomerEditViewController : BaseViewController<UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, OrderAddCellDelegate,CustomerEditDelegate, SelectCustomersViewControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CustomerDoc *customerDoc;
//@property (assign, nonatomic) BOOL isEditing;





@end



