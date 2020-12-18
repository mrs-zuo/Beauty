//
//  BeautyEditTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "BeautyEditTableViewCell.h"
#import "BranchShopRes.h"

@implementation BeautyEditTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}      
- (IBAction)deletBtnClick:(UIButton *)sender {
    self.deletBlock();
}
@end
