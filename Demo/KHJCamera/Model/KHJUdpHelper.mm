//
//  KHJUdpHelper.m

#import "KHJUdpHelper.h"
#import <CocoaAsyncSocket/AsyncUdpSocket.h>
#import "KHJBaseDevice.h"

@interface KHJUdpHelper()<AsyncUdpSocketDelegate>
{
    AsyncUdpSocket* m_udpSocket;
}

@end

@implementation KHJUdpHelper

+ (KHJUdpHelper *)getinstance
{
    static KHJUdpHelper *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    return instanceManager ;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [KHJUdpHelper getinstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [KHJUdpHelper getinstance] ;
}

/**
 open
 */
- (void)openUDPServer
{
    m_udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    NSError* error = nil;
    BOOL ret = [m_udpSocket bindToPort:6008 error:&error];
    if (ret) {
        NSLog(@"绑定成功");
        NSLog(@"Binding successful");
        [m_udpSocket joinMulticastGroup:@"224.0.1.2" error:&error];
        [m_udpSocket receiveWithTimeout:-1 tag:0];
    }
    else {
        NSLog(@"绑定失败");
        NSLog(@"Binding failed");
    }
}

/**
 收到 UDP 消息

 @param data 设备返回的 json 数据
 */

/**
Receive UDP message

@param data json data returned by the device
*/
- (BOOL)onUdpSocket:(AsyncUdpSocket*)sock didReceiveData:(NSData*)data withTag:(long)tag fromHost:(NSString*)host port:(UInt16)port
{
    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    KHJBaseDevice *bdevice = [[KHJBaseDevice alloc] init];
    bdevice.mDeviceManager = [[KHJDeviceManager alloc] init];
    [bdevice.mDeviceManager creatCameraBase:body[@"uid"] keyword:@""];
    [bdevice.mDeviceManager connect:@"888888" withUid:body[@"uid"] flag:0 successCallBack:^(NSString *uidStr, NSInteger isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess == 0) {
                
                CLog(@"连接成功");
                
                CLog(@"connection succeeded");
                
                // 1.用888888连接成功

                // 1. Connect successfully with 888888
            
                // 2.设置设备密码，设置成功后
                
                // 2. Set device password, after successful setting
                
                [bdevice.mDeviceManager setPassword:@"888888" Newpassword:@"U4I6384375Wr9L01" withUid:body[@"uid"] returnCallBack:^(BOOL result) {
                    if (result) {
                        // 3.向服务器添加设备
                        // uid      = body[@"uid"]
                        // pwd      = JZIq6XMBtH38iQHIsCZUsA==
                        // version  = 0.0.0
                        // type     = body[@"type"]
                        // name     = @""
                    }
                }];
            }
            else {
                WeakSelf
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf popMainViewCtrl];
                });
            }
        });
    } offLineCallBack:^{
        
    }] ;
    

    return YES;
}

- (void)popMainViewCtrl
{
    NSLog(@"返回设备列表");
    NSLog(@"Return Device List");
}

- (void)onUdpSocket:(AsyncUdpSocket*)sock didNotSendDataWithTag:(long)tag dueToError:(NSError*)error
{
    NSLog(@"error1");
}

- (void)onUdpSocket:(AsyncUdpSocket*)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError*)error
{

    NSLog(@"error2");
}
- (void)closeUpdServer{
    
    if (m_udpSocket) {
        [m_udpSocket close];
    }
}

@end
