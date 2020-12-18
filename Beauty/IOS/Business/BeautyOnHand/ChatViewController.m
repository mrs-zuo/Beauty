//
//  ChatViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-10.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageDoc.h"
#import "UIImageView+WebCache.h"
#import "DEFINE.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLNode.h"
#import "ChatSendMesgCell.h"
#import "ChatReceiveMsgCell.h"
#import "GPNavigationController.h"
#import "GDataXMLNode.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "UIInputToolbar.h"
#import "TemplateViewController.h"
#import "TemplateDoc.h"
#import "UserDoc.h"

#import "NSDate+Convert.h"
#import "GPBHTTPClient.h"

#define UPDATE_CHAT_HISTORY_DATE @"UPDATE_CHAT_HISTORY_DATE"
#define REQUEST_NEW_MESSAGE_RATE 10
#define ACC_COMPANTID [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_COMPANTID"] integerValue]
#define ACC_BRANCHID  [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_BRANCHID"] integerValue]
#define ACC_ACCOUNTID [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_USERID"] integerValue]

@interface ChatViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestMesgListByOneToOneOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestMesgListByOneToMoreOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestHistoryMessageOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetNewMessageOperation;
@property (strong, nonatomic) UIInputToolbar *inputToolbar;

@property (strong, nonatomic) NSMutableArray *messageArray;


@property (strong, nonatomic) UITextView *textView_Selected;

@property (assign, nonatomic) CGFloat text_Y;
@property (assign, nonatomic) BOOL isGroud;  // 判断是群发(YES)  还是单发(NO)

@property (assign, nonatomic) NSInteger max_MessageId;

@property (strong, nonatomic) NSTimer *timer;

// -- 发送消息 三种状态
- (void)sendMesgWhenLoading:(MessageDoc *)messageDoc;
- (void)reloadMesgWhenSucceeding:(MessageDoc *)messageDoc retMesgId:(NSInteger)retMessageId;
- (void)reloadMesgWhenFailed:(MessageDoc *)messageDoc;
@end

@implementation ChatViewController
@synthesize users_Selected;
@synthesize messageArray;
@synthesize receiverLabel;
@synthesize personCountLabel;
@synthesize text_Y;
@synthesize inputToolbar;
@synthesize timer;
@synthesize contactView;
@synthesize textView_Selected;

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
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)initData
{
    // 初始化 收件人
    if ([users_Selected count] > 1) {
        UserDoc *user0 = [users_Selected objectAtIndex:0];
        UserDoc *user1 = [users_Selected objectAtIndex:1];
        NSString *receiverStr = [NSString stringWithFormat:@"群发:%@,%@", user0.user_Name, user1.user_Name];
        NSString *personCountStr = [NSString stringWithFormat:@"等%ld人",(long)[users_Selected count]];
        
        CGSize size_receiverStr = [[NSString stringWithFormat:@"群发:%@,%@", user0.user_Name, user1.user_Name] sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(165.0f, 21.0f)];
        CGSize size_personCountStr = [[NSString stringWithFormat:@"等%ld人",(long)[users_Selected count]] sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(100.0f, 21.0f)];
        
        [receiverLabel setFrame:CGRectMake(5, 11, size_receiverStr.width+2, 21)];
        [personCountLabel setFrame:CGRectMake(5+size_receiverStr.width+4, 11, size_personCountStr.width+2, 21)];
        
        [receiverLabel setText:receiverStr];
        [personCountLabel setText:personCountStr];
        
        //由于每次群发的对象不一样，所以不取历史记录
        //[self requestMessageListByOneToMore];
        
        
        _isGroud = YES;
        
    } else {
        UserDoc *user = [users_Selected objectAtIndex:0];
        NSString *receiverStr = [NSString stringWithFormat:@"收件人:%@", user.user_Name];
        [receiverLabel setText:receiverStr];
        [personCountLabel setText:nil];
        [self requestMessageListByOneToOne];
        _isGroud = NO;
    }
    
    // 将该viewController的句柄给AppDelegate
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setChatViewController:self];
    
    if (timer == nil || ![timer isValid]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:REQUEST_NEW_MESSAGE_RATE target:self selector:@selector(requestGetNewMessage) userInfo:nil repeats:YES];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    
    if (messageArray) {
        [messageArray removeAllObjects];
    } else {
        messageArray = [NSMutableArray array];
    }
    
    //#####刷新 查看历史#########
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)initTableView
{
    contactView.frame = CGRectMake(0.0f, kORIGIN_Y, 320.0f, 44.0f);
    
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setScrollsToTop:NO];
    [_tableView setAllowsSelection:YES];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    _tableView.frame = CGRectMake( 0.0f, contactView.frame.origin.y + contactView.frame.size.height, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - contactView.frame.size.height - 64.0f - 40.0f);
    
    inputToolbar = [[UIInputToolbar alloc] initWithFrame:CGRectMake(0.0f, _tableView.frame.origin.y + _tableView.frame.size.height, kSCREN_BOUNDS.size.width, 40.0f)];
    inputToolbar.inputDelegate = self;
    inputToolbar.backgroundColor = [UIColor clearColor];
    inputToolbar.textView.maximumNumberOfLines = 6;
    inputToolbar.textView.placeholder = @"请输入发送的消息";
    [self.view addSubview:inputToolbar];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        [inputToolbar addSubview:inputToolbar.textView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setChatViewController:nil];
}

