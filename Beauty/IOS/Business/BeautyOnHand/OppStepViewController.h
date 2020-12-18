//
//  OppStepViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-5-14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OppStepVCDelegate;
@interface OppStepViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *stepArray;
@property (nonatomic, strong) NSMutableArray *prodArray;
@property (nonatomic, weak) id<OppStepVCDelegate> delegate;
@end

@protocol OppStepVCDelegate <NSObject>

- (void)oppStepVCDidFinishChooseOppStep;

@end
