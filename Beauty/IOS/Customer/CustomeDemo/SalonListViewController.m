//
//  SalonListViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-9-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "SalonListViewController.h"
#import "GPHTTPClient.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "CompanyDoc.h"
#import "SalonDetailViewController.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "AppDelegate.h"

#define UPLATE_NOTICE_LIST_DATE  @"UPLATE_NOTICE_LIST_DATE"

@interface SalonListViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *salonListOperation;
@property (nonatomic) CompanyDoc *companyDoc_Selected;
@end

@implementation SalonListViewController
@synthesize salonList;
@synthesize myListView;
@synthesize companyDoc_Selected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [myListView triggerPullToRefresh];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_salonListOperation || [_salonListOperation isExecuting]){
        [_salonListOperation cancel];
        _salonListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [myListView setFrame:CGRectMake(5.0f, 0, 310.0f, kSCREN_BOUNDS.size.height - 27.0f)];
    }
    
//    TitleView *titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:[NSString stringWithFormat:@"%@门店",[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_COMPANYABBREVIATION"]]]];

    self.title = [NSString stringWithFormat:@"%@门店",[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_COMPANYABBREVIATION"]];
    
	myListView.dataSource = self;
    myListView.delegate = self;
    myListView.showsHorizontalScrollIndicator = NO;
    myListView.showsVerticalScrollIndicator = NO;
    
    __weak SalonListViewController *salonListViewController = self;
    [myListView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [salonListViewController pullToRefreshData];
        });
    }];
    
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_NOTICE_LIST_DATE];
    if (uploadDate) {
        [myListView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    } else {
        [myListView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
}

- (void)pullToRefreshData
{
    if (_salonListOperation && [_salonListOperation isExecuting]) {
        [_salonListOperation cancel];
        _salonListOperation = nil;
    }
    [self requesSalonList];
}

- (void)pullToRefreshDone
{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:[@"上次更新时间" stringByAppendingString:@": MM/dd hh:mm:ss"]];
//    NSString *data2Str = [formatter stringFromDate:[NSDate date]];
    NSString *data2Str = [@"上次更新时间：" stringByAppendingString:[NSDate stringDateTimeLongFromDate:[NSDate date]]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_NOTICE_LIST_DATE];
    [myListView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [myListView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setMyListView:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [salonList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *addressLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:103];

    [titleLabel setFont:kFont_Light_16];
    [addressLabel setFont:kFont_Light_14];
    [titleLabel setTextColor:kColor_TitlePink];
    [addressLabel setTextColor:kColor_Black];
    CompanyDoc *salonData = [self.salonList objectAtIndex:indexPath.row];
    [titleLabel setText:salonData.company_BranchName];
    [addressLabel setText:salonData.company_Address];
    [distanceLabel setText:[NSString stringWithFormat:@"%@km",salonData.Distance]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [myListView deselectRowAtIndexPath:indexPath animated:YES];
    companyDoc_Selected = [salonList objectAtIndex:indexPath.row];
    companyDoc_Selected.tag = 1;
    [self performSegueWithIdentifier:@"goDetailSalonViewFromSalonList" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goDetailSalonViewFromSalonList"]) {
        SalonDetailViewController *salonDetailEditViewController = segue.destinationViewController;
        salonDetailEditViewController.branchId = companyDoc_Selected.company_BranchID;
        salonDetailEditViewController.tag = companyDoc_Selected.tag;
        salonDetailEditViewController.businessName = companyDoc_Selected.company_BranchName;
    }
}

#pragma mark - 接口

- (void)requesSalonList
{
    NSNumber *longitude = [[NSUserDefaults standardUserDefaults]objectForKey:@"longitude"];
    NSNumber *latitude = [[NSUserDefaults standardUserDefaults]objectForKey:@"latitude"];
    NSDictionary *para = @{@"Longitude":longitude,
                           @"Latitude":latitude,
                           };

    _salonListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/company/getBranchList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        myListView.userInteractionEnabled = NO;
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {

            NSMutableArray *salonArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CompanyDoc *salon = [[CompanyDoc alloc] init];
                [salon setValuesForKeysWithDictionary:obj];
                [salonArray addObject:salon];
            }];
            salonList = salonArray;
            [myListView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self pullToRefreshDone];
         myListView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        [self pullToRefreshDone];
    }];
//    _salonListOperation = [[GPHTTPClient shareClient] requestBeautySalonListSuccess:^(id xml) {
//        myListView.userInteractionEnabled = NO;
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData) {
//            [self pullToRefreshDone];
//            if (salonList == nil){
//                salonList = [NSMutableArray array];
//            } else {
//                [salonList removeAllObjects];
//            }
//            NSMutableArray *salonArray = [NSMutableArray array];
//            for (GDataXMLElement *data in [contentData elementsForName:@"Branch"]) {
//                CompanyDoc *salon = [[CompanyDoc alloc] init];
//                [salon setCompany_BranchID:[[[[data elementsForName:@"ID"] objectAtIndex:0] stringValue] integerValue]];
//                [salon setCompany_BranchName:([[[data elementsForName:@"Name"] objectAtIndex:0] stringValue] == nil ? @"" : [[[data elementsForName:@"Name"] objectAtIndex:0] stringValue])];
//                [salon setCompany_Address:([[[data elementsForName:@"Address"] objectAtIndex:0] stringValue] == nil ? @"":[[[data elementsForName:@"Address"] objectAtIndex:0] stringValue])];
//                [salonArray addObject:salon];
//            }
//            salonList = salonArray;
//            [myListView reloadData];
//        } failure:^{
//        }];
//        myListView.userInteractionEnabled = YES;
//    } failure:^(NSError *error) {
//        [self pullToRefreshDone];
//        NSLog(@"Error:%@ address:%s",error.description, __FUNCTION__);
//    }];
}

@end
