//
//  BeautyShareTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/4.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "BeautyShareTableViewCell.h"

@implementation BeautyShareTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)share:(UIButton *)sender {
    self.shareBlock(sender);
}
@end
