//
//  OrderProgressCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/26.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "OrderProgressCell.h"

@implementation OrderProgressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.textLabel.textColor = kColor_TitlePink;
        self.textLabel.font = kNormalFont_14;
        
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = kColor_Black;
        self.detailTextLabel.font = kNormalFont_14;
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 15, 145, kLabel_DefaultHeight)];
        self.detailLabel.textColor = kColor_Black;
        self.detailLabel.font = kNormalFont_14;
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(15, 15, 150, kLabel_DefaultHeight);
    if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator || self.accessoryView != nil) {
        self.detailTextLabel.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame), 15, 130, kLabel_DefaultHeight);
    } else {
        self.detailTextLabel.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame), 15, 135, kLabel_DefaultHeight);
    }
}

@end
