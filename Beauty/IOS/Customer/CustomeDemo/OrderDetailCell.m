//
//  OrderDetailCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/25.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "OrderDetailCell.h"

@implementation OrderDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.textLabel.textColor = kColor_TitlePink;
        self.textLabel.font = kNormalFont_14;
        
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        
        
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.textColor = kColor_Black;
        self.detailTextLabel.font = kNormalFont_14;
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 15, 145,kLabel_DefaultHeight)];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(10, 15, 150 , kLabel_DefaultHeight);
    
    self.detailTextLabel.frame = CGRectMake(160, 15, 150, kLabel_DefaultHeight);

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
