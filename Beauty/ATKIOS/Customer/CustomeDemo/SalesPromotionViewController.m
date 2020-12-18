//
//  SalesPromotionViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-9-4.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "SalesPromotionViewController.h"
#import "GPHTTPClient.h"
#import "UIImageView+WebCache.h"
#import "CacheInDisk.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "SalesPromotionDoc.h"
#import "GDataXMLDocument+ParseXML.h"
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "UIButton+InitButton.h"

@interface SalesPromotionViewController ()
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) int salesWidth;
@property (assign, nonatomic) int salesHeight;
@property (strong, nonatomic) SalesPromotionDoc *salesPromotionDoc;
@property (strong, nonatomic) NSMutableArray *mutableSalesPromotionArray;
@property (strong, nonatomic) NSArray *imageArray;                              //存放静态图片
@property (strong, nonatomic) NSMutableArray *mutableImgArray;
@property (strong, nonatomic) UIScrollView *myScrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIView *frontPage;                                //正面
@property (strong, nonatomic) UIView *backPage;                                 //反面
@property (assign, nonatomic) BOOL isTurnOver;
@property (strong, nonatomic) UIButton *detailButton;
@end

@implementation SalesPromotionViewController
@synthesize salesPromotionList;
@synthesize myScrollView;
@synthesize pageControl;
@synthesize currentPage;
@synthesize salesWidth, salesHeight;
@synthesize mutableSalesPromotionArray;
@synthesize imageArray, mutableImgArray;

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
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    if(self.promotionSource == 0)
        [self requesNoticeList];
    else
        [self requestSalesPromotionListByJsonWithWidth:salesWidth*2 andHeight:salesHeight*2];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}


- (void)viewDidLoad
{
    self.navigationController.delegate = self;
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 11, 300, kSCREN_BOUNDS.size.height - 100 + 20)];
    [self.view addSubview:myScrollView];
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(81, myScrollView.frame.origin.y + myScrollView.frame.size.height + 10, 157, 36)];
    [self.view addSubview:pageControl];
    
    salesWidth = myScrollView.bounds.size.width;
    salesHeight = myScrollView.bounds.size.height;
    
    _detailButton = [UIButton buttonWithTitle:@""
                                       target:self
                                     selector:@selector(click:)
                                        frame:CGRectMake(276.0f, 0, 65.0f, 65.0f)
                                backgroundImg:[UIImage imageNamed:@"handOfPromotion"]
                             highlightedImage:nil];
    
    _detailButton.frame = CGRectMake(230, self.myScrollView.frame.size.height - 35, 65, 65);
    _detailButton.hidden = YES;
    [self.view addSubview:_detailButton];
}

- (void)configScrollView
{
    myScrollView.pagingEnabled = YES;                   //设为YES时，会按页滑动
    myScrollView.bounces = NO;                          //取消UIScrollView的弹性属性，这个可以按个人喜好来定
    self.myScrollView.delegate = self;                  //UIScrollView的delegate函数在本类中定义
    myScrollView.showsHorizontalScrollIndicator = NO;   //因为我们使用UIPageControl表示页面进度，所以取消UIScrollView自己的进度条。
    
    self.pageControl.layer.cornerRadius = 8.0f;
    self.pageControl.numberOfPages = [mutableSalesPromotionArray count];
    self.pageControl.currentPage = 0;
    self.pageControl.enabled = YES;
    
    [self addListInScrollView];
}

