//
//  CosmetologistListViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//
//
//#import "CosmetologistListViewController.h"
//#import "GPHTTPClient.h"
//#import "GDataXMLNode.h"
//#import "AccountDoc.h"
//#import "UIScrollView+SVPullToRefresh.h"
//#import "UIImageView+WebCache.h"
//#import "DEFINE.h"
//#import "BeauticianEditViewController.h"
//#define UPLATE_COSMETOLOGIST_LIST_DATE  @"UPLATE_COSMETOLOGIST_LIST_DATE"
//
//@interface CosmetologistListViewController ()
//@property (weak, nonatomic) AFHTTPRequestOperation *cosmetologistListOperation;
//@property (strong, nonatomic) AccountDoc *cosmetologist_selected;
//@end
//
//@implementation CosmetologistListViewController
//@synthesize cosmetologist;
//@synthesize myListView;
//@synthesize cs;
//@synthesize cosmetologist_selected;
//@synthesize AccountDoc;
//@synthesize cos_Name,cos_Mobile,cos_Expert,cos_UserID,cos_Introduction,cos_Title,cos_Available,cos_Department,cos_CompanyID,cos_HeadImgURL;
//
//
//
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//    }
//    return self;
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    if (![self.slidingViewController.underRightViewController isKindOfClass:[MenuViewController class]]) {
//        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
//    }
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
//    
//    [myListView triggerPullToRefresh];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    if (_cosmetologistListOperation || [_cosmetologistListOperation isExecuting]) {
//        [_cosmetologistListOperation cancel];
//        _cosmetologistListOperation = nil;
//    }
//}
//
//- (void)viewDidLoad
//{
//    self.navigationController.delegate = self;
//    [super viewDidLoad];
//	myListView.dataSource = self;
//    myListView.delegate = self;
//    myListView.showsHorizontalScrollIndicator = NO;
//    myListView.showsVerticalScrollIndicator = NO;
//    
//    [self requesCosmetologistList];
//    
//    __weak CosmetologistListViewController *cosmetologistListViewController = self;
//    [myListView addPullToRefreshWithActionHandler:^{
//        int64_t delayInSeconds = 0.5;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [cosmetologistListViewController pullToRefreshData];
//        });
//    }];
//    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_COSMETOLOGIST_LIST_DATE];
//    if (uploadDate) {
//        [myListView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
//    } else {
//        [myListView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
//    }
//    
//}
//
//- (void)pullToRefreshData
//{
//    if (_cosmetologistListOperation && [_cosmetologistListOperation isExecuting]) {
//        [_cosmetologistListOperation cancel];
//        _cosmetologistListOperation = nil;
//    }
//    [self requesCosmetologistList];
//}
//
//- (void)pullToRefreshDone
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"上次更新时间: MM/dd hh:mm:ss"];
//    NSString *data2Str = [formatter stringFromDate:[NSDate date]];
//    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_COSMETOLOGIST_LIST_DATE];
//    [myListView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
//    [myListView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//
//#pragma mark - UITableViewDelegate && UITableViewDataSource
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [cosmetologist count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellIndentify = @"MyCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
//    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
//    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
//    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:102];
//    UILabel *departmentLabel = (UILabel *)[cell.contentView viewWithTag:103];
//    UIImageView *state_imageView = (UIImageView *)[cell.contentView viewWithTag:104];
//    
//    AccountDoc *cosmetologistData = [self.cosmetologist objectAtIndex:indexPath.row];
//    [imageView setImageWithURL:[NSURL URLWithString:cosmetologistData.cos_HeadImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg40"]];
//    [nameLabel setText:cosmetologistData.cos_Name];
//    [titleLabel setText:cosmetologistData.cos_Title];
//    [departmentLabel setText:cosmetologistData.cos_Department];
//    //NSLog(@"avail=%@", cosmetologistData.cos_Available);
//    if ([cosmetologistData.cos_Available isEqualToString:@"true"]) {
//        [state_imageView setImage:[UIImage imageNamed:@"cosmetologist_open.png"]];
//    }else{
//        [state_imageView setImage:[UIImage imageNamed:@"cosmetologist_close.png"]];
//    }
//    
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        cs =[cosmetologist objectAtIndex:indexPath.row];
//    AccountDoc *select_cosmetologist = [cosmetologist objectAtIndex:indexPath.row];
//    
//        cos_Name=select_cosmetologist.cos_Name;
//        cos_Title=select_cosmetologist.cos_Title;
//        cos_Mobile=select_cosmetologist.cos_Mobile;
//        cos_Department =select_cosmetologist.cos_Department;
//        cos_Introduction=select_cosmetologist.cos_Introduction;
//        cos_UserID=select_cosmetologist.cos_UserID;
//        cos_Expert=select_cosmetologist.cos_Expert;
//        cos_HeadImgURL=select_cosmetologist.cos_HeadImgURL;
//        cos_Available=select_cosmetologist.cos_Available;
//    
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:select_cosmetologist.cos_UserID] forKey:@"Selected_Cosmetologist_ID"];
//    [self performSegueWithIdentifier:@"goBeauticianInfoFromBeauticianList" sender:self];
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//       
//    if ([segue.identifier isEqualToString:@"goBeauticianInfoFromBeauticianList"]) {
//        BeauticianEditViewController *beauticianEditViewController= segue.destinationViewController;
//        beauticianEditViewController.cos_Name = cos_Name;
//        beauticianEditViewController.cos_Mobile =cos_Mobile;
//        beauticianEditViewController.cos_Title =cos_Title;
//        beauticianEditViewController.cos_Introduction =cos_Introduction;
//        beauticianEditViewController.cos_Available =cos_Available;
//        beauticianEditViewController.cos_Department =cos_Department;
//        beauticianEditViewController.cos_HeadImgURL =cos_HeadImgURL;
//        beauticianEditViewController.cos_Expert =cos_Expert;
//        beauticianEditViewController.cos_UserID=cos_UserID;
//    }
//}
//
//#pragma mark - Cosmetologist Method
//- (IBAction)addCosmetologistAction:(id)sender {
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"Selected_Cosmetologist_ID"];
//    [self performSegueWithIdentifier:@"goBeauticianInfoFromBeauticianList" sender:self];
//}
//
//#pragma mark - 接口
//- (void)requesCosmetologistList
//{
//    _cosmetologistListOperation = [[GPHTTPClient shareClient] requestGetCosmetologistListWithSuccess:^(id xml) {
//        [self pullToRefreshDone];
//        if (cosmetologist == nil){
//            cosmetologist = [NSMutableArray array];
//        } else {
//            [cosmetologist removeAllObjects];
//        }
//        
//        NSMutableArray *cosmetologistArray = [NSMutableArray array];
//        GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
//        NSArray *datas = [xmlDoc nodesForXPath:@"//ds" error:nil];
//        for (GDataXMLElement *data in datas) {
//            AccountDoc *cosmet = [[AccountDoc alloc] init];
//            [cosmet setCos_UserID:[[[[data elementsForName:@"ID"] objectAtIndex:0] stringValue] integerValue]];
//            [cosmet setCos_Name:[[[data elementsForName:@"Name"] objectAtIndex:0] stringValue]];
//            [cosmet setCos_Department:[[[data elementsForName:@"Department"] objectAtIndex:0] stringValue]];
//            [cosmet setCos_Title:[[[data elementsForName:@"Title"] objectAtIndex:0] stringValue]];
//            [cosmet setCos_Available:[[[data elementsForName:@"Available"] objectAtIndex:0] stringValue]];
//            [cosmet setCos_Mobile:[[[data elementsForName:@"Mobile"] objectAtIndex:0] stringValue]];
//            [cosmet setCos_Introduction:[[[data elementsForName:@"Introduction"] objectAtIndex:0] stringValue]];
//            [cosmet setCos_Expert:[[[data elementsForName:@"Expert"] objectAtIndex:0] stringValue]];
//           // NSString *urlStr = [kGPImageURLString stringByAppendingFormat:@"image/customer/%d/head.png",cosmet.cos_UserID];
//            //[cosmet setCos_HeadImgURL:urlStr];
//            [cosmetologistArray addObject:cosmet];
//        }
//        cosmetologist = cosmetologistArray;
//        //NSLog(@"cosmetologist===%@",cosmetologist);
//        [myListView reloadData];
//        
//    } failure:^(NSError *error) {
//        [self pullToRefreshDone];
//        NSLog(@"Error:%@ address:%s",error.description, __FUNCTION__);
//    }];
//}

//@end