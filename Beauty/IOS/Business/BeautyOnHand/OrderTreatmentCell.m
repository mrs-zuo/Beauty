//
//  OrderTreatmentCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-12.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OrderTreatmentCell.h"
#import "TreatmentDoc.h"
#import "DEFINE.h"

#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"

#define DESIGNATEDFRAME CGRectMake(30.0f -5, 25.f, 15.0f, 15.0f)
#define NAMELABELFRAME  CGRectMake(30.0f -5, 19.0f, 130.0f, kTableView_HeightOfRow)

@implementation OrderTreatmentCell
@synthesize titleLabel, accNameLabel, dateLabel, deleteBtn,subServiceNameLabel;
@synthesize statusImgView0, statusImgView1, statusImgView2, statusImgView3, statusImgView4;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        statusImgView0 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,  0.0f, 22.0f, 22.0f)];
        statusImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(32.0f -5, 8.f, 14.0f, 14.0f)];
        statusImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(47.0f -5,8.f, 14.0f, 14.0f)];
        statusImgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(62.0f -5, 8.f, 14.0f, 14.0f)];
        statusImgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(30.0f -5, 25.f, 15.0f, 15.0f)];
        
        statusImgView0.image = [UIImage imageNamed:@"order_FinishStatus"];
        statusImgView1.image = [UIImage imageNamed:@"order_RemarkStatus"];
        statusImgView2.image = [UIImage imageNamed:@"order_PictureStatus"];
        statusImgView3.image = [UIImage imageNamed:@"order_AppraiseStatus"];
        statusImgView4.image = [UIImage imageNamed:@"order_designated"];
        
        [self.contentView addSubview:statusImgView0];
        [self.contentView addSubview:statusImgView1];
        [self.contentView addSubview:statusImgView2];
        [self.contentView addSubview:statusImgView3];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(4.0f, 15, 28.0f, 20.0f) title:@""];
        [titleLabel setTextColor:kColor_DarkBlue];
        [titleLabel setFont:kFont_Medium_16];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:titleLabel];
        
        
        subServiceNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(100.0f, 0, 178.0f, 30.0f) title:@""];
        subServiceNameLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:subServiceNameLabel];
        
        accNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(30.0f -5, 19.0f, 130.0f, kTableView_HeightOfRow) title:@""];
        accNameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:accNameLabel];
        [self.contentView addSubview:statusImgView4];
        
        dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(148.0f, 24.f, 130.0f, 30.0f) title:@""];
        dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:dateLabel];
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(275.0f, 12.0f, 30.0f, 30.0f);
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"order_operateButton"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(operateAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
    }
    return self;
}

- (void)updateData:(TreatmentDoc *)treatmentDoc canEdited:(BOOL)edited
{
    if (!edited) {
        statusImgView0.hidden = (treatmentDoc.treat_Schedule.sch_Completed == 1 || treatmentDoc.treat_Schedule.sch_Completed == 4) ? NO : YES;

        statusImgView1.image = (treatmentDoc.status_RemarkCnt > 0 ? [UIImage imageNamed:@"order_RemarkStatus"] : [UIImage imageNamed:@"order_RemarkStatusInvalid"]);
        statusImgView2.image = (treatmentDoc.status_PictureCnt > 0 ? [UIImage imageNamed:@"order_PictureStatus"] : [UIImage imageNamed:@"order_PictureStatusInvalid"]);
        statusImgView3.image = (treatmentDoc.status_AppraiseCnt > 0 ? [UIImage imageNamed:@"order_AppraiseStatus"] : [UIImage imageNamed:@"order_AppraiseStatusInvalid"]);
        statusImgView4.hidden = !treatmentDoc.status_Designated;
        deleteBtn.hidden = YES;
        
        accNameLabel.textColor = [UIColor blackColor];
        dateLabel.textColor = [UIColor blackColor];
    } else {
        statusImgView0.hidden = (treatmentDoc.treat_Schedule.sch_Completed == 1 || treatmentDoc.treat_Schedule.sch_Completed == 4) ? NO : YES;
        statusImgView1.image = (treatmentDoc.status_RemarkCnt > 0 ? [UIImage imageNamed:@"order_RemarkStatus"] : [UIImage imageNamed:@"order_RemarkStatusInvalid"]);
        statusImgView2.image = (treatmentDoc.status_PictureCnt > 0 ? [UIImage imageNamed:@"order_PictureStatus"] : [UIImage imageNamed:@"order_PictureStatusInvalid"]);
        statusImgView3.image = (treatmentDoc.status_AppraiseCnt > 0 ? [UIImage imageNamed:@"order_AppraiseStatus"] : [UIImage imageNamed:@"order_AppraiseStatusInvalid"]);
        statusImgView4.hidden = !treatmentDoc.status_Designated;
        deleteBtn.hidden = NO;
        
        accNameLabel.textColor = [UIColor blackColor];
        dateLabel.textColor = [UIColor blackColor];
    }
    
    statusImgView4.frame = DESIGNATEDFRAME;
    accNameLabel.frame = NAMELABELFRAME;
    
    accNameLabel.text = treatmentDoc.treat_AccName;
    subServiceNameLabel.text = treatmentDoc.treat_SubServiceName;
    
    if (treatmentDoc.status_Designated) {
//        CGRect desigView = statusImgView4.frame;
        
        CGRect nameFrame = accNameLabel.frame;
        
//        CGSize size =[treatmentDoc.treat_AccName sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(70, 20) lineBreakMode:NSLineBreakByTruncatingTail];
//        nameFrame.size.width = size.width;
        
        nameFrame.origin.x += 8;
        nameFrame.size.width -= 16;
        accNameLabel.frame = nameFrame;
//        statusImgView4.frame = desigView;

    }
    dateLabel.text = treatmentDoc.treat_Schedule.sch_ScheduleTime;
    titleLabel.text = @"";
//    titleLabel.text = [NSString stringWithFormat:@"%ld", treatmentDoc.treat_Number];
    if (treatmentDoc.treat_Schedule.sch_Completed == 4) {
        self.backgroundColor = [UIColor colorWithWhite:0.777 alpha:0.5];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)operateAction
{
    if ([delegate respondsToSelector:@selector(chickOperateRowButton:)]) {
        [delegate chickOperateRowButton:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
