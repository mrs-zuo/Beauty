//
//  NoticeCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "NoticeCell.h"
#import "NoticeDoc.h"

@interface NoticeCell ()

@property (nonatomic,strong) UILabel *nameLab;
@property (nonatomic,strong) UILabel *dateLab;


@end


@implementation NoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {

        _nameLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _nameLab.textColor = kColor_TitlePink;
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = kNormalFont_14;
        [self.contentView addSubview:_nameLab];
        
        _dateLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _dateLab.textColor = kColor_TitlePink;
        _dateLab.textAlignment = NSTextAlignmentLeft;
        _dateLab.font = kNormalFont_14;
        [self.contentView addSubview:_dateLab];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;

    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)setData:(id)data
{
    if ([data isKindOfClass:[NoticeDoc class]]) {
        NoticeDoc *noticeData = data;
        _nameLab.text = noticeData.notice_Title;
        _dateLab.text = [NSString stringWithFormat:@"%@~%@", [noticeData.notice_StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."], [noticeData.notice_EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
   _nameLab.frame = CGRectMake( 10, 10, 240, 20);
    _dateLab.frame = CGRectMake( 10, 40, 240, 20);
}

@end
