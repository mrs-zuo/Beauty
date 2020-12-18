//
//  CustomerOrderCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/9.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "CertificateCell.h"

@interface CertificateCell()

@end

@implementation CertificateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.productName = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 250, 20)];
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 150, 20)];
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 45, 135, 20)];
        self.accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 45, 160, 20)];
        self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 25,150, 20)];
        
        [self.contentView addSubview:self.productName];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.progressLabel];
        [self.contentView addSubview:self.accountLabel];
        [self.contentView addSubview:self.stateLabel];
        
        self.stateLabel.textAlignment = NSTextAlignmentRight;
        self.progressLabel.textAlignment = NSTextAlignmentRight;
        
        self.productName.font = kFont_Light_14;
        self.dateLabel.font = kFont_Light_14;
        self.progressLabel.font = kFont_Light_14;
        self.accountLabel.font = kFont_Light_14;
        self.stateLabel.font = kFont_Light_14;
        
        self.productName.textColor = kColor_TitlePink;
        self.dateLabel.textColor = kColor_Editable;
        self.progressLabel.textColor = kColor_Editable;
        self.accountLabel.textColor = kColor_Editable;
        self.stateLabel.textColor = kColor_Editable;
    }
    return self;
}

@end
