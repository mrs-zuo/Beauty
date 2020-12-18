//
//  PayEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-12.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "PayEditCell.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"
#import "UIButton+InitButton.h"
#import "DEFINE.h"

@implementation PayEditCell
@synthesize delegate;

@synthesize titleNameLabel, contentText,payButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 0.0f, 80.0f, kTableView_HeightOfRow) title:@"--"];
        [titleNameLabel setTextColor:kColor_DarkBlue];
        [[self contentView] addSubview:titleNameLabel];
        
        contentText = [UITextField initNormalTextViewWithFrame:CGRectMake(210.0f, 0.0f, 90.0f, kTableView_HeightOfRow)
                                                          text:@""
                                                   placeHolder:@"0.00"];
        contentText.borderStyle = UITextBorderStyleNone;
        contentText.keyboardType = UIKeyboardTypeDecimalPad;
        contentText.textAlignment = NSTextAlignmentRight;
        contentText.tag = 1100;
        [[self contentView] addSubview:contentText];
        
        payButton = [UIButton buttonTypeRoundedRectWithTitle:@"全" target:self selector:@selector(selectPayButtonAction) frame:CGRectMake(195.0f,(kTableView_HeightOfRow - 20.0f)/2,30.0f,20.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:5];
        [[self contentView] addSubview:payButton];
    }
    
    return self;
}

- (void)setShowTextViewBoard
{
    [contentText setEnabled:YES];
    contentText.layer.masksToBounds = YES;
    contentText.layer.cornerRadius = 3.0f;
    contentText.layer.borderWidth = 0.8f;
    contentText.layer.borderColor = [[UIColor colorWithRed:91.0f/255.0f green:195.0f/255.0f blue:255.0f/255.0f alpha:1.0f] CGColor];
    contentText.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    contentText.layer.shadowOpacity = 0.5f;
    contentText.layer.shadowRadius = 3.0f;
    contentText.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
}

-(void)selectPayButtonAction
{
    if([delegate respondsToSelector:@selector(chickSelectionBtnWithCell:)]){
        [delegate chickSelectionBtnWithCell:self];
    }
}

@end
