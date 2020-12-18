//
//  InfoTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "InfoTableViewCell.h"
#import "OperatingOrder.h"
#import "UIImageView+WebCache.h"
#import "UILabel+InitLabel.h"
@interface InfoTableViewCell()

//
//@property (weak, nonatomic) IBOutlet UIImageView *headImage;
//@property (weak, nonatomic) IBOutlet UILabel *customerName;
//@property (weak, nonatomic) IBOutlet UILabel *productName;
//@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
//@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
//@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@end

@implementation InfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 52,52) ];
        self.customerName = [UILabel initNormalLabelWithFrame:CGRectMake(65, 7, 110, 15) title:@"" font:kFont_Light_14 textColor:kColor_Black];
        self.productName = [UILabel initNormalLabelWithFrame:CGRectMake(65, 27, 110, 15) title:@"" font:kFont_Light_14 textColor:kColor_Black];
        self.dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(65, 47, 130, 15) title:@"" font:kFont_Light_14 textColor:kColor_Black];
        self.statusLabel = [UILabel initNormalLabelWithFrame:CGRectMake(220, 47, 80, 15) title:@"" font:kFont_Light_14 textColor:kColor_Black];
        self.personLabel = [UILabel initNormalLabelWithFrame:CGRectMake(194, 7, 110, 15) title:@"" font:kFont_Light_14 textColor:kColor_Black];
        
        [self.contentView addSubview:self.headImage];
        [self.contentView addSubview:self.customerName];
        [self.contentView addSubview:self.productName];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.statusLabel];
        [self.contentView addSubview:self.personLabel];
        
        self.personLabel.textAlignment = NSTextAlignmentRight;
         self.statusLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return self;
}

- (void)setOperInfo:(OperatingOrder *)Info
{
    _operInfo = Info;
    [self.headImage setImageWithURL:[NSURL URLWithString:_operInfo.HeadImageURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg40"]];
    self.productName.text = _operInfo.ProductName;
    self.dateLabel.text = _operInfo.TGStartTime;
    self.personLabel.text = _operInfo.designateAccountName;
    self.customerName.text = _operInfo.CustomerName;
    
    self.customerName.textColor = kColor_DarkBlue;
    self.productName.textColor = kColor_Editable;
    self.dateLabel.textColor = kColor_Editable;

    
    if(_operInfo.Status == 1)
    {
        self.statusLabel.text = [NSString stringWithFormat:@"┅ %@",_operInfo.statusText ];
        self.statusLabel.textColor = [UIColor colorWithRed:30/255. green:164/255. blue:20/255. alpha:1.];
    }else if(_operInfo.Status == 5)
    {
        self.statusLabel.text = [NSString stringWithFormat:@"? %@",_operInfo.statusText ];
        self.statusLabel.textColor = [UIColor colorWithRed:0/255. green:172/255. blue:247/255. alpha:1.];
    }else{
        self.statusLabel.text = _operInfo.statusText;
        self.statusLabel.textColor = [UIColor blackColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
