//
//  ShoppingCartViewController.m
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-15.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "CommodityDoc.h"
#import "ShoppingCartCell.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "OrderEditViewController.h"
#import "ProductAndPriceDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "PayDetail_ViewController.h"
#import "ProductInBranchDoc.h"

@interface ShoppingCartViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestCartListOperation;
@property (strong, nonatomic) UILabel *totalLabel;

@property (strong, nonatomic) NSMutableArray *commodityArray;
@property (strong, nonatomic) NSMutableArray *commodityArray_Selected;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property (strong, nonatomic) UITextField *textField_Selected;
@property (strong, nonatomic) UITableViewCell *cell_Selected;
@property (assign, nonatomic) CGFloat table_Height;
@property (assign, nonatomic) NSInteger productCount;
@property (assign, nonatomic) NSInteger flag;//判断选择器是否已弹起
//@property (nonatomic , retain) UIButton *stateButton;
@property (nonatomic ,strong) UIButton *payButton;
@property (nonatomic ,strong) UIButton *rightBtn;
@property (nonatomic ,assign) BOOL editShopCart;
@property (nonatomic, strong)UIButton *selectAllCommodityBt;

@end

@implementation ShoppingCartViewController
@synthesize commodityArray;
@synthesize commodityArray_Selected;
@synthesize totalLabel;
@synthesize pickerView, accessoryInputView;
@synthesize textField_Selected, cell_Selected;
@synthesize table_Height;
@synthesize productCount;
@synthesize flag;
//@synthesize stateButton;
@synthesize payButton;
@synthesize rightBtn;
@synthesize selectAllCommodityBt;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    flag = 0;
    
    _tableView.backgroundColor = kColor_White;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake(0,
                                   5,
                                  kSCREN_BOUNDS.size.width ,
                                  kSCREN_BOUNDS.size.height - 5.0f - kToolBar_Height - 5.0f - kNavigationBar_Height - 49 + 20);
    
    _tableView.separatorColor = kTableView_LineColor;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 5.0f - kToolBar_Height - 5.0f - kNavigationBar_Height - 20 , kSCREN_BOUNDS.size.width , 49.0f)];
    footView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:footView];
    //全选
    
    selectAllCommodityBt = [UIButton buttonWithTitle:@""
                                                       target:self
                                                     selector:@selector(selectAllAction:)
                                                        frame:CGRectMake(5.0f, 8.0f , 36.0f, 36.0f)
                                                backgroundImg:[UIImage imageNamed:@"icon_unSelected"]
                                             highlightedImage:nil];
    [selectAllCommodityBt setImage:[UIImage imageNamed:@"icon_Selected"] forState:UIControlStateSelected];
    //
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 40, 40)];
    label.textColor = [UIColor blackColor];
    label.font = kNormalFont_14;
    label.text = @"全选";
    [footView addSubview:label];
    
    payButton = [UIButton buttonWithTitle:@"结算(0)"
                                             target:self
                                           selector:@selector(gotoPayAction:)
                                              frame:CGRectMake(235.0f, (49.0f - 32.0f)/2 , 80, 33.0f)
                                      backgroundImg:nil
                                   highlightedImage:nil];
    payButton.backgroundColor = kColor_BtnBackground;
    payButton.layer.cornerRadius = 1;
    payButton.titleLabel.font = kNormalFont_14;
    
    [footView addSubview:selectAllCommodityBt];
    [footView addSubview:payButton];
    
    totalLabel = [UILabel initNormalLabelWithFrame:CGRectMake(95.0f, 10.0f, 130.0f, 32.0f) title:@"合计:"];
    totalLabel.textColor = [UIColor blackColor];//kColor_TitlePink;
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.font = kFont_Light_16;
    [footView addSubview:totalLabel];
    
    
    //  点击收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
}
- (void)tapClick{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = NO;
    [super viewWillAppear:animated];
    self.title = @"购物车";
    
    rightBtn  = [UIButton buttonWithTitle:@"编辑" target:self selector:@selector(editShopCatrAction:) frame:CGRectMake(kSCREN_BOUNDS.size.width - 60.0f, 10 , 40, 30) backgroundImg:nil  highlightedImage:nil];
    rightBtn.titleLabel.font = kFont_Medium_16;
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
 
    _editShopCart = NO;
    selectAllCommodityBt.selected = NO;
    [self changeEditState:0];
    
    [self getCartList];
}

