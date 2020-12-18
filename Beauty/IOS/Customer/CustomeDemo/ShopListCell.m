//
//  ShopListCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "ShopListCell.h"
#import "ShopInfoModel.h"

static CGFloat const kLabel_Height = 20;

@interface ShopListCell()
@property (nonatomic, strong) UIImageView *nameImage;
@property (nonatomic, strong) UIImageView *addressImage;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *addressLab;
@property (nonatomic, strong) UILabel *distanceLab;


@end
@implementation ShopListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _nameImage = ({
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Beauty-CompanyNameIcon"]];
            image.contentMode = UIViewContentModeScaleAspectFit;
            image;
        });
        _addressImage = ({
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Beauty-AddressIcon"]];
            image.contentMode = UIViewContentModeScaleAspectFit;
            image;
        });
    
   
        [self.contentView addSubview:_nameImage];
        [self.contentView addSubview:_addressImage];
        
        _nameLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = kNormalFont_14;
        _nameLab.textColor = kColor_TitlePink;
        [self.contentView addSubview:_nameLab];
        
        _addressLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _addressLab.textAlignment = NSTextAlignmentLeft;
        _addressLab.font = kNormalFont_14;
        _addressLab.textColor = kColor_Black;
        [self.contentView addSubview:_addressLab];
        
        

        //距离
        _distanceLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _distanceLab.textAlignment = NSTextAlignmentRight;
        _distanceLab.font = kNormalFont_14;
        _distanceLab.textColor = kMainLightGrayColor;
        [self.contentView addSubview:_distanceLab];
        
        
        self.textLabel.font = kFont_Light_16;
        self.textLabel.textColor = kColor_TitlePink;
        self.textLabel.textAlignment = NSTextAlignmentLeft;

        self.detailTextLabel.font = kFont_Light_14;
        self.detailTextLabel.textColor = kColor_Black;
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;

    }
    return self;
}

- (void)setShop:(ShopInfoModel *)shopModel
{
    _shop = shopModel;
    _nameLab.text = _shop.BranchName;
  _addressLab.text = _shop.Address;
    
    
    if (_shop.Distance.doubleValue == -1) {
         self.distanceLab.text = @"未知";
    }else{
        double distance = _shop.Distance.doubleValue;
        self.distanceLab.text = [NSString stringWithFormat:@"%.1lfkm",distance];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _nameImage.frame = CGRectMake(10, 10, 25, 17);
    _addressImage.frame = CGRectMake(10, 40, 25, 17);
    
    _nameLab.frame = CGRectMake(45, 10, 200, kLabel_Height);
    _addressLab.frame = CGRectMake(45, 40,200, kLabel_Height);

    _distanceLab.frame = CGRectMake(self.contentView.frame.size.width - 120, 25, 100, kLabel_Height);

  
}
@end
