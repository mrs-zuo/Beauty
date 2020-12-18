//
//  CompletionOrderCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/16.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OperatingOrder;
@protocol  OperatingOrderDelegate;

@interface CompletionOrderCell : UITableViewCell
@property (nonatomic, strong) OperatingOrder *opOrder;
@property (nonatomic, weak) id<OperatingOrderDelegate> delegate;
@end
@protocol  OperatingOrderDelegate<NSObject>

- (void)updateCheckButton;

@end