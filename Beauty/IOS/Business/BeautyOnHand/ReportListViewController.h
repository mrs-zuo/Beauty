//
//  ReportListViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportListViewController : BaseViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *reportTitle;
@end
