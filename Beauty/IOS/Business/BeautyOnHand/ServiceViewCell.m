//
//  ServiceViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/8/2.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ServiceViewCell.h"

@implementation ServiceViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.desigImage = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"order_designated"];
            [self.contentView addSubview:imageView];
            imageView;
        });
        self.tailImage = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"order_operateButton"];
            [self.contentView addSubview:imageView];
            imageView;
        });
        
        self.quanImage = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"yuan"];
            [self.contentView addSubview:imageView];
            imageView;
        });
        self.detailTextLabel.textColor = kColor_Black;
        self.detailTextLabel.font = kFont_Light_15;
        self.textLabel.font = kFont_Light_15;
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    if (self.imageLayout == ServiceCellLayoutNormol) {
        self.desigImage.frame = CGRectMake(5, 12, 15, 15);
        self.textLabel.frame = CGRectMake(30, 9, 120, 20);
//    } else {
//        self.desigImage.frame = CGRectMake(25, 16.5, 6, 6);
//        self.textLabel.frame = CGRectMake(35, 9, 120, 20);
//    }
    self.quanImage.frame = CGRectMake(22, 17, 6, 6);
    self.detailTextLabel.frame = CGRectMake(180, 9, 100, 20);
    self.tailImage.frame = CGRectMake(CGRectGetMaxX(self.detailTextLabel.frame), 4, 30, 30);
    
}
@end
