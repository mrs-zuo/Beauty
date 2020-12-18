//
//  EcardIndateCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DFTableCell.h"

@implementation DFTableCell

- (void)awakeFromNib {
    // Initialization code
}




- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.textLabel.textColor = kColor_DarkBlue;
    self.textLabel.font = kFont_Medium_16;
    self.detailTextLabel.font = kFont_Light_16;
    self.detailTextLabel.textAlignment = NSTextAlignmentRight;
    self.detailTextLabel.numberOfLines = 0;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(9.0f, 9.0f, 80.0f, 20.0f);
    self.detailTextLabel.frame = CGRectMake(120.0f, 4.0f, 180.0f, 30.0f);
    self.imageView.frame = CGRectMake(155.0f, 9.0f, 45.0f, 18.0f);
    if (self.layoutBlock) {
        self.layoutBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
