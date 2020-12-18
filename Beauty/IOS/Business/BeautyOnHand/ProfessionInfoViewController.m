//
//  ProfessionInfoViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-11-26.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ProfessionInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "ProfessionEditViewController.h"
#import "CustomerDoc.h"
#import "CacheInDisk.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "DEFINE.h"
#import "QuestionDoc.h"
#import "PermissionDoc.h"
#import "NavigationView.h"
#import "GPBHTTPClient.h"

@interface ProfessionInfoViewController ()
@property (strong, nonatomic) AFHTTPRequestOperation *requestCustomerDetailOperation;
@property (strong, nonatomic) CustomerDoc *customer;

@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *valueArray;
@property (strong, nonatomic) NSMutableArray *answerArray;
@property(assign,nonatomic) CGSize size_hours;
@end

@implementation ProfessionInfoViewController
@synthesize customer;
@synthesize titleArray, valueArray, answerArray;
@synthesize size_hours;

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
    
    [answerArray removeAllObjects];
    [self requestDetailInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestCustomerDetailOperation && [_requestCustomerDetailOperation isExecuting]) {
        [_requestCustomerDetailOperation cancel];
        _requestCustomerDetailOperation = nil;
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"专业信息"];
    [self.view addSubview:navigationView];
    
    if ([[PermissionDoc sharePermission] rule_CustomerInfo_Write]) {
    [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Edit"] selector:@selector(editCustomerDetailAction)];
    }
    
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView  = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f - 5.0f);
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f - 5.0f);
    }
    
    answerArray = [[NSMutableArray alloc] init];
}

