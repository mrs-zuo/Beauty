//
//  OrderTreatmentCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-12.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TreatmentDoc;

@protocol OrderTreatmentCellDelegate <NSObject>
- (void)chickOperateRowButton:(UITableViewCell *)cell;
@end

@interface OrderTreatmentCell : UITableViewCell
@property (weak, nonatomic) id<OrderTreatmentCellDelegate> delegate;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *accNameLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *subServiceNameLabel;
@property (nonatomic) UIButton *deleteBtn;
@property (nonatomic) UIImageView *statusImgView0;  // treatment完成状态
@property (nonatomic) UIImageView *statusImgView1;  // 是否填写了remark
@property (nonatomic) UIImageView *statusImgView2;  // 是否上传了图片
@property (nonatomic) UIImageView *statusImgView3;  // 是否评价了该treatment
@property (nonatomic) UIImageView *statusImgView4;  //是否指定

- (void)updateData:(TreatmentDoc *)treatmentDoc canEdited:(BOOL)edited;
@end
