//
//  PeriodDetailTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/12/1.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#define TITLELAB_COLOR [UIColor colorWithRed:12.0/255.0 green:86.0/255.0 blue:157.0/255.0 alpha:1]

#import "PeriodDetailTableViewCell.h"
#import "ChartModel.h"
#import "DEFINE.h"

@implementation PeriodDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _titleLab.backgroundColor = TITLELAB_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

-(void)setData:(id)data
{
    if ([data isKindOfClass:[ChartModel class]]) {
        ChartModel *chart = (ChartModel *)data;
        _monthLab.text = chart.ObjectName;
        _consumptionLab.text = MoneyFormat(chart.ConsumeAmout.doubleValue);
        _countLab.text = [NSString stringWithFormat:@"%@ 次",chart.ObjectCount.stringValue];
        _rechargeLab.text = MoneyFormat(chart.RechargeAmout.doubleValue);
    }
}
@end
