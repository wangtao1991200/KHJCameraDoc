//
//  CloudVController.m
//  KHJCamera
//
//  Created by hezewen on 2018/8/27.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "CloudVController.h"
#import <WebKit/WebKit.h>
#import "KHJPayView.h"
#import <AlipaySDK/AlipaySDK.h>
#import <WXApi.h>
#import "KHJPayResultVController.h"
@interface CloudVController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

{
    WKWebView *wkWebView;
    UIButton *backBtn;
    UIBarButtonItem  *barBut;
    KHJPayView *payView;
}
@property (weak, nonatomic) CALayer *progresslayer;
@property (assign, nonatomic) NSUInteger payKind;

@end

@implementation CloudVController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = KHJLocalizedString(@"cloudService", nil);
    [self setbackBtn];
    [self setWebView];

}

#pragma mark - setbackBtn
- (void)setbackBtn
{
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame =CGRectMake(0,0, 66, 44);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);//解决按钮不能靠左问题
    [backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    barBut = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = barBut;
}
- (void)backViewController
{
    //判断是否能返回到H5上级页面
    if (wkWebView.canGoBack==YES) {
        //返回上级页面
        [wkWebView goBack];
    }else{
        //退出控制器
        [wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (KHJPayView *)getPayView
{
    if (payView == nil) {
        payView = [[KHJPayView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-320, SCREEN_WIDTH, 320)];
    }
    return payView;
}
#pragma mark - setWebView
- (void)setWebView{
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 创建UserContentController（提供JavaScript向webView发送消息的方法）
    WKUserContentController* userContent = [[WKUserContentController alloc] init];
    // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
    //NativeMethod 这个方法一会要与JS里面的方法写的一样
    [userContent addScriptMessageHandler:self name:@"NativeMethod"];
    // 将UserConttentController设置到配置文件
    config.userContentController = userContent;
    

    wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-Height_NavBar)];
    
//    NSURL *url = [NSURL URLWithString:REQUEST_URLH_FOR_PAY];

    NSString *uString = [NSString stringWithFormat:@"http://www.khjtecapp.com/smart-camera-ucenter/h5/pay?deviceUid=%@",self.deviceID];
    NSURL *url = [[NSURL alloc] initWithString:uString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *languageValue = nil;
    //获取手机系统语言
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        languageValue = @"1";
    } else if ([language hasPrefix:@"zh"]) {

        languageValue = @"-1";

    } else {
        languageValue = @"1";
    }
    [request addValue:languageValue forHTTPHeaderField:@"language"];
    [wkWebView loadRequest:request];
    wkWebView.navigationDelegate = self;
    wkWebView.UIDelegate = self;
    [self.view addSubview:wkWebView];
    
    //进度条76 151 243
    UIView *progress = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 3)];
    progress.backgroundColor = [UIColor clearColor];
    [self.view addSubview:progress];
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = ssRGB(76,151,243).CGColor;
    [progress.layer addSublayer:layer];
    self.progresslayer = layer;
    
    [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];

}
#pragma mark -WKUIDelegate
// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{//这里修改导航栏的标题，动态改变
    
//    self.title = webView.title;
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
    CLog(@"didReceiveServerRedirectForProvisionalNavigation");
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
//    CLog(@"%@",webView);
//    CLog(@"%@",navigationResponse);
    
    WKNavigationResponsePolicy actionPolicy = WKNavigationResponsePolicyAllow;
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
    
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    CLog(@"navigationAction.request.URL.query=%@", navigationAction.request.URL.query);
    if([[navigationAction.request.URL absoluteString] isEqualToString:@"js://pay"])
    {
        [self showAlert];
    }else if([[navigationAction.request.URL absoluteString] containsString:@"js://webview"]){
        
        NSDictionary *dic = [self dictionaryFromQuery:navigationAction.request.URL.query];
        NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [mDic setValue:self.deviceID forKey:@"deviceUid"];
        if(self.payKind == 0){
            [mDic setValue:@"0" forKey:@"payType"];
        }else{
            [mDic setValue:@"1" forKey:@"payType"];
        }
        [self handleGetOrder:mDic];
    }
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    if (navigationAction.navigationType==WKNavigationTypeBackForward) {//判断是返回类型
        
    }
    //这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}
