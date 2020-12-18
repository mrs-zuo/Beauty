//
//  ServiceCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "ServiceCell.h"
#import "AccountDoc.h"
#import "UILabel+Extend.h"

static const CGFloat kImageView_Height = 60;

@interface ServiceCell()
@property (nonatomic, strong) UIImageView *serviceImageView;

@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *detailLab;


@end

@implementation ServiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _serviceImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, kImageView_Height, kImageView_Height)];
        _serviceImageView.layer.masksToBounds = YES;
        _serviceImageView.layer.cornerRadius = _serviceImageView.layer.bounds.size.width * 0.5;
        [self.contentView addSubview:_serviceImageView];
        
        _detailLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _detailLab.font = kNormalFont_14;
        _detailLab.textColor = kColor_TitlePink;
        _detailLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_detailLab];
        
        _nameLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _nameLab.font = kNormalFont_14;
        _nameLab.textColor = kColor_TitlePink;
        _nameLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_nameLab];
        
      
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    return self;
}

- (void)setAccountDoc:(AccountDoc *)account
{
    _accountDoc = account;
    _nameLab.text = _accountDoc.acc_Name;
    _detailLab.text = _accountDoc.acc_Title;
    [self.serviceImageView setImageWithURL:[NSURL URLWithString:account.acc_HeadImgURL] placeholderImage:[UIImage imageNamed:@"People-default"]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _detailLab.frame = CGRectMake(kImageView_Height + 20, 30, 100, 20);
    _nameLab.frame = CGRectMake(kImageView_Height + 20 + 100,  30, kSCREN_BOUNDS.size.width - (kImageView_Height + 20 + 100 + 40), 20);

}

@end
