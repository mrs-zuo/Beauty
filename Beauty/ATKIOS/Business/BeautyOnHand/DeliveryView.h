//
//  DeliveryView.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/5.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeliveryViewConfrimBlock)(void);
@interface DeliveryView : UIView

@property (nonatomic,copy) NSString *groupNo;
@property (nonatomic,copy) NSString *thumbnailURL;

@property (nonatomic,copy) DeliveryViewConfrimBlock deliveryViewConfrimBlock;

- (void)initView;
- (void)initSignImageView;
@end