//编辑购物车

-(void)editShopCatrAction:(UIButton *)sender
{
    _editShopCart = !_editShopCart;
    if (_editShopCart) {
        
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        
        payButton.backgroundColor = kMainPinkColor;
        [payButton setTitle:[NSString stringWithFormat:@"删除(%ld)",(long)commodityArray_Selected.count ]  forState:UIControlStateNormal];
        
        totalLabel.hidden = YES;
        
    }else
    {
        //改变按钮状态
        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        
        payButton.backgroundColor = kColor_BtnBackground;
        [payButton setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)commodityArray_Selected.count ]  forState:UIControlStateNormal];
        totalLabel.hidden = NO;
    }
}

-(void)changeEditState:(NSInteger )count
{
    if (_editShopCart) {
        
        payButton.backgroundColor = [UIColor colorWithRed:222/255. green:144/255. blue:148/255. alpha:1.];
        [payButton setTitle:[NSString stringWithFormat:@"删除(%ld)",(long)count ] forState:UIControlStateNormal];
        
    }else
    {
        [payButton setTitle:[NSString stringWithFormat:@"结算(%ld)",(long)count ] forState:UIControlStateNormal];
    }

}

-(void)addCommodityToArray
{
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (_requestCartListOperation && [_requestCartListOperation isExecuting]) {
        [_requestCartListOperation cancel];
        _requestCartListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initPickerView
{
    if (pickerView == nil) {
        pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [pickerView setShowsSelectionIndicator:YES];
        [pickerView sizeThatFits:CGSizeZero];
        pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        pickerView.delegate = self;
        pickerView.dataSource = self;
    }
}

- (void)initInputAccessoryView
{
    if (accessoryInputView == nil) {
        accessoryInputView  = [[UIToolbar alloc] init];
        accessoryInputView.barStyle = UIBarStyleBlackTranslucent;
        accessoryInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [accessoryInputView sizeToFit];
        CGRect frame1 = accessoryInputView.frame;
        frame1.size.height = 44.0f;
        accessoryInputView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        [doneBtn setTintColor:[UIColor whiteColor]];
        UIBarButtonItem *cancelBtu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissKeyBoard)];
        [cancelBtu setTintColor:[UIColor whiteColor]];

        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, cancelBtu, doneBtn, nil];
        [accessoryInputView setItems:array];
    }
}

- (void)done
{
    flag = 0;
    
    NSIndexPath *indexPath = [self indexPathForCell:cell_Selected];
    
    if (productCount == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否将该商品从购物车中删除？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                
                CommodityDoc *commodity = [[[commodityArray objectAtIndex:indexPath.section] commodityDocArray] objectAtIndex:indexPath.row];
                
                if ([commodityArray_Selected containsObject:commodity])
                    [commodityArray_Selected removeObject:commodity];
                NSInteger selectCount = 0;
                NSInteger avaibleCount = 0;
                for (ProductInBranchDoc *branch in commodityArray) {
                    BOOL allContained = YES;
                    branch.isAvaible = NO;
                    for (int i = 0; i < [branch commodityDocArray].count ; i++){
                        CommodityDoc *obj = [[branch commodityDocArray] objectAtIndex:i];
                        if (obj.comm_BranchID == commodity.comm_BranchID && commodity.comm_Code == obj.comm_Code){
                            [[branch commodityDocArray] removeObject:obj];
                            i --;
                        }
                        if (obj.comm_Available && (commodity.comm_Code != obj.comm_Code || commodity.comm_BranchID != obj.comm_BranchID))
                            branch.isAvaible = YES;
                        if (obj.comm_Available && obj.status == 0 && (commodity.comm_Code != obj.comm_Code || commodity.comm_BranchID != obj.comm_BranchID))
                            allContained = NO;
                    }
                    if (branch.isAvaible){
                        avaibleCount ++;
                        selectCount = allContained ? ++selectCount : selectCount;
                    }
                    
                    unsigned long i = [commodityArray indexOfObject:branch];
                    UIButton *button = (UIButton *)[[[_tableView headerViewForSection:i] subviews] objectAtIndex:4];
                    if (button) {
                        if (branch.isAvaible && allContained)
                            branch.select = button.selected = YES;
                        if (![[commodityArray objectAtIndex:i] isAvaible])
                            [button setHidden:YES];
                    }
                }
                if (avaibleCount > 0 && selectCount == avaibleCount)
                    selectAllCommodityBt.selected = YES;
                else
                    selectAllCommodityBt.selected = NO;
                
                //selectAllCommodityBt.hidden =  avaibleCount == 0 ? YES : NO;
                
                NSArray *array = @[commodity.cart_ID];
                [self deleteCaretListWithCartId:array clearSelected:NO];
            }
        }];
    }else {
        [self updateCaretListWithCommodity:[[[commodityArray objectAtIndex:indexPath.section] commodityDocArray] objectAtIndex:indexPath.row] andPrountCount:productCount];
    }
    [self dismissKeyBoard];
}

