//
//  RecordEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentEditCell.h"

@class RecordDoc;
@interface RecordEditViewController : BaseViewController <UITextFieldDelegate, ContentEditCellDelegate,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RecordDoc *recordDoc;
@property (assign, nonatomic) BOOL isEditing;

@end