- (void)addListInScrollView
{
    if (mutableImgArray == nil) {
        mutableImgArray = [NSMutableArray array];
    }
    if (imageArray.count == 1)
        [mutableImgArray addObjectsFromArray:imageArray];
    else
        [mutableImgArray addObjectsFromArray:imageArray];
    
    CGFloat Width = self.myScrollView.frame.size.width;
    CGFloat Height = self.myScrollView.frame.size.height;
    self.myScrollView.contentSize = CGSizeMake(Width * [mutableImgArray count], self.myScrollView.frame.size.height);

    
    for (int i=0; i<[mutableImgArray count]; i++) {
        SalesPromotionDoc *showSalesPromotionDoc = [[SalesPromotionDoc alloc] init];
        showSalesPromotionDoc = [mutableImgArray objectAtIndex:i];
        UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(Width*i, 0, Width, Height)];
        view.tag = i;
        [self.myScrollView addSubview:view];
        if (showSalesPromotionDoc.salesPromotion_Type == 0) {
            UIImageView *subViews=[[UIImageView alloc] init];
            [subViews setImageWithURL:[NSURL URLWithString:showSalesPromotionDoc.salesPromotion_Url] placeholderImage:[UIImage imageNamed:@""]];
            subViews.tag = 2;
            subViews.frame=CGRectMake(0, 0, Width, Height);
            subViews.userInteractionEnabled = YES;
            [view addSubview:subViews];
        } else {
            UITextView *textViews = [[UITextView alloc] init];
            textViews.text = [NSString stringWithFormat:@"  %@", showSalesPromotionDoc.salesPromotion_Text];
            textViews.textColor = [UIColor blackColor];
            textViews.font = kFont_Light_18;
            textViews.backgroundColor = [UIColor whiteColor];
            textViews.tag = 2;
            textViews.frame = CGRectMake(0, 0, Width, Height);
            textViews.userInteractionEnabled = YES;
            textViews.editable = NO;
            [view addSubview: textViews];
            
        }
    }
    
    if (mutableImgArray.count == 0 || (mutableImgArray.count > 0 && [[mutableImgArray objectAtIndex:pageControl.currentPage] salesPromotion_Type] == 3))
        _detailButton.hidden = YES;
    else
        _detailButton.hidden = NO;
}

- (UIView *)addView:(CGRect)frame andIndex:(NSInteger)index
{

    CGFloat Height = frame.size.height;
    CGFloat y = 0.f;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,frame.size.width, frame.size.height)];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2 - 130, 30, 260, 200)];
    view.layer.cornerRadius = 5;
    view.userInteractionEnabled = NO;
    [backgroundView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleBranch = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 80, 24)];
    titleBranch.text = @"促销门店";
    titleBranch.textColor =kColor_TitlePink;
    titleBranch.userInteractionEnabled = NO;
    titleBranch.backgroundColor = [UIColor clearColor];
    [view addSubview:titleBranch];
    
    UITextView *textBranch = [[UITextView alloc] initWithFrame:CGRectMake(20, 30, 230, 60)];
    textBranch.backgroundColor = [UIColor clearColor];
    textBranch.text = [[mutableImgArray objectAtIndex:index] salesPromotion_BranchName];
    textBranch.font = kFont_Light_16;
    CGSize size = [textBranch.text sizeWithFont:textBranch.font constrainedToSize:CGSizeMake(textBranch.contentSize.width - 8, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect rect = textBranch.frame;
    rect.size.height = size.height + 21;
    textBranch.frame = rect;
    if (IOS7 || IOS8)
        [textBranch setSelectable:NO];
    [textBranch setEditable:NO];
    [textBranch setScrollEnabled:NO];
    [textBranch setUserInteractionEnabled:NO];
    [view addSubview:textBranch];
    y = textBranch.frame.origin.y + textBranch.frame.size.height;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, y + 6, 260, .5)];
    line.backgroundColor = [UIColor colorWithRed:200.0/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:.5f];
    line.userInteractionEnabled = NO;
    [view addSubview:line];
    
    UILabel *titleTime = [[UILabel alloc] initWithFrame:CGRectMake(8, y + 12, 80, 24)];
    titleTime.text = @"促销时间";
    titleTime.textColor =kColor_TitlePink;
    titleTime.backgroundColor = [UIColor clearColor];
    titleTime.userInteractionEnabled = NO;
    [view addSubview:titleTime];
    y = titleTime.frame.origin.y + titleTime.frame.size.height;
    
    UITextView *textTime = [[UITextView alloc] initWithFrame:CGRectMake(20, y , 230, 30)];
    textTime.backgroundColor = [UIColor  clearColor];
    textTime.font = kFont_Light_16;
    textTime.text = [NSString stringWithFormat:@"%@ ~ %@",[[mutableImgArray objectAtIndex:index] salesPromotion_StartTime],[[mutableImgArray objectAtIndex:index] salesPromotion_EndTime]];
    [textTime setEditable:NO];
    if (IOS7 || IOS8)
        [textTime setSelectable:NO];
    [textTime setScrollEnabled:NO];
    [textTime setUserInteractionEnabled:NO];
    [view addSubview:textTime];
    
    
    UIButton *button = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(click1:)
                                           frame:CGRectMake(276.0f, 0, 65, 65)
                                   backgroundImg:[UIImage imageNamed:@"handOfPromotion"]
                                highlightedImage:nil];
    
    button.frame = CGRectMake(230, backgroundView.frame.size.height - 65, 65, 65);

    [self.myScrollView addSubview:backgroundView];
    
    backgroundView.tag = 1000;
    backgroundView.hidden = YES;
    rect = view.frame;
    rect.origin.y = (Height - y - 60)/2;
    rect.size.height = y + 36;
    view.frame = rect;
    if (frame.size.width != 320)
        [backgroundView addSubview:button];
    else {
        backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        tap.delegate = self;
        [backgroundView addGestureRecognizer:tap];
    }

    return backgroundView;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *backGroundView = touch.view;
    UIView *view = [[backGroundView subviews] objectAtIndex:0];
    CGPoint point = [touch locationInView:view];

    if (point.x > 0 && point.y > 0 && point.x < view.frame.size.width && point.y < view.frame.size.height)
        return NO;
    return YES;
}

