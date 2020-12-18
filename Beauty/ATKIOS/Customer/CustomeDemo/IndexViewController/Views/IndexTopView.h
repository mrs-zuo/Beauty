//
//  IndexTopView.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/1/14.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IndexTopView;
@protocol IndexTopViewDelegate <NSObject>

- (void)IndexTopView:(IndexTopView *)indexTopView tapImageView:(UIImageView *)tapImageView;

@end
@interface IndexTopView : UIView

@property (nonatomic,assign) id <IndexTopViewDelegate>delegate;
@property (nonatomic,strong) NSMutableArray *datas;
@end
