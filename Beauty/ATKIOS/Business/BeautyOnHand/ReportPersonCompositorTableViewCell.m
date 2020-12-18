//
//  ReportPersonCompositorTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ReportPersonCompositorTableViewCell.h"
#import "ChartModel.h"

@implementation ReportPersonCompositorTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)ReportPersonCompositorCellWithChart:(ChartModel *)theChart type:(NSInteger)theType
{
    _numLab.text =  [NSString stringWithFormat:@"%ld",(long)(_indexPath.row + 1)];
    _nameLab.text = theChart.ObjectName;
    switch (theType) {
        case 1:
        {
            _detailLab.text = [NSString stringWithFormat:@"%ld次",(long)[theChart.ObjectCount integerValue]];
        }
            break;
        case 2:
        {
            _detailLab.text = [NSString stringWithFormat:@"%@",MoneyFormat([theChart.ConsumeAmout doubleValue])];
        }
            break;
        case 3:
        {
            _detailLab.text = [NSString stringWithFormat:@"%@",MoneyFormat([theChart.RechargeAmout doubleValue])];
        }
            break;
            
        default:
            break;
    }
    
}


@end
