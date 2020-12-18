//
//  OrderInfoCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/13.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "OrderInfoCell.h"

@implementation OrderInfoCell
@synthesize textLabel,detailTextLabel;
- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 140, kTableView_HeightOfRow)];
        detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 160, kTableView_HeightOfRow)];
        detailTextLabel.textAlignment = NSTextAlignmentRight;
        self.detailTextLabel.font = kFont_Light_16;
        self.detailTextLabel.textColor = kColor_Black;
        self.textLabel.textColor = kColor_DarkBlue;
        self.textLabel.font = kFont_Light_16;
        
        [self.contentView addSubview:textLabel];
        [self.contentView addSubview:detailTextLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
