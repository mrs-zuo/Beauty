//
//  ECardOutViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-8-27.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "BaseViewController.h"

@interface ECardOutViewController : BaseViewController<UITextViewDelegate, UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate>


@property (nonatomic, assign) double eCardBalance;
@property (nonatomic ,assign) NSString * ecardOutCardId;

@end