- (void)dismissKeyBoard
{
    accessoryInputView = nil;
    [textField_Selected resignFirstResponder];
}

- (void)editedTextField:(UITextField *)textField cell:(UITableViewCell *)cell
{
    textField_Selected = textField;
    cell_Selected = cell;
}

- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell
{
    return [_tableView indexPathForCell:cell];
}

- (void)setCustomKeyboardWithSection:(NSInteger)type textField:(UITextField *)textField selectedText:(NSString *)selectedText
{
    [self initPickerView];
    [self initInputAccessoryView];
    NSInteger selectCount = selectedText.integerValue;
    NSInteger thousand = selectCount / 1000;
    NSInteger hundred = (selectCount - thousand * 1000) / 100;
    NSInteger ten = (selectCount - thousand * 1000 - hundred * 100) / 10;
    NSInteger one = selectCount - thousand * 1000 - hundred * 100 - ten * 10;
    [pickerView selectRow: thousand inComponent:0 animated:NO];
    [pickerView selectRow: hundred inComponent:1 animated:NO];
    [pickerView selectRow: ten inComponent:2 animated:NO];
    [pickerView selectRow: one inComponent:3 animated:NO];
    textField.inputAccessoryView = accessoryInputView;
    textField.inputView = pickerView;
    productCount = selectCount;
}

#pragma mark - button

- (void)selectAllAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    
    if (button.selected) {
        [commodityArray_Selected removeAllObjects];
        for (int i = 0; i < commodityArray.count; i ++) {
            for (CommodityDoc *doc in [[commodityArray objectAtIndex:i] commodityDocArray]) {
                if(doc.comm_Available)
                    [commodityArray_Selected addObject:doc];
            }
            if ([[commodityArray objectAtIndex:i] isAvaible]){
                UIButton *button =  (UIButton *)[[[_tableView headerViewForSection:i] subviews] objectAtIndex:4];
                button.selected = YES;
                ProductInBranchDoc *product = [commodityArray objectAtIndex:i];
                product.select = YES;
            }
        }
        
        //commodityArray_Selected = [commodityArray mutableCopy];
        for (CommodityDoc *commodityDoc in commodityArray_Selected) {
            commodityDoc.status = 1;
        }
        [self changeQuantityWithShoppingCartCell:Nil];
        [_tableView reloadData];
    } else {
        [commodityArray_Selected removeAllObjects];
        for (int i = 0; i < commodityArray.count; i ++) {
            for (CommodityDoc *commodityDoc in [[commodityArray objectAtIndex:i] commodityDocArray]) {
                if(commodityDoc.comm_Available)
                    commodityDoc.status = 0;
            }
            if ([[commodityArray objectAtIndex:i] isAvaible]){
                UIButton *button =  (UIButton *)[[[_tableView headerViewForSection:i] subviews] objectAtIndex:4];
                button.selected = NO;
                ProductInBranchDoc *product = [commodityArray objectAtIndex:i];
                product.select = NO;
            }
        }
        self.totalLabel.text = [NSString stringWithFormat:@"合计 %@%.2f", CUS_CURRENCYTOKEN,0.00f];
        [_tableView reloadData];
    }
    // 删除/结算
    [self changeEditState:commodityArray_Selected.count];
}

- (void)gotoPayAction:(UIButton *)sender
{
    if (_editShopCart) {

        [self deleteAction];

        
    }else{
        if (commodityArray_Selected.count != 0) {

            NSMutableArray * arr = [[NSMutableArray alloc] init];
        
            for (CommodityDoc * doc in commodityArray_Selected) {
                
                [arr addObject:doc.cart_ID];
            }
            self.hidesBottomBarWhenPushed  =YES;
            PayDetail_ViewController * pay = [[PayDetail_ViewController alloc] init];
            pay.cartIdArr = arr ;
            [self.navigationController pushViewController:pay animated:YES];
            self.hidesBottomBarWhenPushed  =NO;

        } else {
            [SVProgressHUD showErrorWithStatus2:@"请选择需要购买的商品"];
        }
    }
}

