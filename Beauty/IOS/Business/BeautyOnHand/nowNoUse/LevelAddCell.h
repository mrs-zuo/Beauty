//
//  LevelAddCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LevelAddCellDelegate <NSObject>
- (void)chickAddButton:(UITableViewCell *)cell;
@end

@interface LevelAddCell : UITableViewCell
@property (weak, nonatomic) id<LevelAddCellDelegate> delegate;
@property (strong, nonatomic) UILabel *promptLabel;
@property (strong, nonatomic) UIButton *addButton;
@end
