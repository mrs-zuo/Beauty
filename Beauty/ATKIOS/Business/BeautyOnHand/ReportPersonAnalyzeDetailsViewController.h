//
//  ReportPersonAnalyzeDetailsViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"

@interface ReportPersonAnalyzeDetailsViewController : BaseViewController

@property (nonatomic,assign) NSInteger  currentSelectButtonTag;
@property (nonatomic,assign) NSInteger  accountID;
@property (nonatomic,copy) NSString *personName;
@property (nonatomic, strong) NSDate *startDateBasic;
@property (nonatomic, strong) NSDate *endDateBasic;

@end
