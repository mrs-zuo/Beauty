//
//  SelectCustomersCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "SelectCustomersCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+InitButton.h"
#import "UILabel+InitLabel.h"
#import "UserDoc.h"

@interface SelectCustomersCell ()
@property (strong, nonatomic) UserDoc *theUserDoc;
@end

@implementation SelectCustomersCell
@synthesize headImageView;
@synthesize nameLabel;
@synthesize accessoryLabel;
@synthesize selectButton;
@synthesize theUserDoc;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f,(HEIGHT_SELECT_CUSTOMERS_CELL - 40.0f)/2, 40.0f, 40.0f)];
       
        nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(headImageView.frame.origin.x + headImageView.frame.size.width + 3.0f, (HEIGHT_SELECT_CUSTOMERS_CELL - 20.0f)/2, 100.0f, 20.0f) title:@""];
        
        accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW - 5.0f - 100.0f, 0.0f, 100.0f, HEIGHT_SELECT_CUSTOMERS_CELL) title:@""];
        accessoryLabel.textAlignment = NSTextAlignmentRight;
        
        selectButton = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(selectAction:)
                                           frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW - 5.0f , (HEIGHT_SELECT_CUSTOMERS_CELL - HEIGHT_NAVIGATION_VIEW)/2, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                   backgroundImg:[UIImage imageNamed:@"icon_unChecked"]
                                highlightedImage:nil];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_Checked"] forState:UIControlStateSelected];
        
         [[self contentView] addSubview:headImageView];
         [[self contentView] addSubview:nameLabel];
         [[self contentView] addSubview:accessoryLabel];
         [[self contentView] addSubview:selectButton];
    }
    return self;
}

- (void)updateData:(UserDoc *)userDoc
{
    theUserDoc = userDoc;
    
    [headImageView setImageWithURL:[NSURL URLWithString:userDoc.user_HeadImage] placeholderImage:[UIImage imageNamed:@"loading_HeadImg40"]];
    [nameLabel setText:userDoc.user_Name];

    if (userDoc.user_Type == 0) { // customer
        accessoryLabel.hidden = YES;
    } else {  // account
        accessoryLabel.hidden = NO;
        accessoryLabel.text = userDoc.user_Code;
    }
    
    if (userDoc.user_SelectedState == 0) { // 未选中
        selectButton.selected = NO;
    } else {
        selectButton.selected = YES;
    }
    if (userDoc.user_Type == 1) {
        if (userDoc.accountType == AccountTypeMine || userDoc.accountType == AccountTypeSale) {
            NSString *tailString = userDoc.accountType == AccountTypeMine ? @"(专属顾问)":@"(销售顾问)";
            
            NSString *nameString = [NSString stringWithFormat:@"%@%@",userDoc.user_Name,tailString];
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:nameString];
            
            NSDictionary *nameDic = @{NSFontAttributeName:kFont_Light_14};
            NSDictionary *tailDic = @{NSFontAttributeName:kFont_Light_12, NSForegroundColorAttributeName:[UIColor redColor]};
            [attributedStr addAttributes:nameDic range:NSMakeRange(0, userDoc.user_Name.length)];
            [attributedStr addAttributes:tailDic range:NSMakeRange(userDoc.user_Name.length, tailString.length)];
            nameLabel.attributedText = attributedStr;
        } else {
            nameLabel.text = userDoc.user_Name;
        }
    } else {
        nameLabel.text = userDoc.user_Name;
    }

}

- (void)selectAction:(id)sender
{
    if (theUserDoc.user_SelectedState == 0) {
        theUserDoc.user_SelectedState = 1;
        selectButton.selected = YES;
    } else {
        theUserDoc.user_SelectedState = 0;
        selectButton.selected = NO;
    }
    
    if ([delegate respondsToSelector:@selector(selectCustomersCell:touchTheSelectButton:)]) {
        [delegate selectCustomersCell:self touchTheSelectButton:sender];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
