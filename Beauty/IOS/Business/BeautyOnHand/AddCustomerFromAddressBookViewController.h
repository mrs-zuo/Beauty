//
//  AddCustomerFromAddressBookViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-12.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class CustomerDoc;
@interface AddCustomerFromAddressBookViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *allAddButton;
@property (strong, nonatomic) NSMutableArray *customerListArray;
@property (strong, nonatomic) NSMutableArray *receiveArray;
@property (strong, nonatomic) CustomerDoc *customerDoc;

- (IBAction)allAddAction:(id)sender;
- (IBAction)affirmAddAction:(id)sender;
@end
