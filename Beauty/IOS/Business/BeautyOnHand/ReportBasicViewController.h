//
//  ReportBasicViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportBasicViewController : BaseViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *reportTitle;
@property (assign, nonatomic) NSInteger reportBranchID;
@property (assign, nonatomic) NSInteger reportAccountID;
@property (assign, nonatomic) NSInteger cycleType;
//wugang
@property (nonatomic, assign) NSInteger TreatmentRateDesigned;
//wugang
@property (nonatomic, strong)   NSDate *startDateBasic;
@property (nonatomic, strong)   NSDate *endDateBasic;
@end
