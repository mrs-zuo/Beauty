//
//  TemplateTotalViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-19.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "TemplateViewController.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLNode.h"
#import "TemplateDoc.h"
#import "TemplateTitleCell.h"
#import "TemplateContentCell.h"
#import "TemplateEditViewController.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "GPBHTTPClient.h"

@interface TemplateViewController ()
@property (assign, nonatomic) AFHTTPRequestOperation *requestAllTemplateListOperation;
@property (strong, nonatomic) NSMutableArray *templateArray;

@property (nonatomic) TemplateDoc *selected_Template;
@end

@implementation TemplateViewController
@synthesize templateArray;
@synthesize delegate;
@synthesize templateType;
@synthesize selected_Template;

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
     [self requestTemplateList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"选择模板"];
    [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_AddMsg"] selector:@selector(addTemplateAction)];
    [self.view addSubview:navigationView];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [templateArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateDoc *theTemplate = [templateArray objectAtIndex:indexPath.section];
    if (indexPath.row == 0) {
        NSString *cellIndentify = @"TemplateCell_Title";
        TemplateTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[TemplateTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        }
        cell.titleLabel.text = theTemplate.Subject;
        cell.editButton.tag = indexPath.section;
        cell.delegate = self;
        
        return cell;
    } else if (indexPath.row == 1) {
        NSString *cellIndentify = @"TemplateCell_Content";
        TemplateContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[TemplateContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        }
        [cell updateData:theTemplate type:templateType];
        return cell;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateDoc *theTemplate = [templateArray objectAtIndex:indexPath.section];
    if (indexPath.row == 0) {
      return kTableView_HeightOfRow;
    } else {
        return theTemplate.height_Tmp_TemplateContent  + 25.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return  kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
   return  kTableView_Margin_Bottom;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1) {
         TemplateDoc *selectedTemplateDoc = [templateArray objectAtIndex:indexPath.section];
        
        if ([delegate respondsToSelector:@selector(returnTemplate:)]) {
            [delegate returnTemplate:selectedTemplateDoc];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - TemplateTitleCellDelegate

- (void)editTemplateWithIndex:(NSInteger)index
{
    selected_Template = [templateArray objectAtIndex:index];
    [self performSegueWithIdentifier:@"goTemplateEditViewFromTemplateView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goTemplateEditViewFromTemplateView"]) {
        TemplateEditViewController *templateEditController = segue.destinationViewController;
        if (selected_Template) {
            templateEditController.theTemplateDoc = selected_Template;
            templateEditController.isEditing = YES;
        } else {
            templateEditController.theTemplateDoc = nil;
            templateEditController.isEditing = NO;
        }
    }
}

- (void)addTemplateAction
{
    [self performSegueWithIdentifier:@"goTemplateEditViewFromTemplateView" sender:self];
}

#pragma mark - 接口

- (void)requestTemplateList
{
    int type = 0;
    if (templateType == TemplateTypePrivate) {
        type = 1;
    } else if (templateType == TemplateTypePublic) {
        type = 0;
    }
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
    _requestAllTemplateListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/template/getTemplateList" andParameters:nil failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(NSArray *data, NSInteger code, id message) {
            if (!templateArray) {
                templateArray = [NSMutableArray array];
            } else {
                [templateArray removeAllObjects];
                selected_Template = nil;
            }
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [templateArray addObject:[[TemplateDoc alloc] initWithDictionary:obj]];
            }];
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    /*
    _requestAllTemplateListOperation = [[GPHTTPClient shareClient] requestTemplateListWithType:type Success:^(id xml) {
        [SVProgressHUD dismiss];
        
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if (!templateArray) {
                templateArray = [NSMutableArray array];
            } else {
                [templateArray removeAllObjects];
                selected_Template = nil;
            }

            for (GDataXMLElement *data in [contentData elementsForName:@"Template"]) {
                TemplateDoc *templateDoc = [[TemplateDoc alloc] init];
                templateDoc.tmp_ID = [[[[data elementsForName:@"TemplateID"] objectAtIndex:0] stringValue] integerValue];
                templateDoc.tmp_TemplateContent = [[[data elementsForName:@"TemplateContent"] objectAtIndex:0] stringValue];
                templateDoc.tmp_Date = [[[data elementsForName:@"Time"] objectAtIndex:0] stringValue];
                templateDoc.tmp_CreatorName = [[[data elementsForName:@"CreatorName"] objectAtIndex:0] stringValue];
                templateDoc.tmp_UpdaterName = [[[data elementsForName:@"UpdaterName"] objectAtIndex:0] stringValue];
                templateDoc.tmp_Subject = [[[data elementsForName:@"Subject"] objectAtIndex:0] stringValue];
                templateDoc.tmp_Type = [[[[data elementsForName:@"TemplateType"] objectAtIndex:0] stringValue] integerValue];
                [templateArray addObject:templateDoc];
            }
            [_tableView reloadData];
        } failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        DLOG(@"Error:%@ Address:%s", error, __FUNCTION__);
    }];
     */
}

@end
