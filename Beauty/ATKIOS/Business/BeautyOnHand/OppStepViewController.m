//
//  OppStepViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-5-14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "OppStepViewController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "OppStepObject.h"
#import "ProductAndPriceDoc.h"
#import "DFTableCell.h"
#import "FooterView.h"
#import "UIAlertView+AddBlockCallBacks.h"

@interface OppStepViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) DFUITableView *oppStepTableView;
@end

@implementation OppStepViewController
@synthesize oppStepTableView;
@synthesize stepArray;
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColor_Background_View;
    
    OppStepObject *oppStepObj = [self.stepArray firstObject];
    [self.prodArray enumerateObjectsUsingBlock:^(ProductDoc *obj, NSUInteger idx, BOOL *stop) {
        obj.oppStep = oppStepObj;
    }];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"选择模板"];
    oppStepTableView = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    oppStepTableView.delegate = self;
    oppStepTableView.dataSource = self;
    
    if (IOS7 || IOS8) {
        oppStepTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        oppStepTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    [self.view addSubview:navigationView];
    [self.view addSubview:oppStepTableView];

    
    oppStepTableView.separatorColor = kColor_Background_View;
    oppStepTableView.separatorInset = UIEdgeInsetsMake(0, -40, 0, 30);
    
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"buttonLong_Confirm"]submitTitle:@"确定" submitAction:@selector(confirmAction)];
    [footerView showInTableView:oppStepTableView];

    
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    
}

#pragma mark 确定
- (void)confirmAction {
    if ([delegate respondsToSelector:@selector(oppStepVCDidFinishChooseOppStep)]) {
        [delegate oppStepVCDidFinishChooseOppStep];
//        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.prodArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *stepCell = @"stepCell";
    DFTableCell *cell = [tableView dequeueReusableCellWithIdentifier:stepCell];
    if (!cell) {
        cell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:stepCell];
        cell.textLabel.textColor = kColor_DarkBlue;
        cell.textLabel.font = kFont_Light_16;
        cell.detailTextLabel.textColor = kColor_Editable;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    ProductDoc *pro = [self.prodArray objectAtIndex:indexPath.row];
    
    __weak DFTableCell *weakCell = cell;
    cell.layoutBlock = ^{
        weakCell.textLabel.frame = CGRectMake(9.0f, 9.0f, 150.0f, 20.0f);
        weakCell.detailTextLabel.frame = CGRectMake(160.0f, 9.0f, 120.0f, 20.0f);

    };
    cell.textLabel.text = pro.pro_Name;
    cell.detailTextLabel.text = pro.oppStep.StepName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self productOfStepChoose:indexPath];
}

- (void)productOfStepChoose:(NSIndexPath *)index {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"选择模板" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
    for (OppStepObject *opp in self.stepArray) {
        [alert addButtonWithTitle:opp.StepName];
    }
    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            return ;
        } else {
            OppStepObject *opp = [self.stepArray objectAtIndex:(buttonIndex - 1)];
            ProductDoc *pro = [self.prodArray objectAtIndex:index.row];
            pro.oppStep = opp;
            [self.oppStepTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}
@end
