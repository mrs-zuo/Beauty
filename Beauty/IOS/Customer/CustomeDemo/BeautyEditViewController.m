//
//  BeautyEditViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "BeautyEditViewController.h"
#import "UIButton+InitButton.h"
#import "GPHTTPClient.h"
#import "BeautyEditTableViewCell.h"
#import "BeautyRecordPhotoTableViewCell.h"
#import "CustomerTGPicRes.h"
#import "TGPicListRes.h"
#import "BeautyCommentsTableViewCell.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "EditPhotoViewController.h"
#import "BeautyRecordViewController.h"
#import "AddPhotoViewController.h"
#import "BeautyShareTableViewCell.h"
#import <ShareSDK/ShareSDK.h>
#import "RemarkEditCell.h"


@interface BeautyEditViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,ContentEditCellDelegate>

@property (nonatomic,strong) UITextView *commentTextView;
@property (nonatomic,strong)  CustomerTGPicRes *picRes;
@property (weak, nonatomic) AFHTTPRequestOperation *requestShareGroupNoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestEditCustomerPicOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetCustomerTGPicOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateServiceEffectImageOperation;

@property(nonatomic,strong) UITableView *beautyEditTableView;
@property (nonatomic,strong) NSMutableArray *rowDatas;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (assign, nonatomic) CGFloat table_Height;


@end

@implementation BeautyEditViewController
@synthesize table_Height;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    [self initData];
    [self initView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestGetCustomerTGPic];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    _picRes = nil;
    
}
- (void)initData
{
    self.title = @"美丽记录";
    self.rowDatas  = [NSMutableArray arrayWithObjects:@"服务",@"门店",@"照片",@"心情",@"分享美丽", nil];
}
- (void)initView
{
    self.view.backgroundColor = RGBA(241, 241, 241, 1);
    
    _beautyEditTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 60 + 20+10) style:UITableViewStyleGrouped];
    _beautyEditTableView.dataSource = self;
    _beautyEditTableView.delegate = self;
    _beautyEditTableView.separatorColor = kTableView_LineColor;
    _beautyEditTableView.showsHorizontalScrollIndicator = NO;
    _beautyEditTableView.showsVerticalScrollIndicator = NO;
    _beautyEditTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_beautyEditTableView];
    table_Height = _beautyEditTableView.frame.size.height +44;
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 30, kSCREN_BOUNDS.size.width, 49.0f)];
    footView.backgroundColor = kColor_FootView;
    [self.view addSubview:footView];
    
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    
    
    
    UIButton *confirmBtn= [UIButton buttonWithTitle:@"确定"
                                             target:self
                                           selector:@selector(confirm:)
                                              frame:CGRectMake(5,5,kSCREN_BOUNDS.size.width - 10, 39)
                                      backgroundImg:nil
                                   highlightedImage:nil];
    confirmBtn.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
    confirmBtn.titleLabel.font=kNormalFont_14;
    [footView addSubview:confirmBtn];
}

