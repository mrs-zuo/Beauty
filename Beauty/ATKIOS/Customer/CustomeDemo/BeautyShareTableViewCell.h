//
//  BeautyShareTableViewCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/4.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ShareBlock) (UIButton *button);
@interface BeautyShareTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
- (IBAction)share:(UIButton *)sender;
@property (nonatomic,copy) ShareBlock shareBlock;
@end
