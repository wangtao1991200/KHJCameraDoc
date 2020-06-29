//
//  AddSuerVController.m
//
//  配网连接
//  Distribution network connection
//
//

#import "KHJAddSuerVController.h"
#import "KHJAllBaseManager.h"
#import "XNRefreshView.h"
#import "UIViewController+XNProgressHUD.h"
#import <SystemConfiguration/CaptiveNetwork.h>

// Include header files
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define CWIDTH (SCREENWIDTH*2/5)
#define DWIDTH (15)

//static AddSuerVController *selfClass1 =nil;

@interface KHJAddSuerVController ()
{
    XNRefreshView * _refreshView;
    NSTimer *pTimer;
    int pCount;
    NSTimer *mTimer;
    int mCount;
    // Device password
    NSString *newPwdString;
    BOOL isFirstInto;
    // Device account default admin
    NSString *dAccount;
    // Device version
    NSString *dVersion;
    UIButton *sureBtn;
    dispatch_source_t checkWifiTime;
    BOOL isNewFirmware;
}
@property (weak, nonatomic) IBOutlet UIView *roundView;
@property (nonatomic, assign) CFSocketRef clientSockfd;

@end

@implementation KHJAddSuerVController
@synthesize ssidName;
@synthesize ppPwd;

- (instancetype)init
{
    self = [super init];
    if (self) {
//        selfClass1 = self;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self setLittleRound];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (mTimer) {
        [mTimer invalidate];
        mTimer = nil;
    }
    if (pTimer) {
        [pTimer invalidate];
        pTimer = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = KHJLocalizedString(@"setNeConn", nil);
    self.view.backgroundColor = bgVCcolor;
    mCount = 0;
    [self setbackBtn];
    pTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeSlider) userInfo:nil repeats:YES];
    mTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeShow) userInfo:nil repeats:YES];
    [self setKSlider];
    [NSThread detachNewThreadSelector:@selector(connectTCPSer) toTarget:self withObject:nil];
}

#pragma mark  - Connection success callback

- (void)changeShow
{
    for (int i = 0; i <5; i++) {
        UIImageView *imgV = (UIImageView *)[self.roundView viewWithTag:140+i];
        if (mCount == i) {
            imgV.image = [UIImage imageNamed:@"white_p"];
        }else{
            imgV.image = [UIImage imageNamed:@"Orange_p"];
        }
    }
    mCount ++;
    if (mCount == 5) {
        mCount = 0;
    }
}
- (void)setLittleRound
{
    CGFloat ww = self.roundView.frame.size.width;
    CGFloat hh = self.roundView.frame.size.height;
    int space = ((int)ww  -  DWIDTH*5)/6;
    for (int i = 0; i <5; i++) {
        UIImageView *imgV =[[UIImageView alloc] initWithFrame:CGRectMake(space*(i+1)+(DWIDTH*i), (hh-DWIDTH)/2, DWIDTH,DWIDTH)];
        imgV.image = [UIImage imageNamed:@"Orange_p"];
        imgV.tag = 140+i;
        [self.roundView addSubview:imgV];
    }
}

- (void)setbackBtn
{
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame =CGRectMake(0,0, 66, 44);
    but.imageEdgeInsets = UIEdgeInsetsMake(0,-40, 0, 0);
    [but setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:but];
    self.navigationItem.leftBarButtonItem = barBut;
}

- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
    if (pTimer) {
        [pTimer invalidate];
        pTimer = nil;
    }
}

