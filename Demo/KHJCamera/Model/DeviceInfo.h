//
//  DeviceInfo.h
//  用户名下设备列表信息

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

@property(nonatomic,copy)NSString *devId;//设备账号ID
@property(nonatomic,copy)NSString *deviceAccount;//设备账号
@property(nonatomic,copy)NSString *deviceConfigs;//配置信息
@property(nonatomic,copy)NSString *deviceInfoId;//设备信息ID
@property(nonatomic,copy)NSString *deviceName;//设备名称
@property(nonatomic,copy)NSString *devicePwd;//设备密码
@property(nonatomic,copy)NSString *deviceRealPwd;//真实密码

@property(nonatomic,copy)NSString *deviceRemark;//备注
@property(nonatomic,copy)NSString *deviceStatus;//设备状态
@property(nonatomic,copy)NSString *deviceType;//设备类型
@property(nonatomic,copy)NSString *deviceUid;//设备UID
@property(nonatomic,copy)NSString *deviceVersion;//版本信息
@property(nonatomic,assign)NSInteger cloudStatus;//是否开通云

@property(nonatomic,assign)NSInteger recType;//云服务类型(1全天录像，0报警录制)
@property(nonatomic,assign)NSInteger storageTime;//开同云时间

@property(nonatomic,assign)NSInteger ownFlag;// 设备所属
@property(nonatomic,assign)NSInteger isPtz;// 是否摇头机

@property(nonatomic,assign)BOOL isShare;//是否可以分享给其他客户
@property(nonatomic,assign)BOOL isAPMode;//等价于deviceRemark


@property(nonatomic,assign)BOOL isOpen;//设备是否开启
@property(nonatomic,assign)NSInteger DeviceConnectState;//连接状态，0离线，1成功，2，正在连接, 0 成功，1.正在连接，2，连接失败（0-1）（1-2）（2-0）
@property(nonatomic,assign)NSInteger connectTimes;//连接次数



- (void)copyAttribute:(DeviceInfo *)dInfo;

@end
