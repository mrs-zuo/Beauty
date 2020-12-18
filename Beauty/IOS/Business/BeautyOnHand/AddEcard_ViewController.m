//
//  AddEcard_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/6/26.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AddEcard_ViewController.h"
#import "NavigationView.h"
#import "GPBHTTPClient.h"
#import "AccountCellTableViewCell.h"
#import "NormalEditCell.h"
#import "CustomerDoc.h"
#import "AppDelegate.h"
#import "FooterView.h"
#import "UserDoc.h"
#import "UIPlaceHolderTextView.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "UILabel+InitLabel.h"
#import "DFDateView.h"
#import "EcardInfo.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, COUNSELORTYPE) {
    COUNSELORPERSON = 0,
    COUNSELORSLAVE = 1
};
@interface AddEcard_ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,SelectCustomersViewControllerDelegate>

@property(nonatomic,strong)UITableView * addCardTableView;
@property(nonatomic,strong)NSMutableDictionary * cardTypeMDic;
@property (nonatomic,strong)NSMutableArray * accountGradeMArr;
@property (strong, nonatomic) CustomerDoc *customer_Selected;
@property (strong, nonatomic) UserDoc *userDoc;
@property (weak, nonatomic) AFHTTPRequestOperation *getAllLevelOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestLevelChangeOperation;
@property (nonatomic, weak) AFHTTPRequestOperation *ecardInfo;
@property (nonatomic,weak) AFHTTPRequestOperation * addNewCardOPeration;
@property (strong, nonatomic) NSArray *ecardInfoArray;
@property (strong, nonatomic) NSString *cardRemark;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (nonatomic ,strong) NSString * dateForEndStr;
@property (nonatomic ,strong) NSString * dateForStartStr;
@property (nonatomic, assign) NSInteger levelId;
@property (nonatomic, strong) NSArray *DiscountListArr;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property (strong, nonatomic) UITextField *textField_Selected;
@property (assign, nonatomic) CGFloat table_Height;
@property (nonatomic, assign) NSInteger textFieldY;
@property (strong, nonatomic) NSString *levelChange;
@property (nonatomic, assign) COUNSELORTYPE type;
@property (nonatomic, strong) NSMutableArray *slaveArray;
@property (nonatomic ,strong) UIButton *isDefaultButton;
@property (nonatomic,strong) NSString * inputCard;
@end

@implementation AddEcard_ViewController
@synthesize addCardTableView;
@synthesize accountGradeMArr,DiscountListArr;
@synthesize customer_Selected,userDoc,cardRemark;
@synthesize levelId,table_Height,levelChange;
@synthesize  accessoryInputView,pickerView,textField_Selected;
@synthesize ecardInfo,textFieldY,ecardInfoArray;
@synthesize isDefaultButton,inputCard;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initTableView];
    [self initPickerView];
    [self initInputAccessoryView];
    [self initdata];
    [self requestGetAllLevel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
    
}