#pragma mark - handleSelf
- (void)handleGetOrder:(NSMutableDictionary *)mDic
{
    [[KHJNetWorkingManager sharedManager] getOrderList:mDic returnCode:^(NSDictionary *dict, NSInteger c) {
        
        if (c == 1) {
            if(self.payKind == 0){//支付宝支付
                NSString *DataStr = [dict objectForKey:@"data"];

                [[AlipaySDK defaultService] payOrder:DataStr fromScheme:@"com.khj.KHJCameraRelease" callback:^(NSDictionary *resultDic) {
                    
                    CLog(@"resultDic = %@",resultDic);
                    NSInteger returnCode = [[resultDic objectForKey:@"resultStatus"] integerValue];
                    if (returnCode == 9000) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            KHJPayResultVController *payResultVC = [KHJPayResultVController alloc];
                            payResultVC.isSuccess = YES;
                            [self.navigationController pushViewController:payResultVC animated:YES];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            KHJPayResultVController *payResultVC = [KHJPayResultVController alloc];
                            payResultVC.isSuccess = NO;
                            [self.navigationController pushViewController:payResultVC animated:YES];
                        });
                    }
                }];
            }else{//微信支付

                NSDictionary *payDic = [dict objectForKey:@"data"];
                NSString *noncestr = [payDic objectForKey:@"noncestr"];
                NSString *packages = [payDic objectForKey:@"packages"];
                NSString *partnerid = [payDic objectForKey:@"partnerid"];
                                NSString *prepayid = [payDic objectForKey:@"prepayid"];
                NSString *sign = [payDic objectForKey:@"sign"];
                uint32_t timestamp = [[payDic objectForKey:@"timestamp"] intValue];
                PayReq *request = [[PayReq alloc] init];
                request.partnerId = partnerid;
                request.prepayId= prepayid;
                request.package = packages;
                request.nonceStr= noncestr;
                request.timeStamp = timestamp;
                request.sign= sign;
                if([WXApi isWXAppInstalled]){
                    BOOL isRet = [WXApi sendReq:request];
                    CLog(@"isRet == %d",isRet);
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[KHJHub shareHub] showText:KHJLocalizedString(@"NoWechat", nil) addToView:self.view];
                    });
                }
            }
           
        }
    }];
}
- (NSDictionary*)dictionaryFromQuery:(NSString*)query
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString* value = [[kvPair objectAtIndex:1] stringByRemovingPercentEncoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}
- (void)showAlert//弹出支付方式
{
    CLog(@"showAlert");
    payView = [self getPayView];
    [payView show];
    WeakSelf
    [payView setBtnClickPayBlock:^(NSInteger kind) {
       
        weakSelf.payKind = kind;
        [weakSelf handle:kind];
    }];
}
- (void)handle:(NSInteger)kind
{

    
    [wkWebView evaluateJavaScript:@"callAndroid()" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
        CLog(@"ojb = %@",obj);
    }];
    //    wkWebView.loadUrl("javascript:callAndroid()");
}
//设置绕过证书验证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
        
    }
}
#pragma mark - progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{ if ([keyPath isEqualToString:@"estimatedProgress"])
{
    self.progresslayer.opacity = 1;
    if ([change[@"new"] floatValue] < [change[@"old"] floatValue])
    {
        return;
        
    }
    self.progresslayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[@"new"] floatValue], 3);
    if ([change[@"new"] floatValue] == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ self.progresslayer.opacity = 0;
            
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progresslayer.frame = CGRectMake(0, 0, 0, 3); }); } }else{ [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
                
            }
    
}
#pragma mark - WKScriptMessageHandler
-(void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message
{
    CLog(@"didReceiveScriptMessage");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end







