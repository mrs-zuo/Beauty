//
//  AddEcard_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/6/26.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddNewCarddelegate <NSObject>
@optional
-(void)requestCardList;
@end

@interface AddEcard_ViewController : BaseViewController
@property (assign, nonatomic) id<AddNewCarddelegate> delegate;
@property (assign ,nonatomic) int cardNumber;
@end
