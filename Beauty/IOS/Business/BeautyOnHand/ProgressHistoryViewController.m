//
//  ProgressHistoryViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "ProgressHistoryViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "ProgressDoc.h"
#import "DEFINE.h"
#import "ProgressEditViewController.h"
#import "NavigationView.h"
#import "GPBHTTPClient.h"

#define WIDTH_CONTENT 270.0f

@interface ProgressHistoryViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetProgressHistoryOperation;
@property (strong, nonatomic) NSMutableArray *progressArray;

@property (assign, nonatomic) NSInteger progressID_Selected;
@property (assign, nonatomic) NSInteger index;
@end

@implementation ProgressHistoryViewController
@synthesize progressArray;
@synthesize opportunityID;
@synthesize productType;
@synthesize progressID_Selected;
@synthesize index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestProgressHistoryList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetProgressHistoryOperation && [_requestGetProgressHistoryOperation isExecuting]) {
        [_requestGetProgressHistoryOperation cancel];
    }
    _requestGetProgressHistoryOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"进度历史"];
    [self.view addSubview:navigationView];
    
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f- 5.0f);

     if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [progressArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ProgressHistoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *progressNameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *progressUpdateTimeLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *progressDescibleLabel = (UILabel *)[cell.contentView viewWithTag:102];
    [progressNameLabel setFont:kFont_Medium_16];
    [progressNameLabel setTextColor:kColor_DarkBlue];
    [progressUpdateTimeLabel setFont:kFont_Light_14];
    [progressDescibleLabel setFont:kFont_Light_14];
  
    ProgressDoc *tempProgress = [progressArray objectAtIndex:indexPath.row];
    progressNameLabel.text = tempProgress.prg_ProgressStr;
    progressUpdateTimeLabel.text = tempProgress.prg_UpdateTime;
    progressDescibleLabel.text = tempProgress.prg_Describle;

//    progressDescibleLabel.numberOfLines = 0;
//    CGRect rect = progressDescibleLabel.frame;
//    CGSize size = [tempProgress.prg_Describle sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(WIDTH_CONTENT, 100.0f)];
//    rect.size.height = size.height;
//    progressDescibleLabel.frame = rect;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ProgressDoc *tempProgress = [progressArray objectAtIndex:indexPath.row];
//    CGSize size = [tempProgress.prg_Describle sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(WIDTH_CONTENT, 100.0f)];
//    if (size.height > 20) {
//        return 40.0f + size.height;
//    } else {
//        return 60.0f;
//    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    progressID_Selected = ((ProgressDoc *)[progressArray objectAtIndex:indexPath.row]).prg_ID;
    index = indexPath.row;
    [self performSegueWithIdentifier:@"goProgressEditViewFromProgressHistoryView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goProgressEditViewFromProgressHistoryView"]) {
        ProgressEditViewController *progressEditVC = segue.destinationViewController;
        progressEditVC.progressID = progressID_Selected;
        progressEditVC.productType = productType;
        progressEditVC.progressDoc = (ProgressDoc *)[progressArray objectAtIndex:index];
        progressEditVC.fromType = FromTypeProgressHistoryView;
    }
}

#pragma mark - 接口 

