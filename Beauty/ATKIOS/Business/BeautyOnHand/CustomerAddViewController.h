//
//  CustomerAddViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-12-29.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomerDoc;
typedef NS_ENUM(NSInteger, CustomerAddOrigin) {
    CustomerAddOriginNormol,
    CustomerAddOriginOrderMain
};
@interface CustomerAddViewController : UIViewController
@property (nonatomic, strong) CustomerDoc *newcustomer;
@property (nonatomic, assign) CustomerAddOrigin addOrigin;
@end
