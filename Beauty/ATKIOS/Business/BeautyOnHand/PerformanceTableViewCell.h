//
//  PerformanceTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/27.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserDoc;
@protocol PerformanceTableViewCellDelegate <NSObject>

-(void)PerformanceTableViewCellWithDidEndEditing:(UITextField *)textField;
-(void)PerformanceTableViewCellWithDidBeginEditing:(UITextField *)textField;

@end

@interface PerformanceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UITextField *numText;
@property (weak, nonatomic) IBOutlet UILabel *percentLab;

@property (nonatomic,strong) UserDoc *userDoc;
@property (nonatomic,weak) id delegate;
@end
