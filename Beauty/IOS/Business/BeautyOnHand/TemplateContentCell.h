//
//  TemplateContentCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-24.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TemplateDoc;
@interface TemplateContentCell : UITableViewCell
@property (nonatomic) UILabel *contentLabel;
@property (nonatomic) UILabel *createrLabel;
@property (nonatomic) UILabel *menderLabel;
@property (nonatomic) UILabel *dateLabel;

- (void)updateData:(TemplateDoc *)newTemplateDoc type:(int)type;
@end
