//
//  AppraiseCellTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/9.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "AppraiseCellTableViewCell.h"
#import "UILabel+InitLabel.h"

@implementation AppraiseCellTableViewCell


- (void)awakeFromNib {
    }

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([reuseIdentifier isEqualToString:@"Cell"] || [reuseIdentifier isEqualToString:@"ThreeCell"]) {
            _nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 10, 150.0f, kLabel_DefaultHeight) title:@""];
            _dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 40, 160.0f, kLabel_DefaultHeight) title:@""];
            _accounNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(145.0f, 10, 160.0f, kLabel_DefaultHeight) title:@""];
            _numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(155, 54.0f, 40, kLabel_DefaultHeight) title:@""];
            _accounNameLabel.textAlignment = NSTextAlignmentRight;
            _numberLabel.textAlignment = NSTextAlignmentRight;
        }else{
            _nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 10, 145.0f, kLabel_DefaultHeight) title:@""];
            _dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 40.0f, 180.0f, kLabel_DefaultHeight) title:@""];
            _accounNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(165.0f, 10, 140.0f, kLabel_DefaultHeight) title:@""];
            _numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(165, 40.0f, 140.0f, kLabel_DefaultHeight) title:@""];
            
            _accounNameLabel.textAlignment = NSTextAlignmentRight;
            _numberLabel.textAlignment = NSTextAlignmentRight;
            _buttonView = [[UIImageView alloc]initWithFrame:CGRectMake(255.0f, 70.0f, 50.0f, 26.0f)];
            UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 26)];
            titleLab.text  = @"评价";
            titleLab.font = kNormalFont_14;
            titleLab.textColor = kColor_White;
            titleLab.textAlignment = NSTextAlignmentCenter;
            [_buttonView addSubview:titleLab];
            _ViewForbutton = [[UIImageView alloc]initWithFrame:CGRectMake(255.0f, 70.0f, 50.0f, 26.0f)];
            _nameLabel.textColor = kColor_TitlePink;
            _buttonView.backgroundColor = KColor_NavBarTintColor;
            [self.contentView addSubview:_ViewForbutton];
            [self.contentView addSubview:_buttonView];
        }
        
        _numberLabel.font = kNormalFont_14;
        _accounNameLabel.font = kNormalFont_14;
        _dateLabel.font = kNormalFont_14;
        _nameLabel.font = kNormalFont_14;

        [self.contentView addSubview:_numberLabel];
        [self.contentView addSubview:_accounNameLabel];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
