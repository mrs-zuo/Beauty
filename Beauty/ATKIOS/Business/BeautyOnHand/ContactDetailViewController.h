//
//  ContactDetailViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditContactDetailViewController.h"


@class ContactDoc;
@interface ContactDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, EditContactDetailViewControllerDelegate >
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) ContactDoc *contactDoc;

@end
