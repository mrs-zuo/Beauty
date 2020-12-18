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
@synthesize theUserDoc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f,(HEIGHT_SELECT_CUSTOMERS_CELL - 40.0f)/2, 40.0f, 40.0f)];
        headImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(10, 10,60,60)];
        headImageView.layer.masksToBounds = YES;
        headImageView.layer.cornerRadius = headImageView.layer.bounds.size.width * 0.5;
       
        nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(headImageView.frame.origin.x + headImageView.frame.size.width + 10.0f,30,110.0f, 20.0f) title:@""];
        nameLabel.font=kNormalFont_14;
        
        accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(320.0f -15 - 100.0f,30, 100.0f, 20) title:@""];
        accessoryLabel.font=kNormalFont_14;
        accessoryLabel.textAlignment = NSTextAlignmentRight;
        
        
         [[self contentView] addSubview:headImageView];
         [[self contentView] addSubview:nameLabel];
         [[self contentView] addSubview:accessoryLabel];
    }
    return self;
}

- (void)updateData:(UserDoc *)userDoc
{
    theUserDoc = userDoc;
    
    [headImageView setImageWithURL:[NSURL URLWithString:userDoc.user_HeadImage] placeholderImage:[UIImage imageNamed:@"People-default"]];
    [nameLabel setText:userDoc.user_Name];

    if (userDoc.user_Type == 0) { // customer
        accessoryLabel.hidden = YES;
    } else {  // account
        accessoryLabel.hidden = NO;
        accessoryLabel.text = userDoc.user_Code;
    }

    if (userDoc.user_Type == 1) {
        //userDoc.accountType == AccountTypeMine ||
        if ( userDoc.accountType == AccountTypeSale) {
//            NSString *tailString = userDoc.accountType == AccountTypeMine ? @"(专属顾问)":@"(销售顾问)";
//            
//            NSString *nameString = [NSString stringWithFormat:@"%@%@",userDoc.user_Name,tailString];
//            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:nameString];
//            
//            NSDictionary *nameDic = @{NSFontAttributeName:kFont_Light_14};
//            NSDictionary *tailDic = @{NSFontAttributeName:kFont_Light_12, NSForegroundColorAttributeName:[UIColor redColor]};
//            [attributedStr addAttributes:nameDic range:NSMakeRange(0, userDoc.user_Name.length)];
//            [attributedStr addAttributes:tailDic range:NSMakeRange(userDoc.user_Name.length, tailString.length)];
//            nameLabel.attributedText = attributedStr;
        } else {
            nameLabel.text = userDoc.user_Name;
        }
    } else {
        nameLabel.text = userDoc.user_Name;
    }

}


@end
