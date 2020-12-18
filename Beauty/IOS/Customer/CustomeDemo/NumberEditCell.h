//
//  NumberEditCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-13.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumberEditCellDelegate;

@interface NumberEditCell : UITableViewCell
@property (weak, nonatomic) id<NumberEditCellDelegate> delegate;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *numberLabel;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;

@property (nonatomic, assign) int minNum;
@property (nonatomic, assign) int maxNum;
@end

@protocol NumberEditCellDelegate <NSObject>
- (void)chickLeftButton:(NumberEditCell *)cell;
- (void)chickRightButton:(NumberEditCell *)cell;
@end
