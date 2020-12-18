//
//  TreatmentDetailViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreatmentDetailEditViewController.h"

@class TreatmentDoc;
@interface TreatmentDetailViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate, TreatmentDetailEditViewControllerDelegate, ContentEditCellDelegate>
@property (strong, nonatomic) TreatmentDoc *treatmentDoc;
//@property (retain, nonatomic) NSString *remark;
@property (assign, nonatomic) BOOL permission_Write;
@property (assign, nonatomic) BOOL isLastTreatment;
@property (assign, nonatomic) NSInteger customerId;
@property (assign ,nonatomic) NSInteger treatMentOrGroup;//0 group  1 teatment
@property (assign ,nonatomic) NSInteger TreatmentID;
@property (assign ,nonatomic) double  GroupNo;
@property (assign ,nonatomic) NSInteger OrderID;

//是否有签名
@property (nonatomic,assign) BOOL isConfirmed;

@end