- (IBAction)editReceiverAction:(id)sender
{
    SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectCustomer setSelectModel:1 userType:0 customerRange:CUSTOMEROFMINE defaultSelectedUsers:users_Selected];
    [selectCustomer setDelegate:self];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];}

- (void)dismissKeyBoard
{
    [inputToolbar.textView.internalTextView resignFirstResponder];
}

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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"上次请求时间: MM/dd hh:mm:ss"];
    NSString *data2Str = [formatter stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPDATE_CHAT_HISTORY_DATE];
    [_tableView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [_tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
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
    
    //add begin by zhangwei map to GPB-950
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue ].size;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(rect.size.height > 480)
        _tableView.frame = CGRectMake(0.f, 44.f, 320.f, 420.f - keyboardSize.height);
    else
        _tableView.frame = CGRectMake(0.f, 44.f, 320.f, 340.f - keyboardSize.height );
    
    NSInteger numberOfRows = [_tableView numberOfRowsInSection:0];
    if(numberOfRows > 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    //add end by zhangwei map to GPB-950
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect frame = self.inputToolbar.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.inputToolbar.frame = frame;
    
    //add begin by zhangwei map to GPB-950
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(rect.size.height > 480)
        _tableView.frame = CGRectMake(0.f, 44.f, 320.f, 420.f);
    else
        _tableView.frame = CGRectMake(0.f, 44.f, 320.f, 340.f);
    
    NSInteger numberOfRows = [_tableView numberOfRowsInSection:0];
    if(numberOfRows > 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    //add end by zhangwei map to GPB-950
    
    [UIView commitAnimations];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goTemplateViewFromChatView"]) {
        TemplateViewController *templateViewController = segue.destinationViewController;
        templateViewController.templateType = TemplateTypePrivate;
        templateViewController.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - UIInputToolbarDelegate

-(void)inputButtonPressed:(NSString *)inputText
{
    if (![[PermissionDoc sharePermission] rule_Chat_Use]) {
        [SVProgressHUD showErrorWithStatus2:@"您没有发送消息的权限!" touchEventHandle:^{}];
        return;
    }
    
    UserDoc *userAvailable = [users_Selected objectAtIndex:0];
    if (userAvailable.user_Available == 0) {
        [SVProgressHUD showErrorWithStatus2:@"用户已被删除，不能发送消息!" touchEventHandle:^{}];
        return;
    }
    
    if ([inputText length] == 0) {
        [SVProgressHUD showErrorWithStatus2:@"消息不能为空!" touchEventHandle:^{}];
        return;
    }
    
    if ([inputText length] > 300) {
        [SVProgressHUD showErrorWithStatus2:@"信息长度不能超过300个字" touchEventHandle:^{}];
        return;
    }
    
    MessageDoc *messageDoc = [[MessageDoc alloc] init];
    NSInteger accoundId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_USERID"] integerValue];
    [messageDoc setMesg_MessageContent:inputText];
    [messageDoc setMesg_FromUserID:accoundId];
    [messageDoc setMesg_SendTime:[OverallMethods FormatTimeWithDate:[NSDate date] andFormat:@"yyyy-MM-dd HH:mm"]];
    
    if (_isGroud) {
        [messageDoc setMesg_FromUserID:ACC_ACCOUNTID];
        [messageDoc setMesg_AllMsgCount: [users_Selected count]];
        [messageDoc setMesg_ReadMsgCount:0];
        [messageDoc setMesg_GroupFlag:1];
        [self requestAddMsgByOneToOne:messageDoc];
    } else {
        UserDoc *user = [users_Selected objectAtIndex:0];
        [messageDoc setMesg_FromUserID:ACC_ACCOUNTID];
        [messageDoc setMesg_ToUserID:user.user_Id];
        [messageDoc setMesg_ToUserIDString:[NSString stringWithFormat:@"%ld",(long)user.user_Id]];
        [messageDoc setMesg_GroupFlag:0];
        [self requestAddMsgByOneToOne:messageDoc];
    }
}

- (void)chickTemplateButton
{
    [self dismissKeyBoard];
    [self performSegueWithIdentifier:@"goTemplateViewFromChatView" sender:self];
}

- (void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    if ([expandingTextView.text length] > 300) {
        // add by zhangwei map "输入三百个字符不在让其输入"
        [SVProgressHUD showErrorWithStatus2:@"信息长度不能超过300个字" touchEventHandle:^{}];
        return;
    }
}

#pragma mark - SelectCustomersViewControllerDelegate

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    users_Selected = [NSMutableArray arrayWithArray:userArray];
    [self initData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDoc *messageDoc = [messageArray objectAtIndex:indexPath.row];
    if (messageDoc.mesg_SendOrReceiveFlag == 0) {
        NSString *cellIndentify = @"ChatSendMesgCell";
        ChatSendMesgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[ChatSendMesgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        messageDoc.mesg_FromUserImgURL = [[users_Selected objectAtIndex:0] user_HeadImage];
        [cell updateData:messageDoc];
        
        
        if (_isGroud) {
            [cell.stateLabel setHidden:NO];
        } else {
            [cell.stateLabel setHidden:YES];
        }
        
        return cell;
    } else  {
        NSString *cellIndentify = @"ChatReceiveMsgCell";
        ChatReceiveMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[ChatReceiveMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        messageDoc.mesg_FromUserImgURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"ACCOUNT_HEADIMAGE"];
        [cell updateData:messageDoc];
        
        if (_isGroud) {
            [cell.stateLabel setHidden:NO];
        } else {
            [cell.stateLabel setHidden:YES];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDoc *theMessage = [messageArray objectAtIndex:indexPath.row];
    return 40.0f + theMessage.mesg_MsgHegiht;
}

#pragma mark - TemplateViewControllerDelegate

- (void)returnTemplate:(TemplateDoc *)theTemplateDoc
{
    [inputToolbar.textView setText:theTemplateDoc.TemplateContent];
}

#pragma mark -

// --Loading
- (void)sendMesgWhenLoading:(MessageDoc *)messageDoc
{
    [messageDoc setMesg_SendOrReceiveFlag:1];
    [messageDoc setMesg_ID:-1];
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
    [messageDoc setMesg_ID:retMessageId];
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
    [messageDoc setMesg_ID:0];
    [messageDoc setMesg_Status:2];
    [messageArray insertObject:messageDoc atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - 接口

//获得最初的10条聊天记录
- (void)requestMessageListByOneToOne
{
    
    
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    UserDoc *user = [users_Selected objectAtIndex:0];
    NSString *par = [NSString stringWithFormat:@"{\"HereUserID\":%ld,\"ThereUserID\":%ld,\"MessageID\":%d}", (long)ACC_ACCOUNTID, (long)user.user_Id, 0];
    
    _requestMesgListByOneToOneOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/getHistoryMessage" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        if (messageArray) {
            [messageArray removeAllObjects];
        } else {
            messageArray = [NSMutableArray array];
        }
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            NSMutableArray *tempMutableArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempMutableArray addObject:[[MessageDoc alloc] initWithDictionary:obj]];
            }];
            if ([tempMutableArray count] > 0) {
                NSMutableArray *_MessageArray = [NSMutableArray arrayWithArray:messageArray];
                [messageArray removeAllObjects];
                [messageArray addObjectsFromArray:tempMutableArray];
                [messageArray addObjectsFromArray:_MessageArray];
                
                [_tableView reloadData];
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            if ([messageArray count] > 0) {
                [_tableView reloadData];
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count] -1  inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    /*
     _requestMesgListByOneToOneOperation = [[GPHTTPClient shareClient] requestGetMessagesListByOneToOneWithCustomer:user.user_Id Success:^(id xml) {
     [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
     [SVProgressHUD dismiss];
     if (messageArray) {
     [messageArray removeAllObjects];
     } else {
     messageArray = [NSMutableArray array];
     }
     for (GDataXMLElement *item in [contentData elementsForName:@"Message"]) {
     MessageDoc *messageDoc = [[MessageDoc alloc] init];
     [messageDoc setMesg_ID:[[[[item elementsForName:@"MessageID"] objectAtIndex:0] stringValue] integerValue]];
     [messageDoc setMesg_MessageContent:[[[item elementsForName:@"MessageContent"] objectAtIndex:0] stringValue] ];
     [messageDoc setMesg_SendTime:[[[item elementsForName:@"SendTime"] objectAtIndex:0] stringValue]];
     [messageDoc setMesg_SendOrReceiveFlag:[[[[item elementsForName:@"SendOrReceiveFlag"] objectAtIndex:0] stringValue] integerValue]];
     int groupFlag = [[[[item elementsForName:@"GroupFlag"] objectAtIndex:0] stringValue] isEqualToString:@"true"] ? 1 : 0;
     [messageDoc setMesg_GroupFlag:groupFlag];
     [messageArray addObject:messageDoc];
     }
     if ([messageArray count] > 0) {
     [_tableView reloadData];
     [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count] -1  inSection:0]
     atScrollPosition:UITableViewScrollPositionBottom animated:NO];
     }
     } failure:^{}];
     } failure:^(NSError *error) {
     [SVProgressHUD dismiss];
     DLOG(@"Error:%@ Address:%s", error.description, __FUNCTION__);
     }];
     */
    
}

//发送message时的接口，单发和群发已经合并
- (void)requestAddMsgByOneToOne:(MessageDoc *)messageDoc
{
    [self sendMesgWhenLoading:messageDoc];
    
    if (messageDoc.mesg_GroupFlag == 1) {
        NSMutableString *toUserIdsStr = [NSMutableString string];
        for (UserDoc *userDoc in users_Selected) {
            [toUserIdsStr appendFormat:@"%ld,", (long)userDoc.user_Id];
        }
        [messageDoc setMesg_ToUserIDString:toUserIdsStr];
    } else {
        [messageDoc setMesg_ToUserIDString:[NSString stringWithFormat:@"%ld,",(long)messageDoc.mesg_ToUserID]];
    }
    
    
    NSString *par = [NSString stringWithFormat:@"{\"FromUserID\":%ld,\"ToUserIDs\":\"%@\",\"MessageContent\":\"%@\",\"MessageType\":%ld,\"GroupFlag\":%ld}", (long)messageDoc.mesg_FromUserID, messageDoc.mesg_ToUserIDString, messageDoc.mesg_MessageContent, (long)messageDoc.mesg_MessageType, (long)messageDoc.mesg_GroupFlag];
    
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/addMessage" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }
            NSInteger retMessageId = [[[data firstObject] objectForKey:@"NewMessageID"] integerValue];
            if (retMessageId > 0){
                if (_isGroud){
                    [self reloadMesgWhenSucceeding:messageDoc retMesgId:0];
                } else {
                    [self reloadMesgWhenSucceeding:messageDoc retMesgId:retMessageId];
                }
            } else {
                [self reloadMesgWhenFailed:messageDoc];
            }
            
        } failure:^(NSInteger code, NSString *error) {
            [self reloadMesgWhenFailed:messageDoc];
            
        }];
        
    } failure:^(NSError *error) {
        [self reloadMesgWhenFailed:messageDoc];
        
    }];
    
    
    
    
    
    
    
    
    /*
     
     [[GPHTTPClient shareClient] requestSendMessageByOneToOneWithMessage:messageDoc Success:^(id xml) {
     [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
     if (!messageArray) {
     messageArray = [NSMutableArray array];
     }
     NSInteger retMessageId = [[[[contentData elementsForName:@"NewMessageID"] objectAtIndex:0] stringValue] integerValue];
     if (retMessageId > 0){
     if (_isGroud){
     [self reloadMesgWhenSucceeding:messageDoc retMesgId:0];
     } else {
     [self reloadMesgWhenSucceeding:messageDoc retMesgId:retMessageId];
     }
     } else {
     [self reloadMesgWhenFailed:messageDoc];
     }
     } failure:^{
     [self reloadMesgWhenFailed:messageDoc];
     }];
     } failure:^(NSError *error) {
     [self reloadMesgWhenFailed:messageDoc];
     }];
     */
}

// 获得最新消息 by OneToOne
- (void)requestGetNewMessage
{
    if (_isGroud) {
        [self pullToRefreshDone];
        return;
    }
    
    if (_requestGetNewMessageOperation || [_requestGetNewMessageOperation isExecuting]) {
        [_requestGetNewMessageOperation cancel];
        _requestGetNewMessageOperation = nil;
    }
    
    NSInteger customerId = [(UserDoc *)[users_Selected objectAtIndex:0] user_Id];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.mesg_ID != -1"];
    NSArray *preArray = [messageArray filteredArrayUsingPredicate:predicate];
    NSInteger last_messageId = ((MessageDoc *)[preArray lastObject]).mesg_ID;
    
    //    if ([messageArray count] > 0) {
    //        MessageDoc *last_MessageDoc = [messageArray objectAtIndex:([messageArray count] -1)];
    //        last_messageId = last_MessageDoc.mesg_ID;
    //    }
    //    if (last_messageId == 0) return;
    
    NSString *par = [NSString stringWithFormat:@"{\"HereUserID\":%ld,\"ThereUserID\":%ld,\"MessageID\":%ld}", (long)ACC_ACCOUNTID, (long)customerId, (long)last_messageId];
    
    _requestGetNewMessageOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/getNewMessage" andParameters:par failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            if (!messageArray) {
                messageArray = [NSMutableArray array];
            }
            NSMutableArray *indexPathArray = [NSMutableArray array];  // 存储indexPath
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [messageArray addObject:[[MessageDoc alloc] initWithDictionary:obj]];
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
    
    
    
    /*
     _requestGetNewMessageOperation = [[GPHTTPClient shareClient] requestGetNewMessagesWithCustomerId:customerId lastMessageId:last_messageId Success:^(id xml) {
     [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
     if (!messageArray) {
     messageArray = [NSMutableArray array];
     }
     NSMutableArray *indexPathArray = [NSMutableArray array];  // 存储indexPath
     for (GDataXMLElement *item in [contentData elementsForName:@"Message"]) {
     MessageDoc *messageDoc = [[MessageDoc alloc] init];
     
     DLOG(@"++++++++new ID:%ld", (long)[[[[item elementsForName:@"MessageID"] objectAtIndex:0] stringValue] integerValue]);
     [messageDoc setMesg_ID:[[[[item elementsForName:@"MessageID"] objectAtIndex:0] stringValue] integerValue]];
     [messageDoc setMesg_MessageContent:[[[item elementsForName:@"MessageContent"] objectAtIndex:0] stringValue]];
     [messageDoc setMesg_SendTime:[[[item elementsForName:@"SendTime"] objectAtIndex:0] stringValue]];
     [messageDoc setMesg_SendOrReceiveFlag:[[[[item elementsForName:@"SendOrReceiveFlag"] objectAtIndex:0] stringValue] integerValue]];
     [messageArray addObject:messageDoc];
     
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageArray.count -1 inSection:0];
     [indexPathArray addObject:indexPath];
     }
     if ([indexPathArray count] > 0) {
     [_tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationRight];
     [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count] -1 inSection:0]
     atScrollPosition:UITableViewScrollPositionBottom animated:NO];
     }
     } failure:^{
     
     }];
     } failure:^(NSError *error) {
     DLOG(@"Error:%@ Address:%s", error.description, __FUNCTION__);
     }];
     */
}

