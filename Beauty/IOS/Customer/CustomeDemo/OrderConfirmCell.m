//
//  OrderConfirmCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-6.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderConfirmCell.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "OrderDoc.h"

@interface OrderConfirmCell ()
@property (strong, nonatomic) UIImageView *newsImageView;
@end

@implementation OrderConfirmCell
@synthesize selectButton, nameLabel, dateLabel, numberLabel, totalNumberLabel;
@synthesize accounNameLabel;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([reuseIdentifier isEqualToString:@"MyCellConfirm"]){
            nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 10.0f, 200.0f, kLabel_DefaultHeight) title:@""];
            dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 40, 120.0f, kLabel_DefaultHeight) title:@""];
            totalNumberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(150, 40, 120.0f, kLabel_DefaultHeight) title:@""];
            numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(150, 10.0f, 120.0f, kLabel_DefaultHeight) title:@""];
        
        }else {
        
            nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 10.0f, 200.0f, kLabel_DefaultHeight) title:@""];
            dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 40, 100.0f, 14.0f) title:@""];
            accounNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(120.0f, 40, 70.0f, kLabel_DefaultHeight) title:@""];
            totalNumberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(180, 40, 90.0f, kLabel_DefaultHeight) title:@""];
            numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(220, 10.0f, 50.0f, kLabel_DefaultHeight) title:@""];
        }
        totalNumberLabel.textAlignment = NSTextAlignmentRight;
        numberLabel.textAlignment = NSTextAlignmentRight;

        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:accounNameLabel];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:numberLabel];
        [self.contentView addSubview:totalNumberLabel];
        
        totalNumberLabel.textColor = kColor_Editable;
        dateLabel.textColor = kColor_Editable;
        accounNameLabel.textColor = kColor_Editable;
        
        selectButton = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(selectAction)
                                           frame:CGRectMake(275.0f, (70 - 36.0f)/2, 36.0f, 36.0f)
                                   backgroundImg:[UIImage imageNamed:@"icon_unSelected"]
                                highlightedImage:nil];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_Selected"]   forState:UIControlStateSelected];
        [self.contentView addSubview:selectButton];
        
        [nameLabel setFont:kNormalFont_14];
        [numberLabel setFont:kNormalFont_14];
        [dateLabel setFont:kNormalFont_14];
        [accounNameLabel setFont:kNormalFont_14];
        [totalNumberLabel setFont:kNormalFont_14];
        
    }
    return self;
}

- (void)selectAction
{
    if ([delegate respondsToSelector:@selector(selectedTheOrderConfirmListCell:)]) {
        [delegate selectedTheOrderConfirmListCell:self];
    }
}

- (void)updateData:(OrderDoc *)orderDoc
{   
    [nameLabel setText:orderDoc.order_ProductName];
    [dateLabel setText:orderDoc.order_OrderTime];
    [accounNameLabel setText:orderDoc.order_AccountName];
    [totalNumberLabel setText:orderDoc.order_Remark];
    [numberLabel setText:[NSString stringWithFormat:@"×%ld", (long)orderDoc.order_ProductNumber]];
    [selectButton setSelected:orderDoc.status];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
