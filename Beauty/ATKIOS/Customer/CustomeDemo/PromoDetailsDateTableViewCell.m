//
//  PromoDetailsDateTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/9.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "PromoDetailsDateTableViewCell.h"

@implementation PromoDetailsDateTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _startLab.textColor = kMainLightGrayColor;
    _endLab.textColor =   kMainLightGrayColor;
    _startLab.font = kNormalFont_14;
    _endLab.font = kNormalFont_14;
    
    _staName.textColor =  kMainLightGrayColor;
    _endName.textColor =  kMainLightGrayColor;
    _staName.font = kNormalFont_14;
    _endName.font = kNormalFont_14;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
