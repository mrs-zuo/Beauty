//
//  ThirdWeChatWeb_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/29.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ThirdWeChatWeb_ViewController.h"
#import "WebKit/WebKit.h"

@interface ThirdWeChatWeb_ViewController ()
{
    WKWebView *webView;
}
@end

@implementation ThirdWeChatWeb_ViewController
@synthesize payType;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    if ((IOS7 || IOS8)) {
        webView.frame = CGRectMake(0, 0, 320.0f, kSCREN_BOUNDS.size.height - 64);
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        webView.frame = CGRectMake(0,0, 340.0f, kSCREN_BOUNDS.size.height - 64);
    }
    
    NSString *urlString;
    if (payType == PayTypeWeiXin) {
        urlString = @"http://kf.qq.com/touch/faq/151210NZzmuY151210ZRj2y2.html";
    }
    if (payType == PayTypeZhiFuBao) {
        urlString = @"https://cschannel.alipay.com/mobile/helpDetail.htm?help_id=419480";
    }
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.view addSubview: webView];
    [webView loadRequest:request];
}

- (void) webViewDidFinishLoad:(WKWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}
- (void) webView:(WKWebView *)webView didFailLoadWithError:(NSError *)error
{
//     NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
//    [webView loadRequest:request];
    
    NSLog(@"didFailLoadWithError:%@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
