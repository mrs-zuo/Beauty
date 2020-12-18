//
//  DepositReceiptTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/12/1.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "DepositReceiptTableViewCell.h"
#import "UILabel+InitLabel.h"
@implementation DepositReceiptTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
     self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([reuseIdentifier isEqualToString:@"Cell"] || [reuseIdentifier isEqualToString:@"ThreeCell"]) {
            _nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 10, 150.0f, kLabel_DefaultHeight) title:@""];
            _dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 40, 160.0f, kLabel_DefaultHeight) title:@""];
            _accounNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 70, 160.0f, kLabel_DefaultHeight) title:@""];
            _numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(155, 40, 150.0f, kLabel_DefaultHeight) title:@""];
            
            _accounNameLabel.textAlignment = NSTextAlignmentLeft;
            _numberLabel.textAlignment = NSTextAlignmentRight;
        }else{
            _nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 10, 145.0f, kLabel_DefaultHeight) title:@""];
            _dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 40, 180.0f, kLabel_DefaultHeight) title:@""];
            _accounNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 70, 140.0f, kLabel_DefaultHeight) title:@""];
            _numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(165, 40, 140.0f, kLabel_DefaultHeight) title:@""];
            
            _accounNameLabel.textAlignment = NSTextAlignmentLeft;
            _numberLabel.textAlignment = NSTextAlignmentRight;
            
            _dateLabel.textColor = KColor_SaveDanTitleColor;
            _accounNameLabel.textColor = KColor_SaveDanTitleColor;
            _numberLabel.textColor = KColor_SaveDanTitleColor;

            
            _nameLabel.font = kNormalFont_14;
            _dateLabel.font = kNormalFont_14;
            _accounNameLabel.font = kNormalFont_14;
            _numberLabel.font = kNormalFont_14;
            
            _appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_appointButton setFrame:CGRectMake(250, 65, 60, 30)];
            _appointButton.backgroundColor = KColor_NavBarTintColor;
            [_appointButton setTitle:@"预约" forState:UIControlStateNormal];
            _appointButton.titleLabel.font = kNormalFont_14;
            [self.contentView addSubview:_appointButton];
        }
        [self.contentView addSubview:_numberLabel];
        [self.contentView addSubview:_accounNameLabel];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_nameLabel];

    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
