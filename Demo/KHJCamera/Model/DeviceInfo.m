//
//  DeviceInfo.m

#import "DeviceInfo.h"

@implementation DeviceInfo

@synthesize devId;
@synthesize  deviceAccount;//设备账号
@synthesize deviceConfigs;//配置信息
@synthesize deviceInfoId;//设备信息ID
@synthesize deviceName;//设备名称
@synthesize devicePwd;//设备密码
@synthesize deviceRealPwd;
@synthesize deviceRemark;//备注
@synthesize deviceStatus;//设备状态
@synthesize deviceType;//设备类型
@synthesize deviceUid;//设备UID
@synthesize deviceVersion;//版本信息
@synthesize ownFlag;// 设备所属
@synthesize isShare; //是否可以分享
@synthesize DeviceConnectState; //是否连接
@synthesize recType;
@synthesize cloudStatus;
@synthesize storageTime;
@synthesize isPtz;
@synthesize isOpen;
@synthesize connectTimes;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    deviceAccount = [[NSString alloc] init];
    deviceConfigs = [[NSString alloc] init];
    deviceInfoId = [[NSString alloc] init];
    deviceName = [[NSString alloc] init];
    devicePwd = [[NSString alloc] init];

    deviceRemark = [[NSString alloc] init];
    deviceStatus = [[NSString alloc] init];
    deviceType = [[NSString alloc] init];
    deviceUid = [[NSString alloc] init];
    deviceVersion = [[NSString alloc] init];
    ownFlag = 0;
    recType = -1;
    
    return self;
}

- (void)copyAttribute:(DeviceInfo *)dInfo{
    
    self.devId = dInfo.devId;
    self.deviceAccount = dInfo.deviceAccount;
    self.deviceConfigs = dInfo.deviceConfigs;
    self.deviceInfoId = dInfo.deviceInfoId;
    self.deviceName = dInfo.deviceName;
    self.devicePwd = dInfo.devicePwd;
    self.deviceRemark = dInfo.deviceRemark;
    self.deviceStatus = dInfo.deviceStatus;
    self.deviceType = dInfo.deviceType;
    self.deviceUid = dInfo.deviceUid;
    
    
    self.deviceVersion = dInfo.deviceVersion;
    self.cloudStatus = dInfo.cloudStatus;
    self.storageTime = dInfo.storageTime;
    self.ownFlag = dInfo.ownFlag;
    self.isPtz = dInfo.isPtz;
    self.isShare = dInfo.isShare;
    self.isOpen = dInfo.isOpen;
    self.DeviceConnectState = dInfo.DeviceConnectState;

}
@end
