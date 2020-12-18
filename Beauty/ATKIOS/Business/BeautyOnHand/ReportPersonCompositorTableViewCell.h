//
//  ReportPersonCompositorTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChartModel;
@interface ReportPersonCompositorTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;


@property (nonatomic,assign) NSIndexPath *indexPath;

- (void)ReportPersonCompositorCellWithChart:(ChartModel *)theChart type:(NSInteger)theType;

@end
