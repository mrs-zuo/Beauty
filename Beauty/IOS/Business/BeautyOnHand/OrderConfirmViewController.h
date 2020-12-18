//
//  OrderConfirmViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-24.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberEditCell.h"
#import "ContentEditCell.h"
#import "SelectCustomersViewController.h"

typedef NS_ENUM(NSInteger, OrderEditMode){
    OrderEditModeConfirm1,  // 服务、商品->订单
    OrderEditModeConfirm2,  // 需求->订单
    OrderEditModeFavour,    //收藏->订单
    OrderEditModeOlder      //存单->订单
};

@class OpportunityDoc;
@interface OrderConfirmViewController : BaseViewController<NumberEditCellDelegate, UITextFieldDelegate, UIScrollViewDelegate,ContentEditCellDelegate,SelectCustomersViewControllerDelegate ,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) OrderEditMode orderEditMode;
@property (strong, nonatomic) OpportunityDoc *theOpportunityDoc;
@property (nonatomic, strong) NSMutableArray *pastOrderArray;
@property (nonatomic, strong) NSMutableArray *favouritestList;
@property (nonatomic, strong) NSDictionary *userDic;
@property (nonatomic ,assign) long long taskID;

@end

