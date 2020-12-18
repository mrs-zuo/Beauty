//
//  TemplateTotalViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-19.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateTitleCell.h"

@class TemplateDoc;

@protocol TemplateViewControllerDelegate <NSObject>
- (void)returnTemplate:(TemplateDoc *)theTemplateDoc;
@end

typedef NS_ENUM (NSInteger, TemplateType)
{
    TemplateTypePrivate,
    TemplateTypePublic
};

@interface TemplateViewController : BaseViewController<TemplateTitleCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) TemplateType templateType;
@property (assign, nonatomic) id <TemplateViewControllerDelegate> delegate;

@end
