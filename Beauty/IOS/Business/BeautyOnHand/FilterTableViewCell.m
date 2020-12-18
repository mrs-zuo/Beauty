//
//  FilterTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "FilterTableViewCell.h"

@implementation FilterTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = kColor_DarkBlue;
        self.textLabel.font = kFont_Light_16;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.detailTextLabel.textColor = kColor_Editable;
        self.detailTextLabel.font = kFont_Light_16;
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;

        self.selectionStyle = UITableViewCellSelectionStyleGray;
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
    self.textLabel.frame = CGRectMake(5, 10, 100, 20);
    self.detailTextLabel.frame = CGRectMake(110, 10, 195, 20);

}
@end
