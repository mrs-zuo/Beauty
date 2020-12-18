//
//  TreatmentDetailViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"
@class TreatmentDoc;
@interface TreatmentDetailViewController : ZXBaseViewController<UITableViewDataSource,UITableViewDelegate>
//@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) TreatmentDoc *treatmentDoc;
@property (assign ,nonatomic) NSInteger OrderID;
@property (assign, nonatomic) long long GroupNo;
@property (assign ,nonatomic) NSInteger treatMentOrGroup;//1 TG  0 teatment
@end
