//
//  ServiceFilterViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/17.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import "ServicePara.h"
#import "ServicePara.h"
typedef void(^ServiceFilterBlock)(ServicePara *serPara);

typedef void(^ServiceGoBackBlock)();

@interface ServiceFilterViewController : BaseViewController

@property (nonatomic,strong)ServicePara *servicePara;

@property (nonatomic,copy)ServiceFilterBlock filterBlock;
@property (nonatomic,copy)ServiceGoBackBlock goBackBlock;

@end