- (void)setKSlider
{
    _refreshView = [[XNRefreshView alloc] initWithFrame:CGRectMake(0, 0, CWIDTH, CWIDTH)];
    _refreshView.tintColor = DeCcolor;
    _refreshView.lineWidth = 8.f;
    _refreshView.label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:20.f];

    _refreshView.style = XNRefreshViewStyleProgress;
    _refreshView.center = CGPointMake((SCREENWIDTH)/2, (SCREENHEIGHT-64)/2);
    _refreshView.progress = 0;
    [self.view addSubview:_refreshView];
    
    [[XNProgressHUD shared] setPosition:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.7)];
    [[XNProgressHUD shared] setTintColor:[UIColor colorWithRed:10/255.0 green:85/255.0 blue:145/255.0 alpha:0.7]];
    
    [self.hud setPosition:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.7)];
    [self.hud setTintColor:[UIColor colorWithRed:38/255.0 green:50/255.0 blue:56/255.0 alpha:0.8]];
    [self.hud setRefreshStyle:(XNRefreshViewStyleProgress)];
    [self.hud setMaskType:(XNProgressHUDMaskTypeBlack)  hexColor:0x00000044];
    [self.hud setMaskType:(XNProgressHUDMaskTypeCustom) hexColor:0xff000044];
}
- (void)changeSlider
{
    _refreshView.progress = (pCount*100/60.0) /100.0;
    pCount ++;
    if (pCount>59 && pTimer) {
        [pTimer invalidate];
        pTimer = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Connect process, add devices
- (IBAction)clickSureListen:(UIButton *)sender
{
    [self showAlertConnected];
}

- (void)backRootVC
{
    if (pTimer) {
        [pTimer invalidate];
        pTimer = nil;
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showAlertConnected
{
    WeakSelf
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:KHJLocalizedString(@"ConfirmHeardConnectSuccess", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf backRootVC];
        });
    }];
    [alertview addAction:cancel];
    [alertview addAction:defult];
    [self presentViewController:alertview animated:YES completion:nil];
}

#pragma mark - CFSock

- (void)connectTCPSer
{
    BOOL success;
    // Create socket
    self.clientSockfd = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, ServerConnectCallBack, NULL);
    success = (self.clientSockfd != nil);
    NSString *logStr = nil;
    if (success == NO) {
        logStr = @"Failed to create socket...\n";
        CLog(@"%@",logStr);
        return;
    }
    else {
        logStr = @"Failed to create socket...\n";
        CLog(@"%@",logStr);

        // server address
        struct sockaddr_in ser_addr;
        memset(&ser_addr, 0, sizeof(ser_addr));
        ser_addr.sin_len         = sizeof(ser_addr);
        ser_addr.sin_family      = AF_INET;
        NSString * portSti = @"10000";
        NSString *ttS =@"192.168.201.1";
        ser_addr.sin_port        = htons(portSti.intValue);
        ser_addr.sin_addr.s_addr = inet_addr(ttS.UTF8String);
        
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&ser_addr, sizeof((ser_addr)));
        // connection
        CFSocketError result = CFSocketConnectToAddress(self.clientSockfd, address, 5);
        CFRelease(address);
        success = (result == kCFSocketSuccess);
    }
    
    if (success == NO) {
        logStr = @"socket connection failed...\n";
        CLog(@"%@",logStr);
        return;
    }
    else {
        
        logStr = [NSString stringWithFormat:@"socket connection successful...\n"];
        CLog(@"%@",logStr);
        [self socketSendData];
        char buf[2048];
        do {
            // Receive data
            ssize_t recvLen = recv(CFSocketGetNative(self.clientSockfd), buf, sizeof(buf), 0);
            
            if (recvLen > 0) {
                logStr = [NSString stringWithFormat:@"recv：%@\n", [NSString stringWithFormat:@"%s", buf]];
                CLog(@"%@",logStr);
                if([[NSString stringWithFormat:@"%s", buf] isEqualToString:@"ok"]) {
                    CFSocketInvalidate(_clientSockfd);
                    [self showAlertConnected];
                }
            }
            
        } while (strcmp(buf, "exit") != 0);
        
        CFRunLoopRef cfrl = CFRunLoopGetCurrent();
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.clientSockfd, 0);
        CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
        CFRelease(source);
        CFRunLoopRun();
    }
}

// 连接成功的回调函数

// Callback function for successful connection

void ServerConnectCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void * data, void *info) {
    
    if (data != NULL) {
        NSLog(@"connect\n");
    }
    else {
        NSLog(@"connect success\n");
    }
}

- (void)socketSendData
{
    NSString *codeData = [NSString stringWithFormat:@"S=%@,P=%@",self.ssidName,self.ppPwd];
    
    // 发送数据
    
    // send data
    
    ssize_t sendLen = send(CFSocketGetNative(self.clientSockfd), codeData.UTF8String, strlen(codeData.UTF8String), 0);
}

@end












