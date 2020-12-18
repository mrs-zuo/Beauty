//
//  AppointmentListTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentListTableViewCell.h"
#import "UILabel+InitLabel.h"
@implementation AppointmentListTableViewCell
@synthesize dateLable,customerNameLable,serviceNameLable,statusLable,appointPersonalLable;
- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        dateLable = [UILabel initNormalLabelWithFrame:CGRectMake(5, 5.0f, 230.0f, 14.0f) title:@" " font:kFont_Light_14 textColor:kColor_DarkBlue];
        
        customerNameLable = [UILabel initNormalLabelWithFrame:CGRectMake(140, 5.0f, 150.0f, 14.0f) title:@" " font:kFont_Light_14 textColor:kColor_Black];
        
        serviceNameLable = [UILabel initNormalLabelWithFrame:CGRectMake(5, 45.0f, 160.0f, 14.0f) title:@" " font:kFont_Light_14 textColor:kColor_Editable];
        
        statusLable = [UILabel initNormalLabelWithFrame:CGRectMake(240, 25.0f, 50.0f, 14.0f) title:@" " font:kFont_Light_14 textColor:kColor_Black];
        
        appointPersonalLable = [UILabel initNormalLabelWithFrame:CGRectMake(5, 25.0f, 160.0f, 14.0f) title:@" " font:kFont_Light_14 textColor:kColor_Editable];
        
        dateLable.textAlignment = NSTextAlignmentLeft;
        customerNameLable.textAlignment = NSTextAlignmentRight;
        serviceNameLable.textAlignment = NSTextAlignmentLeft;
        
        statusLable.textAlignment = NSTextAlignmentRight;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:dateLable];
        [self.contentView addSubview:customerNameLable];
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
