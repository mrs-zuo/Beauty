//
//  DoServiceTodayTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/9/15.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DoServiceTodayTableViewCell.h"
#import "UILabel+InitLabel.h"
@implementation DoServiceTodayTableViewCell
@synthesize stateLabel,dateLable,productNameLabel,customerNameLabel,countLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        productNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5, 5, 200, 15) title:@"" font:kFont_Light_14 textColor:kColor_DarkBlue];
        dateLable = [UILabel initNormalLabelWithFrame:CGRectMake(5, 25, 150, 20) title:@"" font:kFont_Light_14 textColor:kColor_Editable];
        customerNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5, 45, 160, 15) title:@"" font:kFont_Light_14 textColor:kColor_Black];
        countLabel = [UILabel initNormalLabelWithFrame:CGRectMake(160, 25, 125, 15) title:@"" font:kFont_Light_14 textColor:kColor_Editable];
        stateLabel= [UILabel initNormalLabelWithFrame:CGRectMake(160, 45, 125, 15) title:@"" font:kFont_Light_14 textColor:kColor_Editable];
        
        stateLabel.textAlignment = NSTextAlignmentRight;
        countLabel.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:productNameLabel];
        [self.contentView addSubview:dateLable];
        [self.contentView addSubview:customerNameLabel];
        [self.contentView addSubview:countLabel];
        [self.contentView addSubview:stateLabel];
    
    }
    return self;
}
- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
