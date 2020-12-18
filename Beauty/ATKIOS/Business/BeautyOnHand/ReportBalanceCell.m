//
//  ReportBalanceCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-3-25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ReportBalanceCell.h"
#import "EcardReport.h"
#import "DEFINE.h"

#define XWIDTH  (IOS6 ? 20.0 : 10.0)
@interface ReportBalanceCell()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) UILabel *rechangeLabel;
@property (nonatomic, strong) UILabel *outlayLabel;
@end

@implementation ReportBalanceCell
@synthesize nameLabel;
@synthesize balanceLabel;
@synthesize rechangeLabel;
@synthesize outlayLabel;

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(XWIDTH, 6, 100, 20.0f)];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = kColor_DarkBlue;
        nameLabel.font = kFont_Light_16;
        
        balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(100 + XWIDTH, 6, 190, 20)];
        balanceLabel.textAlignment = NSTextAlignmentRight;
        balanceLabel.textColor = kColor_Black;
        balanceLabel.font = kFont_Light_16;
        
        rechangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(XWIDTH, 31, 145, 20)];
        rechangeLabel.textAlignment = NSTextAlignmentLeft;
        rechangeLabel.textColor = [UIColor greenColor];
        rechangeLabel.font = kFont_Light_16;

        outlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(145 + XWIDTH, 31, 145, 20)];
        outlayLabel.textAlignment = NSTextAlignmentRight;
        outlayLabel.textColor = [UIColor redColor];
        outlayLabel.font = kFont_Light_16;

        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:balanceLabel];
        [self.contentView addSubview:rechangeLabel];
        [self.contentView addSubview:outlayLabel];
    }
    
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setReport:(EcardReport *)report {
    _report = report;
    self.nameLabel.text = [NSString stringWithFormat:@"%@", _report.CustomerName];
    self.balanceLabel.text = [NSString stringWithFormat:@"净 %@", MoneyFormat(_report.BalanceAmount)];
    self.rechangeLabel.text = [NSString stringWithFormat:@"充 %@", MoneyFormat(_report.RechargeAmount)];
    self.outlayLabel.text = [NSString stringWithFormat:@"支 %@", MoneyFormat(_report.PayAmount)];
}
@end