- (void)keyboardDidShown:(NSNotification *)obj
{
    //    NSLog(@"keyboardDidShown:");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

-(void)initdata
{
    inputCard = @"";
    _dateForEndStr = @"2099-12-31" ;
    
    NSDate * date = [NSDate date];
    NSDateFormatter * matter = [[NSDateFormatter alloc] init];
    [matter setDateFormat:@"yyyy-MM-dd"];
    _dateForStartStr = [matter stringFromDate:date];
    
    userDoc = [[UserDoc alloc] init];
    userDoc.user_Id = ACC_ACCOUNTID;
    userDoc.user_Name = ACC_ACCOUNTName;
    userDoc.user_SelectedState = YES;
    self.slaveArray = [NSMutableArray arrayWithObject:userDoc];
}
#pragma mark - init
-(void)initTableView
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"账户"];
    [self.view addSubview:navigationView];
    
    addCardTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f)style:UITableViewStyleGrouped];
    addCardTableView.allowsSelection = YES;
    addCardTableView.showsHorizontalScrollIndicator = NO;
    addCardTableView.showsVerticalScrollIndicator = NO;
    addCardTableView.backgroundColor = [UIColor clearColor];
    addCardTableView.separatorColor = kTableView_LineColor;
    addCardTableView.autoresizingMask = UIViewAutoresizingNone;
    addCardTableView.delegate = self;
    addCardTableView.dataSource = self;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        addCardTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        addCardTableView.sectionFooterHeight = 0;
        addCardTableView.sectionHeaderHeight = 10;
    }
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [addCardTableView setTableFooterView:view];
    [self.view addSubview:addCardTableView];
    
    if ((IOS7 || IOS8)) {
        addCardTableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
        addCardTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        addCardTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f  - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定"submitAction:@selector(addNewCardRequest)];
    [footerView showInTableView:addCardTableView];
    
     table_Height = addCardTableView.frame.size.height;
      _initialTVHeight = addCardTableView.frame.size.height;
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
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
        [doneBtn setTintColor:kColor_White];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [accessoryInputView setItems:array];
    }
}

