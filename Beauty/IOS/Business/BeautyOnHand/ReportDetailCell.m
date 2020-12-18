
//
//  ReportCustomerDetailCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15-3-25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ReportDetailCell.h"
#import "UILabel+InitLabel.h"
#import "ReportDetailDoc.h"
#import "DEFINE.h"


@interface ReportDetailCell()
@property (assign, nonatomic) float length;
@end

@implementation ReportDetailCell
@synthesize headerTitle,headerValue,tailTitle,tailValue;
@synthesize length;
@synthesize ratioView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        headerTitle = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 5.0f, 150.0f, 20.0f) title:@"--"];
        headerTitle.font = kFont_Light_16;
        headerTitle.textColor = kColor_DarkBlue;
        headerTitle.lineBreakMode = NSLineBreakByTruncatingMiddle;//UILineBreakModeMiddleTruncation;
        [self.contentView addSubview:headerTitle];
        
        //        tailTitle = [UILabel initNormalLabelWithFrame:CGRectMake(140.0f, 5.0f, 130.0f, 20.0f) title:@"--"];
        //        tailTitle.font = kFont_Light_16;
        //        tailTitle.textColor = kColor_DarkBlue;
        //        tailTitle.lineBreakMode = NSLineBreakByTruncatingMiddle;//UILineBreakModeMiddleTruncation;
        //        [self.contentView addSubview:tailTitle];
        
        headerValue = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 28.0f, 120.0f, 20.0f) title:MoneyFormat(0.0f)];
        headerValue.font = kFont_Light_16;
        headerValue.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:headerValue];
        
        tailValue = [UILabel initNormalLabelWithFrame:CGRectMake(125.0f, 28.0f, 180.0f, 20.0f) title:MoneyFormat(0.0f)];
        tailValue.font = kFont_Light_16;
        tailValue.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:tailValue];
        
        //        ratioView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 38.0f, 290.0f, 10.0f)];
        //        ratioView.backgroundColor = [UIColor colorWithRed:198.0f/255.0f green:229.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
        //[self.contentView addSubview:ratioView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateData:(ReportDetailDoc *)doc andProductType:(NSInteger)productType andItemType:(NSInteger)itemType
{
    headerTitle.text = [NSString stringWithFormat:@"%@", doc.objectName];
    
    //    if (doc.flag == 0) {
    //        headerValue.text = MoneyFormat(doc.amount);
    //    } else {
    if (productType == 0) {
        headerValue.text = [NSString stringWithFormat:@"%ld项(%.2Lf%%)", (long)doc.cases, doc.casesRatio];
    } else if (productType == 1) {
        headerValue.text = [NSString stringWithFormat:@"%ld件(%.2Lf%%)", (long)doc.cases, doc.casesRatio];
    }
    if (itemType == 4) {
        headerValue.text = [NSString stringWithFormat:@"%ld次(%.2Lf%%)", (long)doc.cases, doc.casesRatio];
    }
    //    }
    tailValue.text = [NSString stringWithFormat:@"%@(%.2Lf%%)", MoneyFormat(doc.amount), doc.amountRatio];
    
    //    CGRect rect = self.ratioView.frame;
    //    rect.size.width = doc.viewRatio * 290.0f;
    //    self.ratioView.frame = rect;
}

@end
