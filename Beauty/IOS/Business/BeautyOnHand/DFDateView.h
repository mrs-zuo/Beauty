//
//  DFDateView.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-15.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSDate *(^DFDateViewStartBlock)();
typedef void (^DFDateViewCompletionBlock)(NSDate *);
@interface DFDateView : UIView
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) DFDateViewStartBlock startBlock;
@property (nonatomic, strong) DFDateViewCompletionBlock completionBlock;
- (void)show;
@end