- (void)done
{
    [self dismissKeyBoard];
}
- (void)dismissKeyBoard
{
    [self.view endEditing:YES];
    [self restoreHeightOfTableView];
    
}
//恢复tableView的高度
- (void)restoreHeightOfTableView
{
    if (addCardTableView.frame.size.height != table_Height) {
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        CGRect tableFrame = addCardTableView.frame;
        tableFrame.size.height =  table_Height;
        addCardTableView.frame = tableFrame;
        [UIView commitAnimations];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 200)
    {
        textFieldY = textField.frame.origin.y + textField.frame.size.height + 20;
        textField_Selected = textField;
    }else if (textField.tag ==201)
    {
        textFieldY = textField.frame.origin.y + textField.frame.size.height + 20;
        textField_Selected = textField;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 201) {
        inputCard = [NSString stringWithFormat:@"%@",textField.text];
         NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:1];
         [addCardTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    }else
    {
        NSInteger row = [pickerView selectedRowInComponent:0];
        if (ecardInfoArray.count == 0) {
            return;
        }
        levelChange =[[ecardInfoArray objectAtIndex:row] objectForKey:@"CardName"];
        
        levelId = [[[ecardInfoArray objectAtIndex:row] objectForKey:@"CardID"] integerValue];
        DiscountListArr = nil;
        DiscountListArr = [[ecardInfoArray objectAtIndex:row] objectForKey:@"DiscountList"];
        cardRemark = [[ecardInfoArray objectAtIndex:row] objectForKey:@"CardDescription"];
        _dateForEndStr = [[ecardInfoArray objectAtIndex:row] objectForKey:@"CardExpiredDate"];
        [addCardTableView reloadData];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
//add begin by zhangwei map GPB-918
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    if([textField text])
    {
        if(textField.text.length > 16)
            textField.text = [NSString stringWithString:[textField.text substringToIndex:16]];
    }
}

//add end by zhangwei map GPB-918
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    if(textField.text.length >= 16)
        return NO;
    
    return YES;
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath* path = [addCardTableView indexPathForCell:cell];
    
    [addCardTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UIPickerDelegate && UIPickerDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [ecardInfoArray count];
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"ecar =%@",ecardInfoArray);
    return [[ecardInfoArray objectAtIndex:row] objectForKey:@"CardName"];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300.0f;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _dateForEndStr = @"2099-12-31" ;
    NSDate * date = [NSDate date];
    NSDateFormatter * matter = [[NSDateFormatter alloc] init];
    [matter setDateFormat:@"yyyy-MM-dd"];
    _dateForStartStr = [matter stringFromDate:date];

}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }else if (section == 1) {
        return 5;
    }else if(section == 2)
    {
        if (DiscountListArr.count >0) {
            return DiscountListArr.count+1;
        }else return 0;
        
    }
    return 2;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return cardRemark.length>0?4:3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"NormalEditCell_NotEditing";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueText.userInteractionEnabled = NO;
    }
    cell.valueText.textColor = [UIColor blackColor];
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
            {
                CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
                cell.titleLabel.text = @"顾客";
                cell.valueText.text = customer.cus_Name;
            }
                return cell;
                break;
            case 1:
                cell.titleLabel.text = @"美丽顾问";
                cell.valueText.text = (userDoc.user_Name.length <= 0 ? @"请选择美丽顾问  " : userDoc.user_Name);
                cell.valueText.frame = CGRectMake(100.0f, kTableView_HeightOfRow/2 - 30.0f/2, 180, 30.0f);
                 [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                return cell;
                break;
        }
    }else if (indexPath.section==1)
    {
       cell.valueText.tag = 200 + indexPath.row;
        switch (indexPath.row) {
            case 0:
                cell.valueText.userInteractionEnabled = YES;
                [cell.valueText setInputView:pickerView];
                [cell.valueText setInputAccessoryView:accessoryInputView];
#pragma mark 权限
//                if (![[PermissionDoc sharePermission] rule_CustomerLevel_Write]) {
//                    cell.valueText.textColor = kColor_Black;
//                    cell.valueText.userInteractionEnabled = NO;
//                }
                cell.titleLabel.text = @"e账户";
                if (!(levelId > 0)){
                    cell.valueText.placeholder = @"请选择e账户";
                }
                cell.valueText.text = levelChange;
                cell.valueText.textColor =kColor_Editable;
                cell.valueText.delegate = self;

                return cell;
                break;
            case 1:
                cell.valueText.userInteractionEnabled = YES ;
                cell.titleLabel.text = @"实体卡号";
                cell.valueText.placeholder = @"请输入实体卡号";
                cell.valueText.tag = 201;
                cell.valueText.delegate = self;
                cell.valueText.text = inputCard;
                cell.valueText.returnKeyType = UIReturnKeyDefault;
            break;
            case 2:
                cell.titleLabel.text = @"开卡日期";
                cell.valueText.text = _dateForStartStr;
                cell.valueText.textColor =[UIColor blackColor];
                return cell;
                break;
            case 3:
                cell.titleLabel.text = @"有效期";
                cell.valueText.text = _dateForEndStr;
                cell.valueText.textColor = [UIColor blackColor];
                return cell;
                break;
            case 4:
                cell.titleLabel.text = @"默认卡";
                cell.valueText.text = @"";
                [cell.valueText removeFromSuperview];
                isDefaultButton = [[UIButton alloc] initWithFrame:CGRectMake(270.0f, kTableView_HeightOfRow/2 - 30.0f/2, 30, 30.0f) ];
                [isDefaultButton setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
                [isDefaultButton setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
                [isDefaultButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:isDefaultButton];
                if (self.cardNumber == 0) {
                    isDefaultButton.userInteractionEnabled = NO;
                    isDefaultButton.selected = YES;
                }
                return cell;
                break;
                
            default:
                break;
        }
    }else if(indexPath.section == 2)
    {
        if (indexPath.row==0) {
            cell.titleLabel.text = @"账户等级";
            cell.valueText.text = @"" ;
            cell.valueText.enabled = NO;
            return cell;
        }else{
            cell.titleLabel.text =[NSString stringWithFormat:@"        %@",[[DiscountListArr objectAtIndex:indexPath.row -1] objectForKey:@"DiscountName"]];
            cell.valueText.text = [NSString stringWithFormat:@"%.2f", [[[DiscountListArr objectAtIndex:indexPath.row-1] objectForKey:@"Discount"]doubleValue]];
            return cell;
        }
    }else
    {
        
        NSString *myCell = @"RechargeEditCell1";
        UITableViewCell *cellDefault = [tableView dequeueReusableCellWithIdentifier:myCell];
        if (cellDefault == nil){
            cellDefault = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
            cellDefault.selectionStyle = UITableViewCellSelectionStyleNone;
            cellDefault.accessoryType = UITableViewCellAccessoryNone;
            cellDefault.selected = NO;
        }else
        {
            while ([cellDefault.contentView.subviews lastObject] != nil) {
                [(UIView*)[cellDefault.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
            }
        }
        switch (indexPath.row) {
            case 0:{
                UILabel * lableName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
                lableName.text =@"描述";
                lableName.textColor = kColor_DarkBlue ;
                lableName.font = kFont_Medium_16 ;
                [cellDefault.contentView addSubview:lableName];
                return cellDefault;
            }
                break;
            case 1:
            {
                NSInteger height = [cardRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                UITextView *record = [[UITextView alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 2, ((IOS6) ? 310.f : 300.f), height <= 38 ? 34: height)];
                record.font = kFont_Light_16;
                record.scrollEnabled = NO;
                record.editable = NO;
                record.text = cardRemark;
                record.backgroundColor = [UIColor clearColor];
                [cellDefault.contentView addSubview:record];
                return cellDefault;
            }
                break;
            default:
                break;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==3 &&indexPath.row==1) {
         NSInteger height = [cardRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
        return height;
    }
    return kTableView_HeightOfRow;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if(indexPath.section ==0)
//    {
//        self.type = COUNSELORPERSON;
//        [self chosePersion:COUNSELORPERSON];
//    }
//     if (indexPath.section ==1 && indexPath.row == 3)
//    {
//        [self dateSelector:indexPath];
//    }
//    
//    if (indexPath.section ==1 && indexPath.row ==3) {
//        [self dateSelector:indexPath];
//    }
}

-(void)select:(UIButton *)sender{
    if (isDefaultButton.selected) {
        isDefaultButton.selected = NO;
    }else
    {
        isDefaultButton.selected = YES;
    }
}

- (void)chosePersion:(COUNSELORTYPE)choseType
{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectCustomer setSelectModel:self.type userType: (choseType == COUNSELORPERSON) ? 3 : 1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:(self.type == COUNSELORPERSON ? @[userDoc]:self.slaveArray)];
    selectCustomer.navigationTitle = (choseType == COUNSELORPERSON ? @"选择美丽顾问" : @"选择业绩参与者");
    selectCustomer.personType = (choseType == COUNSELORPERSON ? CustomePersonGroup : CustomePersonDefault);
    selectCustomer.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

#pragma mark - SelectCustomersViewControllerDelegate
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    if (self.type == COUNSELORPERSON) {
        userDoc = [userArray firstObject];
        if (userDoc == nil)
            userDoc = [[UserDoc alloc] init];
    } else {
        self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    }
    [addCardTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark 日期选择
- (void)dateSelector:(NSIndexPath *)indexPath
{
    DFDateView *dateView = [[DFDateView alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    dateView.completionBlock = ^(NSDate *date){
        if (indexPath.row==2) {
            _dateForStartStr= [formatter stringFromDate:date];
        }else {
            _dateForEndStr = [formatter stringFromDate:date];
        }
        [self filterDateCheck:indexPath];
    };
    [dateView show];
}

#pragma mark 日期检查
- (void)filterDateCheck:(NSIndexPath *)indexPath
{
    NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
    dateFor.dateFormat = @"yyyy-MM-dd";
    
//    NSDate * date = [NSDate date];
//    NSDateFormatter * matter = [[NSDateFormatter alloc] init];
//    [matter setDateFormat:@"yyyy-MM-dd"];
    
//    NSString * ss = [matter stringFromDate:date];
//    NSDate * dateNow = [dateFor dateFromString:ss];
//    NSDate *dateStar = [dateFor dateFromString:self.dateForStartStr];
//    NSDate *dateEnd = [dateFor dateFromString:self.dateForEndStr];
//    
    
//    if (!(dateStar == nil && dateNow == nil)) {
//        switch ([dateNow compare:dateStar]) {
//            case NSOrderedDescending:{
//                [SVProgressHUD showErrorWithStatus2:@"开卡日期不能小于当前日期！" touchEventHandle:^{ }];
//                _dateForStartStr = ss;
//                return;
//            }
//                break;
//            case NSOrderedSame:
//                
//            case NSOrderedAscending:
//            {
//                [addCardTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            }
//                break;
//        }
//    }
    
//    if (dateStar == nil && dateEnd == nil) {
//
//    }else {
//        switch ([dateStar compare:dateEnd]) {
//            case NSOrderedDescending:
//                [SVProgressHUD showErrorWithStatus2:@"日期有误，请重新设置" touchEventHandle:^{ }];
//                _dateForEndStr = @"2099-12-31";
//                break;
//            case NSOrderedSame:
//                
//            case NSOrderedAscending:
//            {
//                [addCardTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            }
//                break;
//        }
//    }
    [addCardTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -  UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    int64_t delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToTextView:textView];
    });
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self scrollToTextView:textView];
    
    cardRemark = textView.text;
    
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)cardRemark.length];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    
    cardRemark = textView.text;
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 200) {
                textView.text = [toBeString substringToIndex:200];
                cardRemark = textView.text;
            }
            label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)cardRemark.length];
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 200) {
            textView.text = [toBeString substringToIndex:200];
            cardRemark = textView.text;
        }
        label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)cardRemark.length];
    }
}


