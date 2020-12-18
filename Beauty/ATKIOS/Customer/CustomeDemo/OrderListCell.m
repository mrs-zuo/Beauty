//
//  OrderListCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-14.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OrderListCell.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "ProductAndPriceDoc.h"
#import "OrderDoc.h"
#import "TGList.h"
@interface OrderListCell ()
@property (strong, nonatomic) UIImageView *newsImageView;
@end

@implementation OrderListCell
@synthesize selectButton, nameLabel, dateLabel, stateLabel, customerLabel, totalPriceLabel, numberLabel;
@synthesize accounNameLabel,totalPriceLabel2,shopName, stateCurrentLabel;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([reuseIdentifier isEqual:@"payCell"]){
            dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15, 10, 125.0f, kLabel_DefaultHeight) title:@"--"];
            shopName = [UILabel initNormalLabelWithFrame:CGRectMake(135, 10, 145.0f, kLabel_DefaultHeight) title:@"--"];

            nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 40, 160.0f, kLabel_DefaultHeight) title:@"--"];
            numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(100, 40, 175.0f, kLabel_DefaultHeight) title:@"--"];
            stateCurrentLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15, 70, 160, kLabel_DefaultHeight) title:@"--"];
            totalPriceLabel = [UILabel initNormalLabelWithFrame:CGRectMake(105, 70, 170.0f, kLabel_DefaultHeight) title:@"--"];

            totalPriceLabel.textAlignment = NSTextAlignmentRight;
            shopName.textAlignment = NSTextAlignmentRight;
            numberLabel.textAlignment = NSTextAlignmentRight;
            customerLabel = [UILabel initNormalLabelWithFrame:CGRectMake(100, dateLabel.frame.origin.y, 175.0f, kLabel_DefaultHeight) title:@""];
            customerLabel.textAlignment = NSTextAlignmentRight;
            
            [self.contentView addSubview:dateLabel];
            [self.contentView addSubview:nameLabel];
            [self.contentView addSubview:numberLabel];
            [self.contentView addSubview:totalPriceLabel];
            [self.contentView addSubview:customerLabel];
             [self.contentView addSubview:shopName];
            [self.contentView addSubview:stateCurrentLabel];
            
            dateLabel.textColor = kColor_Editable;
            nameLabel.textColor = kColor_Black;
            numberLabel.textColor = kColor_Editable;
            totalPriceLabel.textColor = KColor_NavBarTintColor;
            shopName.textColor = kColor_Editable;
            customerLabel.textColor = kColor_Editable;
            stateCurrentLabel.textColor = kColor_Editable;

            selectButton = [UIButton buttonWithTitle:@""
                                              target:self
                                            selector:@selector(selectAction)
                                               frame:CGRectMake(275.0f, (100 - 36.0f)/2 + 10, 36.0f, 36.0f)
                                       backgroundImg:[UIImage imageNamed:@"icon_unSelected"]
                                    highlightedImage:nil];
            [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
            [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_Selected"]   forState:UIControlStateSelected];
            [self.contentView addSubview:selectButton];
            [stateCurrentLabel setFont:kNormalFont_14];
            [dateLabel setFont:kNormalFont_14];
            [nameLabel setFont:kNormalFont_14];
            [numberLabel setFont:kNormalFont_14];
            [totalPriceLabel setFont:kNormalFont_14];
            [shopName setFont:kNormalFont_14];
        }else if ([reuseIdentifier  isEqual: @"myCellPayBalance"]){
            dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2, 160, kCell_LabelHeight) title:@"消费支出"];
            nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 30, 160, kCell_LabelHeight) title:@"Date"];
            totalPriceLabel = [UILabel initNormalLabelWithFrame:CGRectMake(145.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2, 155, kCell_LabelHeight) title:@"--"];
            accounNameLabel = [UILabel initNormalLabelWithFrame: CGRectMake(145.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 +30, 155, kCell_LabelHeight) title:@"--"];
            //dateLabel.textColor = kColor_TitlePink;
            //nameLabel.textColor = kColor_TitlePink;
            [self.contentView addSubview:dateLabel];
            [self.contentView addSubview:nameLabel];
            [self.contentView addSubview:totalPriceLabel];
            [self.contentView addSubview:accounNameLabel];
            totalPriceLabel.textAlignment = NSTextAlignmentRight;
            accounNameLabel.textAlignment = NSTextAlignmentRight;
            [dateLabel setFont:kNormalFont_14];
            [nameLabel setFont:kNormalFont_14];
            [totalPriceLabel setFont:kNormalFont_14];
            [accounNameLabel setFont:kNormalFont_14];
        }else{
            dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15, 10, 160.0f, kLabel_DefaultHeight) title:@"--"];
            nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15.0f, 40, 235.0f, kLabel_DefaultHeight) title:@"--"];
            totalPriceLabel = [UILabel initNormalLabelWithFrame:CGRectMake(15, 70, 160.0f, kLabel_DefaultHeight) title:@"--"];
            
            accounNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(175, 10, 130.0f, kLabel_DefaultHeight) title:@""];
            numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(240, 40, 65.0f, kLabel_DefaultHeight) title:@"--"];
            
            stateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(175, 70, 130.0f, kLabel_DefaultHeight) title:[NSString stringWithFormat:@"%@ 0.0f", CUS_CURRENCYTOKEN ]];
            
            accounNameLabel.textAlignment = NSTextAlignmentRight;
            numberLabel.textAlignment = NSTextAlignmentRight;
            stateLabel.textAlignment = NSTextAlignmentRight;
            
            customerLabel = [UILabel initNormalLabelWithFrame:CGRectMake(175, dateLabel.frame.origin.y, 130.0f, 20.0f) title:@""];
            customerLabel.textAlignment = NSTextAlignmentRight;
            
            [self.contentView addSubview:dateLabel];
            [self.contentView addSubview:accounNameLabel];
            [self.contentView addSubview:nameLabel];
            [self.contentView addSubview:numberLabel];
            [self.contentView addSubview:totalPriceLabel];
            [self.contentView addSubview:customerLabel];
            [self.contentView addSubview:stateLabel];
            
            stateLabel.textColor = kColor_TitlePink;
            dateLabel.textColor = kColor_Editable;
            
            selectButton = [UIButton buttonWithTitle:@""
                                              target:self
                                            selector:@selector(selectAction)
                                               frame:CGRectMake(275.0f, (100 - 36.0f)/2, 36.0f, 36.0f)
                                       backgroundImg:[UIImage imageNamed:@"icon_unSelected"]
                                    highlightedImage:nil];
            [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
            [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_Selected"]   forState:UIControlStateSelected];
            [self.contentView addSubview:selectButton];
            
            [dateLabel setFont:kNormalFont_14];
            [accounNameLabel setFont:kNormalFont_14];
            [nameLabel setFont:kNormalFont_14];
            [numberLabel setFont:kNormalFont_14];
            [stateLabel setFont:kNormalFont_14];
            [totalPriceLabel setFont:kNormalFont_14];
        }
    
    }
    return self;
}