//淡入动画
-(void)click:(UIView *)sender
{
    
    if (!_isTurnOver){
        UIView *view  =[self addView:[UIScreen mainScreen].bounds andIndex:pageControl.currentPage];
        view.hidden = NO;
        [[[UIApplication sharedApplication] keyWindow] addSubview:view];
        _frontPage = view;
        
        [UIView animateWithDuration:.4 animations:^{
            view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
            [[view.subviews objectAtIndex:0] setBackgroundColor:[UIColor whiteColor]];
        } completion:^(BOOL finished) {
            _isTurnOver = YES;
        }];
        
    }else{
        [_frontPage  removeFromSuperview];
        _isTurnOver = NO;
    }
}
//翻转动画（弃用）
- (void)click1:(UIView *)sender
{
    BOOL show = [[mutableImgArray objectAtIndex:self.pageControl.currentPage] isShow];
    if (!show)
    {
        _frontPage = sender.superview;
        _backPage = [[sender.superview.superview subviews] objectAtIndex:0];
        if ([_backPage isKindOfClass:[UITextView class]] || [_backPage isKindOfClass:[UIImageView class]])
            _backPage = [[sender.superview.superview subviews] objectAtIndex:1];

        _frontPage.hidden = _backPage.hidden = NO;
        
        [UIView transitionFromView:_frontPage toView:_backPage duration:.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            UIView *view = _frontPage;
            _frontPage = _backPage;
            _backPage = view;
            _backPage.hidden = YES;
            [_frontPage.superview addSubview:_backPage];
            [[mutableImgArray objectAtIndex:self.pageControl.currentPage] setIsShow:YES];
        }];
        
    }else{
        _frontPage = sender.superview;
        _backPage = [[sender.superview.superview subviews] objectAtIndex:1];
        if (!([_backPage isKindOfClass:[UITextView class]] || [_backPage isKindOfClass:[UIImageView class]]))
            _backPage = [[sender.superview.superview subviews] objectAtIndex:0];

        _frontPage.hidden = _backPage.hidden = NO;
        [UIView transitionFromView:_frontPage toView:_backPage duration:.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            UIView *view = _frontPage;
            _frontPage = _backPage;
            _backPage = view;
            _backPage.hidden = YES;
            [_frontPage.superview addSubview:_backPage];
            [[mutableImgArray objectAtIndex:self.pageControl.currentPage] setIsShow:NO];
        }];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setPageControl:nil];
    [self setMyScrollView:nil];
    [super viewDidUnload];
}

