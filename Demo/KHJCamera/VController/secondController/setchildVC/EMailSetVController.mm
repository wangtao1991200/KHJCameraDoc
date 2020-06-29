//
//  EMailSetVController.m
//
//
//
//
//

#import "EMailSetVController.h"
#import "KHJAllBaseManager.h"

@interface EMailSetVController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *openSwith;
@property (weak, nonatomic) IBOutlet UITextView *recvTextV;
@property (weak, nonatomic) IBOutlet UITextField *sendTextV;
@property (weak, nonatomic) IBOutlet UITextField *smtpCodeTextV;
@property (weak, nonatomic) IBOutlet UITextField *smtpAddressTextV;
@property (weak, nonatomic) IBOutlet UITextField *portTextV;
- (IBAction)changeOpenState:(UISwitch *)sender;

@end

@implementation EMailSetVController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = KHJLocalizedString(@"setAlarmEmail", nil);
    [self setbackBtn];
    [self setRightButton ];
    self.recvTextV.delegate = self;
    self.recvTextV.textColor = [UIColor lightGrayColor];
    [self getAlarmEmailInfo];
    [self getAlarmState];
    self.recvTextV.text = KHJLocalizedString(@"MNeedSeparate", nil);
}

#pragma mark - setbackBtn
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
- (void)setRightButton
{
    UIButton *addBut = [UIButton buttonWithType:UIButtonTypeCustom];
    addBut.frame = CGRectMake(0,0,44,44);
    [addBut addTarget:self action:@selector(saveAllData) forControlEvents:UIControlEventTouchUpInside];
    [addBut setTitle:KHJLocalizedString(@"save", nil) forState:UIControlStateNormal];
    UIBarButtonItem *settingBtnItem = [[UIBarButtonItem alloc] initWithCustomView:addBut];
    self.navigationItem.rightBarButtonItem  = settingBtnItem;
}
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)getAlarmState
{
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    WeakSelf
    if (dDevice) {
        
        [dDevice.mDeviceManager getEmailAlarm:^(BOOL isOpen) {
            
            [weakSelf getEmailAlarmCallBack:isOpen];
        }];
    }
}
- (IBAction)changeOpenState:(UISwitch *)sender
{

    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    WeakSelf
    if (dDevice) {
        
        [dDevice.mDeviceManager setEmailAlarm:sender.on returnBlock:^(BOOL success) {
            
            [weakSelf setEmailAlarmCallBack:success];
        }];
    }
}
#pragma mark - 邮箱报警开关返回
- (void)setEmailAlarmCallBack:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
        });
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
        });
    }
}
- (void)getEmailAlarmCallBack:(BOOL)isOpen
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.openSwith.on = isOpen;
    });
}
- (void)getAlarmEmailInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[KHJHub shareHub] showText:@"" addToView:self.view type:_lightGray];
    });
    KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
    WeakSelf
    if (dDevice) {
        [dDevice.mDeviceManager getEmail:^(NSString *userStr, NSString *userPwd, NSString *serverStr, NSString *sendTo,int mPort) {
            [weakSelf getEmailCallback:userStr andPwd:userPwd andServer:serverStr andSendto:sendTo andPort:mPort];
        }];
    }
    
}
#pragma mark - 返回邮件信息
/**
 * param1: 邮箱用户
 * param2: 邮箱密码
 * param3: 邮箱服务器
 * param4: 邮箱服务器端口
 * param5: 接收邮箱
 */

#pragma mark-return email message
/**
  * param1: email user
  * param2: email password
  * param3: mail server
  * param4: email server port
  * param5: receive email
  */
- (void)getEmailCallback:(NSString *)user andPwd:(NSString *)pass andServer:(NSString *)server andSendto:(NSString *)sendO andPort:(int)port
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [KHJHub shareHub].hud.hidden = YES;
        if (sendO && ![sendO isEqualToString:@""]) {
            
            self.recvTextV.text = user;
            self.recvTextV.textColor = UIColor.blackColor;
        }
        if (user && ![user isEqualToString:@""]) {
            
            self.sendTextV.text = user;
        }
        if (pass && ![pass isEqualToString:@""]) {
            
            self.smtpCodeTextV.text = pass;
        }
        if (server && ![server isEqualToString:@""]) {
            
            self.smtpAddressTextV.text = server;
        }
        if (port != 0) {
            
            self.portTextV.text = [NSString stringWithFormat:@"%d",port];
        }
    });
   
}
- (void)saveAllData
{
    BOOL canSave = ![self.recvTextV.text isEqualToString:@""] && ![self.sendTextV.text isEqualToString:@""] && ![self.smtpCodeTextV.text isEqualToString:@""] && ![self.smtpAddressTextV.text isEqualToString:@""] && ![self.portTextV.text isEqualToString:@""];
    if (canSave) {
        KHJBaseDevice *dDevice = [[KHJAllBaseManager sharedBaseManager] searchForkey:self.uuidStr];
        WeakSelf
        if (dDevice) {
            [dDevice.mDeviceManager setEmail:self.recvTextV.text andPwd:self.smtpCodeTextV.text andServer:self.smtpAddressTextV.text andSendto:self.sendTextV.text andPort:[self.portTextV.text intValue] returnBlock:^(BOOL success) {
                [weakSelf setEmailCallBack:success];
            }];
        }
    }
    else {
        [[KHJToast share] showToastActionWithToastType:_WarningType
                                          toastPostion:_CenterPostion
                                                   tip:@""
                                               content:KHJLocalizedString(@"enttyInformation", nil)];
    }
}

#pragma mark - 设置邮件信息

- (void)setEmailCallBack:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_SuccessType
                                              toastPostion:_CenterPostion
                                                       tip:@""
                                                   content:KHJLocalizedString(@"setSuccess", nil)];
        });
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KHJToast share] showToastActionWithToastType:_ErrorType
                                              toastPostion:_CenterPostion
                                                       tip:KHJLocalizedString(@"tips", nil)
                                                   content:KHJLocalizedString(@"setFail", nil)];
        });
    }
}
#pragma mark - uitextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:KHJLocalizedString(@"MNeedSeparate", nil)]) {
        
        textView.text = @"";
        self.recvTextV.textColor = [UIColor lightGrayColor];

    }else{
        self.recvTextV.textColor = [UIColor blackColor];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (textView.text.length<1) {
        
        textView.text = KHJLocalizedString(@"MNeedSeparate", nil);
        
        self.recvTextV.textColor = [UIColor lightGrayColor];
    }
}
@end
