//
//  ReportProductTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportProductTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;

@property (nonatomic,getter = SelectServer) BOOL isSelectServer;
@property (nonatomic,strong) id data;
@property (nonatomic,assign) NSIndexPath *indexPath;

@end
