//
//  CustomerOrderCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/9.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "CustomerOrderCell.h"
#import "AwaitFinishOrder.h"
#import "PermissionDoc.h"
#import "SVProgressHUD.h"

@interface CustomerOrderCell()

@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

@implementation CustomerOrderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    self.productName.font = kFont_Light_14;
    self.dateLabel.font = kFont_Light_14;
    self.progressLabel.font = kFont_Light_14;
    self.accountLabel.font = kFont_Light_14;
    self.stateLabel.font = kFont_Light_14;
    
    self.productName.textColor = kColor_DarkBlue;
    self.dateLabel.textColor = kColor_Editable;
    self.progressLabel.textColor = kColor_Editable;
    self.accountLabel.textColor = kColor_Editable;
//    self.stateLabel.textColor = kColor_Editable;
    
//    self.productName.font = kFont_Light_16;

}
- (IBAction)selectButton:(UIButton *)sender {
    if (self.awaitOrder.editStatus == AwaitOrderEditNone) {
        [SVProgressHUD showErrorWithStatus2:@"您无权限处理该笔订单!" touchEventHandle:^{}];
        return;
    }
    
    self.awaitOrder.isSelect = !self.awaitOrder.isSelect;
    sender.selected = self.awaitOrder.isSelect;
    if ([self.delegate respondsToSelector:@selector(selectButton:)]) {
        [self.delegate selectButton:self.awaitOrder];
    }
}

- (void)setAwaitOrder:(AwaitFinishOrder *)order
{
    _awaitOrder = order;
    if (_awaitOrder.awaitType == AwaitOrderBill) {
        self.productName.text = _awaitOrder.ProductName;
        self.dateLabel.text = _awaitOrder.TGStartTime;
        self.progressLabel.text = _awaitOrder.processString;
        self.accountLabel.text = _awaitOrder.AccountName;
        self.stateLabel.text = _awaitOrder.paymentString;

    } else {
        self.productName.text = _awaitOrder.ProductName;
        self.dateLabel.text = _awaitOrder.OrderTime;
        self.progressLabel.text = _awaitOrder.processString;
        self.accountLabel.text = _awaitOrder.AccountName;
        self.stateLabel.text = _awaitOrder.executingString;
    }
    self.choiceButton.selected = _awaitOrder.isSelect;
    if (![[PermissionDoc sharePermission] rule_MyOrder_Write]) {
        self.choiceButton.hidden = YES;
        self.progressLabel.transform =  CGAffineTransformMakeTranslation(30,0);
    }
}



@end
