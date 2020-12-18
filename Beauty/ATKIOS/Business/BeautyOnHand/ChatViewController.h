//
//  ChatViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-10.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIInputToolbar.h"
#import "TemplateViewController.h"
#import "SelectCustomersViewController.h"

@interface ChatViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, TemplateViewControllerDelegate, UIInputToolbarDelegate, TemplateViewControllerDelegate, SelectCustomersViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UILabel *receiverLabel;
@property (weak, nonatomic) IBOutlet UILabel *personCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


//- (IBAction)editReceiverAction:(id)sender;

@property (strong, nonatomic) NSMutableArray *users_Selected;
- (void)requestGetNewMessage;
@end
