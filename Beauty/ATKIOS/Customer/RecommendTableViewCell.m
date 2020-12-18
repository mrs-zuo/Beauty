//
//  RecommendTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/27.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "RecommendTableViewCell.h"
#import "UILabel+InitLabel.h"
#import "AppointmentStoreRecommendModel.h"

@interface RecommendTableViewCell ()
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel * detailLabel;
@end

@implementation RecommendTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];

        
        _appointmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_appointmentButton setFrame:CGRectMake(260, 40, 50, 30)];
        _appointmentButton.backgroundColor = KColor_NavBarTintColor;
        [_appointmentButton setTitle:@"预约" forState:UIControlStateNormal];
        _appointmentButton.tag = 1001;
        _appointmentButton.titleLabel.font = kNormalFont_14;
    
        _detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_detailButton setFrame:CGRectMake(200, 40, 50, 30)];
        _detailButton.backgroundColor = KColor_NavBarTintColor;
        [_detailButton setTitle:@"详情" forState:UIControlStateNormal];
         _detailButton.titleLabel.font = kNormalFont_14;
        _detailButton.tag = 1002;
    
        [self.contentView addSubview:_appointmentButton];
        [self.contentView addSubview:_detailButton];
        
        
        
        
        if (self) {
            _headImageView = ({
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
                imageView;
            });
            _headImageView.layer.borderColor = kColor_Border;
            [self.contentView addSubview:_headImageView];
            
            self.textLabel.font = kFont_Light_14;
            self.textLabel.textColor = kColor_TitlePink;
            self.textLabel.textAlignment = NSTextAlignmentLeft;
            
            self.detailTextLabel.font = kFont_Light_14;
            self.detailTextLabel.textColor = kColor_Editable;
            self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
            self.detailTextLabel.numberOfLines = 0;
            self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            self.selectionStyle = UITableViewCellSelectionStyleGray;
       
        }
    return self;
}

-(void)setAppointmentStoreRecommend:(AppointmentStoreRecommendModel *)AppointmentStoreRecommendModel
{
    _AppointmentStoreRecommend = AppointmentStoreRecommendModel;
    [self.headImageView setImageWithURL:[NSURL URLWithString:_AppointmentStoreRecommend.ThumbnailURL] placeholderImage:[UIImage imageNamed:@"productDefaultImage"]];

    self.textLabel.text = [NSString stringWithFormat:@"%@",AppointmentStoreRecommendModel.ProductName];
    self.detailTextLabel.text = [NSString stringWithFormat:@"￥ %.2f",AppointmentStoreRecommendModel.UnitPrice];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 5, 10, 245, kLabel_DefaultHeight);
    self.detailTextLabel.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 5, 40, 245, kLabel_DefaultHeight);
}

@end
