//
//  ProgressEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductAndPriceView.h"
#import "ContentEditCell.h"

typedef enum {
    FromTypeSaleProgressView,
    FromTypeProgressHistoryView
} FromType;

@class OpportunityDoc;
@class ProgressDoc;
@interface ProgressEditViewController : BaseViewController <ProductAndPriceViewDelegate, ContentEditCellDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


// 1、SaleProgressViewController --> ProgressEditViewController 传的参数
// 2、ViewController的全局变量
@property (strong, nonatomic) OpportunityDoc *theOpportunityDoc;

@property (strong, nonatomic) ProgressDoc *progressDoc;
// ProgressHistoryViewController --> ProgressEditViewController传的参数 （In order to the theOpportunityDoc）
@property (assign, nonatomic) NSInteger progressID;
@property (assign, nonatomic) NSInteger productType;
@property (nonatomic, assign) BOOL oppInvalid;
@property (assign, nonatomic) FromType fromType;
@end