#pragma mark -  UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.rowDatas[indexPath.row];
    if ([title isEqualToString:@"照片"]) {
       
        const CGFloat interval = 10.0f;
        const CGFloat imageView_Height = (kSCREN_BOUNDS.size.width - (5 * interval)) / 4;
        if (_picRes.TGPicList.count > 0) {
            NSInteger col;
            if ((_picRes.TGPicList.count + 1)% 4 == 0) { // 加count +1 是因为最后一个是新增
                col =(_picRes.TGPicList.count + 1) / 4;
            }else{
                col =(_picRes.TGPicList.count + 1) / 4 + 1;
            }
           return (col  * imageView_Height) + ((col-1)  * 40) + 20 ;
        }else{
            return imageView_Height + 20;
        }
        
    }else if ([title isEqualToString:@"心情"]){
        
        NSInteger height = [_picRes.comments sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(310, 500) lineBreakMode:NSLineBreakByCharWrapping].height + 20;
        return height < 100 ? 100 : height;
        
    }else{
            return kTableView_DefaultCellHeight;
        }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rowDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.rowDatas[indexPath.row];
    if ([title isEqualToString:@"服务"]) {
        static  NSString *identifier = @"BeautyEditCell";
        BeautyEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle]loadNibNamed:@"BeautyEditTableViewCell" owner:self options:nil].firstObject;
        }
        cell.deletBlock = ^(){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"确认要删除吗?" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"取消",@"确定",nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self requestrequestEditCustomerPic:_picRes];
                }
            }];
            
        };
        cell.lab.text =_picRes.serviceName;
        return cell;
    }else if ([title isEqualToString:@"门店"]){
        static  NSString *identifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        cell.textLabel.text = _picRes.TGStartTime;
        cell.textLabel.font=kNormalFont_14;
        cell.detailTextLabel.text =_picRes.branchName;
        cell.detailTextLabel.font=kNormalFont_14;
        return cell;
    }else if ([title isEqualToString:@"照片"]) {
        NSString *identifier = [NSString stringWithFormat:@"PhotoCell%ld",(long)indexPath.section];
        BeautyRecordPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BeautyRecordPhotoTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        cell.addImage = YES;
        cell.tGList = _picRes.TGPicList;
        __weak typeof(self) weakSelf = self;
        cell.tapImage = ^(UIImageView *imgView,NSMutableArray *arrs){
            if ((imgView.tag  - 100) == (arrs.count - 1)) {
                AddPhotoViewController *addVC = [[AddPhotoViewController alloc]init];
                addVC.shopRes = weakSelf.shopRes;
                [weakSelf.navigationController pushViewController:addVC animated:YES];
            }else{
                EditPhotoViewController *editVC = [[EditPhotoViewController alloc]init];
                editVC.shopRes = weakSelf.shopRes;
                editVC.tGPicListRes = arrs[imgView.tag - 100];
                [weakSelf.navigationController pushViewController:editVC animated:YES];
            }
           
        };
        return cell;
    }else if ([title isEqualToString:@"心情"]) {
        static  NSString *identifier = @"CommentsCell";
        BeautyCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[NSBundle mainBundle]loadNibNamed:@"BeautyCommentsTableViewCell" owner:self options:nil].firstObject;
        }
        _commentTextView = cell.comTextView;
        _commentTextView.font=kNormalFont_14;
        if (_picRes.comments && _picRes.comments.length > 0) {
            cell.placeholderLab.text = @"";
            
            _commentTextView.text = _picRes.comments;
            
        }else{
            _commentTextView.text = @"";
            cell.placeholderLab.text = @"留下你的心情";
        }
        return cell;
        

//        static NSString *editCellIdentifier = @"editCellForRecord";
//        
//        RemarkEditCell  *editCell = [[RemarkEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
//        editCell.tag = 1088;
//        editCell.selectionStyle = UITableViewCellSelectionStyleNone;
//        CGRect rect=editCell.contentEditText.frame;
//        rect.origin.x=5;
//        rect.origin.y=0;
//        editCell.contentEditText.frame=rect;
//        _commentTextView=editCell.contentEditText;
//        if (_picRes.comments && _picRes.comments.length > 0) {
//            
//            //[editCell setContentText:_picRes.comments];
//            _commentTextView.text=_picRes.comments;
//            
//        } else {
//            _commentTextView.text=@"留下你的心情";
//            //[editCell setContentText: @"留下你的心情"];
//        }
//        editCell.contentEditText.tag = 1000;
//        editCell.contentEditText.font = kNormalFont_14;
//        editCell.delegate = self;
//        return editCell;
    }else{
        static  NSString *identifier = @"ShareCell";
        BeautyShareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle]loadNibNamed:@"BeautyShareTableViewCell" owner:self options:nil].firstObject;
        }
        __weak typeof(self) weakSelf = self;
        cell.shareBlock = ^(UIButton *button){
            DLOG(@"分享美丽");
            [weakSelf requestShareGroupNo:_picRes];
        };
        return cell;
    }
}
//#pragma mark- 键盘
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    _beautyEditTableView.frame = CGRectMake(0,0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 60 + 20);
//    CGRect rect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat y = rect.origin.y;
//    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            CGRect bottomRect = _beautyEditTableView.frame;
//            bottomRect.origin.y = (bottomRect.origin.y - y + 60 + kNavigationBar_Height);
//            _beautyEditTableView.frame = bottomRect;
//    } completion:^(BOOL finished) {
//        
//    }];
//}
//- (void)keyboardWillHide:(NSNotification *)notification
//{
//    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        _beautyEditTableView.frame = CGRectMake(0,0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 60 + 20);
//    } completion:^(BOOL finished) {
//        
//    }];
//}


