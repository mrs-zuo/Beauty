//
//  WSRightMasterView.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkSheet.h"

@interface WSRightMasterView : UIScrollView <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *rTableView;
@property (strong, nonatomic) NSArray *userArray;

@property (assign, nonatomic) id<WSScrollViewDelegate> wsDelegate;
@end
