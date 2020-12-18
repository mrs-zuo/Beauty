//
//  SectionView.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/21.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionView : UIView

///title
@property (nonatomic,strong) NSString *name;

///是否有更多按钮
@property (assign, nonatomic) BOOL isMore;
@property (nonatomic,copy) void(^moreClick)(UIButton *button);

@end
