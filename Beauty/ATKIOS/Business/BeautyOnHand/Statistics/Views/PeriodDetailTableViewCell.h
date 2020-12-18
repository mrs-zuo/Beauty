//
//  PeriodDetailTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/12/1.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeriodDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@property (weak, nonatomic) IBOutlet UILabel *consumptionLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;

@property (weak, nonatomic) IBOutlet UILabel *rechargeLab;

@property (nonatomic,strong) id data;
@property (weak, nonatomic) IBOutlet UILabel *monthLab;

@end
