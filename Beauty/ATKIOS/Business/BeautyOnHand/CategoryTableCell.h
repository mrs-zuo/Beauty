//
//  PSCategoryTableCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-7.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryDoc;
@interface CategoryTableCell : UITableViewCell
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *numberLabel;
@property (strong, nonatomic) UIImageView *accessoryImgView;

- (void)updateData:(CategoryDoc *)categoryDoc;
@end
