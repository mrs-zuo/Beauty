//
//  ChatViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-7-18.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHInputToolbar.h"
#import "ZXBaseViewController.h"

@class MessageDoc;
@interface ChatViewController : ZXBaseViewController <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,BHInputToolbarDelegate>{
    @private
    BOOL keyboardIsVisible;
}
@property (weak,nonatomic) IBOutlet UILabel *receiverLabel;
@property (weak,nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong,nonatomic) NSString *recieveHeadImg;
@property (strong, nonatomic) MessageDoc *selectAccount;

- (void)requestGetNewMessage;
@end