-(void)deleteAction
{
    if (commodityArray_Selected.count != 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否将该商品从购物车中删除？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSMutableArray *array = [NSMutableArray array];
                
                for (CommodityDoc *commodity in commodityArray_Selected) {
                    [array addObject:commodity.cart_ID];
                }
                [self deleteCaretListWithCartId:array clearSelected:YES];
            }
        }];
    } else {
        [SVProgressHUD showErrorWithStatus2:@"请选择需要删除的商品"];
    }
}

#pragma mark - UIPickerViewDelegage && UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [UILabel initNormalLabelWithFrame:view.bounds title:[NSString stringWithFormat:@"%ld",(long)row]];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20.0f];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSIndexPath *indexPath = [self indexPathForCell:cell_Selected];
    if (flag == 0) {
        productCount = [[[[commodityArray objectAtIndex:indexPath.section] commodityDocArray] objectAtIndex:indexPath.row] comm_Quantity];
        flag = 1;
    }
    NSInteger thousand = productCount / 1000;
    NSInteger hundred = (productCount - thousand * 1000) / 100;
    NSInteger ten = (productCount - thousand * 1000 - hundred * 100) / 10;
    NSInteger one = productCount - thousand * 1000 - hundred * 100 - ten * 10;
    if (component == 0) {
        thousand = row ;
    }
    if (component == 1) {
        hundred =  row;
    }
    if (component == 2) {
        ten =  row;
    }
    if (component == 3) {
        one = row;
    }
    productCount = (thousand*1000 + hundred*100 + ten*10 + one);
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [commodityArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[commodityArray objectAtIndex:section] commodityDocArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"ShoppingCartCell";
    __autoreleasing ShoppingCartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[ShoppingCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.delegate = self;
    cell.shoppingCartViewController = self;
    [cell updateData:[[[commodityArray objectAtIndex:indexPath.section] commodityDocArray] objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width - 20, 5.5)];
    view.contentView.backgroundColor = kDefaultBackgroundColor;
    UIView *lineButtom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width - 10, .5)];
    lineButtom.backgroundColor = kTableView_LineColor;
    [view addSubview:lineButtom];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width - 20, kTableView_DefaultCellHeight)];
    view.backgroundColor = kDefaultBackgroundColor;
    
    view.backgroundColor = [UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1.];
    UIView *lineButtom = [[UIView alloc] initWithFrame:CGRectMake(0, kTableView_DefaultCellHeight - 1, kSCREN_BOUNDS.size.width - 10, .5)];
    lineButtom.backgroundColor = kTableView_LineColor;
    [view addSubview:lineButtom];
    
    UIView *lineTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width - 10, .5)];
    lineTop.backgroundColor = kTableView_LineColor;
    [view addSubview:lineTop];
    
    //if (IOS7 || IOS8)
    view.contentView.backgroundColor = kDefaultBackgroundColor;
    
    UIButton *button = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(selectSectionAction:)
                                           frame:CGRectMake(0, 0, kTableView_DefaultCellHeight, kTableView_DefaultCellHeight)
                                   backgroundImg:nil
                                highlightedImage:nil];
    
    [button setImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_Selected"] forState:UIControlStateSelected];

    button.tag = section * 1000;
    button.hidden = YES;
    [view addSubview:button];
    
    if ([[commodityArray objectAtIndex:section] isAvaible]){
        [button setSelected:[[commodityArray objectAtIndex:section] select]];
        button.hidden = NO;
    }
    
    UILabel *branchNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 240, 20)];
    branchNameLabel.text = [[commodityArray objectAtIndex:section] branchName];
    branchNameLabel.textColor = kColor_Black;
    branchNameLabel.font = kNormalFont_14;
    [view addSubview:branchNameLabel];
    
    return view;
}


