//
//  NumberEditCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-13.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "noCopyTextField.h"
@protocol NumberEditCellDelegate;

@interface NumberEditCell : UITableViewCell
@property (weak, nonatomic) id<NumberEditCellDelegate> delegate;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) noCopyTextField *numberLabel;
@property (nonatomic) UIButton *leftButton;
@property (nonatomic) UIButton *rightButton;
@property (nonatomic) BOOL *editByNumKeyBoard;
@property (nonatomic, assign) int minNum;
@property (nonatomic, assign) int maxNum;
@end

@protocol NumberEditCellDelegate <NSObject>
- (void)chickLeftButton:(NumberEditCell *)cell;
- (void)chickRightButton:(NumberEditCell *)cell;
@end
