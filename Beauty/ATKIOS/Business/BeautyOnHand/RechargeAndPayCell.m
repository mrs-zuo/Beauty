//
//  RechargeAndPayCell.m
//  test1
//
//  Created by macmini on 13-8-15.
//  Copyright (c) 2013年 macmini. All rights reserved.
//

#import "RechargeAndPayCell.h"
#import "UILabel+InitLabel.h"
#import "PayAndRechargeDoc.h"
#import "DEFINE.h"

@implementation RechargeAndPayCell
@synthesize titleLabel, dateLabel, payLabel, balanceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 10.0f, 160.0f, 20.0f) title:@"title"];
        dateLabel  = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 35.0f, 205.0f, 20.0f) title:@"date"];
        payLabel   = [UILabel initNormalLabelWithFrame:CGRectMake(165.0f, 10.0f, 125.0f, 20.0f) title:@"pay"];
        balanceLabel = [UILabel initNormalLabelWithFrame:CGRectMake(165.0f, 35.0f, 125.0f, 20.0f) title:@"balace"];
        [[self contentView] addSubview:titleLabel];
        [[self contentView] addSubview:dateLabel];
        [[self contentView] addSubview:payLabel];
        [[self contentView] addSubview:balanceLabel];
        
        UILabel *typeLabel = [UILabel initNormalLabelWithFrame:CGRectMake(170.0f, 35.0f, 40.0f, 20.0f) title:@""];
        [self.contentView addSubview:typeLabel];
        
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.font = kFont_Medium_16;
        
        dateLabel.font = kFont_Light_14;
        typeLabel.font = kFont_Light_14;
        balanceLabel.font = kFont_Light_14;
        payLabel.font = kFont_Light_14;
        
        payLabel.textAlignment = NSTextAlignmentRight;
        balanceLabel.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)updateData:(PayAndRechargeDoc *)payDoc
{
    titleLabel.text = payDoc.RechargeText;
    dateLabel.text = payDoc.Time;
   
    balanceLabel.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, payDoc.p_Balance];
    
    if(payDoc.Type==0){
         payLabel.textColor = [UIColor greenColor];
         payLabel.text  = [NSString stringWithFormat:@"+ %.2Lf", payDoc.p_Amount];
    }
    else{
         payLabel.textColor = [UIColor redColor];
         payLabel.text  = [NSString stringWithFormat:@" %.2Lf", payDoc.p_Amount];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
