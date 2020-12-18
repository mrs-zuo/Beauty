//
//  RemindCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-20.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RichTextView.h"
#import "MessageDoc.h"
#import "RemindViewController.h"
@class RemindDoc;

@interface RemindCell : UITableViewCell<RichTextViewDelegate>
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) RichTextView *contentLabel;//用来显示提醒的内容
@property (strong, nonatomic) RemindDoc *remindDoc;
@property (weak, nonatomic) RemindViewController *remindViewController;
-(void) updateDate:(RemindDoc *)remind;

@end
