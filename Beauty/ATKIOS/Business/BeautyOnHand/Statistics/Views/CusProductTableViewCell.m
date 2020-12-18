//
//  CusProductTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/12/4.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "CusProductTableViewCell.h"
#import "ChartModel.h"

@implementation CusProductTableViewCell

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
        _numLabel.text =  [NSString stringWithFormat:@"%ld",(long)_indexPath.row + 1];
        _contentLabel.text = chart.ObjectName;
        if (_isSelectServer) {
            _detailLabel.text = [NSString stringWithFormat:@"%ld次",(long)[chart.ObjectCount integerValue]];
        }else{
            _detailLabel.text = [NSString stringWithFormat:@"%ld件",(long)[chart.ObjectCount integerValue]];

        }
    }
}


@end
