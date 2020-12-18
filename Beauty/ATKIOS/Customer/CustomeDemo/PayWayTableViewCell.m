//
//  PayWayTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/4/25.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "PayWayTableViewCell.h"

@implementation PayWayTableViewCell

- (void)awakeFromNib {

    self.titleLab.textColor = kColor_TitlePink;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)markButtonClick:(UIButton *)sender {
    
    self.btnClickBlcok(sender);
    
}
@end