- (void)selectSectionAction:(UIButton *)sender
{
    NSInteger section = sender.tag / 1000;
    
    if (sender.selected){
        ProductInBranchDoc *product = [commodityArray objectAtIndex:section];
        sender.selected = product.select = NO;
        for (CommodityDoc *comm in [[commodityArray objectAtIndex:section] commodityDocArray]) {
            if([commodityArray_Selected containsObject:comm]){
                [commodityArray_Selected removeObject:comm];
                NSInteger row = [[[commodityArray objectAtIndex:section] commodityDocArray] indexOfObject:comm];
                UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                UIButton *button = (UIButton *)[cell viewWithTag:10001];
                button.selected = NO;
                comm.status = 0;
            }
        }
    }else{
        ProductInBranchDoc *product = [commodityArray objectAtIndex:section];
        sender.selected = product.select = YES;
        for (CommodityDoc *comm in [[commodityArray objectAtIndex:section] commodityDocArray]) {
            if(comm.comm_Available && ![commodityArray_Selected containsObject:comm]){
                [commodityArray_Selected addObject:comm];
                NSInteger row = [[[commodityArray objectAtIndex:section] commodityDocArray] indexOfObject:comm];
                UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                UIButton *button = (UIButton *)[cell viewWithTag:10001];
                button.selected = YES;
                comm.status = 1;
            }
        }
    }
    
    
    BOOL isAllSelected = YES;
    for (ProductInBranchDoc *productInBranch in commodityArray){
        if (productInBranch.isAvaible){
            if (productInBranch.select)
                isAllSelected = YES;
            else{
                isAllSelected = NO;
                break;
            }
        }
    }
    
    if (isAllSelected)
        selectAllCommodityBt.selected = YES;
    else
        selectAllCommodityBt.selected = NO;
    
    CGFloat total = 0.0f;
    for (CommodityDoc *comm in commodityArray_Selected) {
        total += comm.comm_PromotionPrice * comm.comm_Quantity;
    }
    //刷新全选按钮和下面合计和计算或者删除的按钮
    totalLabel.text = [NSString stringWithFormat:@"合计 %@%.2f",CUS_CURRENCYTOKEN ,total];
    [self changeEditState:commodityArray_Selected.count];
}


#pragma mark - ShoppingCartCellDelegate

- (void)changeQuantityWithShoppingCartCell:(ShoppingCartCell *)cell
{
    if (commodityArray_Selected == nil){
        commodityArray_Selected = [NSMutableArray array];
    }
    
    
    if (cell != nil) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        CommodityDoc *theCommodity = [[[commodityArray objectAtIndex:indexPath.section] commodityDocArray] objectAtIndex:indexPath.row];
        
        if (![commodityArray_Selected containsObject:theCommodity]){
            theCommodity.status = 1;
            [commodityArray_Selected addObject:theCommodity];
        }else{
            theCommodity.status = 0;
            [commodityArray_Selected removeObject:theCommodity];
        }
        NSInteger allCount = 0;
        for (int i = 0 ; i < commodityArray.count ; i ++){
            BOOL allContained = YES;
            for(CommodityDoc *doc in [[commodityArray objectAtIndex:i] commodityDocArray]){
                if(doc.comm_Available)
                    allCount ++ ;
                
                if (![commodityArray_Selected containsObject:doc] && doc.comm_Available)
                    allContained = NO;
            }
            if ([[commodityArray objectAtIndex:i] isAvaible]){
                UIButton *button = (UIButton *)[[[_tableView headerViewForSection:i] subviews] objectAtIndex:4];
                button.selected = allContained;
                ProductInBranchDoc *product = [commodityArray objectAtIndex:i];
                product.select = allContained;
            }
        }
        if (cell.stateButton.selected){
            if (commodityArray_Selected.count == allCount)
                [selectAllCommodityBt setSelected:YES];
        }else{
            [selectAllCommodityBt setSelected:NO];

        }
        
        if (commodityArray_Selected.count == allCount){
            
            selectAllCommodityBt.selected = YES;
        }else{
        
        selectAllCommodityBt.selected = NO;
        }
        // 删除/结算
        [self changeEditState:commodityArray_Selected.count];
    }
    
    
    
    CGFloat total = 0.0f;
    for (CommodityDoc *comm in commodityArray_Selected) {
        total += comm.comm_PromotionPrice * comm.comm_Quantity;
    }
    

    totalLabel.text = [NSString stringWithFormat:@"合计 %@%.2f",CUS_CURRENCYTOKEN ,total];
}

