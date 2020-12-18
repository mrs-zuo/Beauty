//
//  ReportOperationAnalyzeDetailsViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"

@interface ReportOperationAnalyzeDetailsViewController : BaseViewController

@property (nonatomic,assign) NSInteger extractItemType;
@property (nonatomic, strong) NSDate *startDateBasic;
@property (nonatomic, strong) NSDate *endDateBasic;
@property (nonatomic, assign) NSInteger cycleType;
@end
