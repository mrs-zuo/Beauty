//
//  CustomerOrderCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/9.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AwaitFinishOrder;
@protocol AwaitFinishOrderDelegate;

@interface CustomerOrderCell : UITableViewCell
@property (nonatomic, strong) AwaitFinishOrder *awaitOrder;
@property (weak, nonatomic) IBOutlet UIButton *choiceButton;
@property (nonatomic, weak) id<AwaitFinishOrderDelegate>    delegate;
@end

@protocol AwaitFinishOrderDelegate <NSObject>

- (void)selectButton:(AwaitFinishOrder *)order;



@end