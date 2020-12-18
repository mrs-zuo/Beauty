//
//  ChatViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-7-18.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageDoc.h"
#import "UIImageView+WebCache.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLNode.h"
#import "ChatSendMesgCell.h"
#import "ChatReceiveMsgCell.h"
#import "GPNavigationController.h"
#import "GDataXMLNode.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "GDataXMLDocument+ParseXML.h"
#import "AFHTTPClient.h"
#import "MessageDoc.h"

#define  UPDATE_CHAT_HISTORY_DATE @"UPDATE_CHAT_HISTORY_DATE"
#define  REQUEST_NEW_MESSAGE_RATE 10

#define kStatusBarHeight 20
#define kDefaultToolbarHeight 40
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@interface ChatViewController ()

@property (weak,nonatomic) AFHTTPRequestOperation * requestMesgListByOneToOneOperation;
@property (weak,nonatomic) AFHTTPRequestOperation * requestMesgListByOneToMoreOperation;
@property (weak,nonatomic) AFHTTPRequestOperation * requestHistoryMessageOperation;
@property (weak,nonatomic) AFHTTPRequestOperation * requestGetNewMessageOperation;
@property (strong,nonatomic) BHInputToolbar *inputToolbar;
@property (strong,nonatomic) NSMutableArray *messageArray;
@property (assign,nonatomic) CGFloat text_Y;
@property (assign,nonatomic) NSInteger max_MessageId;
@property (strong,nonatomic) NSTimer *timer;
@property (strong, nonatomic) UITextView *textView_Selected;

// -- 发送消息 三种状态
- (void)sendMesgWhenLoading:(MessageDoc *)messageDoc;
- (void)reloadMesgWhenSucceeding:(MessageDoc *)messageDoc retMesgId:(NSInteger)retMessageId;
- (void)reloadMesgWhenFailed:(MessageDoc *)messageDoc;
@end

@implementation ChatViewController
@synthesize messageArray;
@synthesize receiverLabel;
@synthesize text_Y;
@synthesize backgroundView;
@synthesize inputToolbar;
@synthesize timer;
@synthesize recieveHeadImg;
@synthesize textView_Selected;
@synthesize selectAccount;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    keyboardIsVisible = NO;
    self.title = @"飞语";
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setScrollsToTop:NO];
    [_tableView setAllowsSelection:NO];
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _tableView.userInteractionEnabled = YES;
    _tableView.separatorColor = kTableView_LineColor;
    [_tableView setFrame:CGRectMake(0.0f, 20.0f, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.height - 44)];

    inputToolbar = [[BHInputToolbar alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 88.0f, kSCREN_BOUNDS.size.width, 44.0f)];
    inputToolbar.inputDelegate = self;
    inputToolbar.backgroundColor = [UIColor clearColor];
    inputToolbar.textView.placeholder = @"消息:";
    inputToolbar.textView.maximumNumberOfLines = 5;
    
    [self.view addSubview:inputToolbar];
    
    __weak ChatViewController *chatViewController = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [chatViewController pullToRefreshData];
        });
    }];
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPDATE_CHAT_HISTORY_DATE];
    if (uploadDate) {
        [_tableView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    } else {
        [_tableView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
    
    UITapGestureRecognizer *tapGestureRecognozer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGestureRecognozer.numberOfTapsRequired = 1;
    tapGestureRecognozer.numberOfTouchesRequired = 1;
    tapGestureRecognozer.delegate = self;
    [_tableView addGestureRecognizer:tapGestureRecognozer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard) name:@"dismissKeyboard" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    recieveHeadImg = selectAccount.mesg_HeadImageURL;
    NSString *receiverStr = selectAccount.mesg_AccountName;
    [receiverLabel setText:receiverStr];
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setChatViewController:self];
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:REQUEST_NEW_MESSAGE_RATE target:self selector:@selector(requestGetNewMessage) userInfo:nil repeats:YES];
    }
    
    [self requestMessageListByOneToOne];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [timer invalidate];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setChatViewController:nil];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect r = self.inputToolbar.frame;
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        r.origin.y = screenFrame.size.height - self.inputToolbar.frame.size.height - kStatusBarHeight;
        if (keyboardIsVisible) {
            r.origin.y -= kKeyboardHeightPortrait;
        }
        [self.inputToolbar.textView setMaximumNumberOfLines:13];
	}
	else
    {
        r.origin.y = screenFrame.size.width - self.inputToolbar.frame.size.height - kStatusBarHeight;
        if (keyboardIsVisible) {
            r.origin.y -= kKeyboardHeightLandscape;
        }
        [self.inputToolbar.textView setMaximumNumberOfLines:7];
        [self.inputToolbar.textView sizeToFit];
    }
    self.inputToolbar.frame = r;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}


