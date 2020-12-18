//
//  TemplateTitleCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-24.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TemplateTitleCellDelegate <NSObject>
- (void)editTemplateWithIndex:(NSInteger)index;
@end

@interface TemplateTitleCell : UITableViewCell
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *editButton;

@property (assign, nonatomic) id<TemplateTitleCellDelegate> delegate;
@end
