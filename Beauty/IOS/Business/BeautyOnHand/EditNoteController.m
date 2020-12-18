//
//  EditNoteController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-10.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "EditNoteController.h"
#import "NavigationView.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "GPNavigationController.h"
#import "UIButton+InitButton.h"
#import "LabelChooseController.h"
#import "FooterView.h"
#import "GPHTTPClient.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "LabelView.h"
#import "Tags.h"
#import "GPBHTTPClient.h"

@interface EditNoteController ()<ContentEditCellDelegate>
@property (nonatomic, weak) AFHTTPRequestOperation *requestAddNote;

@property (nonatomic, strong) UITableView *editTable;

@property (nonatomic, strong) NSMutableArray *tagArray;

//@property (nonatomic, strong) UITextView *content;

@property (nonatomic, strong) NSString *content;

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, assign) CGFloat tableHeight;
@end

@implementation EditNoteController
 
@synthesize tagArray;
@synthesize contentHeight;
@synthesize content;
@synthesize tableHeight;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];
    
    self.view.backgroundColor = kColor_Background_View;
//    ((GPNavigationController *)self.navigationController).canDragBack = YES;
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"笔记编辑"];
    _editTable = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    _editTable.delegate = self;
    _editTable.dataSource = self;
    _editTable.backgroundColor = [UIColor clearColor];
    _editTable.backgroundView = nil;
    _editTable.showsVerticalScrollIndicator = NO;
    _editTable.sectionHeaderHeight = 0.0;
    _editTable.sectionFooterHeight = 5.0;

    if (IOS7 || IOS8) {
        _editTable.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        //        _payList.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _editTable.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    [self.view addSubview:navigationView];
    [self.view addSubview:_editTable];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(submitInfo)];
    [footerView showInTableView:_editTable];
    tableHeight = _editTable.frame.size.height;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    if (!tagArray) {
        tagArray = [NSMutableArray array];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardWillHideNotification object:nil];

    [_editTable reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    
    if (_requestAddNote && [_requestAddNote isExecuting]) {
        [_requestAddNote cancel];
    }
    
    _requestAddNote = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark submit
- (void)submitInfo
{
    [self.view endEditing:YES];
    
    if (content.length == 0 || (content == nil)) {

        [SVProgressHUD showErrorWithStatus2:@"内容不能为空" touchEventHandle:^{
            
        }];
        return ;
    }
    [self commitNote];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == 1) {
        if (indexPath.section == 0) {
            return  fmaxf(contentHeight, 100);
        }
    }
    return 38;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        ContentEditCell *cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.contentEditText.text = content;
        cell.delegate = self;
        return cell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.font = kFont_Light_16;
    cell.textLabel.textColor = kColor_DarkBlue;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"内容";
        return cell;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"标签";
        UIButton *editButton = [UIButton buttonWithTitle:@""
                                                  target:self
                                                selector:@selector(changeRemark)
                                                   frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                           backgroundImg:[UIImage imageNamed:@"tjbiaoqian"]
                                        highlightedImage:nil];
        editButton.tag = 1003;
        [cell.contentView addSubview:editButton];

        return cell;
    }
    if (indexPath.row == 1) {
        
        UITableViewCell *viewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        viewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addLabel:tagArray cell:viewCell];
        return viewCell;
    }
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark content
- (void)keyboardDidShown:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect tvFrame = _editTable.frame;
    tvFrame.size.height = tableHeight - initialFrame.size.height + 5.0f;
    _editTable.frame = tvFrame;
}

