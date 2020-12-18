//
//  CusMainViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GPUniqueArray;
UIKIT_EXTERN NSString * const CustomerChildViewRefreshNotification;
typedef NS_ENUM(NSInteger, CusMainViewOrigin){
    CusMainViewOriginNormal,
    CusMainViewOriginFirstPage = 2,
    CusMainViewOriginProductList = 3,
    CusMainViewOriginMenu = 4
};
@interface CusMainViewController : UIViewController
@property (nonatomic, assign) CusMainViewOrigin viewOrigin;
@property (nonatomic, strong) NSMutableArray *oldOrderList;
- (void)gotoAwaitOrderView;
- (void)updateButtonFieldTitle;
@end