#pragma mark -  按钮事件
- (void)confirm:(UIButton *)sender
{
    [self.view endEditing:YES];
   _picRes.comments =  _commentTextView.text;
    [self requestUpdateServiceEffectImage:_picRes];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark - 分享
- (void)share:(NSString *)urlStr
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK" ofType:@"png"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"美丽分享"]
                                       defaultContent:nil
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"美丽分享"
                                                  url:urlStr
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建iPad弹出菜单容器,详见第六步
    id<ISSContainer> container = [ShareSDK container];
    //    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%ld,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}


#pragma mark - 接口
- (void)requestGetCustomerTGPic
{
//    /image/getCustomerTGPic获取TG记录
//    所需参数
//    {"GroupNo":1601220000000001,"ImageWidth":160,"ImageHeight":160}
//    返回参数
//    {"Data":{"ServiceName":"daf","ServiceCode":1507080000000002,"TGStartTime":"2016-01-22 16:18","Comments":"","BranchName":"门店1","BranchID":98,"GroupNo":1601220000000001,"TGPicList":[{"RecordImgID":"dfggt456123158","ImageTag":null,"ImageURL":"http://data.test.beauty.glamise.com/GetThumbnail.aspx?fn=69/Customer/11810/BeautyRec/20160122161901225349124.JPEG&th=160&tw=160&bg=FFFFFF"}]},"Code":"1","Message":null}
    
    
    NSDictionary *paraGet = @{@"GroupNo":self.shopRes.groupNo,
                              @"ImageWidth":@(160),
                              @"ImageHeight":@(160)};
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestGetCustomerTGPicOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/getCustomerTGPic"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)data;
                _picRes = [[CustomerTGPicRes alloc]init];
                _picRes.serviceCode = [dic objectForKey:@"ServiceCode"];
                _picRes.serviceName = [dic objectForKey:@"ServiceName"];
                _picRes.TGStartTime = [dic objectForKey:@"TGStartTime"];
                _picRes.comments = [dic objectForKey:@"Comments"];
                _picRes.branchName = [dic objectForKey:@"BranchName"];
                _picRes.branchID = [dic objectForKey:@"BranchID"];
                _picRes.groupNo = [dic objectForKey:@"GroupNo"];
                NSArray *TGPicList = [dic objectForKey:@"TGPicList"];
                if (TGPicList.count > 0) {
                    for (int i =0 ; i<  TGPicList.count; i ++) {
                        NSDictionary *dic =  TGPicList[i];
                        TGPicListRes *picList = [[TGPicListRes alloc]init];
                        picList.recordImgID = [dic objectForKey:@"RecordImgID"];
                        picList.imageTag = [dic objectForKey:@"ImageTag"];
                        picList.imageURL = [dic objectForKey:@"ImageURL"];
                        [_picRes.TGPicList addObject:picList];
                    }
                }
            }
            [_beautyEditTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)requestrequestEditCustomerPic:(CustomerTGPicRes *)picRes
{
    //    /image/editCustomerPic 修改记录
    //    所需参数
    //    {"RecordImgID":"2012568547854","GroupNo":160,"ImageTag":"160","Type":1}
    //
    //    Type==1 删除TG的美丽记录 GroupNo必传
    //    Type==2 删除的美丽记录的单张照片 RecordImgID必传
    //    Type==3 修改美丽记录TAG RecordImgID必传
    NSDictionary *paraGet = @{@"GroupNo":picRes.groupNo,
                              @"Type":@(1),
                              };
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestUpdateServiceEffectImageOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/editCustomerPic"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSNumber class]]) {
                NSNumber  *dataNum = (NSNumber *)data;
                if (dataNum.boolValue) {
                    NSLog(@"删除成功");
                    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[BeautyRecordViewController class]]) {
                            [self.navigationController popToViewController:obj animated:YES];
                        }
                    }];
                }else{
                    NSLog(@"删除失败");
                }
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestUpdateServiceEffectImage:(CustomerTGPicRes *)picRes
{
    NSDictionary *paraGet = @{@"GroupNo":picRes.groupNo,
                              @"CustomerID":@(CUS_CUSTOMERID),
                              @"Comment":picRes.comments,
                            };
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestUpdateServiceEffectImageOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/UpdateServiceEffectImage"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSNumber class]]) {
                NSNumber  *dataNum = (NSNumber *)data;
                if (dataNum.boolValue) {
                    NSLog(@"标签更新成功");
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    NSLog(@"标签更新失败");
                }
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestShareGroupNo:(CustomerTGPicRes *)picRes
{
//    /ShareToOther/ShareGroupNo
//    参数 GroupNo
//
    NSNumber  *type;
    NSString *serviceURLStr  = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DATABASE"];
    if ([serviceURLStr isEqualToString:kGPBaseURLString_Test]) {
       type = @(2);
    }else{
        type = @(1);
    }
    NSDictionary *paraGet = @{@"GroupNo":picRes.groupNo,@"Type":type};
    [SVProgressHUD showWithStatus:@"Loading"];
  _requestShareGroupNoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ShareToOther/ShareGroupNo"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if([data isKindOfClass:[NSString class]]){
                NSString *urlStr = (NSString *)data;
                [self share:urlStr];
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}



#pragma mark 备注编辑

- (BOOL)contentEditCell:(RemarkEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    contentText.returnKeyType = UIReturnKeyDefault;
    
    return YES;
}

- (void)contentEditCell:(RemarkEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
    if ([textView.text isEqualToString:@"留下你的心情"]) {
        textView.text = @"";
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
    CGRect rect = textView.frame;
    rect.size.width = 310;
    textView.frame = rect;
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length >= 300) {
                textView.text = [toBeString substringToIndex:300];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 300) {
            textView.text = [toBeString substringToIndex:300];
        }
    }
}

- (BOOL)contentEditCell:(RemarkEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    return YES;
}

- (BOOL)contentEditCell:(RemarkEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)contentEditCell:(RemarkEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
    _picRes.comments = textView.text;
}

- (void)contentEditCell:(RemarkEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [_beautyEditTableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 16;
        _prevCaretRect = newCursorRect;
        [_beautyEditTableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(310.0f, 500.0f)];
    if (textViewSize.height < kTableView_DefaultCellHeight) {
        textViewSize.height = kTableView_DefaultCellHeight;
    }
    if (textViewSize.width < 310) {
        textViewSize.width = 310;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    _picRes.comments = textView.text;
    
    [_beautyEditTableView beginUpdates];
    [_beautyEditTableView endUpdates];
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark 点击收回键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _beautyEditTableView.frame;
    tvFrame.size.height = table_Height - (initialFrame.size.height + 5.0f);
    _beautyEditTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    _beautyEditTableView.frame = CGRectMake( 0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.height - 90.0f-44);
}



@end
