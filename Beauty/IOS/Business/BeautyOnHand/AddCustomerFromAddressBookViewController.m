//
//  AddCustomerFromAddressBookViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-12.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "AddCustomerFromAddressBookViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "CustomerDoc.h"
#import "DEFINE.h"
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"
#import "InitialSlidingViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface AddCustomerFromAddressBookViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddCustomerOperation;
@property (assign, nonatomic) BOOL allAddButtonBool;
@end

@implementation AddCustomerFromAddressBookViewController
@synthesize allAddButton;
@synthesize customerListArray;
@synthesize allAddButtonBool;
@synthesize receiveArray;
@synthesize customerDoc;

#pragma mark - initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [allAddButton setBackgroundImage:[UIImage imageNamed:@"icon_unCheckedTitle"] forState:UIControlStateNormal];
    [allAddButton setBackgroundImage:[UIImage imageNamed:@"icon_CheckedTitle"] forState:UIControlStateSelected];
    
    _myTableView.showsHorizontalScrollIndicator = NO;
    _myTableView.showsVerticalScrollIndicator = NO;
    
    
   [self ReadPhoneBook];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [customerListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIButton *addButton = (UIButton *)[cell.contentView viewWithTag:100];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UIImageView *addedImageView = (UIImageView *)[cell.contentView viewWithTag:102];
    UILabel *addStateLabel = (UILabel *)[cell.contentView viewWithTag:103];
    [addStateLabel setTag:indexPath.row+10000];
     
    CustomerDoc *linkDoc = [customerListArray objectAtIndex:indexPath.row];
    [addButton setBackgroundImage:[UIImage imageNamed:@"icon_unChecked"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"icon_Checked"] forState:UIControlStateSelected];
    [addButton setTag:indexPath.row+1000];          //通过tag获取与button对应的行号
    
    [nameLabel setText:linkDoc.cus_Name];
    
    if (linkDoc.cus_ServerState == NO) {
        addedImageView.hidden = YES;
    }
    [addButton addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark -- changeState

- (void)changeState:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([[customerListArray objectAtIndex:button.tag-1000] cus_nowState] == NO) {
        [button setSelected:YES];
        [[customerListArray objectAtIndex:button.tag-1000] setCus_nowState:YES];
    }else{
        [button setSelected:NO];
        [[customerListArray objectAtIndex:button.tag-1000] setCus_nowState:NO];
    }

}

#pragma mark - Button

- (IBAction)allAddAction:(id)sender {
    
    if (allAddButtonBool == NO) {
        for(int i = 0; i < customerListArray.count; i++){
            if ([[customerListArray objectAtIndex:i] cus_nowState] == NO) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                UIButton *addButton = (UIButton *)[[_myTableView cellForRowAtIndexPath:indexPath] viewWithTag:i+1000];
                [addButton setSelected:YES];
                [[customerListArray objectAtIndex:indexPath.row] setCus_nowState:YES];
            }
        [allAddButton setSelected:YES];
        allAddButtonBool = YES;
        }
    }else {
        for(int i = 0; i < customerListArray.count; i++){
            if ([[customerListArray objectAtIndex:i] cus_nowState] == YES) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                UIButton *addButton = (UIButton *)[[_myTableView cellForRowAtIndexPath:indexPath] viewWithTag:i+1000];
                [addButton setSelected:NO];
                [[customerListArray objectAtIndex:indexPath.row] setCus_nowState:NO];
            }
            [allAddButton setSelected:NO];
            allAddButtonBool = NO;
        }
    }
}

