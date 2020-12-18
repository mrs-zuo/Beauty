//
//  LevelDateCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CustomerLevelViewController.h"
#import <QuartzCore/QuartzCore.h>

@class LevelDoc;
@interface LevelDateCell : UITableViewCell<UITextViewDelegate>
@property (strong, nonatomic) UITextView *nameText;
@property (strong, nonatomic) UITextView *discountText;
@property (strong, nonatomic) UIButton *deleteBtn;

@property (weak, nonatomic) id <LevelDateCellDelete> delegate;
@property (weak, nonatomic) CustomerLevelViewController *customerLevelViewController;

- (void)updateData:(LevelDoc *)levelDoc;
@end
