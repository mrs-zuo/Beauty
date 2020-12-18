//
//  DisplayMarketViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-23.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "DisplayMarketViewController.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "MessageDoc.h"
#import "DEFINE.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"
#import "NavigationView.h"
#import "PermissionDoc.h"
#import "MJRefresh.h"
#import "GPBHTTPClient.h"

#define REQUEST_GROUPMsg_DATE  @"REQUEST_GROUPMsg_DATE"
typedef NS_ENUM(NSInteger, MarketRefreshType){
    MarketRefreshNew,
    MarketRefreshOld
};

@interface DisplayMarketViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetGroupMsgHistoryOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestRefreshGroupMsgOperation;

@property (nonatomic, strong) NSMutableArray *messageArray;
@property (assign, nonatomic) int uplod_Cout;
@property (nonatomic, assign) NSInteger marketIndex;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NavigationView *navigationView;
@end

@implementation DisplayMarketViewController
@synthesize messageArray;
@synthesize uplod_Cout;
@synthesize navigationView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [messageArray removeAllObjects];
    
    if (self.tableView.footerHidden) {
        self.tableView.footerHidden = NO;
    }
    
    [_tableView headerBeginRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetGroupMsgHistoryOperation || [_requestGetGroupMsgHistoryOperation isExecuting]) {
        [_requestGetGroupMsgHistoryOperation cancel];
        [self setRequestGetGroupMsgHistoryOperation:nil];
    }
    
    if (_requestRefreshGroupMsgOperation || [_requestRefreshGroupMsgOperation isExecuting]) {
        [_requestRefreshGroupMsgOperation cancel];
        _requestRefreshGroupMsgOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"市场营销"];
    [self.view addSubview:navigationView];
    
    if ([[PermissionDoc sharePermission] rule_Marketing_Write])  {
        [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Edit"] selector:@selector(addMsgAction)];
    }

    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
         _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    [_tableView addHeaderWithTarget:self action:@selector(getNewMarkingMsg)];
    [_tableView addFooterWithTarget:self action:@selector(getHistoryMarkingMsg)];
}

- (void)getNewMarkingMsg
{
    self.marketIndex = 1;
    if (self.tableView.footerHidden) {
        self.tableView.footerHidden = NO;
    }
    [self requestGroupMsg:MarketRefreshNew];
//    [self  requestRefreshGroupMsg];
}

