//
//  WSLeftMasterView.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSLeftTableViewCell.h"
#import "WorkSheet.h"

@protocol WSLeftMasterViewDelegate;

@class WorkSheetViewController;
@interface WSLeftMasterView : UIView <UITableViewDataSource, UITableViewDelegate, WSLeftTableViewCellDelegate>

@property (weak, nonatomic) WorkSheetViewController *workSheetVC;
@property (strong, nonatomic) UITableView *lTableView;
@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) NSMutableArray *select_UserArray;
@property (strong, nonatomic) NSString *dateStr;

@property (assign, nonatomic) BOOL multipleSelection;  // default YES

@property (assign, nonatomic) id<WSScrollViewDelegate> wsDelegate;
@property (assign, nonatomic) id<WSLeftMasterViewDelegate> wsLeftMasterDelegate;
@end

@protocol WSLeftMasterViewDelegate <NSObject>
- (void)leftMasterView:(WSLeftMasterView *)view didChangeDate:(NSDate *)date;
- (void)displayDatePickerInLeftMasterView:(WSLeftMasterView *)view;
@end