// 获得历史记录 by OneToOne
// 在最初的10条聊天记录过后，通过message获取后续的message
- (void)requestGetHistoryMessage
{
    if (_isGroud) {
        [self pullToRefreshDone];
        return;
    }
    NSInteger customerId = [(UserDoc *)[users_Selected objectAtIndex:0] user_Id];
    
    if ([messageArray count] == 0) {
        [self pullToRefreshDone];
        return;
    }
    
    MessageDoc *first_MessageDoc = [messageArray objectAtIndex:0];
    NSInteger first_messageId = first_MessageDoc.mesg_ID;
    
    NSString *par = [NSString stringWithFormat:@"{\"HereUserID\":%ld,\"ThereUserID\":%ld,\"MessageID\":%ld}", (long)ACC_ACCOUNTID, (long)customerId, (long)first_messageId];
    
    _requestHistoryMessageOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/getHistoryMessage" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [self pullToRefreshDone];
        if (!messageArray) {
            messageArray = [NSMutableArray array];
        }
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            NSMutableArray *tempMutableArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tempMutableArray addObject:[[MessageDoc alloc] initWithDictionary:obj]];
            }];
            if ([tempMutableArray count] > 0) {
                NSMutableArray *_MessageArray = [NSMutableArray arrayWithArray:messageArray];
                [messageArray removeAllObjects];
                [messageArray addObjectsFromArray:tempMutableArray];
                [messageArray addObjectsFromArray:_MessageArray];
                
                [_tableView reloadData];
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
     _requestHistoryMessageOperation = [[GPHTTPClient shareClient] requestHistoryMessagesWithCustomerId:customerId firstMessageId:first_messageId Success:^(id xml) {
     [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
     [self pullToRefreshDone];
     if (!messageArray) {
     messageArray = [NSMutableArray array];
     }
     NSMutableArray *tempMutableArray = [NSMutableArray array];
     for (GDataXMLElement *item in [contentData elementsForName:@"Message"]) {
     MessageDoc *messageDoc = [[MessageDoc alloc] init];
     [messageDoc setMesg_ID:[[[[item elementsForName:@"MessageID"] objectAtIndex:0] stringValue] integerValue]];
     [messageDoc setMesg_MessageContent:[[[item elementsForName:@"MessageContent"] objectAtIndex:0] stringValue] ];
     [messageDoc setMesg_SendTime:[[[item elementsForName:@"SendTime"] objectAtIndex:0] stringValue]];
     [messageDoc setMesg_SendOrReceiveFlag:[[[[item elementsForName:@"SendOrReceiveFlag"] objectAtIndex:0] stringValue] integerValue]];
     [tempMutableArray addObject:messageDoc];
     }
     if ([tempMutableArray count] > 0) {
     NSMutableArray *_MessageArray = [NSMutableArray arrayWithArray:messageArray];
     [messageArray removeAllObjects];
     [messageArray addObjectsFromArray:tempMutableArray];
     [messageArray addObjectsFromArray:_MessageArray];
     
     [_tableView reloadData];
     [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
     atScrollPosition:UITableViewScrollPositionBottom animated:NO];
     }
     } failure:^{
     
     }];
     } failure:^(NSError *error) {
     DLOG(@"Error:%@ Address:%s", error.description, __FUNCTION__);
     }];
     
     */
    
}

