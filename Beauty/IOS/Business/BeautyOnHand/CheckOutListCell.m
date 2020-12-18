//
//  OrderListCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-14.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CheckOutListCell.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "ProductAndPriceDoc.h"
#import "OrderDoc.h"
#import "DEFINE.h"

@interface CheckOutListCell ()
@property (strong, nonatomic) UIImageView *newsImageView;
@end

@implementation CheckOutListCell
@synthesize selectButton, ProductNameLabel, dateLabel, stateLabel, UserNameLabel, totalPriceLabel, numberLabel, PersonNameLabel;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(165, 5.0f, 110.0f, 14.0f) title:@"--"];
        ProductNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5, 23.0f, 200.0f, 14.0f) title:@"--"];
        totalPriceLabel = [UILabel initNormalLabelWithFrame:CGRectMake(135.0f, 43.0f, 140.0f, 14.0f) title:@"--"];
        
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:ProductNameLabel];
        [self.contentView addSubview:totalPriceLabel];
        
        stateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 43, 110.0f, 14.0f) title:@"--"];
        UserNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 5.0f, 150.0f, 14.0f) title:@"--"];
//        PersonNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 43.0f, 150.0f, 14.0f) title:@"--"];
        numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(235.0f, 23.0f, 40.0f, 14.0f) title:@"x 1"];
        
//        UserNameLabel.textAlignment = NSTextAlignmentRight;
        UserNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        PersonNameLabel.textAlignment = NSTextAlignmentRight;
        PersonNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        dateLabel.textAlignment = NSTextAlignmentRight;
        numberLabel.textAlignment = NSTextAlignmentRight;
        totalPriceLabel.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:UserNameLabel];
        [self.contentView addSubview:PersonNameLabel];
        [self.contentView addSubview:stateLabel];
        [self.contentView addSubview:numberLabel];
        
        stateLabel.textColor = kColor_Black;
        dateLabel.textColor = kColor_Editable;
        numberLabel.textColor = kColor_Editable;
        UserNameLabel.textColor = kColor_Editable;
        totalPriceLabel.textColor = kColor_Black;
        ProductNameLabel.textColor = kColor_DarkBlue;
        
        selectButton = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(selectAction)
                                           frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW , (62.0f - HEIGHT_NAVIGATION_VIEW)/ 2 , HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                   backgroundImg:[UIImage imageNamed:@"icon_unChecked"]
                                highlightedImage:nil];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_unChecked"] forState:UIControlStateNormal];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_Checked"]   forState:UIControlStateSelected];
        [self.contentView addSubview:selectButton];
        
        [dateLabel setFont:kFont_Light_14];
        [ProductNameLabel setFont:kFont_Light_14];
        [stateLabel setFont:kFont_Light_14];
        [totalPriceLabel setFont:kFont_Light_14];
        [UserNameLabel setFont:kFont_Light_14];
        [PersonNameLabel setFont:kFont_Light_14];
        [numberLabel setFont:kFont_Light_14];
        
        self.backgroundColor = [UIColor whiteColor];

    }
    return self;
}

#pragma mark GPB-1007 

- (id)initWithStyleAlignRight:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        stateLabel.frame = CGRectMake(190.0f, dateLabel.frame.origin.y, 110.0f, 14.0f);
        UserNameLabel.frame = CGRectMake(150.0f, 43.0f, 150.0f, 14.0f);
        PersonNameLabel.frame = CGRectMake(150.0f, 43.0f, 150.0f, 14.0f);
        numberLabel.frame = CGRectMake(260.0f, 23.0f, 40.0f, 14.0f);

    }
    return self;
}


- (void)selectAction
{
    if ([delegate respondsToSelector:@selector(selectedTheOrderListCell:)]) {
        [delegate selectedTheOrderListCell:self];
    }
}

