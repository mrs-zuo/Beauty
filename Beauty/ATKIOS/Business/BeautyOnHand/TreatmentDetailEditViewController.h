//
//  TreatmentDetailEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentEditCell.h"


@class TreatmentDoc;
@protocol TreatmentDetailEditViewControllerDelegate <NSObject>
- (void)editSuccessWithTreatmentDoc:(TreatmentDoc *)newTreament;
@end

@interface TreatmentDetailEditViewController : BaseViewController<ContentEditCellDelegate>
@property (assign, nonatomic) id<TreatmentDetailEditViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView  *myTableview;
@property (nonatomic) TreatmentDoc *treatmentDoc;
@property (assign, nonatomic) BOOL isLastTreatment;
@end

