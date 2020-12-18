//
//  ShoppingCartCell.m
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-15.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "ShoppingCartCell.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"
#import "UIButton+InitButton.h"
#import "CommodityDoc.h"
#import "UIImageView+WebCache.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "UITextField+InitTextField.h"
#import "UITextField+InitLabel.h"
#import "ShoppingCartViewController.h"
#import "UILabelStrikeThrough.h"
#import "noCopyTextField.h"

@interface ShoppingCartCell ()
@property (strong, nonatomic) CommodityDoc *theCommodityDoc;
@property (strong, nonatomic) NSIndexPath *theIndexPath;
@end

@implementation ShoppingCartCell
@synthesize imageView;
@synthesize titleLabel;
@synthesize quantityTextField;
@synthesize priceLabel;
@synthesize promotionPriceLabel;
@synthesize stateButton;
@synthesize delegate;
@synthesize theCommodityDoc;
@synthesize shoppingCartViewController;
@synthesize theIndexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView =[[UIImageView alloc] initWithFrame:CGRectMake(50, 0, 80.0f, 80.0f)];
        [self.contentView addSubview:imageView];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(140, 10, 220.0f, 20.0f) title:@"--"];
        titleLabel.textColor = kColor_TitlePink;
        titleLabel.font = kNormalFont_14;
        [self.contentView addSubview:titleLabel];
        
        quantityTextField = [[noCopyTextField alloc] init];
        quantityTextField.frame = CGRectMake(140, 40, 60.0f, 20.0f);
        quantityTextField.font = kNormalFont_14;
        quantityTextField.textAlignment = NSTextAlignmentCenter;
        quantityTextField.delegate = self;
        quantityTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        quantityTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        quantityTextField.backgroundColor = [UIColor clearColor];
        quantityTextField.layer.masksToBounds = YES;
        quantityTextField.layer.cornerRadius = 5.0f;
        quantityTextField.textColor = kColor_Editable;
        quantityTextField.layer.borderColor = [kTableView_LineColor CGColor];
        quantityTextField.layer.borderWidth = 1.0f;
        
        //显示促销价
        promotionPriceLabel = [UILabel initNormalLabelWithFrame:CGRectMake(205.0f, 35, 100.0f, 30.0f) title:
                              [NSString stringWithFormat:@"%@ 0.0",CUS_CURRENCYTOKEN]];
        promotionPriceLabel.font = kNormalFont_14;
        
        //显示原价
        priceLabel = [[UILabelStrikeThrough alloc] initWithFrame:CGRectMake(270.0f, 35, 100.0f, 30.0f)];
        priceLabel.isWithStrikeThrough = YES;
        priceLabel.font = kNormalFont_14;
        priceLabel.textColor = kColor_Editable;
        priceLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:quantityTextField];
        [self.contentView addSubview:priceLabel];
        [self.contentView addSubview:promotionPriceLabel];
        
        
        stateButton = [UIButton buttonWithTitle:@""
                                         target:self
                                       selector:@selector(selectAction)
                                          frame:CGRectMake(5.0f, (80 - 36) / 2, 36.0f, 36.0f)
                                  backgroundImg:[UIImage imageNamed:@"icon_unSelected"]
                               highlightedImage:nil];
        [stateButton setBackgroundImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
        [stateButton setBackgroundImage:[UIImage imageNamed:@"icon_Selected"] forState:UIControlStateSelected];
        stateButton.tag = 10001;
        [self.contentView addSubview:stateButton];
        [stateButton setSelected:NO];
    }
    return self;
}

- (void)selectAction
{
    [stateButton setSelected:!stateButton.selected];
   
    if ([delegate respondsToSelector:@selector(changeQuantityWithShoppingCartCell:)]) {
        [delegate changeQuantityWithShoppingCartCell:self];
    }
}

- (void)updateData:(CommodityDoc *)commodityDoc
{
    theCommodityDoc = commodityDoc;
    [imageView setImageWithURL:[NSURL URLWithString:commodityDoc.comm_Thumbnail] placeholderImage:[UIImage imageNamed:@"productDefaultImage"]];
    [titleLabel setText:commodityDoc.comm_CommodityName];
    [quantityTextField setText:[NSString stringWithFormat:@"%ld", (long)commodityDoc.comm_Quantity]];
    
    if (commodityDoc.comm_MarketingPolicy == 0 || (commodityDoc.comm_UnitPrice == commodityDoc.comm_PromotionPrice)) {
        [priceLabel setHidden:YES];
        
        CGSize size_UnitPrice = [[NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN,
                                  commodityDoc.comm_UnitPrice * commodityDoc.comm_Quantity] sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(140.0f, 21.0f)];
        
        CGRect promotionPriceLabelFrame = promotionPriceLabel.frame;
        promotionPriceLabelFrame.size.width = size_UnitPrice.width + 2.0f;
        [promotionPriceLabel setFrame:promotionPriceLabelFrame];
        
        [promotionPriceLabel setText:[NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN, commodityDoc.comm_UnitPrice * commodityDoc.comm_Quantity]];
    } else {
        [priceLabel setHidden:NO];
        
        CGSize size_UnitPrice = [[NSString stringWithFormat:@"%.2Lf", commodityDoc.comm_UnitPrice * commodityDoc.comm_Quantity] sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(180.0f, 21.0f)];
        CGSize size_PromotionPrice = [[NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN, commodityDoc.comm_PromotionPrice * commodityDoc.comm_Quantity] sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(190.0f, 21.0f)];
        
        CGRect promotionPriceLabelFrame = promotionPriceLabel.frame;
        promotionPriceLabelFrame.size.width = size_PromotionPrice.width + 2.0f;
        [promotionPriceLabel setFrame:promotionPriceLabelFrame];
        
        CGRect priceLabelFrame = promotionPriceLabel.frame;
        priceLabelFrame.size.width = size_UnitPrice.width + 2.0f;
        priceLabelFrame.origin.x = promotionPriceLabelFrame.origin.x + promotionPriceLabelFrame.size.width + 4.0f;
        [priceLabel setFrame:priceLabelFrame];
        
        [promotionPriceLabel setText:[NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN, commodityDoc.comm_PromotionPrice * commodityDoc.comm_Quantity]];
        [priceLabel setText:[NSString stringWithFormat:@"%.2Lf", commodityDoc.comm_UnitPrice * commodityDoc.comm_Quantity]];
    }
    UIImageView *invalidImage = (UIImageView *)[self viewWithTag:10000];
    UIButton *button = (UIButton*)[self.contentView viewWithTag:10001];
    if(!invalidImage)
        invalidImage= [[UIImageView alloc] init];
    invalidImage.frame = CGRectMake(70, 0, 60, 60);
    invalidImage.tag = 10000;
    invalidImage.image = [UIImage imageNamed:@"invalid.png"];
    [self addSubview:invalidImage];
    if(commodityDoc.comm_Available){
        invalidImage.hidden = YES;
        button.hidden = NO;
    } else {
        invalidImage.hidden = NO;
        button.hidden = YES;
    }
    [stateButton setSelected:commodityDoc.status];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [shoppingCartViewController editedTextField:textField cell:self];
    theIndexPath = [shoppingCartViewController indexPathForCell:self];
    
    if (textField == quantityTextField) {
        [shoppingCartViewController setCustomKeyboardWithSection:theIndexPath.section textField:quantityTextField selectedText:quantityTextField.text];
    }
    return YES;
}

@end
