//
//  OneLabelCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 13-12-26.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneLabelCell : UITableViewCell
@property (nonatomic) UILabel *contentLabel;

- (void)setContent:(NSString *)content;
@end
