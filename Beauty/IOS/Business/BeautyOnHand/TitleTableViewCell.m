//
//  TitleTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/8/2.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "TitleTableViewCell.h"
#import "Masonry.h"
@implementation TitleTableViewCell
@synthesize mdetailTextLabel;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //->wugang
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    //wugang<-
    if (self) {
        self.textLabel.font = kFont_Light_15;
        //->wugang
        mdetailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 6, 65, 27)];
        self.mdetailTextLabel.font = kFont_Light_15;
        self.mdetailTextLabel.textColor = [UIColor whiteColor];
        self.mdetailTextLabel.layer.masksToBounds = YES;
        self.mdetailTextLabel.layer.cornerRadius = 5.0f;
        self.mdetailTextLabel.backgroundColor = KColor_Blue;
        //wugang<-
//        [self.detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.offset(-5);
//            make.top.offset(5);
//            make.width.mas_equalTo(100);
//            make.height.mas_equalTo(50);
//        }];
        //->wugang
        self.mdetailTextLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.mdetailTextLabel];
        //wugang<-
        [self.contentView addSubview:self.textLabel];
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
    self.textLabel.frame = CGRectMake(5, 9, 100, 20);
    //->wugang
    //self.detailTextLabel.frame = CGRectMake(240, 6, 65, 27);
    //wugang<-
}
@end