#pragma UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth=self.myScrollView.frame.size.width;
//    CGFloat pageHeigth=self.myScrollView.frame.size.height;
    currentPage = floor((self.myScrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    
    self.pageControl.currentPage = currentPage % imageArray.count;

    if (mutableImgArray.count > 0 && [[mutableImgArray objectAtIndex:pageControl.currentPage] salesPromotion_Type] == 3)
        _detailButton.hidden = YES;
    else
        _detailButton.hidden = NO;

//    NSLog(@" page %ld  x %f",self.pageControl.currentPage,self.myScrollView.contentOffset.x);
//    if (currentPage == 0) {
//        if (imageArray.count != 1) {
//            [self.myScrollView scrollRectToVisible:CGRectMake(pageWidth * imageArray.count, 0, pageWidth, pageHeigth) animated:NO];
//            return;
//        } else {
//            return;
//        }
//    }else  if(currentPage == [mutableImgArray count] - 1){
//        [self.myScrollView scrollRectToVisible:CGRectMake(pageWidth * ([imageArray count] - 1), 0, pageWidth, pageHeigth) animated:NO];
//        return;
//    }
}

#pragma mark - 接口


- (void)requestSalesPromotionListByJsonWithWidth:(NSInteger)width andHeight:(NSInteger)height
{
    if(self.promotionSource == 1){
        if (mutableSalesPromotionArray == nil){
            mutableSalesPromotionArray = [NSMutableArray array];
        } else {
            [mutableSalesPromotionArray removeAllObjects];
        }
    }
    NSMutableArray *mSPArray = [NSMutableArray arrayWithArray:mutableSalesPromotionArray];
    [SVProgressHUD showWithStatus:@"Loading"];

    NSDictionary *para = @{@"ImageHeight":@(height),
                           @"ImageWidth":@(width)};
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/Promotion/GetPromotionList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            for (NSDictionary *obj in data){
                SalesPromotionDoc *temporarySalesPromotionDoc = [[SalesPromotionDoc alloc] init];
                temporarySalesPromotionDoc.PromotionCode = obj[@"PromotionCode"];
                temporarySalesPromotionDoc.salesPromotion_Type = [obj[@"Type"] integerValue];
                temporarySalesPromotionDoc.salesPromotion_Text = (obj[@"Title"] == [NSNull null] ? @"":obj[@"Title"]);
                temporarySalesPromotionDoc.salesPromotion_Url = (obj[@"PromotionPictureURL" ] == [NSNull null] ? @"":obj[@"PromotionPictureURL" ]);
                
                NSMutableString *name = [NSMutableString string];
                NSArray *array = obj[@"BranchList"];
                array = (NSNull *)array == [NSNull null] ? nil : array;
                for (NSDictionary *branch in array) {
                    [name appendString:[branch objectForKey:@"BranchName"]];
                    if (branch != [array lastObject])
                        [name appendString:@","];
                }
                
                temporarySalesPromotionDoc.salesPromotion_BranchName = name;
                temporarySalesPromotionDoc.salesPromotion_StartTime = obj[@"StartDate"] == [NSNull null] ? @"":obj[@"StartDate"];
                temporarySalesPromotionDoc.salesPromotion_EndTime = obj[@"EndDate"] == [NSNull null] ? @"":obj[@"EndDate"];
                [mSPArray addObject:temporarySalesPromotionDoc];
            }
            mutableSalesPromotionArray = mSPArray;
            imageArray = mutableSalesPromotionArray;
            [self configScrollView];
            if(imageArray.count <= 0){
                [self updateBackground];
            }
        } failure:^(NSInteger code, NSString *error) {
            if(self.promotionSource == 0)
                [self configScrollView];
            [self updateBackground];
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {

        if(self.promotionSource == 0)
            [self configScrollView];
        [self updateBackground];
    }];
//    [[GPHTTPClient shareClient] requestSalesPromotionWithByJsonWidth:width andHeight:height success:^(id xml) {
//        [SVProgressHUD dismiss];
//        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data, NSInteger code, id message) {
//            for (NSDictionary *obj in data){
//                SalesPromotionDoc *temporarySalesPromotionDoc = [[SalesPromotionDoc alloc] init];
//                temporarySalesPromotionDoc.salesPromotion_ID = [obj[@"PromotionID"] intValue];
//                temporarySalesPromotionDoc.salesPromotion_Type = [obj[@"PromotionType"] integerValue];
//                temporarySalesPromotionDoc.salesPromotion_Text = (obj[@"PromotionContent"] == [NSNull null] ? @"":obj[@"PromotionContent"]);
//                temporarySalesPromotionDoc.salesPromotion_Url = (obj[@"PromotionPictureURL" ] == [NSNull null] ? @"":obj[@"PromotionPictureURL" ]);
//                
//                NSMutableString *name = [NSMutableString string];
//                NSArray *array = obj[@"BranchList"];
//                array = (NSNull *)array == [NSNull null] ? nil : array;
//                for (NSDictionary *branch in array) {
//                    [name appendString:[branch objectForKey:@"BranchName"]];
//                    if (branch != [array lastObject])
//                        [name appendString:@","];
//                }
//                
//                temporarySalesPromotionDoc.salesPromotion_BranchName = name;
//                temporarySalesPromotionDoc.salesPromotion_StartTime = obj[@"StartDate"];
//                temporarySalesPromotionDoc.salesPromotion_EndTime = obj[@"EndDate"];
//                [mSPArray addObject:temporarySalesPromotionDoc];
//            }
//            mutableSalesPromotionArray = mSPArray;
//            imageArray = mutableSalesPromotionArray;
//            [self configScrollView];
//            if(imageArray.count <= 0){
//                [self updateBackground];
//            }
//        } failure:^(NSInteger code, NSString *error) {
//            if(self.promotionSource == 0)
//                [self configScrollView];
//            [self updateBackground];
//        }];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        if(self.promotionSource == 0)
//            [self configScrollView];
//        [self updateBackground];
//        
//        NSLog(@"Eeror:%@ address:%s",error, __FUNCTION__);
//    }];
}
- (void)requesNoticeList
{
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/notice/getNoticeList"  showErrorMsg:YES  parameters:nil WithSuccess:^(id json) {
        if (mutableSalesPromotionArray == nil){
            mutableSalesPromotionArray = [NSMutableArray array];
        } else {
            [mutableSalesPromotionArray removeAllObjects];
        }
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
           NSMutableArray *noticeArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SalesPromotionDoc *notice = [[SalesPromotionDoc alloc] init];
                [notice setSalesPromotion_Text:(obj[@"NoticeTitle"]  == [NSNull null] ? @"" : obj[@"NoticeTitle"])];
                [notice setSalesPromotion_Text:(obj[@"NoticeContent"]  == [NSNull null] ? @"":obj[@"NoticeContent"])];
                [notice setSalesPromotion_Type:3];
                [noticeArray addObject:notice];
            }];
            mutableSalesPromotionArray = noticeArray;
            imageArray = mutableSalesPromotionArray;
            [self requestSalesPromotionListByJsonWithWidth:salesWidth*2 andHeight:salesHeight*2];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
