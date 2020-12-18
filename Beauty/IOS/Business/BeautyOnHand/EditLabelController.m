//
//  EditLabelController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-11.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "EditLabelController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "FooterView.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"

@interface EditLabelController ()
@property (nonatomic, weak) AFHTTPRequestOperation *requestAddTag;
@property (nonatomic, strong) UITableView *editLabel;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *tagString;
@end

@implementation EditLabelController
@synthesize label;
@synthesize tagString;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];
    
    self.view.backgroundColor = kColor_Background_View;
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"添加标签"];
    
    _editLabel = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    _editLabel.delegate = self;
    _editLabel.dataSource = self;
    _editLabel.rowHeight = 38.0f;
    _editLabel.backgroundColor = [UIColor clearColor];
    _editLabel.backgroundView = nil;
    _editLabel.showsVerticalScrollIndicator = NO;
    _editLabel.sectionFooterHeight = 5.0;
    _editLabel.autoresizingMask = UIViewAutoresizingNone;
    
    tagString = [[NSString alloc] init];
    
    if (IOS7 || IOS8) {
        _editLabel.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        //        self.automaticallyAdjustsScrollViewInsets = NO;
        //        _labelList.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _editLabel.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    [self.view addSubview:navigationView];
    [self.view addSubview:_editLabel];
    
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定"  submitAction:@selector(commitTag)];
    [footerView showInTableView:_editLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_requestAddTag && [_requestAddTag isExecuting]) {
        [_requestAddTag cancel];
    }
    _requestAddTag = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    DLOG(@"NoteList viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)commitTag
{
    [self.view endEditing:YES];
    if (tagString.length == 0 || (tagString == nil)) {
        [SVProgressHUD showErrorWithStatus2:@"内容不能为空" touchEventHandle:^{
            
        }];
        return;
    }
    [self addTag];
}

#pragma mark text
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 38.0;
    }
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mark = @"mark";
    UITableViewCell *cell = [_editLabel dequeueReusableCellWithIdentifier:mark];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:mark];
        cell.textLabel.font = kFont_Light_16;
        cell.textLabel.textColor = kColor_DarkBlue;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"内容";
        return cell;
    } else {
        ContentEditCell *edit = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        edit.contentEditText.text = tagString;
        edit.contentEditText.placeholder = @"请输入标签内容";
        edit.delegate = self;
        return edit;
    }
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    contentText.returnKeyType = UIReturnKeyDone;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:textView];
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char * ch=[text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 10) {
        [contentText resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 20) {
                [SVProgressHUD showErrorWithStatus2:@"标签内容不能超过20字" touchEventHandle:^{}];
                textView.text = [toBeString substringToIndex:20];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 20) {
            [SVProgressHUD showErrorWithStatus2:@"标签内容不能超过20字" touchEventHandle:^{}];
            textView.text = [toBeString substringToIndex:20];
        }
    }
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    tagString = textView.text;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark addTag
- (void)addTag
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    
    [SVProgressHUD showWithStatus:@"Loading"];

    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"CreatorID\":%ld,\"Name\":\"%@\",\"Type\":1}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)customerId, tagString];
    
    _requestAddTag = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Tag/addTag" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];

        }];
    } failure:^(NSError *error) {
        
    }];

    
    
    
    
    /*
    _requestAddTag = [[GPHTTPClient shareClient] requestAddTagCreatorID:customerId TagName:tagString success:^(id xml) {
        
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
            return;
        origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
        
        NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
        NSInteger code = [[dataDic objectForKey:@"Code"] integerValue];
        
        if ( code == 1) {
            [SVProgressHUD showSuccessWithStatus2:[dataDic objectForKey:@"Message"] duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            NSString *mesg = [dataDic objectForKey:@"Message"];
            if (!mesg) {
                mesg = @"系统异常添加失败";
            }
            [SVProgressHUD showErrorWithStatus2:mesg touchEventHandle:^{}];
        }
        
    } failure:^(NSError *error) {
        DLOG(@"the failuer %@",error);
        [SVProgressHUD dismiss];
    }];
     */
//    [SVProgressHUD dismiss];
}


@end