- (id)initWithStyleAlignRight:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
   self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
            if ([reuseIdentifier isEqualToString:@"payCell"]){
                CGRect totalLabelFrame = CGRectMake(115, totalPriceLabel.frame.origin.y, totalPriceLabel.frame.size.width, totalPriceLabel.frame.size.height);
                CGRect shopFrame = CGRectMake(115, shopName.frame.origin.y, shopName.frame.size.width, shopName.frame.size.height);
                CGRect numberFrame = CGRectMake(115, numberLabel.frame.origin.y, numberLabel.frame.size.width, numberLabel.frame.size.height);
                shopName.frame = shopFrame;
                numberLabel.frame = numberFrame;
                totalPriceLabel.frame = totalLabelFrame;
            }else{
                
            CGRect accounFrame = CGRectMake(195, accounNameLabel.frame.origin.y, accounNameLabel.frame.size.width, accounNameLabel.frame.size.height);
            CGRect numberFrame = CGRectMake(265, numberLabel.frame.origin.y, numberLabel.frame.size.width, numberLabel.frame.size.height);
            CGRect stateFrame = CGRectMake(195, stateLabel.frame.origin.y, stateLabel.frame.size.width, stateLabel.frame.size.height);
                
            accounNameLabel.frame = accounFrame;
            numberLabel.frame = numberFrame;
            stateLabel.frame = stateFrame;
        }
        }
    
      return self;
}

- (void)selectAction
{
    if ([delegate respondsToSelector:@selector(selectedTheOrderListCell:)]) {
        [delegate selectedTheOrderListCell:self];
    }
}
-(void)updateData:(OrderDoc *)orderDoc{
    if (orderDoc.tgListMuArray != nil){

        [dateLabel setText:[NSString stringWithFormat:@"%@",orderDoc.order_OrderTime]];
        CGFloat totalPaid = orderDoc.productAndPriceDoc.discountMoney - orderDoc.order_UnPaidPrice;
        [totalPriceLabel setText:[NSString stringWithFormat:@"%@%.2f/%.2f",CUS_CURRENCYTOKEN, totalPaid ,orderDoc.productAndPriceDoc.discountMoney]];
        
        if(orderDoc.order_cardName.length >0)
            [stateCurrentLabel setText:[NSString stringWithFormat:@"%@|%@",orderDoc.order_BranchName,orderDoc.order_cardName]];
        else
            [stateCurrentLabel setText:[NSString stringWithFormat:@"%@",orderDoc.order_BranchName]];
    
        [shopName setText: orderDoc.order_AccountName];

       if (orderDoc.order_Status == 0) {
            selectButton.hidden = NO;
       } else {
           selectButton.hidden = YES;
        
       }
        [nameLabel setText:orderDoc.order_ProductName];
        [numberLabel setText:[NSString stringWithFormat:@"×%ld", (long)orderDoc.order_ProductNumber]];
        [selectButton setSelected:orderDoc.status];

    }else {
        [dateLabel setText:orderDoc.order_OrderTime];
        [accounNameLabel setText:orderDoc.order_AccountName];
        [totalPriceLabel setText:[NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN, orderDoc.productAndPriceDoc.discountMoney]];
        if (orderDoc.order_Type == 0) {
            [stateLabel setText:[NSString stringWithFormat:@"%@|%@", orderDoc.order_StatusStr, orderDoc.order_IspaidStr]];
        } else {

            [stateLabel setText:[NSString stringWithFormat:@"%@|%@", orderDoc.order_StatusStrForCommodity, orderDoc.order_IspaidStr]];
        }
        
        [customerLabel setText:@""];
        if (orderDoc.order_Status == 0) {
            selectButton.hidden = NO;
        } else {
            selectButton.hidden = YES;
        }

        [nameLabel setText:orderDoc.order_ProductName];
        [numberLabel setText:[NSString stringWithFormat:@"×%ld", (long)orderDoc.order_ProductNumber]];
        [selectButton setSelected:orderDoc.status];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
