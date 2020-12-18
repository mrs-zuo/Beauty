//
//  BeautyEditTableViewCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BranchShopRes.h"
typedef void(^BeautyEdiCellDeletBlock) ();

@interface BeautyEditTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lab;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn;

- (IBAction)deletBtnClick:(UIButton *)sender;

@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) BeautyEdiCellDeletBlock deletBlock;


@end
