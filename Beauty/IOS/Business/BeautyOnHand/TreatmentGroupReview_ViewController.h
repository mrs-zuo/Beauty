//
//  TreatmentGroupReview_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/9/22.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreatmentGroupReview_ViewController : BaseViewController
@property (strong, nonatomic)  UITableView *tableView;

@property (assign, nonatomic) BOOL permission_Write;
@property (assign ,nonatomic) double  GroupNo;
@property (assign ,nonatomic) NSInteger OrderID;

@end
