//
//  EditContactDetailViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactDoc.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"

@class ContactDoc;

@protocol EditContactDetailViewControllerDelegate <NSObject>
- (void)editSuccessWithContactDoc:(ContactDoc *)newContactDoc;
@end

@interface EditContactDetailViewController : BaseViewController<ContentEditCellDelegate>
@property (assign, nonatomic) id<EditContactDetailViewControllerDelegate> delegate;
@property (strong, nonatomic) ContactDoc *contactDoc; // 接收用DOC
@property (weak, nonatomic) IBOutlet UITableView *myTableview;

@end