- (IBAction)affirmAddAction:(id)sender {
//    int addNumber = 0;
//    for (int i = 0; i < customerListArray.count; i++){
//        CustomerDoc *judgeAddDoc = [customerListArray objectAtIndex:i];
//        if (judgeAddDoc.cus_nowState == YES) {
//            addNumber++;
//        }
//    }
//    if (addNumber == 0) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请选择需要添加的顾客" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
//        return;
//    }else{
//        for(int i = 0; i < customerListArray.count; i++){
//            CustomerDoc *judgeAddDoc = [customerListArray objectAtIndex:i];
//            if (judgeAddDoc.cus_nowState == YES) {
//                [SVProgressHUD showWithStatus:@"Loading"];
//                _requestAddCustomerOperation = [[GPHTTPClient shareClient] requestAddCustomerBasicInfo:judgeAddDoc success:^(id xml) {
//                    
//                    [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
//                        
//                    } failure:^{
//                        
//                    }];
//                     [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:YES showFailureMsg:YES success:^(int code) {
//                        if (code > 0) {
//                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                            UILabel *addStateLabel = (UILabel *)[[_myTableView cellForRowAtIndexPath:indexPath] viewWithTag:i+10000];
//                            [addStateLabel setText:@"添加成功"];
//                            
//                            UIButton *addButton = (UIButton *)[[_myTableView cellForRowAtIndexPath:indexPath] viewWithTag:i+1000];
//                            addButton.hidden = YES;
//                            
//                            [[customerListArray objectAtIndex:i] setCus_nowState: NO];
//                        } else {
//                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                            UILabel *addStateLabel = (UILabel *)[[_myTableView cellForRowAtIndexPath:indexPath] viewWithTag:i+10000];
//                            [addStateLabel setText:@"添加失败"];
//                        }
//                    
//                    } failure:^{}];
//                } failure:^(NSError *error) {
//                    DLOG(@"Error:%@ Address:%s", error.description, __FUNCTION__);
//                }];
//            }
//        }
//    }
}

//#pragma mark - UIScrollViewDelegate
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    customerListArray = [self fetchAddButtonState];
//}
//
//// 临时保存修改的内容
//- (NSMutableArray *)fetchAddButtonState
//{
//    NSMutableArray *theCustomerDoc = [[NSMutableArray alloc] initWithArray:customerListArray];
//    for (int i =0 ; i < customerListArray.count ; i++) {
//        //[[theCustomerDoc objectAtIndex:i] setCus_nowState:[[customerListArray objectAtIndex:i] cus_nowState]];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        UIButton *addButton = (UIButton *)[[_myTableView cellForRowAtIndexPath:indexPath] viewWithTag:i+1000];
//        [[theCustomerDoc objectAtIndex:i] setCus_nowState:([addButton state] == UIControlStateNormal ? NO : YES)];
//    }
//    return theCustomerDoc;
//}

#pragma mark - 接口