- (void)getHistoryMarkingMsg
{
    if (self.marketIndex < self.pageCount) {
        ++self.marketIndex;
        [self requestGroupMsg:MarketRefreshOld];
    } else {
        [self.tableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus2:@"没有更多数据了" touchEventHandle:^{}];
        self.tableView.footerHidden = YES;
    }
//    [self requestGroupMsgHistory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addMsgAction
{
    [self performSegueWithIdentifier:@"goMKSendMessageViewFromMKDisplayView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goMKSendMessageViewFromMKDisplayView"]) {
        
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (messageArray.count != 0) {
        return [messageArray count];
    } else {
       return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (messageArray.count != 0) {
        return 5;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"marketingDisplayCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.font = kFont_Light_16;
    label.textColor = kColor_DarkBlue;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.frame = CGRectMake(10.0f, 0.0f, 300.0f, kTableView_HeightOfRow);
     [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (messageArray.count != 0) {
        MessageDoc *theMessage = [messageArray objectAtIndex:indexPath.section];
        switch (indexPath.row) {
            case 0:
            {
                NSMutableString *strNames = [NSMutableString string];
                for (int i=0; i<[theMessage.mesg_FromUserNameArray count]&& i<3; i++ ) {
                    NSString *strName = [theMessage.mesg_FromUserNameArray objectAtIndex:i];
                    
                    if (i == [theMessage.mesg_FromUserNameArray count] - 1 || i == 2) {
                        [strNames appendString:strName];
                    } else {
                        [strNames appendFormat:@"%@,", strName];
                    }
                }
                label.text = [NSString stringWithFormat:@"接收人:%@等%lu人", strNames, (unsigned long)[theMessage.mesg_FromUserNameArray count]];
            }
                break;
            case 1:
                label.text = [NSString stringWithFormat:@"发送人:%@", theMessage.mesg_FromUserName];
                break;
            case 2:
                label.text = theMessage.mesg_SendTime;
                break;
            case 3:
            {
                __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
                textView.text = theMessage.mesg_MessageContent;
                textView.font = kFont_Light_16;
                CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
                float currentHeight = size.height;
                if (currentHeight < kTableView_HeightOfRow) {
                    currentHeight = kTableView_HeightOfRow;
                }
                textView = nil;
                
                CGRect rect = label.frame;
                rect.size.height = currentHeight;
                label.frame = rect;
                label.text = theMessage.mesg_MessageContent;
            }
                break;
            case 4:
                label.text = [NSString stringWithFormat:@"已接受%ld人/发送%ld人", (long)theMessage.mesg_ReadMsgCount, (long)theMessage.mesg_AllMsgCount];
                break;
            default:
                label.text = @"";
                break;
        }
        
        return cell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDoc *theMesag = [messageArray objectAtIndex:indexPath.section];
    if (indexPath.row == 3) {
        __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
        textView.text = theMesag.mesg_MessageContent;
        textView.font = kFont_Light_16;
        CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
        float currentHeight = size.height;
        if (currentHeight < kTableView_HeightOfRow) {
            currentHeight = kTableView_HeightOfRow;
        }
        textView = nil;
        return currentHeight;
    } else {
        return  kTableView_HeightOfRow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

#pragma mark - 接口

- (void)requestGroupMsg:(MarketRefreshType)type {
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];

    NSString *par = [NSString stringWithFormat:@"{\"PageIndex\":%ld,\"PageSize\":10}", (long)self.marketIndex];

    _requestGetGroupMsgHistoryOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/GetMessageForMarket" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [self endRefresh:type];
            self.pageCount = [[data objectForKey:@"PageCount"] integerValue];
            
            if (self.pageCount > 0)
                [self.navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",(long)self.marketIndex, (long)self.pageCount]];
            else
                [self.navigationView setSecondLabelText:@""];

            NSArray *marketArray = [data objectForKey:@"MessageList"];
            if ([marketArray isKindOfClass:[NSNull class]]) {
                marketArray = nil;
            }
            NSMutableArray *newMesgArray = [NSMutableArray array];
            [marketArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [newMesgArray addObject:[[MessageDoc alloc] initWithDictionary:obj]];
            }];

            if (type == MarketRefreshNew) {
                self.messageArray = [newMesgArray mutableCopy];
            } else {
                [self.messageArray addObjectsFromArray:[newMesgArray copy]];
            }
            if (self.pageCount == self.marketIndex) {
                self.tableView.footerHidden = YES;
            }
            
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [self endRefresh:type];
        }];
    } failure:^(NSError *error) {
        [self endRefresh:type];
    }];
}

- (void)endRefresh:(MarketRefreshType)type {
    if (type == MarketRefreshNew) {
        [_tableView headerEndRefreshing];
    } else {
        [_tableView footerEndRefreshing];
    }
}

- (void)requestGroupMsgHistory
{
    NSInteger lastID = 0;
    if ([messageArray count] == 0) {
        lastID = 0;
    } else {
        MessageDoc *theFirstMessage =  [messageArray lastObject];
        lastID = theFirstMessage.mesg_ID;
    }
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];

    
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"MessageID\":%ld}", (long)ACC_BRANCHID, (long)lastID];

    _requestGetGroupMsgHistoryOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/getHistoryMessageForMarketing" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            NSMutableArray *newMesgArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [newMesgArray addObject:[[MessageDoc alloc] initWithDictionary:obj]];
            }];
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }
            if ([newMesgArray count] > 0) {
                [messageArray addObjectsFromArray:newMesgArray];
                [_tableView footerEndRefreshing];
                [_tableView reloadData];
            } else {
                [_tableView footerEndRefreshing];
                _tableView.footerHidden = YES;
            }
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
    }];

    
    
    
    
    
    
    
    
    /*
    
    _requestGetGroupMsgHistoryOperation = [[GPHTTPClient shareClient] requestGetGroupMsgWithLastID:lastID success:^(id xml) {
        [_tableView.infiniteScrollingView stopAnimating];
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [SVProgressHUD dismiss];

            NSMutableArray *newMesgArray = [NSMutableArray array];
            for (GDataXMLElement *item in [contentData elementsForName:@"Message"]) {
                MessageDoc *message = [[MessageDoc alloc] init];
                
                [message setMesg_FromUserID:[[[[item elementsForName:@"FromUserID"] objectAtIndex:0] stringValue] integerValue]];
                [message setMesg_FromUserName:[[[item elementsForName:@"FromUserName"] objectAtIndex:0] stringValue]];
                [message setMesg_ID:[[[[item elementsForName:@"MessageID"] objectAtIndex:0] stringValue] integerValue]];
                [message setMesg_MessageContent:[[[item elementsForName:@"MessageContent"] objectAtIndex:0] stringValue]];
                [message setMesg_SendTime:[[[item elementsForName:@"SendTime"] objectAtIndex:0] stringValue]];
                [message setMesg_AllMsgCount:[[[[item elementsForName:@"SendCount"] objectAtIndex:0] stringValue] intValue]];
                [message setMesg_ReadMsgCount:[[[[item elementsForName:@"ReceiveCount"] objectAtIndex:0] stringValue] intValue]];
                
                for (GDataXMLElement *user in [item elementsForName:@"ToUserName"]) {
                    [message.mesg_FromUserNameArray addObject:[user stringValue]];
                }
                [newMesgArray addObject:message];
            }
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }
            if ([newMesgArray count] > 0) {
                [messageArray addObjectsFromArray:newMesgArray];
                [_tableView footerEndRefreshing];
                [_tableView reloadData];
            } else {
                [_tableView footerEndRefreshing];
                _tableView.footerHidden = YES;
                //[SVProgressHUD showErrorWithStatus2:@"没有更多的数据" touchEventHandle:^{}];
            }
            
        } failure:^{
            [SVProgressHUD dismiss];

        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];

        DLOG(@"Error:%@ Address:%s", error.description, __FUNCTION__);
    }];
     */
}

 
- (void)requestRefreshGroupMsg
{
    NSInteger recentId = 0;
    if ([messageArray count] == 0) {
        recentId = 0;
    } else {
        MessageDoc *theFirstMessage =  [messageArray firstObject];
        recentId = theFirstMessage.mesg_ID;
    }
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld, \"MessageID\":%ld}", (long)ACC_BRANCHID, (long)recentId];
    _requestRefreshGroupMsgOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/getNewMessageForMarketing" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];

        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            NSMutableArray *newMesgArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [newMesgArray addObject:[[MessageDoc alloc] initWithDictionary:obj]];
            }];
