
//设备是否开启
//设备是否开启//
//  DeviceInfo.h
//  用户名下设备列表信息
// Device list information under user name

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

// 设备账号ID
// Device account ID
@property(nonatomic,copy)NSString *devId;
// 设备账号
// Device account
@property(nonatomic,copy)NSString *deviceAccount;
// 配置信息
// Configuration information
@property(nonatomic,copy)NSString *deviceConfigs;
// 设备信息ID
// Device information ID
@property(nonatomic,copy)NSString *deviceInfoId;
// 设备名称
// Device name
@property(nonatomic,copy)NSString *deviceName;
// 设备密码
// Device password
@property(nonatomic,copy)NSString *devicePwd;
// 真实密码
// Real password
@property(nonatomic,copy)NSString *deviceRealPwd;
// 备注
// Remarks
@property(nonatomic,copy)NSString *deviceRemark;
// 设备状态
// device status
@property(nonatomic,copy)NSString *deviceStatus;
// 设备类型
// device type
@property(nonatomic,copy)NSString *deviceType;
// 设备UID
// Device UID
@property(nonatomic,copy)NSString *deviceUid;
// 版本信息
// Version Information
@property(nonatomic,copy)NSString *deviceVersion;
// 是否开通云
// Whether to open the cloud
@property(nonatomic,assign)NSInteger cloudStatus;
// 云服务类型(1全天录像，0报警录制)
// Cloud service type (1 all-day recording, 0 alarm recording)
@property(nonatomic,assign)NSInteger recType;
// 开通云时间
// Open Cloud Time
@property(nonatomic,assign)NSInteger storageTime;
// 设备所属
// Device belongs
@property(nonatomic,assign)NSInteger ownFlag;
// 是否摇头机
// Whether PTZ
@property(nonatomic,assign)NSInteger isPtz;
// 是否可以分享给其他客户
// Can it be shared with other customers
@property(nonatomic,assign)BOOL isShare;
// 等价于deviceRemark
// Equivalent to deviceRemark
@property(nonatomic,assign)BOOL isAPMode;
@property(nonatomic,assign)BOOL isOpen;
// 连接状态，0离线，1成功，2，正在连接, 0 成功，1.正在连接，2，连接失败（0-1）（1-2）（2-0）
// Connection status, 0 offline, 1 successful, 2, connecting, 0 successful, 1. connecting, 2, connection failed (0-1) (1-2) (2-0)
@property(nonatomic,assign)NSInteger DeviceConnectState;
// 连接次数
// Number of connections
@property(nonatomic,assign)NSInteger connectTimes;
- (void)copyAttribute:(DeviceInfo *)dInfo;

@end
