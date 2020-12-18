//
//  FilterOrderView.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/5/19.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterOrderViewDelegate <NSObject>

- (void)FilterOrderViewCance;
- (void)FilterOrderViewConfirmWithType:(NSInteger) aType orderState:(NSInteger) aOrderState payState:(NSInteger) aPayState;


@end

@interface FilterOrderView : UIView

@property (nonatomic,assign) NSInteger type;
@property (nonatomic,assign) NSInteger orderState;
@property (nonatomic,assign) NSInteger payState;

@property (nonatomic,weak) id<FilterOrderViewDelegate> delegate;
@end
