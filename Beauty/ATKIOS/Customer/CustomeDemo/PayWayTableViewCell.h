//
//  PayWayTableViewCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/4/25.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^btnBlock)(UIButton *button);

@interface PayWayTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *identifierImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *markBtn;

@property (nonatomic,copy)NSString *cellTitle;
@property (nonatomic,copy)btnBlock btnClickBlcok;


- (IBAction)markButtonClick:(UIButton *)sender;
@end
