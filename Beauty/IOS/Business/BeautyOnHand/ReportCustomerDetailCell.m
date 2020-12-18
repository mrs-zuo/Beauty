
//
//  ReportDetailCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ReportCustomerDetailCell.h"
#import "UILabel+InitLabel.h"
#import "ReportDetailDoc.h"
#import "DEFINE.h"

@interface ReportCustomerDetailCell()
@property (assign, nonatomic) float length;
@end

@implementation ReportCustomerDetailCell
@synthesize titleLabel;
@synthesize amountLabel;
@synthesize length;
@synthesize ratioView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 10.0f, 190.0f, 20.0f) title:@"--"];
        titleLabel.font = kFont_Light_16;
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;//UILineBreakModeMiddleTruncation;
        [self.contentView addSubview:titleLabel];
        
        amountLabel = [UILabel initNormalLabelWithFrame:CGRectMake(200.0f, 10.0f, 100.0f, 20.0f) title:MoneyFormat(0.0f)];
        amountLabel.font = kFont_Light_16;
        amountLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:amountLabel];
        
//        ratioView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 38.0f, 290.0f, 10.0f)];
//        ratioView.backgroundColor = [UIColor colorWithRed:198.0f/255.0f green:229.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
//        [self.contentView addSubview:ratioView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateData:(ReportDetailDoc *)doc andProductType:(NSInteger)productType
{
    titleLabel.text = [NSString stringWithFormat:@"%@(%.2Lf%%)", doc.objectName, doc.amountRatio];
    
    if (doc.flag == 0 || doc.flag == 5) {
        amountLabel.text = MoneyFormat((double)doc.amount);
    } else {
        if (productType == 0) {
            amountLabel.text = [NSString stringWithFormat:@"%ld次", (long)doc.cases];
        } else if (productType == 1) {
            amountLabel.text = [NSString stringWithFormat:@"%ld件", (long)doc.cases];
        }
    }
    
    
//    CGRect rect = self.ratioView.frame;
//    rect.size.width = doc.viewRatio * 290.0f;
//    self.ratioView.frame = rect;
}

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//
//   // CGRect rec = CGRectMake(10.0f, 35.0f, length, 10.0f);
//   // CGContextRef context = UIGraphicsGetCurrentContext();
////    CGContextFillRect(context, rec);
////    CGContextSetRGBFillColor(context, 0.0f, 1.0f, 0.0f, 1.0f);
////    CGContextFillPath(context);
//
////    CGContextStrokeRect(context, rec);
////    CGContextSetRGBStrokeColor(context, 1.0f, 0.0f, 0.0f, 1.0f);
////    CGContextStrokePath(context);
//}
@end