- (void)whenQuantityOfEmptyWithShoppingCartCell:(ShoppingCartCell *)cell
{
    NSIndexPath  *indexPath = [_tableView indexPathForCell:cell];
    CommodityDoc *theCommodity = [[[commodityArray objectAtIndex:indexPath.section] commodityDocArray] objectAtIndex:indexPath.row];
    for (ProductInBranchDoc *branch in commodityArray){
        if ([[branch commodityDocArray] containsObject:theCommodity])
            [[branch commodityDocArray] removeObject:theCommodity];
        else if ([commodityArray_Selected containsObject:theCommodity])
            [commodityArray_Selected removeObject:theCommodity];
    }
    
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - 接口


- (void)getCartList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestCartListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Cart/GetCartList"  showErrorMsg:YES  parameters:nil WithSuccess:^(id json) {
        _tableView.userInteractionEnabled = NO;
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (commodityArray){
                [commodityArray removeAllObjects];
            }else{
                commodityArray = [NSMutableArray array];
            }
            
            if (commodityArray_Selected){
                [commodityArray_Selected removeAllObjects];
                
            }else{
                commodityArray_Selected = [NSMutableArray array];
                
            }
            
            NSMutableArray *array_selected = [NSMutableArray array];
            
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                ProductInBranchDoc *productInBranch = [[ProductInBranchDoc alloc] init];
                
                for (NSDictionary * CartDetailDic in [obj objectForKey:@"CartDetailList"]) {
                  
                    CommodityDoc *com = [[CommodityDoc alloc] init];

                    [com setComm_BranchID:[[obj objectForKey:@"BranchID"]integerValue]];
                    [com setComm_BranchName:[obj objectForKey:@"BranchName"]];
                    [com setCart_ID:[CartDetailDic objectForKey:@"CartID"]];
                    [com setComm_Thumbnail:[CartDetailDic objectForKey:@"ImageURL"]];
                    [com setComm_Code:[[CartDetailDic objectForKey:@"ProductCode"] longLongValue]];
                    [com setComm_CommodityName:[CartDetailDic objectForKey:@"ProductName"]];
                    [com setComm_Quantity:[[CartDetailDic objectForKey:@"Quantity"] integerValue]];
                    [com setComm_UnitPrice:[[CartDetailDic objectForKey:@"UnitPrice"] doubleValue]];
                    [com setComm_Type:[[CartDetailDic objectForKey:@"ProductType"] integerValue]];
                    [com setComm_Available:[[CartDetailDic objectForKey:@"Available"] boolValue]];
                    [com setStatus:0];
                    
                    //,,,,,k,m
                    if (com.comm_MarketingPolicy == 0) {
                        com.comm_PromotionPrice = com.comm_UnitPrice;
                    } else if (com.comm_MarketingPolicy == 1) {
                        [com setComm_PromotionPrice:[obj[@"PromotionPrice"] doubleValue]];
                    } else {
                        [com setComm_PromotionPrice:[obj[@"PromotionPrice"] doubleValue]];
                    }
                    
                    [com setComm_DiscountMoney:[com retDiscountMoney]];
                    [com setComm_TotalMoney:[com retTotalMoney]];
                    [com setComm_isShowDiscountMoney:[com retDiscountMoney] != [com retTotalMoney]];
                    
                    [productInBranch.commodityDocArray addObject:com];
                }
               
                [productInBranch setBranchId:[[obj objectForKey:@"BranchID"]integerValue]];
                [productInBranch setBranchName:[obj objectForKey:@"BranchName"]];
                [commodityArray addObject:productInBranch];
            }];
            
            //处理已经选择的商品
            NSInteger selectCount = 0;
            NSInteger avaibleCount = 0;
            for (ProductInBranchDoc *obj in commodityArray) {
                BOOL isAllContained = commodityArray_Selected.count > 0 ? YES : NO;
                obj.isAvaible = NO;
                for (CommodityDoc *comm in [obj commodityDocArray]) {
                    for (CommodityDoc *com in commodityArray_Selected) {
                        if (comm.comm_Available && com.comm_Code == comm.comm_Code && comm.comm_BranchID == com.comm_BranchID){
                            comm.comm_Quantity = com.comm_Quantity;
                            [array_selected addObject:comm];
                            comm.status = YES;
                        }
                    }
                    if (comm.comm_Available && !comm.status)
                        isAllContained = NO;
                    if (comm.comm_Available)
                        obj.isAvaible = YES;
                }
                if (obj.isAvaible)
                    ++ avaibleCount;
                
                selectCount = isAllContained ? selectCount + 1 : selectCount;
                [obj setSelect:isAllContained];
            }
            selectAllCommodityBt.selected = NO;
            //if (avaibleCount > 0 && selectCount == avaibleCount)
              //  selectAllCommodityBt.selected = YES;
            //if (avaibleCount == 0)
               // selectAllCommodityBt.hidden = YES;


            commodityArray_Selected = array_selected;
            
            [self changeQuantityWithShoppingCartCell:nil];
            
            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        _tableView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        
    }];
}



