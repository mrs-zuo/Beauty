//
//  TwoTextFieldCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/7/21.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "TwoTextFieldCell.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"
#import "UIButton+InitButton.h"
#import "DEFINE.h"

@implementation TwoTextFieldCell
@synthesize titleNameLabel,payTextField,contentText,lable;
- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        titleNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(30.0f, 0.0f, 50.0f, kTableView_HeightOfRow) title:@""];
        [titleNameLabel setTextColor:kColor_DarkBlue];
        [[self contentView] addSubview:titleNameLabel];
        titleNameLabel.font = kFont_Light_16;
        
        lable = [[UILabel alloc] initWithFrame:CGRectMake(180, 0.0f, 40, kTableView_HeightOfRow)];
        [[self contentView] addSubview:lable];
        lable.font = kFont_Light_16;
        
        payTextField = [UITextField initNormalTextViewWithFrame:CGRectMake(80.0f, 0.0f,95.0f, kTableView_HeightOfRow)
                                                           text:@""
                                                    placeHolder:@"0.00"];
        payTextField.borderStyle = UITextBorderStyleNone;
        payTextField.keyboardType = UIKeyboardTypeDecimalPad;
        payTextField.textAlignment = NSTextAlignmentRight;
        [[self contentView] addSubview:payTextField];
        payTextField.font = kFont_Light_16;

        contentText = [UITextField initNormalTextViewWithFrame:CGRectMake(220.0f, 0.0f, 85.0f, kTableView_HeightOfRow)
                                                          text:@""
                                                   placeHolder:@"0.00"];
        contentText.borderStyle = UITextBorderStyleNone;
        contentText.keyboardType = UIKeyboardTypeDecimalPad;
        contentText.textAlignment = NSTextAlignmentRight;
        [[self contentView] addSubview:contentText];
        contentText.font = kFont_Light_16;
    }
        return self;
}


@end
