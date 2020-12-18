//
//  Task_TableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "Task_TableViewCell.h"
#import "UILabel+InitLabel.h"

@implementation Task_TableViewCell
@synthesize dateLable,serviceNameLable,statusLable;
- (void)awakeFromNib {
    // Initialization code
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        dateLable = [UILabel initNormalLabelWithFrame:CGRectMake(5, 5.0f, 165.0, 14.0f) title:@" " font:kFont_Light_14 textColor:kColor_Editable];
        
        
        serviceNameLable = [UILabel initNormalLabelWithFrame:CGRectMake(5,26.0f, 300.0f, 14.0f) title:@" " font:kFont_Light_14 textColor:kColor_DarkBlue];
        
        statusLable = [UILabel initNormalLabelWithFrame:CGRectMake(130, 5.0f, self.frame.size.width - 130 - 25, 14.0f) title:@" " font:kFont_Light_14 textColor:kColor_Black];
        
        
        dateLable.textAlignment = NSTextAlignmentLeft;
        serviceNameLable.textAlignment = NSTextAlignmentLeft;
        
        statusLable.textAlignment = NSTextAlignmentRight;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:dateLable];
        [self.contentView addSubview:serviceNameLable];
        [self.contentView addSubview:statusLable];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
