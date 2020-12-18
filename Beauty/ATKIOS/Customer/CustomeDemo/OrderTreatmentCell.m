//
//  OrderTreatmentCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-12.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OrderTreatmentCell.h"
#import "TreatmentDoc.h"
#import "ScheduleDoc.h"

#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"

@implementation OrderTreatmentCell
@synthesize titleLabel, accNameLabel, dateLabel ,subServiceNameLabel;
@synthesize statusImgView0, statusImgView1, statusImgView2, statusImgView3;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        statusImgView0 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,  0.0f, 22.0f, 22.0f)];
        statusImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(28.0f, 8.f, 14.0f, 14.0f)];
        statusImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(43.0f ,8.f, 14.0f, 14.0f)];
        statusImgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(58.0f, 8.f, 14.0f, 14.0f)];
        statusImgView0.image = [UIImage imageNamed:@"order_FinishStatus"];
        statusImgView1.image = [UIImage imageNamed:@"order_RemarkStatus"];
        statusImgView2.image = [UIImage imageNamed:@"order_PictureStatus"];
        statusImgView3.image = [UIImage imageNamed:@"order_AppraiseStatus"];
        [self.contentView addSubview:statusImgView0];
        [self.contentView addSubview:statusImgView1];
        [self.contentView addSubview:statusImgView2];
        [self.contentView addSubview:statusImgView3];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(6.0f, 15, 30.0f, 20.0f) title:@""];
        [titleLabel setTextColor:kColor_TitlePink];
        [titleLabel setFont:kFont_Medium_16];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:titleLabel];
        
        subServiceNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(100.0f, 0, 178.0f, 30.0f) title:@""];
        subServiceNameLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:subServiceNameLabel];
        
        accNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(26.0f, 24.0f, 120.0f, 30.0f) title:@""];
        accNameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:accNameLabel];
        
        dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(148.0f, 24.f, 130.0f, 30.0f) title:@""];
        dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:dateLabel];
    }
    return self;
}

- (void)updateData:(TreatmentDoc *)treatmentDoc canEdited:(BOOL)edited
{
    if (!edited) {
        statusImgView0.hidden = (treatmentDoc.schedule.sch_Completed == 1 || treatmentDoc.schedule.sch_Completed == 4 ) ? NO : YES;
        statusImgView1.image = (treatmentDoc.status_RemarkCnt > 0 ? [UIImage imageNamed:@"order_RemarkStatus"] : [UIImage imageNamed:@"order_RemarkStatusInvalid"]);
        statusImgView2.image = (treatmentDoc.status_PictureCnt > 0 ? [UIImage imageNamed:@"order_PictureStatus"] : [UIImage imageNamed:@"order_PictureStatusInvalid"]);
        statusImgView3.image = (treatmentDoc.status_AppraiseCnt > 0 ? [UIImage imageNamed:@"order_AppraiseStatus"] : [UIImage imageNamed:@"order_AppraiseStatusInvalid"]);
        
        accNameLabel.textColor = [UIColor blackColor];
        dateLabel.textColor = [UIColor blackColor];
    } else {
        statusImgView0.hidden = YES;
        statusImgView1.hidden = YES;
        statusImgView2.hidden = YES;
        statusImgView3.hidden = YES;
        
        accNameLabel.textColor = kColor_Editable;
        dateLabel.textColor = kColor_Editable;
    }
    accNameLabel.text = treatmentDoc.treat_AccName;
    subServiceNameLabel.text = treatmentDoc.treat_SubServiceName;
    dateLabel.text = treatmentDoc.schedule.sch_ScheduleTime;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
