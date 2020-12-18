//
//  CustomerLevelViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelAddCell.h"

@class LevelDoc;

@protocol LevelDateCellDelete <NSObject>
- (void)chickDeleteRowButton:(UITableViewCell *)cell;
@end

@interface CustomerLevelViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, LevelDateCellDelete, LevelAddCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) LevelDoc *levelDoc;     
@property (strong, nonatomic) UITextView *textView_Selected;

@property (assign, nonatomic) CGFloat text_Height;//  作用:记录textView 高度  比较textView前后两次的高度
@property (assign, nonatomic) CGFloat text_Y;     // 记录被选择的textView的(Y+Height)值

// schedule排序
- (void)updateWithLevelDoc:(LevelDoc *)sch cell:(UITableViewCell *)cell;

@end
