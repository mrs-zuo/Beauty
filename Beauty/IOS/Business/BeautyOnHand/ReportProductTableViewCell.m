//
//  ReportProductTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ReportProductTableViewCell.h"
#import "ChartModel.h"

@implementation ReportProductTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setData:(id)data
{
    if ([data isKindOfClass:[ChartModel class]]) {
        ChartModel *chart  = (ChartModel *)data;
        _numLab.text =  [NSString stringWithFormat:@"%ld",(long)(_indexPath.row + 1)];
        _nameLab.text = chart.ObjectName;
        if (_isSelectServer) {
            _detailLab.text = [NSString stringWithFormat:@"%ld次",(long)[chart.ObjectCount integerValue]];
        }else{
            _detailLab.text = [NSString stringWithFormat:@"%ld件",(long)[chart.ObjectCount integerValue]];
        }
    }
}

@end