#pragma mark - Keyboard Notification
-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = addCardTableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    addCardTableView.frame = tvFrame;
    [UIView commitAnimations];
}


-(void)keyboardWillHide:(NSNotification*)notification
{
    CGRect tvFrame = addCardTableView.frame;
    tvFrame.size.height = _initialTVHeight;
    addCardTableView.frame = tvFrame;
}

- (void)scrollToTextView:(UITextView *)textView
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:3];
    [addCardTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView: (UITextView*)textView {
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [addCardTableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [addCardTableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(290.0f, 200.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    [addCardTableView beginUpdates];
    [addCardTableView endUpdates];
}

#pragma mark UIScrollViewDelegate
//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark - request

#pragma mark - 接口

- (void)requestGetAllLevel
{
    NSDictionary * par =@{
                           @"isOnlyMoneyCard":@true,
                           @"isShowAll":@false,
                           @"BranchID":@(ACC_BRANCHID)
                        };
    _getAllLevelOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetBranchCardList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            ecardInfoArray = data;
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}


-(void)addNewCardRequest
{
    if (!(levelId > 0)) {
//        [SVProgressHUD showSuccessWithStatus2:@"您还没有选择卡！" touchEventHandle:^{
//        }];
        [SVProgressHUD showErrorWithStatus2:@"您还没有选择卡！" touchEventHandle:^{
        }];
    }else{
        [SVProgressHUD showWithStatus:@"Loading"];
        BOOL select = isDefaultButton.selected == YES?YES:NO;
        NSDictionary *par = @{
                              @"CardID":@(levelId),
                              @"IsDefault":@(select),//是否设置为默认
                              @"CustomerID":@((long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID),
                              @"Currency":MoneyIcon,
                              @"CardCreatedDate":_dateForStartStr,
                              @"CardExpiredDate":_dateForEndStr,
                              @"RealCardNo":inputCard,
                            };
        _addNewCardOPeration = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/AddCustomerCard" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
            [SVProgressHUD dismiss];
            [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
             NSLog(@"creacte card =%@",data);
                
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer  touchEventHandle:^{
    //            [self.delegate requestCardList];
                [self.navigationController popViewControllerAnimated:YES];
            }];

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error  duration:kSvhudtimer touchEventHandle:^{

                }];

            }];
        } failure:^(NSError *error) {
            
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
