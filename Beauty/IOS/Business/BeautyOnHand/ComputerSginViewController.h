//
//  ComputerSginViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/1.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import "MWPointView.h"

typedef void(^ComputerConfirmSignBlock)(NSString *imgString);
@interface ComputerSginViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIButton *canceBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet MWPointView *drawView;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;

@property (nonatomic,copy) ComputerConfirmSignBlock computerConfirmSignBlock;

- (IBAction)confirm:(UIButton *)sender;
- (IBAction)cance:(UIButton *)sender;
- (IBAction)clear:(UIButton *)sender;


@end
