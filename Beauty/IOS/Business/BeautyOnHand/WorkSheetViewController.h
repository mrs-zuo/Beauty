//
//  WorkSheetViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSLeftMasterView.h"
#import "UserDoc.h"
#import "WorkSheet.h"
#import "TreatmentDoc.h"


@protocol WorkSheetViewControllerDelegate;

@interface WorkSheetViewController : UIViewController <WSScrollViewDelegate, WSLeftMasterViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) NSArray *selected_UserArray;
@property (assign, nonatomic) BOOL multipleSelection;  // default YES
@property (strong, nonatomic) NSDate *wsDate;
//@property (strong, nonatomic) TreatmentDoc *treatment;
@property (assign, nonatomic) NSInteger customerId;
@property (nonatomic, assign) NSInteger orderId;
@property (nonatomic, assign) NSInteger orderObjectId;
@property (nonatomic, assign) long long orderServiceCode;
@property (nonatomic, assign) NSInteger ReservedOrderType;
@property (nonatomic, assign) NSInteger chooseType; // 1 选择预约时间 2 选择服务顾问

@property (assign, nonatomic) id<WorkSheetViewControllerDelegate> delegate;

- (void)requestAndSortByDepartmentWithRefresh:(BOOL)isRefresh;
- (void)setSelectedInfoText;

@end


@protocol WorkSheetViewControllerDelegate <NSObject>
- (void)dismissViewController:(WorkSheetViewController *)workSheetVC userArray:(NSArray *)userArray dateStr:(NSString *)dateStr;
@end