- (void)ReadPhoneBook
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                                                 dispatch_semaphore_signal(sema);
                                             });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (customerListArray) {
        [customerListArray removeAllObjects];
    } else {
        customerListArray = [NSMutableArray array];
    }
    
    if (addressBook == NULL) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"获取通讯录联系人失败！请在“设置-隐私”设置权限" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (CFArrayGetCount(results) == 0) return;
    
    NSMutableArray *nameArray = [NSMutableArray array];
    for (int m = 0 ; m < CFArrayGetCount(results); m++) {
        CustomerDoc *linkmanDoc = [[CustomerDoc alloc] init];
        
        //获取联系人姓名
        ABRecordRef person = CFArrayGetValueAtIndex(results, m);
        NSString *FirstName = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *LastName  = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
    
        linkmanDoc.cus_Name = [(LastName ? LastName : @"") stringByAppendingString:FirstName ? FirstName : @""];
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString *totalPhoneLabel = [[NSString alloc]init];
        NSString *totalPhone = [[NSString alloc]init];
        for (int k = 0; k<ABMultiValueGetCount(phone); k++) {
            if (k != ABMultiValueGetCount(phone) - 1) {
            //获取电话Label
            NSString *personPhoneLabel = [(NSString *)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k))) stringByAppendingString:@","];
            //获取該Label下的电话值
            NSString *personPhone = [(NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k)) stringByAppendingString:@","];
            [totalPhoneLabel stringByAppendingString:personPhoneLabel];
            [totalPhone stringByAppendingString:personPhone];
            }else {
                //获取电话Label
                NSString *personPhoneLabel = (NSString *)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k)));
                //获取該Label下的电话值
                NSString *personPhone = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
                [totalPhoneLabel stringByAppendingString:personPhoneLabel];
                [totalPhone stringByAppendingString:personPhone];
            }
        }
        linkmanDoc.cus_Phones = totalPhone;
        linkmanDoc.cus_PhoneKeys = totalPhoneLabel;
        
        //读取邮件多值
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSString *totalEmailLabel = [[NSString alloc]init];
        NSString *totalEmailContent = [[NSString alloc]init];
        for (int x = 0; x < ABMultiValueGetCount(email); x++)
        {
            if (x != ABMultiValueGetCount(email)-1) {
            //获取email Label
            NSString *emailLabel = [(NSString *)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x)))  stringByAppendingString:@","];
            //获取email值
            NSString *emailContent = [(NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(email, x)) stringByAppendingString:@","];
                [totalEmailLabel stringByAppendingString:emailLabel];
                [totalEmailContent stringByAppendingString:emailContent];
            }else {
                //获取email Label
                NSString *emailLabel = (NSString *)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x)));
                //获取email值
                NSString *emailContent = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(email, x));
                [totalEmailLabel stringByAppendingString:emailLabel];
                [totalEmailContent stringByAppendingString:emailContent];
            }
            
        }
        linkmanDoc.cus_Emails = totalEmailContent;
        linkmanDoc.cus_EmailKeys = totalEmailLabel;
        
        //读取地址多值
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        NSString *totalAddressLabel = [[NSString alloc]init];
        NSString *totalAddress = [[NSString alloc]init];
        NSString *totalZip = [[NSString alloc]init];
        
        //int count = ABMultiValueGetCount(address);
        for(int j = 0; j < ABMultiValueGetCount(address); j++)
        {
            //获取地址Label
            if (j != ABMultiValueGetCount(address) - 1) {
            NSString *addressLabel = [(NSString*)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(address, j)) stringByAppendingString:@","];
                [totalAddressLabel stringByAppendingString:addressLabel];
            }else {
                NSString *addressLabel = (NSString*)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(address, j));
                [totalAddressLabel stringByAppendingString:addressLabel];
            }
            
            //获取該label下的地址4属性
            NSDictionary *personaddress =(NSDictionary *) CFBridgingRelease(ABMultiValueCopyValueAtIndex(address, j));
            NSString *country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            NSString *city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            NSString *state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            NSString *street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            NSString *zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];

            if (j != ABMultiValueGetCount(address) - 1) {
                if(country != nil) {
                    [totalAddress stringByAppendingString:country];
                }
                if(city != nil) {
                    [totalAddress stringByAppendingString:city];
                }
                if(state != nil) {
                    [totalAddress stringByAppendingString:state];
                }
                if(street != nil) {
                    [totalAddress stringByAppendingString:street];
                }
                [totalAddress stringByAppendingString:@","];
            }else {
                if(country != nil) {
                    [totalAddress stringByAppendingString:country];
                }
                if(city != nil) {
                    [totalAddress stringByAppendingString:city];
                }
                if(state != nil) {
                    [totalAddress stringByAppendingString:state];
                }
                if(street != nil) {
                    [totalAddress stringByAppendingString:street];
                }
            }
            
            //获取多值
            if (j != ABMultiValueGetCount(address) - 1) {
                if(zip != nil){
                    [zip stringByAppendingString:@","];
                    [totalZip stringByAppendingString:zip];
                }
            }else {
                if(zip != nil){
                    [totalZip stringByAppendingString:zip];
                }
            }
        }
        
        linkmanDoc.cus_AdrsKeys = totalAddressLabel;
        linkmanDoc.cus_Zips = totalZip;
        linkmanDoc.cus_Adrss = totalAddress;
        
        linkmanDoc.cus_Title = @" ";
        linkmanDoc.cus_Phones= @" ";
        linkmanDoc.cus_Remark = @" ";
        
        linkmanDoc.cus_ServerState = NO;
        
        [nameArray addObject:linkmanDoc];
    }
    
    customerListArray = nameArray;
    [_myTableView reloadData];
}


@end