- (void)requestProgressHistoryList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"OpportunityID\":%ld}", (long)opportunityID];

    _requestGetProgressHistoryOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/GetProgressHistory" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            if (progressArray) {
                [progressArray removeAllObjects];
            } else {
                progressArray = [NSMutableArray array];
            }
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ProgressDoc *progressDoc = [[ProgressDoc alloc] init];
                [progressDoc setPrg_OpportunityID:opportunityID];
                [progressDoc setPrg_ID:[((NSString *)[obj objectForKey:@"ProgressHistoryID"]) integerValue]];
                NSInteger progress = [((NSString *)[obj objectForKey:@"Progress"]) integerValue];
                [progressDoc setPrg_Progress:progress];
                NSArray *stepContents = [(NSString *)[obj objectForKey:@"StepContent"] componentsSeparatedByString:@"|"];
                if (progress  > [stepContents count]) {
                    progress =  [stepContents count];
                    [progressDoc setPrg_Progress:progress];
                }
                [progressDoc setPrg_ProgressStr:[ stepContents objectAtIndex:progress - 1]];
                [progressDoc setPrg_Describle:(NSString *)[obj objectForKey:@"Description"]];
                [progressDoc setPrg_UpdateTime:(NSString *)[obj objectForKey:@"CreateTime"]];
                [progressArray addObject:progressDoc];
            }];
            
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            if( code == 0){
                [SVProgressHUD showErrorWithStatus2:@"获取历史进度失败！" touchEventHandle:^{
                }];
            }

        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    
    /*
    _requestGetProgressHistoryOperation = [[GPHTTPClient shareClient] requestGetJsonProgressHistoryListByOppId:opportunityID success:^(id xml) {
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
        NSString *code = [dataDic objectForKey:@"Code"];
        if ((NSNull *)code == [NSNull null]) {
            return;
        }
        if([code integerValue] == 0){
            [SVProgressHUD showErrorWithStatus2:@"获取历史进度失败！" touchEventHandle:^{
            }];
            return;
        }
        if (progressArray) {
            [progressArray removeAllObjects];
        } else {
            progressArray = [NSMutableArray array];
        }
        NSArray *data = [dataDic objectForKey:@"Data"];
        if ((NSNull *)data == [NSNull null] || data.count == 0) {
            return;
        }
        for (id obj in data)
        {
             ProgressDoc *progressDoc = [[ProgressDoc alloc] init];
            [progressDoc setPrg_OpportunityID:opportunityID];
            [progressDoc setPrg_ID:[((NSString *)[obj objectForKey:@"ProgressHistoryID"]) integerValue]];
            NSInteger progress = [((NSString *)[obj objectForKey:@"Progress"]) integerValue];
            [progressDoc setPrg_Progress:progress];
            NSArray *stepContents = [(NSString *)[obj objectForKey:@"StepContent"] componentsSeparatedByString:@"|"];
            if (progress  > [stepContents count]) {
                progress =  [stepContents count];
                [progressDoc setPrg_Progress:progress];
            }
            [progressDoc setPrg_ProgressStr:[ stepContents objectAtIndex:progress - 1]];
            [progressDoc setPrg_Describle:(NSString *)[obj objectForKey:@"Description"]];
            [progressDoc setPrg_UpdateTime:(NSString *)[obj objectForKey:@"CreateTime"]];
            [progressArray addObject:progressDoc];
        }
        [_tableView reloadData];
        */
        /*
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            for (GDataXMLElement *data in [contentData elementsForName:@"ProgressHistory"]) {
                ProgressDoc *progressDoc = [[ProgressDoc alloc] init];
                [progressDoc setPrg_OpportunityID:opportunityID];
                [progressDoc setPrg_ID:[[[[data elementsForName:@"ProgressHistoryID"] objectAtIndex:0] stringValue] integerValue]];
                NSInteger progress = [[[[data elementsForName:@"Progress"] objectAtIndex:0] stringValue] intValue];
                [progressDoc setPrg_Progress:progress];
                NSArray *stepContents = [[[[data elementsForName:@"StepContent"] objectAtIndex:0] stringValue] componentsSeparatedByString:@"|"];
                
                if (progress > [stepContents count]) {
                    progress = [stepContents count];
                    [progressDoc setPrg_Progress:progress];
                }
                [progressDoc setPrg_ProgressStr:[stepContents objectAtIndex:progress - 1]];
                [progressDoc setPrg_Describle:[[[data elementsForName:@"Description"] objectAtIndex:0] stringValue]];
                [progressDoc setPrg_UpdateTime:[[[data elementsForName:@"CreateTime"] objectAtIndex:0] stringValue]];
                [progressArray addObject:progressDoc];
            }
            [_tableView reloadData];
        } failure:^{}];
        */
    
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}

@end
