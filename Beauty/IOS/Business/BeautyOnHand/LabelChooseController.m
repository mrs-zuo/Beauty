//
//  LabelChooseController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-11.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "LabelChooseController.h"
#import "NavigationView.h"
#import "UIButton+InitButton.h"
#import "SVProgressHUD.h"
#import "NormalEditCell.h"
#import "FooterView.h"
#import "EditLabelController.h"
#import "GPHTTPClient.h"
#import "Tags.h"
#import "GPBHTTPClient.h"

@interface LabelChooseController ()
@property (nonatomic, weak) AFHTTPRequestOperation *getTagList;
@property (nonatomic, strong) UITableView *labelList;
@property (nonatomic, strong) NSMutableArray *tagsArray;
@property (nonatomic, strong) NSMutableArray *tmpArray;
@end

@implementation LabelChooseController
@synthesize tagsArray;
@synthesize chooseArray;
@synthesize tmpArray;
@synthesize type;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];
    
    self.view.backgroundColor = kColor_Background_View;
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"选择标签"];
    
    if (type == CHOOSEADD) {
        UIButton *editButton = [UIButton buttonWithTitle:@""
                                                  target:self
                                                selector:@selector(editLabel)
                                                   frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                           backgroundImg:[UIImage imageNamed:@"tianjiabiaoqian"]
                                        highlightedImage:nil];
        
        [navigationView addSubview:editButton];
    }
    if (type == CHOOSESEARCH) {
        UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                    target:self
                                                  selector:@selector(goBack)
                                                     frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                             backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                          highlightedImage:nil];

        UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
        self.navigationItem.leftBarButtonItem = goBackBarButton;

    }
    
    _labelList = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    _labelList.delegate = self;
    _labelList.dataSource = self;
    _labelList.rowHeight = 38.0f;
    _labelList.backgroundColor = [UIColor clearColor];
    _labelList.backgroundView = nil;
    _labelList.showsVerticalScrollIndicator = YES;
    _labelList.sectionHeaderHeight = 0.0;
    _labelList.sectionFooterHeight = 0.0;
    _labelList.autoresizingMask = UIViewAutoresizingNone;

    
    if (IOS7 || IOS8) {
        _labelList.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f - 44.0f);
    } else if (IOS6) {
        _labelList.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f - 44.0f);
    }
    
    [self.view addSubview:navigationView];
    [self.view addSubview:_labelList];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(submitTag)];
    footerView.frame = CGRectMake(5.0, _labelList.frame.origin.y + _labelList.frame.size.height, 310.0f , 36.0f);
    [self.view addSubview:footerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (!tagsArray) {
        tagsArray = [NSMutableArray array];
    } else {
        [tagsArray removeAllObjects];
    }
    if (!tmpArray) {
        tmpArray = [NSMutableArray array];
        [tmpArray addObjectsFromArray:chooseArray];
    } else {
        [tmpArray removeAllObjects];
        [tmpArray addObjectsFromArray:chooseArray];
    }
    
    [self requestTagList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_getTagList && [_getTagList isExecuting]) {
        [_getTagList cancel];
    }
    
    _getTagList = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark submitTag
- (void)submitTag
{
    if ([tmpArray count] > 3) {
        [SVProgressHUD showSuccessWithStatus2:@"最多选择三个标签" duration:kSvhudtimer touchEventHandle:^{}];
    } else {
        [chooseArray removeAllObjects];
        [chooseArray addObjectsFromArray:tmpArray];
        switch (type) {
            case CHOOSEADD:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case CHOOSESEARCH:
                [self dismissViewControllerAnimated:YES completion:^{}];
                break;
        }
    }
}

#pragma mark search
- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark gotoEditLabel
- (void)editLabel
{
    EditLabelController *editController = [[EditLabelController alloc] init];
    [self.navigationController pushViewController:editController animated:YES];
}

#pragma mark showLabel and chooseLabel
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tagsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"choose";
    UITableViewCell *cell = [_labelList dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.textColor = kColor_DarkBlue;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW - 5.0f, (38.0f - HEIGHT_NAVIGATION_VIEW)/ 2 , HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)];
        button.tag = 1010;
        button.userInteractionEnabled = NO;
        [button setBackgroundImage:[UIImage imageNamed:@"icon_unChecked"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"icon_Checked"]   forState:UIControlStateSelected];
        [cell.contentView addSubview:button];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIButton *but = (UIButton *)[cell viewWithTag:1010];
    but.selected = NO;
    
    if ([tmpArray count] != 0) {
        [tmpArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (((Tags *)obj).tagID == ((Tags *)tagsArray[indexPath.row]).tagID) {
                but.selected = YES;
                *stop = YES;
            }
        }];
    }
    cell.textLabel.text = ((Tags *)tagsArray[indexPath.row]).Name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [_labelList cellForRowAtIndexPath:indexPath];
    UIButton *but = (UIButton *)[cell viewWithTag:1010];
    if (but.selected) {
        [tmpArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (((Tags *)obj).tagID == ((Tags *)[tagsArray objectAtIndex:indexPath.row]).tagID) {
                [tmpArray removeObject:obj];
                but.selected = !but.selected;
                *stop = YES;
            }
        }];
    } else {
        [tmpArray addObject:[tagsArray objectAtIndex:indexPath.row]];
        but.selected = !but.selected;
    }
}

- (void)requestTagList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"Type\":1}", (long)ACC_COMPANTID, (long)ACC_BRANCHID];
    
    _getTagList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Tag/getTagList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            [tagsArray addObject:[[Tags alloc] initWithDictionary:@{@"ID":@0, @"Name":@"无"}]];
            
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tagsArray addObject:[[Tags alloc] initWithDictionary:obj]];
            }];
            [_labelList reloadData];

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];

        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    /*
    _getTagList = [[GPHTTPClient shareClient] requestGetTagListsuccess:^(id xml) {
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
        NSArray *data = [dataDic objectForKey:@"Data"];
        NSInteger reCode = [[dataDic objectForKey:@"Code"] integerValue];

        if (reCode != 1) {
            [SVProgressHUD showErrorWithStatus2:[dataDic objectForKey:@"Message"] touchEventHandle:^{}];
            return;
        }
        
        [tagsArray addObject:[[Tags alloc] initWithDictionary:@{@"ID":@0, @"Name":@"无"}]];

        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tagsArray addObject:[[Tags alloc] initWithDictionary:obj]];
        }];
        [_labelList reloadData];
    } failure:^(NSError *error) {
        DLOG(@"the failuer %@",error);
        [SVProgressHUD dismiss];
    }];
     */
//    [SVProgressHUD dismiss];
}
@end
