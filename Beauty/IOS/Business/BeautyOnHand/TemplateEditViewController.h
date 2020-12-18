//
//  TemplateEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-19.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentEditCell.h"

@class TemplateDoc;

@interface TemplateEditViewController : BaseViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, ContentEditCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TemplateDoc *theTemplateDoc;

@property (assign, nonatomic) BOOL isEditing;

@end