- (void)keyboardDidHidden:(NSNotification*)notification
{
    CGRect tvFrame = _editTable.frame;
    tvFrame.size.height = tableHeight;
    _editTable.frame = tvFrame;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    contentText.returnKeyType = UIReturnKeyDefault;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:textView];
    
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    content = contentText.text;
    if (contentHeight > 98 && height > contentHeight) {
        contentHeight = height;
        [_editTable beginUpdates];
        [_editTable endUpdates];
    }
    contentHeight = height;
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
            if (toBeString.length > 500) {
                textView.text = [toBeString substringToIndex:500];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 500) {
            textView.text = [toBeString substringToIndex:500];
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

    content = textView.text;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark tag delete
- (void)addLabel:(NSArray *)array cell:(UITableViewCell *)cell
{
    for (int i = 0; i < [array count]; i ++) {
        Tags *thetag = (Tags *)[array objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bqshanchu"]];
        CGRect lastFrame;
        if (i == 0) {
            lastFrame = CGRectMake(5, 11, 0, 0);
        } else
         lastFrame = ((UIButton *)[cell.contentView.subviews lastObject]).frame;
        CGPoint point = CGPointMake(lastFrame.origin.x + lastFrame.size.width, lastFrame.origin.y);
        NSString *name = nil;
        if (thetag.Name.length > 5) {
            name = [[thetag.Name substringToIndex:5] stringByAppendingString:@"…"];
            
        } else
            name = thetag.Name;
        CGSize size = [name sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(80, 20) lineBreakMode:NSLineBreakByTruncatingTail];
        
        imageView.frame = CGRectMake(size.width, -5, 15, 15);
        size.width += 20;
        CGRect newFrame = CGRectMake(point.x, point.y ,size.width ,size.height );
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        label.textAlignment = NSTextAlignmentLeft;
        label.font = kFont_Light_16;
        label.text = name;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.backgroundColor = [UIColor clearColor];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//        label.lineBreakMode = UILineBreakModeTailTruncation;
//        button.titleLabel.font = kFont_Light_16;
//        button.titleLabel.frame = CGRectMake(0, 0, 80, 16);
//        [button setTitle:thetag.Name forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.frame = newFrame;
        button.tag = i;
        [button addSubview:imageView];
        [button addSubview:label];
        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
    }
}

- (void)click:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"the click label Tag is %ld", (long)((UILabel *)sender).tag);
    NSInteger tag = button.tag;
    if (IOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否删除标签：%@",((Tags *)tagArray[tag]).Name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [tagArray removeObjectAtIndex:tag];
            NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:1];
            [_editTable reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"cancle click");
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"是否删除标签：%@",((Tags *)tagArray[tag]).Name] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [tagArray removeObjectAtIndex:tag];
                NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:1];
                [_editTable reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }
}

- (void)changeRemark
{
    LabelChooseController *labelController = [[LabelChooseController alloc] init];
    labelController.chooseArray = tagArray;
    labelController.type = CHOOSEADD;
    [self.navigationController pushViewController:labelController animated:YES];
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark postNote
- (void)commitNote
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    if (kMenu_Type == 1 && customerId == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
        return;
    }
    NSMutableString *string = [NSMutableString string];
    if ([tagArray count]) {
        for (Tags *ta in tagArray) {
            [string appendFormat:@"|%ld",(long)ta.tagID];
        }
        [string appendString:@"|"];
    }
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"CustomerID\":%ld,\"CreatorID\":%ld,\"TagIDs\":\"%@\",\"Content\":\"%@\"}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)customerId, (long)ACC_ACCOUNTID, string, content];

    _requestAddNote = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Notepad/addNotepad" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
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
    _requestAddNote = [[GPHTTPClient shareClient] requestAddNoteCustomerID:customerId CreatorID:ACC_ACCOUNTID TagIDS:string andContent:content success:^(id xml) {
        [SVProgressHUD dismiss];
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
        
        if (code == 1) {
            [SVProgressHUD showSuccessWithStatus2:[dataDic objectForKey:@"Message"] duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [SVProgressHUD showErrorWithStatus2:[dataDic objectForKey:@"Message"] touchEventHandle:^{
                
            }];
        }
        NSLog(@"the xml is %@", xml);
    } failure:^(NSError *error) {
        DLOG(@"the failuer %@",error);
        [SVProgressHUD dismiss];
    }];
     */
}

@end