//   [[GPHTTPClient shareClient] requestGetNoticeListWithSuccess:^(id xml) {
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData) {
//            if (mutableSalesPromotionArray == nil){
//                mutableSalesPromotionArray = [NSMutableArray array];
//            } else {
//                [mutableSalesPromotionArray removeAllObjects];
//            }
//            NSMutableArray *noticeArray = [NSMutableArray array];
//            for (GDataXMLElement *data in [contentData elementsForName:@"Notice"]) {
//                SalesPromotionDoc *notice = [[SalesPromotionDoc alloc] init];
//                [notice setSalesPromotion_Text:([[[data elementsForName:@"NoticeTitle"] objectAtIndex:0] stringValue] == nil ? @"" : [[[data elementsForName:@"NoticeTitle"] objectAtIndex:0] stringValue])];
//                [notice setSalesPromotion_Type:3];
//                [notice setSalesPromotion_Text:([[[data elementsForName:@"NoticeContent"] objectAtIndex:0] stringValue] == nil ? @"":[[[data elementsForName:@"NoticeContent"] objectAtIndex:0] stringValue])];
//                [noticeArray addObject:notice];
//            }
//            mutableSalesPromotionArray = noticeArray;
//            imageArray = mutableSalesPromotionArray;
//            [self requestSalesPromotionListByJsonWithWidth:salesWidth*2 andHeight:salesHeight*2];
//        } failure:^{
//        }];
//    } failure:^(NSError *error) {
//        NSLog(@"Error:%@ address:%s",error.description, __FUNCTION__);
//    }];
}

- (void)updateBackground{
    
    if (kSCREN_BOUNDS.size.height >= 548.0f) {
        [_imageView setImage:[UIImage imageNamed:@"WelcomeImg_640x1008"]];
    } else {
        [_imageView setImage:[UIImage imageNamed:@"WelcomeImg"]];
    }
}
@end