- (void)updateData:(OrderDoc *)orderDoc
{    
    [dateLabel setText:orderDoc.order_OrderTime];
    ProductNameLabel.text   = orderDoc.productAndPriceDoc.productDoc.pro_Name;
    numberLabel.text = [NSString stringWithFormat:@" x %ld", (long)orderDoc.productAndPriceDoc.productDoc.pro_quantity];

    /*
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = nameLabel.text;
    textView.font = kFont_Light_14;
    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
    float height  = size.height;
    if (height < kTableView_HeightOfRow) {
        height = kTableView_HeightOfRow;
    }
    textView = nil;
    
    

    
    CGSize tSize = [nameLabel.text sizeWithFont:kFont_Light_14 constrainedToSize:CGSizeMake(300, FLT_MAX)];
    
    if (height > kTableView_HeightOfRow || size.width >= 240.0f) {
        numberLabel.frame = CGRectMake(240.0f, 23.0f, 40.0f, 16.0f) ;
    } else {
        numberLabel.frame = CGRectMake(nameLabel.frame.origin.x + size.width - 8.0f, 23.0f, 40.0f, 16.0f);
    }
    
    _ps(tSize);
    DLOG(@"%@  %f %f", nameLabel.text, size.width,  height);
    _pr(numberLabel.frame);
    */

    NSString *totalString = [NSString stringWithFormat:@"/%.2Lf",orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney];
    
    NSString * haveString = [NSString stringWithFormat:@"%.2Lf",orderDoc.productAndPriceDoc.productDoc.pro_HaveToPay];
    
    NSString * moneyString = [NSString stringWithFormat:@"%@",MoneyIcon];
    
    NSString * string = [NSString stringWithFormat:@"%@%@%@",moneyString,haveString,totalString];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSDictionary *moneyDic = @{NSFontAttributeName:kFont_Light_14};
    NSDictionary *haveDic = @{NSFontAttributeName:kFont_Light_14, NSForegroundColorAttributeName:[UIColor redColor]};
    NSDictionary *totalDic = @{NSFontAttributeName:kFont_Light_14};
    
    [attributedStr addAttributes:moneyDic range:NSMakeRange(0, moneyString.length)];
    [attributedStr addAttributes:haveDic range:NSMakeRange(moneyString.length, haveString.length)];
    [attributedStr addAttributes:totalDic range:NSMakeRange(haveString.length, totalString.length)];

    totalPriceLabel.attributedText = attributedStr;
    
    
    // orderDoc.order_StatusStr,
    [stateLabel setText:[NSString stringWithFormat:@"%@",orderDoc.order_IspaidStr]];
    [UserNameLabel setText:orderDoc.order_ResponsiblePersonName];
    
    /*
    if (kMenu_Type == 0) {
        [UserNameLabel setText:[NSString stringWithFormat:@"%@", orderDoc.order_CustomerName]];
    } else if (kMenu_Type == 1) {
        [UserNameLabel setText:[NSString stringWithFormat:@"%@", orderDoc.order_ResponsiblePersonName.length == 0 ? @"" : orderDoc.order_ResponsiblePersonName]];
    }
    */
    
//    if(orderDoc.order_ResponsiblePersonName ) {
////        PersonNameLabel.hidden = NO;
//        NSString *responsibleString = [NSString stringWithFormat:@"|%@", orderDoc.order_ResponsiblePersonName];
//        
//        CGSize personSize = [responsibleString sizeWithFont:kFont_Light_12 constrainedToSize:CGSizeMake(75.0f, 14.0f) lineBreakMode:NSLineBreakByTruncatingTail];
//        
//        CGRect personFrame = PersonNameLabel.frame;
//        personFrame.origin.x = personFrame.origin.x + personFrame.size.width - ceil(personSize.width);
//        personFrame.size.width = ceil(personSize.width);
//        
//        PersonNameLabel.frame = personFrame;
//        
//        UserNameLabel.frame = CGRectMake(UserNameLabel.frame.origin.x, UserNameLabel.frame.origin.y, 150.0f - ceil(personSize.width), UserNameLabel.frame.size.height);
//        
//        [UserNameLabel setText:[NSString stringWithFormat:@"%@", orderDoc.order_CustomerName]];
//        [PersonNameLabel setText:[NSString stringWithFormat:@"|%@", orderDoc.order_ResponsiblePersonName]];
//    } else {
//        CGRect userFrame = UserNameLabel.frame;
//        userFrame.size.width = 145.0f;
//        UserNameLabel.frame = userFrame;
//        
//        CGRect personFrame = PersonNameLabel.frame;
//        personFrame.origin.x = 295.0f;
//        personFrame.size.width = 5.0f;
////        PersonNameLabel.hidden = YES;
//        [UserNameLabel setText:[NSString stringWithFormat:@"%@", orderDoc.order_CustomerName]];
//        [PersonNameLabel setText:@"|"];
//    }
    
    if (orderDoc.order_Status == 0) {
        selectButton.hidden = NO;
    } else {
        selectButton.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
