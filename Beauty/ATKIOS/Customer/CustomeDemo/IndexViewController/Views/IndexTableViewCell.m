//
//  IndexTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/21.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "IndexTableViewCell.h"
#import "PromotionListRes.h"
#import "NSDate+Additional.h"
#import "NSDate+Convert.h"
#import "SalesPromotionModel.h"

@implementation IndexTableViewCell

- (void)awakeFromNib {
    [self setupSubViewStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
-(void)setData:(id)data
{
    if ([data isKindOfClass:[PromotionListRes class]]) {
        PromotionListRes *res = (PromotionListRes *)data;
        [self setupWithPromotionListRes:res];
    }else if ([data isKindOfClass:[SalesPromotionModel class]]){
        SalesPromotionModel *res = (SalesPromotionModel *)data;
        [self setupWithSalesPromotionModel:res];
    }
}

#pragma mark - 样式
//设置子控件属性
-(void)setupSubViewStyle
{
    _nameLab.font = kNormalFont_14;
    _dateLab.font = kNormalFont_12;
    _dateLab.textColor = kMainLightGrayColor;
    _descLab.numberOfLines = 2;
    _descLab.textColor=kColor_TitlePink;
    _descLab.lineBreakMode = NSLineBreakByTruncatingTail;
    _descLab.font = kNormalFont_14;
}

#pragma mark - 赋值
//首页促销
- (void)setupWithPromotionListRes:(PromotionListRes *)res
{
    [_imgView setImageWithURL:[NSURL URLWithString:res.PromotionPictureURL] placeholderImage:[UIImage imageNamed:@"indexDefaultImage"] options:SDWebImageCacheMemoryOnly];
    _nameLab.text = res.Title;
    _descLab.text = res.Description;
    NSString *tempStr = [NSString stringWithFormat:@"%@至%@", [NSDate stringFromDateString:res.StartDate], [NSDate stringFromDateString:res.EndDate]];
    _dateLab.text = tempStr;
}

//促销详细
- (void)setupWithSalesPromotionModel:(SalesPromotionModel *)res
{
    [_imgView setImageWithURL:[NSURL URLWithString:res.PromotionPictureURL] placeholderImage:[UIImage imageNamed:@"indexDefaultImage"] options:SDWebImageCacheMemoryOnly];
    _nameLab.text = res.Title;
    _descLab.text = res.Description;
    NSString *tempStr = [NSString stringWithFormat:@"%@至%@", [NSDate stringFromDateString:res.StartDate], [NSDate stringFromDateString:res.EndDate]];
    _dateLab.text = tempStr;
}



@end
