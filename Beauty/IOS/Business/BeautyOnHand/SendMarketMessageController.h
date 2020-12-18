//
//  SendMarketMessageController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-24.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateViewController.h"
#import "SelectCustomersViewController.h"
#import "ContentEditCell.h"

@interface SendMarketMessageController : BaseViewController<TemplateViewControllerDelegate, SelectCustomersViewControllerDelegate, ContentEditCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