- (void)editCustomerDetailAction
{
    [self performSegueWithIdentifier:@"goCustomerDetailEditViewFromCustomerDetailView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goCustomerDetailEditViewFromCustomerDetailView"]) {
        ProfessionEditViewController *customerDetailEditController = segue.destinationViewController;
        customerDetailEditController.customer = customer;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [answerArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIdentifier = @"DetailTitleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
        UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
        titleLable.numberOfLines = 0;
        [titleLable setFont:kFont_Light_16];
        [titleLable setTextColor:kColor_DarkBlue];
        [titleLable setFrame:CGRectMake(10.0f, 4.0f, 290.0f, [[answerArray objectAtIndex:indexPath.section] question_Height] - 8.0)];
        [titleLable setText:[[answerArray objectAtIndex:indexPath.section] question_Name]];
        return cell;
    }else {
        QuestionDoc *cellAnswer = [answerArray objectAtIndex:indexPath.section];
        static NSString *cellIdentifier = @"DetailTitleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

        UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
        [titleLable setFrame:CGRectMake(10.0f, 4.0f, 290.0f, [cellAnswer.question_AnswerWord sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(290.0f, 220.0f)].height + 10)];
        [titleLable setFont:kFont_Light_16];
        [titleLable setText:cellAnswer.question_AnswerWord];
        [titleLable setLineBreakMode:NSLineBreakByWordWrapping];
        [titleLable setNumberOfLines:0];
        [titleLable setTextColor:[UIColor blackColor]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [[answerArray objectAtIndex:indexPath.section] question_Height];
    }else {
        QuestionDoc *question = [answerArray objectAtIndex:indexPath.section];
        size_hours = [question.question_AnswerWord sizeWithFont:kFont_Medium_16 constrainedToSize:CGSizeMake(290.0f, 220.0f)];
        return size_hours.height + 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

#pragma mark - 接口

- (void)requestDetailInfo
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    if (customerId == 0 && kMenu_Type == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择顾客" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)customerId];

    _requestCustomerDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/getQuestionAnswer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (customer == nil){
                customer = [[CustomerDoc alloc] init];
                customer.cus_ID = customerId;
            }
            
            if ([customer.cus_Answers count]) {
                [customer.cus_Answers removeAllObjects];
            }
            
            if ([customer.cus_oldAnswer count] > 0) {
                [customer.cus_oldAnswer removeAllObjects];
            }
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                QuestionDoc *answerDoc = [[QuestionDoc alloc] init];
                [answerDoc setQuestion_ID:[[obj objectForKey:@"QuestionID"] integerValue]];
                [answerDoc setQuestion_Type:[[obj objectForKey:@"QuestionType"] integerValue]];
                [answerDoc setQuestion_Name:[obj objectForKey:@"QuestionName"]];
                
                NSLog(@"++Question_ID:%ld", (long)answerDoc.question_ID);
                NSLog(@"++Question_Name:%@", answerDoc.question_Name);
                
                [answerDoc setQuestion_Content:([obj objectForKey:@"QuestionContent"] == [NSNull null] ? @"":[obj objectForKey:@"QuestionContent"])];
                [answerDoc setQuestion_AnswerID:([obj objectForKey:@"AnswerID"] == [NSNull null] ? -1:[[obj objectForKey:@"AnswerID"] integerValue])];
                [answerDoc setQuestion_Answer:([obj objectForKey:@"AnswerContent"]  == [NSNull null] ? @"" :[obj objectForKey:@"AnswerContent"])];

                NSMutableArray  *optionArray = [[answerDoc.question_Content componentsSeparatedByString:@"|"] mutableCopy];

                if ([[optionArray lastObject] isEqualToString:@""]) {
                    [optionArray removeLastObject];
                    NSString *str = [optionArray componentsJoinedByString:@"|"];
                    answerDoc.question_Content = str;
                }
                [answerDoc setQuestion_OptionNumber:[optionArray count]];
                [answerDoc setQuestion_AnswerWord:answerDoc.question_Answer];
                [customer.cus_Answers addObject:answerDoc];

                QuestionDoc *oldAnswerDoc = [answerDoc copy];
                
                NSMutableArray  *optionArray1 = [[answerDoc.question_Content componentsSeparatedByString:@"|"] mutableCopy];
                if ([[optionArray1 lastObject] isEqualToString:@""]) {
                    [optionArray1 removeLastObject];
                    NSString *str = [optionArray componentsJoinedByString:@"|"];
                    answerDoc.question_Content = str;
                }
                [oldAnswerDoc setQuestion_OptionNumber:[optionArray1 count]];
                [oldAnswerDoc setQuestion_AnswerWord:oldAnswerDoc.question_Answer];
                [customer.cus_oldAnswer addObject:oldAnswerDoc];
                
                if (answerDoc.question_Type == 0) {
                    if(![answerDoc.question_Answer isEqualToString:@""])
                        [answerArray addObject:answerDoc];
                } else {
                    NSRange foundObj = [answerDoc.question_Answer rangeOfString:@"1" options:NSCaseInsensitiveSearch];
                    if (foundObj.length > 0 && answerDoc.question_Type != 0)  {
                        NSArray  *quesArray = [answerDoc.question_Content componentsSeparatedByString:@"|"];
                        NSArray  *answArray = [answerDoc.question_Answer componentsSeparatedByString:@"|"];
                        NSString *totalString = [[NSString alloc] initWithFormat:@""];
                        NSInteger count = MIN([quesArray count], [answArray count]);
                        
                        for (int i = 0; i < count; i++) {
                            if ([[answArray objectAtIndex:i] integerValue] == 1) {
                                totalString = [totalString stringByAppendingString:[quesArray objectAtIndex:i]];
                                totalString = [totalString stringByAppendingString:@","];
                            }
                        }
                        
                        NSString *totalStr = totalString.length >0 ? [totalString substringToIndex:totalString.length-1] : totalString;
                        answerDoc.question_AnswerWord = totalStr;
                        if(![answerDoc.question_Answer isEqualToString:@""])
                            [answerArray addObject:answerDoc];
                    }
                }
            }];
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    
    
    
    
    
    
    /*
    _requestCustomerDetailOperation = [[GPHTTPClient shareClient] requestGetProfessionInfoWithCustomerId:customerId success:^(id xml) {
         NSLog(@"++++++XML:%@",xml);
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [SVProgressHUD dismiss];
            if (customer == nil){
                customer = [[CustomerDoc alloc] init];
                customer.cus_ID = customerId;
            }
            
            if ([customer.cus_Answers count]) {
                [customer.cus_Answers removeAllObjects];
            }
            
            if ([customer.cus_oldAnswer count] > 0) {
                [customer.cus_oldAnswer removeAllObjects];
            }
            
            for (GDataXMLElement *ph in [contentData elementsForName:@"QuestionAndAnswer"]) {
                QuestionDoc *answerDoc = [[QuestionDoc alloc] init];
                [answerDoc setQuestion_ID:[[[[ph elementsForName:@"QuestionID"] objectAtIndex:0] stringValue] integerValue]];
                [answerDoc setQuestion_Type:[[[[ph elementsForName:@"QuestionType"] objectAtIndex:0] stringValue] integerValue]];
                [answerDoc setQuestion_Name:[[[ph elementsForName:@"QuestionName"] objectAtIndex:0] stringValue]];
                
                NSLog(@"++Question_ID:%ld", (long)answerDoc.question_ID);
                NSLog(@"++Question_Name:%@", answerDoc.question_Name);
                
                [answerDoc setQuestion_Content:([[[ph elementsForName:@"QuestionContent"] objectAtIndex:0] stringValue] == nil ? @"":[[[ph elementsForName:@"QuestionContent"] objectAtIndex:0] stringValue])];
                [answerDoc setQuestion_AnswerID:([[[ph elementsForName:@"AnswerID"] objectAtIndex:0] stringValue] == nil ? -1:[[[[ph elementsForName:@"AnswerID"] objectAtIndex:0] stringValue] integerValue])];
                [answerDoc setQuestion_Answer:([[[ph elementsForName:@"AnswerContent"] objectAtIndex:0] stringValue] == nil ? @"" :[[[ph elementsForName:@"AnswerContent"] objectAtIndex:0] stringValue])];
                NSMutableArray  *optionArray = [[answerDoc.question_Content componentsSeparatedByString:@"|"] mutableCopy];
//                NSMutableIndexSet  *deleteSet = [NSMutableIndexSet indexSet];
            //选择问题 去重处理
//                [optionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    if ([(NSString *)obj isEqualToString:@""]) {
//                        [deleteSet addIndex:idx];
//                    }
//                }];
//                if (deleteSet.count) {
//                    [optionArray removeObjectsAtIndexes:deleteSet];
//                    NSString *str = [optionArray componentsJoinedByString:@"|"];
//                    answerDoc.question_Content = str;
//                 }
                
                if ([[optionArray lastObject] isEqualToString:@""]) {
                    [optionArray removeLastObject];
                    NSString *str = [optionArray componentsJoinedByString:@"|"];
                    answerDoc.question_Content = str;
                }
                [answerDoc setQuestion_OptionNumber:[optionArray count]];
                [answerDoc setQuestion_AnswerWord:answerDoc.question_Answer];
                [customer.cus_Answers addObject:answerDoc];
                
                QuestionDoc *oldAnswerDoc = [[QuestionDoc alloc] init];
                [oldAnswerDoc setQuestion_ID:[[[[ph elementsForName:@"QuestionID"] objectAtIndex:0] stringValue] integerValue]];
                [oldAnswerDoc setQuestion_Type:[[[[ph elementsForName:@"QuestionType"] objectAtIndex:0] stringValue] integerValue]];
                [oldAnswerDoc setQuestion_Name:[[[ph elementsForName:@"QuestionName"] objectAtIndex:0] stringValue]];
                [oldAnswerDoc setQuestion_Content:([[[ph elementsForName:@"QuestionContent"] objectAtIndex:0] stringValue] == nil ? @"":[[[ph elementsForName:@"QuestionContent"] objectAtIndex:0] stringValue])];
                [oldAnswerDoc setQuestion_AnswerID:([[[ph elementsForName:@"AnswerID"] objectAtIndex:0] stringValue] == nil ? -1:[[[[ph elementsForName:@"AnswerID"] objectAtIndex:0] stringValue] integerValue])];
                [oldAnswerDoc setQuestion_Answer:([[[ph elementsForName:@"AnswerContent"] objectAtIndex:0] stringValue] == nil ? @"" :[[[ph elementsForName:@"AnswerContent"] objectAtIndex:0] stringValue])];
                
                
                
               NSMutableArray  *optionArray1 = [[answerDoc.question_Content componentsSeparatedByString:@"|"] mutableCopy];
                */
                /*
                 NSMutableArray  *optionArray1 = [[answerDoc.question_Content componentsSeparatedByString:@"|"] mutableCopy];
                 NSMutableIndexSet  *deleteOldSet = [NSMutableIndexSet indexSet];
                 
                 [optionArray1 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 if ([(NSString *)obj isEqualToString:@""]) {
                 [deleteOldSet addIndex:idx];
                 }
                 }];
                 if (deleteOldSet.count) {
                 [optionArray1 removeObjectsAtIndexes:deleteOldSet];
                 NSString *str = [optionArray1 componentsJoinedByString:@"|"];
                 answerDoc.question_Content = str;
                 }
                 
                 */
                /*
                if ([[optionArray1 lastObject] isEqualToString:@""]) {
                    [optionArray1 removeLastObject];
                    NSString *str = [optionArray componentsJoinedByString:@"|"];
                    answerDoc.question_Content = str;
                }
                [oldAnswerDoc setQuestion_OptionNumber:[optionArray1 count]];
                [oldAnswerDoc setQuestion_AnswerWord:oldAnswerDoc.question_Answer];
                [customer.cus_oldAnswer addObject:oldAnswerDoc];
                
                
                
                if (answerDoc.question_Type == 0) {
                    if(![answerDoc.question_Answer isEqualToString:@""])
                        [answerArray addObject:answerDoc];
                } else {
                    NSRange foundObj = [answerDoc.question_Answer rangeOfString:@"1" options:NSCaseInsensitiveSearch];
                    if (foundObj.length > 0 && answerDoc.question_Type != 0)  {
                        NSArray  *quesArray = [answerDoc.question_Content componentsSeparatedByString:@"|"];
                        NSArray  *answArray = [answerDoc.question_Answer componentsSeparatedByString:@"|"];
                        NSString *totalString = [[NSString alloc] initWithFormat:@""];
                        NSInteger count = MIN([quesArray count], [answArray count]);
                        
                        for (int i = 0; i < count; i++) {
                            if ([[answArray objectAtIndex:i] integerValue] == 1) {
                                totalString = [totalString stringByAppendingString:[quesArray objectAtIndex:i]];
                                totalString = [totalString stringByAppendingString:@","];
                            }
                        }
                        
                        NSString *totalStr = totalString.length >0 ? [totalString substringToIndex:totalString.length-1] : totalString;
                        answerDoc.question_AnswerWord = totalStr;
                        if(![answerDoc.question_Answer isEqualToString:@""])
                            [answerArray addObject:answerDoc];
                    }
                }
                */
                
                /*NSRange foundObj = [answerDoc.question_Answer rangeOfString:@"1" options:NSCaseInsensitiveSearch];
                if (foundObj.length > 0)  {
                    if (answerDoc.question_Type == 0) {
                        [answerArray addObject:answerDoc];
                    } else {
                        NSArray  *quesArray = [answerDoc.question_Content componentsSeparatedByString:@"|"];
                        NSArray  *answArray = [answerDoc.question_Answer componentsSeparatedByString:@"|"];
                        NSString *totalString = [[NSString alloc] initWithFormat:@""];
                        int count = MIN([quesArray count], [answArray count]);
                        
                        for (int i = 0; i < count; i++) {
                            if ([[answArray objectAtIndex:i] integerValue] == 1) {
                                totalString = [totalString stringByAppendingString:[quesArray objectAtIndex:i]];
                                totalString = [totalString stringByAppendingString:@","];
                            }
                        }
                        
                        NSString *totalStr = totalString.length >0 ? [totalString substringToIndex:totalString.length-1] : totalString;
                        answerDoc.question_AnswerWord = totalStr;
                        [answerArray addObject:answerDoc];
                    }
                }*/
//            }
//            
//            [_tableView reloadData];
//        } failure:^{
//        }];
//    } failure:^(NSError *error) {}];
}

@end


