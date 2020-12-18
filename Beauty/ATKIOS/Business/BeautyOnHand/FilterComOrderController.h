//
//  FilterComOrderController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/17.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FilterComOrderControllerDelegate;
@class ComOrderFilter;
@interface FilterComOrderController : UIViewController
@property (nonatomic, strong) NSArray *customerList;
@property (nonatomic, strong) NSArray *accountList;
@property (nonatomic, strong) ComOrderFilter *originFilter;
@property (nonatomic, weak) id<FilterComOrderControllerDelegate> delegate;
@end
@protocol FilterComOrderControllerDelegate <NSObject>

- (void)searchCustomer:(NSString *)custName person:(NSString *)personName;

@end