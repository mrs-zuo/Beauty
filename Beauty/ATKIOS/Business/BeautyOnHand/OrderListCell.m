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
#import "DEFINE.h"

@interface OrderListCell ()
@property (strong, nonatomic) UIImageView *newsImageView;
@end

@implementation OrderListCell
@synthesize selectButton, ProductNameLabel, dateLabel, stateLabel, totalPriceLabel, numberLabel, PersonNameLabel;
//@synthesize UserNameLabel;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5, 5.0f, 160.0f, 14.0f) title:@"--"];
        ProductNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5, 23.0f,230.0f, 14.0f) title:@"--"];
        totalPriceLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5, 43.0f, 160.0f, 14.0f) title:@"--"];
        
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:ProductNameLabel];
        [self.contentView addSubview:totalPriceLabel];
        
        stateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(170, dateLabel.frame.origin.y, 120.0f, 14.0f) title:@"--"];
//        UserNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(125.0f, 43.0f, 165.0f, 14.0f) title:@"--"];
        PersonNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(125.0f, 43.0f, self.frame.size.width - 125 - 20, 14.0f) title:@"--"];
        numberLabel = [UILabel initNormalLabelWithFrame:CGRectMake(250.0f, 23.0f, 40.0f, 14.0f) title:@"x 1"];
//        UserNameLabel.textAlignment = NSTextAlignmentRight;
//        UserNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        PersonNameLabel.textAlignment = NSTextAlignmentRight;
        PersonNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        stateLabel.textAlignment = NSTextAlignmentRight;
        numberLabel.textAlignment = NSTextAlignmentRight;
        
//        [self.contentView addSubview:UserNameLabel];
        [self.contentView addSubview:PersonNameLabel];
        [self.contentView addSubview:stateLabel];
        [self.contentView addSubview:numberLabel];
        
       
        dateLabel.textColor = kColor_Editable;
        ProductNameLabel.textColor = kColor_DarkBlue;
//        UserNameLabel.textColor = kColor_Editable;
        numberLabel.textColor = kColor_Editable;
        PersonNameLabel.textColor = kColor_Editable;
        totalPriceLabel.textColor = kColor_Editable;
        
        selectButton = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(selectAction)
                                           frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW - 5.0f, (62.0f - HEIGHT_NAVIGATION_VIEW)/ 2 , HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                   backgroundImg:[UIImage imageNamed:@"icon_unChecked"]
                                highlightedImage:nil];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_unChecked"] forState:UIControlStateNormal];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_Checked"]   forState:UIControlStateSelected];
        [self.contentView addSubview:selectButton];
        
        [dateLabel setFont:kFont_Light_14];
        [ProductNameLabel setFont:kFont_Light_14];
        [stateLabel setFont:kFont_Light_14];
        [totalPriceLabel setFont:kFont_Light_14];
//        [UserNameLabel setFont:kFont_Light_14];
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
//        UserNameLabel.frame = CGRectMake(150.0f, 43.0f, 150.0f, 14.0f);
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

    
    
    [totalPriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney]];
    [stateLabel setText:[NSString stringWithFormat:@"%@|%@", orderDoc.order_StatusStr, orderDoc.order_IspaidStr]];
//    [UserNameLabel setText:@""];
    
    /*
    if (kMenu_Type == 0) {
        [UserNameLabel setText:[NSString stringWithFormat:@"%@", orderDoc.order_CustomerName]];
    } else if (kMenu_Type == 1) {
        [UserNameLabel setText:[NSString stringWithFormat:@"%@", orderDoc.order_ResponsiblePersonName.length == 0 ? @"" : orderDoc.order_ResponsiblePersonName]];
    }
    */
    
    if(orderDoc.order_ResponsiblePersonName ) {
        PersonNameLabel.text = [NSString stringWithFormat:@"%@|%@",orderDoc.order_CustomerName,orderDoc.order_ResponsiblePersonName];
    }else{
        PersonNameLabel.text = orderDoc.order_CustomerName;
    }
//    if(orderDoc.order_ResponsiblePersonName ) {
//        PersonNameLabel.hidden = NO;
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
        
//        UserNameLabel.frame = CGRectMake(80.0f, 43.0f, 160.0f, 14.0f);
//        PersonNameLabel.frame = CGRectMake(240.0f, 43.0f, 60.0f, 14.0f);
        
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
        
//        UserNameLabel.frame = CGRectMake(100.0f, 43.0f, 190.0f, 14.0f);
//        PersonNameLabel.frame = CGRectMake(290.0f, 43.0f, 10.0f, 14.0f);
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