- (void)updateCaretListWithCommodity:(CommodityDoc *)commodity andPrountCount:(NSInteger)newCount
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary *para = @{
                           @"CartID":commodity.cart_ID,
                           @"Quantity":@(newCount),
                           };
    
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/Cart/UpdateCart"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
           
            NSIndexPath *indexPath = [self indexPathForCell:cell_Selected];
            CommodityDoc *comm = [[[commodityArray objectAtIndex:indexPath.section] commodityDocArray]objectAtIndex:indexPath.row];
            [comm setComm_Quantity:productCount];
            [comm setComm_DiscountMoney:[comm retDiscountMoney]];
            [comm setComm_TotalMoney:[comm retTotalMoney]];
            [textField_Selected setText:[NSString stringWithFormat:@"%ld",(long)productCount]];
            CGFloat total = 0.0f;
            for (CommodityDoc *comm in commodityArray_Selected) {
                total += comm.comm_PromotionPrice * comm.comm_Quantity;
            }
            totalLabel.text = [NSString stringWithFormat:@"合计 %@%.2f", CUS_CURRENCYTOKEN ,total];
            [_tableView reloadData];
            [SVProgressHUD showSuccessWithStatus2:message];
        } failure:^(NSInteger code, NSString *error) {
            if (code == 2) { 
                [SVProgressHUD showErrorWithStatus2:error];
            }
        }];
        
    } failure:^(NSError *error) {
        
    }];
   
}


- (void)deleteCaretListWithCartId:(NSArray *)cartIdList clearSelected:(BOOL)clear
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary *para = @{@"CartIDList":cartIdList};
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/Cart/DeleteCart"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSInteger avaibleCount = 0;
            for (int i = 0; i < commodityArray.count; ++ i ) {
                //修改数量到0删除，则不改变其他的选择状态，点击删除则去除所有的修改状态
                if (clear)
                    [[[commodityArray objectAtIndex:i] commodityDocArray] removeObjectsInArray:commodityArray_Selected];
                if([[commodityArray objectAtIndex:i] commodityDocArray].count == 0){
                    [commodityArray removeObjectAtIndex:i]; //直接删除比较危险，以后应该改进为将其标记出来，循环完成后，再统一删除
                    -- i;
                }
                
                //将所有门店的勾选全部取消，如果门店下商品全部失效，要去除旁边的勾选按钮
                if (i < commodityArray.count){
                    [[commodityArray objectAtIndex:i] setIsAvaible:NO];
                    for (CommodityDoc *obj in [[commodityArray objectAtIndex:i] commodityDocArray]) {
                        if (obj.comm_Available){
                            [[commodityArray objectAtIndex:i] setIsAvaible:YES];
                            break;
                        }
                    }
                }
                if (i < commodityArray.count &&[[commodityArray objectAtIndex:i] isAvaible])
                    ++ avaibleCount;
                UIButton *button = (UIButton *)[[[_tableView headerViewForSection:i] subviews] objectAtIndex:4];
                if (button) {
                    if (clear)
                        button.selected = NO;
                    if (![[commodityArray objectAtIndex:i] isAvaible])
                        [button setHidden:YES];
                }
            }
            if (clear){
                //selectAllCommodityBt.hidden = avaibleCount == 0 ? YES : NO;
                selectAllCommodityBt.selected = NO;
                [commodityArray_Selected removeAllObjects];
            }
            CGFloat total = 0.f;
            for (CommodityDoc *obj in commodityArray_Selected) {
                total += obj.comm_PromotionPrice * obj.comm_Quantity;
            }
            [self.totalLabel setText:[NSString stringWithFormat:@"合计 %@%.2f",CUS_CURRENCYTOKEN,total]];
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self changeEditState:commodityArray_Selected.count];
        [SVProgressHUD showSuccessWithStatus2:@"删除成功！"];
      


    } failure:^(NSError *error) {
        
    }];
}

@end
