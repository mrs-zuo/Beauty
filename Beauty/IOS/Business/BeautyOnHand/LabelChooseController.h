//
//  LabelChooseController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-11.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, CHOOSETYPE){
    CHOOSESEARCH,
    CHOOSEADD
};

@interface LabelChooseController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *chooseArray;
@property (nonatomic, assign) CHOOSETYPE type;


@end
