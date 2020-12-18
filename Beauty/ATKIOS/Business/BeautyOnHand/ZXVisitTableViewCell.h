//
//  ZXVisitTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/26.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXVisitTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *typeNameLab;
@property (weak, nonatomic) IBOutlet UILabel *cusNameLab;

@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (nonatomic,weak) id data;
@end
