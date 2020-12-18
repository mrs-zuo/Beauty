//
//  CusProductTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/12/4.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CusProductTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (nonatomic,getter = SelectServer) BOOL isSelectServer;

@property (nonatomic,strong) id data;

@property (nonatomic,assign) NSIndexPath *indexPath;
@end