//            for (GDataXMLElement *item in [contentData elementsForName:@"Message"]) {
//                MessageDoc *message = [[MessageDoc alloc] init];
//                [message setMesg_FromUserID:[[[[item elementsForName:@"FromUserID"] objectAtIndex:0] stringValue] integerValue]];
//                [message setMesg_FromUserName:[[[item elementsForName:@"FromUserName"] objectAtIndex:0] stringValue]];
//                [message setMesg_ID:[[[[item elementsForName:@"MessageID"] objectAtIndex:0] stringValue] integerValue]];
//                [message setMesg_MessageContent:[[[item elementsForName:@"MessageContent"] objectAtIndex:0] stringValue]];
//                [message setMesg_SendTime:[[[item elementsForName:@"SendTime"] objectAtIndex:0] stringValue]];
//                [message setMesg_AllMsgCount:[[[[item elementsForName:@"SendCount"] objectAtIndex:0] stringValue] intValue]];
//                [message setMesg_ReadMsgCount:[[[[item elementsForName:@"ReceiveCount"] objectAtIndex:0] stringValue] intValue]];
//                for (GDataXMLElement *user in [item elementsForName:@"ToUserName"]) {
//                    [message.mesg_FromUserNameArray addObject:[user stringValue]];
//                }
//                [newMesgArray addObject:message];
//            }
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }
            if ([newMesgArray count] > 0) {
                NSRange range = NSMakeRange(0, [newMesgArray count]);
                NSIndexSet *index_set = [NSIndexSet indexSetWithIndexesInRange:range];
                [messageArray insertObjects:newMesgArray atIndexes:index_set];
                [_tableView headerEndRefreshing];
                [_tableView reloadData];
            } else {
                [_tableView headerEndRefreshing];
                [SVProgressHUD showErrorWithStatus2:@"已经是最新数据" touchEventHandle:^{}];
            }

        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];

    }];
    
    /*
    _requestRefreshGroupMsgOperation = [[GPHTTPClient shareClient] requestRefreshGroupMsgWithTheOldestTime:recentId success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
//            [self pullToUpdateDone];
            [SVProgressHUD dismiss];
            NSMutableArray *newMesgArray = [NSMutableArray array];
            for (GDataXMLElement *item in [contentData elementsForName:@"Message"]) {
                MessageDoc *message = [[MessageDoc alloc] init];
                [message setMesg_FromUserID:[[[[item elementsForName:@"FromUserID"] objectAtIndex:0] stringValue] integerValue]];
                [message setMesg_FromUserName:[[[item elementsForName:@"FromUserName"] objectAtIndex:0] stringValue]];
                [message setMesg_ID:[[[[item elementsForName:@"MessageID"] objectAtIndex:0] stringValue] integerValue]];
                [message setMesg_MessageContent:[[[item elementsForName:@"MessageContent"] objectAtIndex:0] stringValue]];
                [message setMesg_SendTime:[[[item elementsForName:@"SendTime"] objectAtIndex:0] stringValue]];
                [message setMesg_AllMsgCount:[[[[item elementsForName:@"SendCount"] objectAtIndex:0] stringValue] intValue]];
                [message setMesg_ReadMsgCount:[[[[item elementsForName:@"ReceiveCount"] objectAtIndex:0] stringValue] intValue]];
                for (GDataXMLElement *user in [item elementsForName:@"ToUserName"]) {
                    [message.mesg_FromUserNameArray addObject:[user stringValue]];
                }
                [newMesgArray addObject:message];
            }
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }
            if ([newMesgArray count] > 0) {
                NSRange range = NSMakeRange(0, [newMesgArray count]);
                NSIndexSet *index_set = [NSIndexSet indexSetWithIndexesInRange:range];
                [messageArray insertObjects:newMesgArray atIndexes:index_set];
                [_tableView headerEndRefreshing];
                [_tableView reloadData];
            } else {
                [_tableView headerEndRefreshing];
                [SVProgressHUD showErrorWithStatus2:@"已经是最新数据" touchEventHandle:^{}];
            }
        } failure:^{
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
//        [self pullToUpdateDone];
          [SVProgressHUD dismiss];
        DLOG(@"Error:%@ Address:%s", error.description, __FUNCTION__);
    } ];
     */
}

@end
