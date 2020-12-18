//
//  PSCategoryTableCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-7.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "CategoryTableCell.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"

#import "CategoryDoc.h"

@implementation CategoryTableCell
@synthesize imageView;
@synthesize nameLabel;
@synthesize numberLabel;
@synthesize accessoryImgView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, (kTableView_HeightOfRow - 22.0f)/2, 24.0f, 22.0f)];
        imageView.image = [UIImage imageNamed:@"childNode_bg"];
        [self.contentView addSubview:imageView];
        
        nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake( CGRectGetMaxX(imageView.frame) + 8.0f, 0.0f, 180.0f, kTableView_HeightOfRow) title:@"--"];
        [self.contentView addSubview:nameLabel];
        
        numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(210.0f, 0.0f, 60.0f, kTableView_HeightOfRow) title:@""];
//        [self.contentView addSubview:numberLabel];
        numberLabel.textAlignment = NSTextAlignmentRight;
        
        accessoryImgView = [[UIImageView alloc] initWithFrame:CGRectMake(290.0f, (kTableView_HeightOfRow - 12.0f)/2, 10.0f, 12.0f)];
        accessoryImgView.image = [UIImage imageNamed:@"arrows_bg"];
        [self.contentView addSubview:accessoryImgView];
    }
    return self;
}

- (void)updateData:(CategoryDoc *)categoryDoc
{
    nameLabel.text = categoryDoc.CategoryName;
//    numberLabel.text = [NSString stringWithFormat:@"(%d)", categoryDoc.ProductCount];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
