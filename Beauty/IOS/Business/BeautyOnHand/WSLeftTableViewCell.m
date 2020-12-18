//
//  WSLeftTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "WSLeftTableViewCell.h"
#import "UIButton+InitButton.h"
#import "UILabel+InitLabel.h"

@implementation WSLeftTableViewCell
@synthesize selectButton;
@synthesize nameLabel;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       selectButton = [UIButton buttonWithTitle:nil
                                         target:self
                                       selector:@selector(selectAction)
                                          frame:CGRectMake(5.0f, (44.0f - HEIGHT_NAVIGATION_VIEW)/2, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                  backgroundImg:[UIImage imageNamed:@"icon_unChecked"]
                               highlightedImage:nil];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"icon_Checked"] forState:UIControlStateSelected];
        [self.contentView addSubview:selectButton];
        
        nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(38.0f, 0.0f, 80.0f, 44.0f) title:@"--"];
        [self.contentView addSubview:nameLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateData:(UserDoc *)userDoc
{
    nameLabel.text = userDoc.user_Name;
}

- (void)selectAction
{
    if ([delegate respondsToSelector:@selector(chickSelectedButtonInCell:)]) {
        [delegate chickSelectedButtonInCell:self];
    }
}

@end
