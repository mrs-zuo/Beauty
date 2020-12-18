//
//  BusinessInfoCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/6.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "BusinessInfoCell.h"

@implementation BusinessInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, kSCREN_BOUNDS.size.width - 20, 20)];
        self.titleLabel.textColor = kColor_TitlePink;
        self.titleLabel.font = kNormalFont_14;
        [self.contentView addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 15, 120, 20)];
        self.detailLabel.font  =  kNormalFont_14;
        self.detailLabel.textColor = kColor_Editable;
    
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.detailLabel.numberOfLines = 0;
        [self.contentView addSubview:self.detailLabel];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfoDic:(NSDictionary *)dic
{
    _infoDic = dic;
    NSString *title = _infoDic[@"Title"];
    NSString *content = _infoDic[@"Content"];
    

    if (title.length == 0 || [title isEqualToString:@"网址简介"]) {

        CGSize constraint = CGSizeMake(300, 20000.0f);
        CGSize size = [content sizeWithFont:kNormalFont_14 constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        [self.detailLabel setFrame:CGRectMake(10, 5, size.width, size.height<30?30:size.height)];
        self.detailLabel.textAlignment = NSTextAlignmentLeft;
    }
   
    
    if ([title isEqualToString:@"简介内容"]) {
        
        self.titleLabel.textColor = kColor_Editable;
        self.titleLabel.text = content;
        self.detailLabel.text = nil;
        
    } else {
        self.titleLabel.textColor =kColor_TitlePink;
        self.titleLabel.text = title;
        if ([title isEqualToString:@"网址简介"]) {
            self.titleLabel.text = nil;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",content]];
            NSRange strRange = {0,[str length]};
            [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
            [self.detailLabel setAttributedText:str];
            self.detailLabel.textColor = KColor_Blue;
        }else if ([self.titleLabel.text isEqualToString:@"电话"]) {
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",content]];
            NSRange strRange = {0,[str length]};
            
            [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
            
            [self.detailLabel setAttributedText:str];
            self.detailLabel.userInteractionEnabled = YES;
            self.detailLabel.textColor = KColor_Blue;
        }else if ([title isEqualToString:@"简称"] || [title isEqualToString:@"联系人"] || [title isEqualToString:@"传真"] || [title isEqualToString:@"邮编"])
        {
            
            self.detailLabel.textAlignment = NSTextAlignmentRight;
            self.detailLabel.text = content;

        }else {
            
            CGRect tempRect = [content  boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            CGRect rect = self.detailLabel.frame;
            rect.size.height = tempRect.size.height + (lines * 5) ;
            self.detailLabel.frame = rect;
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",content]];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            
            paragraphStyle.lineSpacing  = 5;
            
            [str setAttributes:@{NSFontAttributeName:kNormalFont_14,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, str.length)];
            [self.detailLabel setAttributedText:str];

        }
    }
}

@end