//- (void)requestMessageListByOneToMore
//{
//    [SVProgressHUD showWithStatus:@"Loading..."];
//    _requestMesgListByOneToMoreOperation = [[GPHTTPClient shareClient] requestGetMessagesListByOneToMoreSuccess:^(id xml) {
//        [SVProgressHUD dismiss];
//        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
//        NSArray *items = [document nodesForXPath:@"//ds" error:nil];
//        if (messageArray) {
//            [messageArray removeAllObjects];
//        } else {
//            messageArray = [NSMutableArray array];
//        }
//        for (GDataXMLElement *item in items) {
//            MessageDoc *messageDoc = [[MessageDoc alloc] init];
//            [messageDoc setMesg_AllMsgCount:[[[[item elementsForName:@"Cnt"] objectAtIndex:0] stringValue] integerValue]];
//            [messageDoc setMesg_MessageContent:[[[item elementsForName:@"MessageContent"] objectAtIndex:0] stringValue] ];
//            int groupFlag = [[[[item elementsForName:@"GroupFlag"] objectAtIndex:0] stringValue] isEqualToString:@"true"] ? 0 : 1;
//            [messageDoc setMesg_GroupFlag:groupFlag];
//            [messageDoc setMesg_SendTime:[[[item elementsForName:@"SendTime"] objectAtIndex:0] stringValue]];
//            [messageDoc setMesg_ReadMsgCount:[[[[item elementsForName:@"receiveCnt"] objectAtIndex:0] stringValue] integerValue]];
//            [messageArray addObject:messageDoc];
//        }
//        if ([messageArray count] > 0) {
//            [_tableView reloadData];
//            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messageArray count] -1  inSection:0]
//                              atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//        }
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        DLOG(@"Error:%@ Address:%s", error.description, __FUNCTION__);
//    }];
//}

//- (void)requestAddMsgByOneToMore:(MessageDoc *)messageDoc
//{
//
//    [self sendMesgWhenLoading:messageDoc];
//
//    NSMutableString *toUserIdsStr = [NSMutableString string];
//    for (UserDoc *userDoc in users_Selected) {
//        [toUserIdsStr appendFormat:@"%d,", userDoc.user_Id];
//    }
//    [[GPHTTPClient shareClient] requestSendMessageByOneToMoreWithMessage:messageDoc toUserIdsStr:toUserIdsStr Success:^(id xml) {
//        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
//        NSArray *items = [document nodesForXPath:@"//soap:Body" error:nil];
//        if (!messageArray) {
//            messageArray = [NSMutableArray array];
//        }
//        if ([[[items objectAtIndex:0] stringValue] isEqualToString:@"true"])
//        {
//            [self reloadMesgWhenSucceeding:messageDoc retMesgId:0];
//        }
//        else
//        {
//            [self reloadMesgWhenFailed:messageDoc];
//        }
//
//    } failure:^(NSError *error) {
//
//        [self reloadMesgWhenFailed:messageDoc];
//        DLOG(@"Error:%@ Address:%s", error.description, __FUNCTION__);
//    }];
//}

@end

