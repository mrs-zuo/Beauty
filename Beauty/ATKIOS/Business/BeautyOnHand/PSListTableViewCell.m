//
//  PSListTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "PSListTableViewCell.h"
#import "UIButton+InitButton.h"
#import "UILabel+InitLabel.h"
#import "UIImageView+WebCache.h"

#import "CommodityDoc.h"
#import "ServiceDoc.h"



@implementation PSListTableViewCell
@synthesize newbrandImgView;
@synthesize recommendImgView;
@synthesize imageView;
@synthesize titleLabel;
@synthesize priceCategoryImageView;
@synthesize unitePriceLabel;
@synthesize promotionPriceLabel;
@synthesize selectedButton;
@synthesize delegate;
@synthesize favoriteImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //图片
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 60.0f, 60.0f)];
        imageView.layer.borderColor = [[UIColor grayColor] CGColor];
        imageView.layer.borderWidth = 0.5f;
        [self.contentView addSubview:imageView];
        
        //推荐
        recommendImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 24.0f, 12.0f)];
        recommendImgView.image = [UIImage imageNamed:@"recommended_bg"];
        [self.contentView  addSubview:recommendImgView];
        
        //新品
        newbrandImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 10.0f + 12.0f + 3.0f, 24.0f, 12.0f)];
        newbrandImgView.image = [UIImage imageNamed:@"newPro_bg"];
        [self.contentView  addSubview:newbrandImgView];
        
        //收藏
        favoriteImageView= [[UIImageView alloc] initWithFrame:CGRectMake(52.0f, -1.0f, 22.0f, 22.0f)];
        favoriteImageView.image = [UIImage imageNamed:@"favourite_Heart"];
        [self.contentView addSubview:favoriteImageView];

        
        //名称
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(70.0f, 5.0f, 200.0f, 40.0f) title:@"--"];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.font = kFont_Light_14;
        [self.contentView addSubview:titleLabel];
        
        //价格类别显示（促销价还是折扣价） 70.0f, 45.0f, 20.0f, 20.0f
        priceCategoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70.0f, 46.5f, 17.0f, 17.0f)];
        [self.contentView addSubview:priceCategoryImageView];
        
        //促销（折扣）价   115.0f, 45.0f, 100.0f, 20.0f
        promotionPriceLabel = [UILabel initNormalLabelWithFrame:CGRectMake(105.0f, 45.0f, 110.0f, 20.0f) title:[NSString stringWithFormat:@"%@0.00",MoneyIcon]];
        promotionPriceLabel.font = kFont_Light_14;
        [self.contentView addSubview:promotionPriceLabel];
        
        //原价
        unitePriceLabel = [[MidLineLabel alloc] initWithFrame:CGRectMake(215.0f, 45.0f, 90.0f, 20.0f)]; //modify by zhangwei "价格过大显示不正常"
        unitePriceLabel.text = [NSString stringWithFormat:@"%@0.00",MoneyIcon];
        unitePriceLabel.backgroundColor = [UIColor clearColor];
        unitePriceLabel.textAlignment = NSTextAlignmentLeft;
        unitePriceLabel.autoresizingMask = UIViewAutoresizingNone;
        unitePriceLabel.font = kFont_Light_14;
        unitePriceLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:unitePriceLabel];
        
        //right content
        UIView *rContentView = [[UIView alloc] initWithFrame:CGRectMake(260.0f, 0.0f, 50.0f, 70.0f)];
        rContentView.backgroundColor = [UIColor clearColor];
        
        selectedButton = [UIButton buttonWithTitle:@""
                                            target:self
                                          selector:@selector(selectedAction)
                                             frame:CGRectMake(310.0f - HEIGHT_NAVIGATION_VIEW - 260.0f, (70.0f - HEIGHT_NAVIGATION_VIEW)/2, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                     backgroundImg:[UIImage imageNamed:@"icon_unChecked"]
                                  highlightedImage:nil];
        [selectedButton setBackgroundImage:[UIImage imageNamed:@"icon_Checked"] forState:UIControlStateSelected];
        
        if ([[PermissionDoc sharePermission ] rule_MyOrder_Write]) { // ACC_BRANCHID != 0 && [[PermissionDoc sharePermission] rule_Order_Write
            [rContentView addSubview:selectedButton];
            [self.contentView addSubview:rContentView];
        } else {
            [selectedButton removeFromSuperview];
            [rContentView removeFromSuperview];
        }
        UITapGestureRecognizer *tapGestures = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedAction)];
        tapGestures.delegate = self;
        [rContentView addGestureRecognizer:tapGestures];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)selectedAction
{
    if ([delegate respondsToSelector:@selector(didSelectedButtonInCell:)]) {
        [delegate didSelectedButtonInCell:self];
    }
}

#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    DLOG(@"%@", gestureRecognizer.view);
    return YES;
}

@end
