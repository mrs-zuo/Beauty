//
//  CompletionOrderCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/16.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "CompletionOrderCell.h"
#import "OperatingOrder.h"
#import "SVProgressHUD.h"

#define LabelWidth  120.0f
@interface CompletionOrderCell()
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *payStatusLabel;
//@property (weak, nonatomic) IBOutlet UILabel *customerLabel;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
//
//@property (nonatomic, strong) UILabel *nameLame;
//@property (nonatomic, strong) UILabel *custLame;
@end

@implementation CompletionOrderCell

- (void)awakeFromNib {
    self.productNameLabel.font = kFont_Light_14;
    self.payStatusLabel.font = kFont_Light_14;
//    self.customerLabel.font = kFont_Light_14;
    self.personLabel.font = kFont_Light_14;
    self.progressLabel.font = kFont_Light_14;
    self.dateLabel.font = kFont_Light_14;
//    self.nameLame = [[UILabel alloc] init];
//    self.custLame = [[UILabel alloc] init];
//    self.nameLame.font = kFont_Light_14;
//    self.custLame.font = kFont_Light_14;
//    self.custLame.textAlignment = NSTextAlignmentRight;
//    self.nameLame.textAlignment = NSTextAlignmentRight;
//    [self.contentView addSubview:self.nameLame];
//    [self.contentView addSubview:self.custLame];
    
    self.productNameLabel.textColor = kColor_DarkBlue;
    self.payStatusLabel.textColor = kColor_Editable;
    self.personLabel.textColor = kColor_Editable;
    self.progressLabel.textColor = kColor_Editable;
//    self.nameLame.textColor = kColor_Editable;
//    self.custLame.textColor = kColor_Editable;
//    self.customerLabel.textColor = kColor_Editable;

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOpOrder:(OperatingOrder *)order
{
    _opOrder = order;
    self.productNameLabel.text = _opOrder.ProductName;
    self.payStatusLabel.text = _opOrder.paymentStatusText;
//    self.customerLabel.text = _opOrder.CustomerName;
    self.personLabel.text = [NSString stringWithFormat:@"%@%@",_opOrder.CustomerName,_opOrder.displayAccountName];
    self.progressLabel.text = _opOrder.progressText;
    self.dateLabel.text = _opOrder.TGStartTime;
    self.selectButton.selected = _opOrder.isSelect;
//    self.custLame.text = _opOrder.CustomerName;
//    self.nameLame.text = _opOrder.displayAccountName;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateLabelSize];
}

- (void)updateLabelSize
{
//    CGSize displaySize = [self.opOrder.displayAccountName sizeWithFont:kFont_Light_12 constrainedToSize:CGSizeMake(67, 20) lineBreakMode:NSLineBreakByTruncatingTail];
//    self.nameLame.frame = CGRectMake(self.selectButton.frame.origin.x - ceilf(displaySize.width), 24, ceilf(displaySize.width), 21);
//    self.custLame.frame = CGRectMake(155, 24, LabelWidth - ceilf(displaySize.width), 21);
//    self.customerLabel.frame = CGRectMake(155, 35, LabelWidth - ceilf(displaySize.width), 21);
}

- (IBAction)selectOrderButton:(UIButton *)sender {
    if (self.opOrder.editStatus == OperatingOrderEditNone) {
        [SVProgressHUD showErrorWithStatus2:@"您无权限处理该笔订单!" touchEventHandle:^{}];
        return;
    }

    self.opOrder.isSelect = !self.opOrder.isSelect;
    sender.selected = self.opOrder.isSelect;
    if ([self.delegate respondsToSelector:@selector(updateCheckButton)]) {
        [self.delegate updateCheckButton];
    }
}

@end
