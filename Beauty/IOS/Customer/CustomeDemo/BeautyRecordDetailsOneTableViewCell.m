//
//  BeautyRecordDetailsOneTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "BeautyRecordDetailsOneTableViewCell.h"
#import "BranchShopRes.h"

@implementation BeautyRecordDetailsOneTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.dateLab.textColor = KColor_NavBarTintColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editBtn:(UIButton *)sender {
    self.editBlock(sender);
}

- (IBAction)shareBtn:(UIButton *)sender {
    self.shareBlock(sender);
}
@end
