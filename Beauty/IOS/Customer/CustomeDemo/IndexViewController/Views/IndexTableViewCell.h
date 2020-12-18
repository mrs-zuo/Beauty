//
//  IndexTableViewCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/21.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *descLab;

@property (nonatomic,weak) id data;
@end
