//
//  SelectYearView.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/2/29.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DisSelectYearViewBlock)(NSString *yearStr);
typedef void (^SelectYearViewBlock)(NSString *yearStr);

@interface SelectYearView : UIView

@property (nonatomic, copy) SelectYearViewBlock selectYearViewBlock;
@property (nonatomic, copy) DisSelectYearViewBlock disSelectYearViewBlock;

@end
