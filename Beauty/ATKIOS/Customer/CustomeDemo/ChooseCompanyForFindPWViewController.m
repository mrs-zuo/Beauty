//
//  ChooseCompanyForFindPWViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-13.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ChooseCompanyForFindPWViewController.h"
#import "ResetPasswordViewController.h"
#import "LoginDoc.h"
#import "UIButton+InitButton.h"

@interface ChooseCompanyForFindPWViewController ()
@property (strong, nonatomic) NSMutableArray *login_selected;
@property (strong, nonatomic) UIButton *goNextButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *stateButtonAll;
@end

@implementation ChooseCompanyForFindPWViewController
@synthesize loginArray;
@synthesize login_selected,stateButtonAll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

- (void)viewDidLoad
{
    self.isOnlyShowBackButton = YES;
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - init

- (void)initView
{
//    TitleView *titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:@"请选择商家"]];
    
    self.title = @"请选择商家";
    
    stateButtonAll = [UIButton buttonWithTitle:@""
                                     target:self
                                   selector:@selector(selectAllAction)
                                      frame:CGRectMake(275.0f, 0.f, 36.0f, 36.0f)
                              backgroundImg:[UIImage imageNamed:@"icon_unSelected_big"]
                           highlightedImage:nil];
    [stateButtonAll setBackgroundImage:[UIImage imageNamed:@"icon_unSelected_big"] forState:UIControlStateNormal];
    [stateButtonAll setBackgroundImage:[UIImage imageNamed:@"icon_Selected_big"] forState:UIControlStateSelected];
//    [titleView addSubview:stateButtonAll];

    [self.view  addSubview:stateButtonAll];
    
    _goNextButton = [UIButton buttonWithTitle:@""
                                       target:self
                                     selector:@selector(goNextPage)
                                        frame:CGRectMake(170.0f, (44.0f - 36.0f)/2, 130.0f, 32.0f)
                                backgroundImg:[UIImage imageNamed:@"nextbth"]
                             highlightedImage:nil];
    [self.view addSubview:_goNextButton];

    _cancelButton = [UIButton buttonWithTitle:@""
                                       target:self
                                     selector:@selector(cancelAction)
                                        frame:CGRectMake(20.0f, (44.0f - 36.0f)/2, 130.0f, 32.0f)
                                backgroundImg:[UIImage imageNamed:@"cancelbth"]
                             highlightedImage:nil];
    [self.view addSubview:_cancelButton];
    
    
    if ((IOS7 || IOS8)) {
        _cancelButton.frame = CGRectMake(20.0f, (44.0f - 36.0f)/2, 130.0f, 32.0f);
        _goNextButton.frame = CGRectMake(170.0f, (44.0f - 36.0f)/2, 130.0f, 32.0f);
    }
    [_tableView setFrame:CGRectMake(0, 41, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 41 + 20)];

    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 44.0f)];
    [footerView addSubview:_goNextButton];
    [footerView addSubview:_cancelButton];
    footerView.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:footerView];
    
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = kDefaultBackgroundColor;
    _tableView.backgroundView = nil;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
}
-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)selectAllAction
{
    if (stateButtonAll.selected){
        self.login_selected = [NSMutableArray array];
        stateButtonAll.selected = NO;
        [_tableView reloadData];
    }else{
        self.login_selected = [NSMutableArray array];
        [self.loginArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.login_selected addObject:obj];
            if (self.loginArray.count-1 == idx){
                stateButtonAll.selected = YES;
                [_tableView reloadData];
            }
        }];

    }
}
- (void)initData
{
    if (loginArray == nil)
        loginArray = [[NSMutableArray alloc] init];
    
    if (!login_selected)
        login_selected = [[NSMutableArray alloc] init];
}
- (void)goNextPage
{
    if (login_selected.count < 1)
        [SVProgressHUD showErrorWithStatus2:@"请选择要修改密码的公司"];
    else {
        [self performSegueWithIdentifier:@"goChangePasswordViewFromChooseCompanyView" sender:self];
    }
}
#pragma mark - Button

- (void)cancelAction
{
//    UIViewController *viewController = self;
//    while(viewController.presentingViewController) {
//        viewController = viewController.presentingViewController;
//    }
//    if(viewController) {
//        [viewController dismissViewControllerAnimated:YES completion:nil];
//    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
   
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kTableView_WithTitle;
    } else {
        return kTableView_Margin;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow + 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return loginArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    LoginDoc *loginDoc = [self.loginArray objectAtIndex:indexPath.section];
    [titleLabel setFont:kFont_Light_16];
    [titleLabel setTextColor:kColor_TitlePink];
    [titleLabel setText:loginDoc.login_CompanyAbbreviation];
    
    UIButton *stateButton = (UIButton *)[cell viewWithTag:10000];
    if (!stateButton) {
        stateButton = [UIButton buttonWithTitle:@""
                                         target:self
                                       selector:@selector(selectAction:)
                                          frame:CGRectMake(275.0f, 3.f, 36.0f, 36.0f)
                                  backgroundImg:[UIImage imageNamed:@"icon_unSelected"]
                               highlightedImage:nil];
        [stateButton setBackgroundImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
        [stateButton setBackgroundImage:[UIImage imageNamed:@"icon_Selected"] forState:UIControlStateSelected];
        [cell addSubview:stateButton];
    }
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF.login_CompanyID == %d",loginDoc.login_CompanyID];
    NSArray *array = [self.login_selected filteredArrayUsingPredicate:pre];
    if (array.count > 0)
        stateButton.selected = YES;
    else
        stateButton.selected = NO;

    return cell;
}

-(void)selectAction:(UIButton *)sender
{
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)sender.superview.superview;
    else
        cell = (UITableViewCell *)sender.superview;
    
    NSInteger index = [_tableView indexPathForCell:cell].section;
    LoginDoc *loginDoc = [self.loginArray objectAtIndex:index];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF.login_CompanyID == %d",loginDoc.login_CompanyID];
    NSArray *array = [self.login_selected filteredArrayUsingPredicate:pre];
    if (array.count > 0){
        [self.login_selected removeObject:loginDoc];
        sender.selected = NO;
    }
    else{
        [self.login_selected addObject:loginDoc];
        sender.selected = YES;
    }
    if (self.login_selected.count == self.loginArray.count)
        stateButtonAll.selected = YES;
    else
        stateButtonAll.selected = NO;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    login_selected = [loginArray objectAtIndex:indexPath.section];
//    [self performSegueWithIdentifier:@"goChangePasswordViewFromChooseCompanyView" sender:self];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goChangePasswordViewFromChooseCompanyView"]) {
        ResetPasswordViewController *detailController = segue.destinationViewController;
        detailController.loginArray = login_selected;
        detailController.loginMobile = self.loginMobile;
    }
}


@end
