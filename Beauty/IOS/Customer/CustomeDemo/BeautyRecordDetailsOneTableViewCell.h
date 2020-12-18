//
//  BeautyRecordDetailsOneTableViewCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BranchShopRes;
typedef void (^DetailsOneEditBlock)(UIButton *button);
typedef void (^DetailsOneShareBlock)(UIButton *button);

@interface BeautyRecordDetailsOneTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UILabel *branchLab;
- (IBAction)editBtn:(UIButton *)sender;
- (IBAction)shareBtn:(UIButton *)sender;

@property(nonatomic,copy)DetailsOneEditBlock editBlock;
@property(nonatomic,copy)DetailsOneShareBlock shareBlock;

@end
