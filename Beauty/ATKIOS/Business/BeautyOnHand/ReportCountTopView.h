//
//  ReportCountTopView.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/11.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReportCountTopView;
@class noCopyTextField;
@protocol ReportCountTopViewDelegate <NSObject>

- (void)ReportCountTopView:(ReportCountTopView *)ReportCountTopView repBeginTime:(noCopyTextField *)repBeginTime repEndTime:(noCopyTextField *)repEndTime;

- (void)ReportCountTopView:(ReportCountTopView *)ReportCountTopView textField:(UITextField *)textField;

- (void)ReportCountTopView:(ReportCountTopView *)ReportCountTopView selCycleType:(NSInteger)selCycleType
        selExtractItemType:(NSInteger)selExtractItemType selStatementCategoryID:(NSInteger)selStatementCategoryID;
@end

@interface ReportCountTopView : UIView

@property (nonatomic,assign) NSInteger cycleType;
@property (nonatomic,assign) NSInteger extractItemType;
@property (nonatomic,assign) NSInteger statementCategoryID;
@property (nonatomic,strong) NSString *reportTitle;
@property (nonatomic, strong)   NSDate *startDateBasic;
@property (nonatomic, strong)   NSDate *endDateBasic;
@property (nonatomic, strong) NSMutableArray *statementCategoryList;
//->Ver.010
@property (nonatomic,assign) NSInteger displayType;
//<-Ver.010
@property (nonatomic, weak) id <ReportCountTopViewDelegate>delegate;
- (void)initView;

@end

