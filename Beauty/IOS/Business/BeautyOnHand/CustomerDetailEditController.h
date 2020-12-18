//
//  CustomerDetailEditController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentEditCell.h"

@class CustomerDoc;
@interface CustomerDetailEditController : BaseViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate, ContentEditCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CustomerDoc *customer;
@end
