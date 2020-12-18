//
//  AppointmentListTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentListTableViewCell.h"


@implementation AppointmentListTableViewCell
@synthesize dateLable,titleLable,serviceNameLable,statusLable,appointPersonalLable;
- (void)awakeFromNib {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        dateLable = [[UILabel alloc] initWithFrame:CGRectMake(5,10, 230.0f, 20)];
        dateLable.font = kNormalFont_14;
        dateLable.textColor = KColor_appointmentCellTitleColor;
        
        serviceNameLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, 290.0f, 20)];
        serviceNameLable.font = kNormalFont_14;
        serviceNameLable.textColor = kColor_Black;
        
        titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 70, 160.0f, 20)];
        titleLable.font = kNormalFont_14;
        titleLable.textColor = KColor_appointmentCellTitleColor;
        
       
        
        statusLable = [[UILabel alloc] initWithFrame:CGRectMake(240, 10, 50.0f + 5, 20)];
        statusLable.font = kNormalFont_14;
        statusLable.textColor = KColor_appointmentCellTitleColor;
        
        appointPersonalLable = [[UILabel alloc] initWithFrame:CGRectMake(110, 70, 185.0f, 20)];
        appointPersonalLable.font = kNormalFont_14;
        appointPersonalLable.textColor = KColor_appointmentCellTitleColor;
        
        dateLable.textAlignment = NSTextAlignmentLeft;
        titleLable.textAlignment = NSTextAlignmentLeft;
        serviceNameLable.textAlignment = NSTextAlignmentLeft;
        
        statusLable.textAlignment = NSTextAlignmentRight;
        appointPersonalLable.textAlignment = NSTextAlignmentRight;
        self.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:dateLable];
        [self.contentView addSubview:titleLable];
        [self.contentView addSubview:serviceNameLable];
        [self.contentView addSubview:statusLable];
        [self.contentView addSubview:appointPersonalLable];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