#pragma mark - pullTo

- (void)pullToRefreshData
{
    if (_requestHistoryMessageOperation && [_requestHistoryMessageOperation isExecuting]) {
        [_requestHistoryMessageOperation cancel];
        _requestHistoryMessageOperation = nil;
    }
    [self requestGetHistoryMessage];
}

- (void)pullToRefreshDone
{

    NSString *data2Str = [@"上次更新时间：" stringByAppendingString:[NSDate stringDateTimeLongFromDate:[NSDate date]]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPDATE_CHAT_HISTORY_DATE];
    [_tableView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [_tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
}

#pragma mark - Keyboard

- (void)dismissKeyboard
{
    [inputToolbar.textView.internalTextView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect;
    NSValue *keyboardValue = [notification userInfo][UIKeyboardFrameEndUserInfoKey];
    [keyboardValue getValue:&keyboardRect];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height - keyboardRect.size.height;
	self.inputToolbar.frame = frame;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue ].size;
    
    
    _tableView.frame = CGRectMake(0, 20, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 44  - keyboardSize.height);
    
    NSInteger numberOfRows = [_tableView numberOfRowsInSection:0];
    if(numberOfRows > 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
	self.inputToolbar.frame = frame;
    _tableView.frame = CGRectMake(0, 20, kSCREN_BOUNDS.size.width,kSCREN_BOUNDS.size.height - 44 - 44 - 20);

    NSInteger numberOfRows = [_tableView numberOfRowsInSection:0];
    if(numberOfRows > 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
	[UIView commitAnimations];
}

#pragma mark - UIInputToolbarDelegate

-(void)inputButtonPressed:(NSString *)inputText
{

    if(selectAccount.mesg_Chat_Use == 0){
        [SVProgressHUD showErrorWithStatus2:@"对方没有使用飞语的权限！"];
        return;
    }
    
    if (selectAccount.mesg_Available == 0) {
        [SVProgressHUD showErrorWithStatus2:@"服务人员已被删除，不能发送消息！"];
        return;
    }
    
    if ([inputText length] == 0) {
        [SVProgressHUD showErrorWithStatus2:@"消息不能为空！"];
        return;
    }
    
    if ([inputText length] > 300) {
        [SVProgressHUD showErrorWithStatus2:@"消息长度不能大于300"];
        return;
    }
    if (selectAccount.mesg_Available == 1) {
        MessageDoc *messageDoc = [[MessageDoc alloc] init];
        NSInteger customerId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_USERID"] integerValue];
        [messageDoc setMesg_FromUserID:customerId];
        [messageDoc setMesg_MessageContent:inputText];
        [messageDoc setMesg_SenderType:0];
        [messageDoc setMesg_SendTime:[OverallMethods FormatTimeWithDate:[NSDate date] andFormat:@"yyyy-MM-dd HH:mm"]];
        
        [messageDoc setMesg_ToUserID:selectAccount.mesg_AccountID];
        [messageDoc setMesg_GroupFlag:0];
        [self requestAddMsgByOneToOne:messageDoc];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageArray count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDoc *messageDoc = [messageArray objectAtIndex:indexPath.row];
    if(messageDoc.mesg_SendOrReceiveFlag == 0){
        NSString *cellIndentify = @"ChatSendMesgCell";
        ChatSendMesgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if(cell == nil){
            cell = [[ ChatSendMesgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
       
        [cell updateData:messageDoc headImg:recieveHeadImg];
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;
        return cell;
    }else{
        NSString *cellIndetify = @"ChatReceiveMsgCell";
        ChatReceiveMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetify];
        if(cell == nil){
            cell = [[ChatReceiveMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetify];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
       
        NSString *sendHeadImg = [[NSUserDefaults standardUserDefaults] stringForKey:@"CUSTOMER_HEADIMAGE"];
        [cell updateData:messageDoc headImg:sendHeadImg];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDoc *theMessage =[messageArray objectAtIndex:indexPath.row];
    CGSize size_Msg = [theMessage.mesg_MessageContent sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(210.0f, 300.0f)];
    return size_Msg.height + 60.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"---------------");
}
#pragma mark - threeState

// --Loading
- (void)sendMesgWhenLoading:(MessageDoc *)messageDoc
{
    [messageDoc setMesg_SendOrReceiveFlag:1];
    [messageDoc setMesg_MessageID:-1];
    [messageDoc setMesg_Status:1];
    [messageArray addObject:messageDoc];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageArray.count -1 inSection:0];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count] -1 inSection:0]
                      atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

// --Success
- (void)reloadMesgWhenSucceeding:(MessageDoc *)messageDoc retMesgId:(NSInteger)retMessageId
{
    NSInteger index = [messageArray indexOfObject:messageDoc];
    [messageArray removeObject:messageDoc];
    [messageDoc setMesg_MessageID:retMessageId];
    [messageDoc setMesg_Status:0];
    [messageArray insertObject:messageDoc atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// --Failure
- (void)reloadMesgWhenFailed:(MessageDoc *)messageDoc
{
    NSInteger index = [messageArray indexOfObject:messageDoc];
    [messageArray removeObject:messageDoc];
    [messageDoc setMesg_MessageID:0];
    [messageDoc setMesg_Status:2];
    [messageArray insertObject:messageDoc atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - 接口

-(void)requestMessageListByOneToOne
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    //<HereUserID>%ld</HereUserID><ThereUserID>%ld</ThereUserID><OlderThanMessageID>%d</OlderThanMessageID>
    NSDictionary *para = @{@"HereUserID":@(CUS_CUSTOMERID),
                           @"ThereUserID":@(selectAccount.mesg_AccountID),
                           @"MessageID":@0};
    _requestMesgListByOneToOneOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/message/getHistoryMessage"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }

            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MessageDoc *messageDoc = [[MessageDoc alloc] init];
                [messageDoc setValuesForKeysWithDictionary:obj];
                [messageArray addObject:messageDoc];
            }];

            if ([messageArray count] > 0) {
                [_tableView reloadData];
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count] -1  inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

//发送message时的接口
- (void)requestAddMsgByOneToOne:(MessageDoc *)messageDoc
{
    [self sendMesgWhenLoading:messageDoc];
    
    [messageDoc setMesg_ToUserIDString:[NSString stringWithFormat:@"%ld",(long)messageDoc.mesg_ToUserID]];
    NSDictionary *para = @{@"FromUserID":@(messageDoc.mesg_FromUserID),
                           @"ToUserIDs":messageDoc.mesg_ToUserIDString,
                           @"MessageContent":[OverallMethods EscapingString:messageDoc.mesg_MessageContent],
                           @"MessageType":@(messageDoc.mesg_MessageType),
                           @"GroupFlag":@(messageDoc.mesg_GroupFlag)};
    
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/message/addMessage"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }

            NSDictionary *dict = [data objectAtIndex:0];
            NSInteger retMessageId = [dict[@"NewMessageID"] integerValue];
            
            if (retMessageId > 0){
                [self reloadMesgWhenSucceeding:messageDoc retMesgId:retMessageId];
            } else {
                [self reloadMesgWhenFailed:messageDoc];
            }
        } failure:^(NSInteger code, NSString *error) {
            [self reloadMesgWhenFailed:messageDoc];
        }];
    } failure:^(NSError *error) {
        [self reloadMesgWhenFailed:messageDoc];
    }];
}

// 获得历史记录 by OneToOne
- (void)requestGetHistoryMessage
{
    NSInteger accountId = selectAccount.mesg_AccountID;
    NSInteger first_messageId = 0;
    if([messageArray count] == 0){
        [self pullToRefreshDone];
        return ;
    }
    MessageDoc *first_MessageDoc = [messageArray objectAtIndex:0];
    first_messageId = first_MessageDoc.mesg_MessageID;
    
    NSDictionary *para = @{@"HereUserID":@(CUS_CUSTOMERID),
                           @"ThereUserID":@(accountId),
                           @"MessageID":@(first_messageId)};
    _requestMesgListByOneToOneOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/message/getHistoryMessage"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }
            NSMutableArray *tempMutableArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MessageDoc *messageDoc = [[MessageDoc alloc] init];
                [messageDoc setValuesForKeysWithDictionary:obj];
                [tempMutableArray addObject:messageDoc];
            }];
            
            if ([tempMutableArray count] > 0) {
                NSMutableArray *_MessageArray = [NSMutableArray arrayWithArray:messageArray];
                _tableView.userInteractionEnabled = NO;
                [messageArray removeAllObjects];
                [messageArray addObjectsFromArray:tempMutableArray];
                [messageArray addObjectsFromArray:_MessageArray];
                
                [_tableView reloadData];
                _tableView.userInteractionEnabled = YES;
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self pullToRefreshDone];
    } failure:^(NSError *error) {
        [self pullToRefreshDone];
    }];
  }

// 获得最新消息 by OneToOne
- (void)requestGetNewMessage
{
    if (_requestGetNewMessageOperation || [_requestGetNewMessageOperation isExecuting]) {
        [_requestGetNewMessageOperation cancel];
        _requestGetNewMessageOperation = nil;
    }
    
    NSInteger accoundId = selectAccount.mesg_AccountID;
    MessageDoc *last_MessageDoc = [[MessageDoc alloc] init];
    NSInteger last_messageId = 0;
    
    if ([messageArray count] == 0) {
        last_messageId = 0;
    } else {
        NSInteger m = [messageArray count] - 1;
        
        for (NSInteger i = [messageArray count] - 1; i >= 0; i--) {
            if ([[messageArray objectAtIndex:i] mesg_Status] == 0) {
                m = i;
                break;
            }
            
            if (i == 0) {
                m = 0;
                break;
            }
        }
        last_MessageDoc = [messageArray objectAtIndex:m];
        last_messageId = last_MessageDoc.mesg_MessageID;
        if (last_messageId == -1) {
            last_messageId = 0;
        }
    }

    NSDictionary *para = @{@"HereUserID":@(CUS_CUSTOMERID),
                           @"ThereUserID":@(accoundId),
                           @"MessageID":@(last_messageId)};
    _requestGetNewMessageOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/message/getNewMessage"  showErrorMsg:NO  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }
            NSMutableArray *indexPathArray = [NSMutableArray array];  // 存储indexPath
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MessageDoc *messageDoc = [[MessageDoc alloc] init];
                [messageDoc setValuesForKeysWithDictionary:obj];
                [messageArray addObject:messageDoc];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageArray.count -1 inSection:0];
                [indexPathArray addObject:indexPath];
            }];

            if ([indexPathArray count] > 0) {
                [_tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationRight];
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count] -1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

// 获取新消息的条目
- (void)requestTheTotalCountOfNewMessage
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSDictionary *para = @{@"ToUserID":@(CUS_CUSTOMERID)};
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/message/getNewMessageCount"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSInteger newMessageCount = [data[@"NewMessageCount"] intValue];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newMessageCount];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
