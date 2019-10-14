//
//  DataBase.m
//  FMDBDemo
//  后期优化，代码现在冗余比较多
//  Created by Zeno on 16/5/18.
//  Copyright © 2016年 zenoV. All rights reserved.
//

#import "DeDataBase.h"
#import "DeviceInfo.h"
#import "FMDB.h"

#import "DeDecEnc.h"
static DeDataBase *_DBCtl = nil;

@interface DeDataBase()<NSCopying,NSMutableCopying>
{
    FMDatabase  *_db;
}

@end

@implementation DeDataBase

+ (instancetype)sharedDataBase
{
    if (_DBCtl == nil) {
        _DBCtl = [[DeDataBase alloc] init];
    }
    return _DBCtl;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (_DBCtl == nil) {
        _DBCtl = [super allocWithZone:zone];
    }
    return _DBCtl;
}

- (id)copy
{
    return self;
}

- (id)mutableCopy
{
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}
// 懒加载数据库队列
- (FMDatabaseQueue *)getQueue
{
    if (_queue == nil) {
        // 获得Documents目录路径
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 文件路径
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"KHJModel.sqlite"];
        _queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    }
    return _queue;
}

// 创建表
- (void)createTableWithSQL:(NSString *)sql
{
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"创建表格成功");
        }
        else {
            NSLog(@"创建表格失败");
        }
    }];
}

- (void)initDataBase
{
    _queue = [self getQueue];
    // 初始化数据表
     NSString *deviceInfosql = @"CREATE TABLE IF NOT EXISTS 'deviceInfo' ('id' VARCHAR(255) PRIMARY KEY,'deviceUid' VARCHAR(255),'isShare' INTEGER, 'deviceAccount' VARCHAR(255),'deviceConfigs' VARCHAR(255),'deviceInfoId' VARCHAR(255),'deviceName' VARCHAR(255),'devicePwd' VARCHAR(255),'deviceRemark' VARCHAR(255),'deviceStatus' VARCHAR(255),'deviceType' VARCHAR(255),'deviceVersion' VARCHAR(255),'ownFlag' INTEGER,'connectState' INTEGER,'ptz' INTEGER)";
    
    NSString *userInfosql = @"CREATE TABLE IF NOT EXISTS 'userInfo' ('id' VARCHAR(255) PRIMARY KEY,'isLogined' INTEGER,'isSaveLogin' INTEGER, 'usereNameRegis' VARCHAR(255),'userePwd' VARCHAR(255),'usereAccountPhone' VARCHAR(255),'userAccountEmail' VARCHAR(255),'headURL' VARCHAR(255),'userNickname' VARCHAR(255),'userID' VARCHAR(255),'userFindPwdUserF' VARCHAR(255))";

    NSString *alarmInfosql = @"CREATE TABLE IF NOT EXISTS 'alarmInfo' (id integer PRIMARY KEY AUTOINCREMENT,'deviceUid' VARCHAR(255),'userAccount' VARCHAR(255),'deviceName' VARCHAR(255),'imageName' VARCHAR(255), 'timeStamp' VARCHAR(255)  NOT NULL  unique,'type' VARCHAR(255))";
//    constraint uk_emp_cardid unique (emp_cardid)
    BOOL isNeedDeleteAlarm= [[NSUserDefaults standardUserDefaults] boolForKey:@"isNeedDeleteAlarm"];
    BOOL isNeedDeleteDevice= [[NSUserDefaults standardUserDefaults] boolForKey:@"isNeedDeleteDevice"];

//    isNeedDeleteAlarm = NO;
    if (!isNeedDeleteAlarm) {
        
        NSString *tString = [self getLocalVersion];
        if ([tString isEqualToString:@"1.2.9"]) {
            [self.queue inDatabase:^(FMDatabase *db) {
                NSString *deleteTable = @"drop table alarmInfo";
                if ([db  executeUpdate:deleteTable]) {
                    CLog(@"删除表成功");
                    [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:@"isNeedDeleteAlarm"];
                }
                else {
                    CLog(@"删除表失败");
                }
            }];
        }
    }
    if (!isNeedDeleteDevice) {
        
        NSString *tString = [self getLocalVersion];
        if ([tString isEqualToString:@"1.3.5"]) {
            [self.queue inDatabase:^(FMDatabase *db) {
                NSString *deleteTable = @"drop table deviceInfo";
                if ([db  executeUpdate:deleteTable]) {
                    CLog(@"删除表成功");
                    [[NSUserDefaults standardUserDefaults] setBool:YES  forKey:@"isNeedDeleteDevice"];
                }
                else {
                    CLog(@"删除表失败");
                }
            }];
            
        }
    }
    [self createTableWithSQL:userInfosql];
    [self createTableWithSQL:deviceInfosql];
    [self createTableWithSQL:alarmInfosql];

}
//版本
- (NSString*)getLocalVersion
{
    NSDictionary *infoDictionary  = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version=  [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

#pragma mark - deviceInfosql

- (void)addDevice:(DeviceInfo *)deviceInfo returnBlocK:(void(^)(DeviceInfo * dInfo,int code)) block
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO deviceInfo (id, deviceUid, isShare,deviceAccount,deviceConfigs,deviceInfoId,deviceName,devicePwd,deviceRemark,deviceStatus,deviceType,deviceVersion,ownFlag,connectState,ptz) VALUES ('%@','%@','%d','%@','%@','%@','%@','%@','%@','%@','%@','%@','%d','%d','%ld')",deviceInfo.devId,deviceInfo.deviceUid,(int)deviceInfo.isShare,deviceInfo.deviceAccount,deviceInfo.deviceConfigs,deviceInfo.deviceInfoId,deviceInfo.deviceName,deviceInfo.devicePwd,deviceInfo.deviceRemark,deviceInfo.deviceStatus,deviceInfo.deviceType,deviceInfo.deviceVersion,(int)deviceInfo.ownFlag,(int)deviceInfo.DeviceConnectState,(long)deviceInfo.isPtz];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"插入数据成功");
            block(nil,1);
        }
        else {
            NSLog(@"插入数据失败");
            block(nil,0);
            
        }
    }];
}

- (void)deleteDevice:(DeviceInfo *)deviceInfo returnBlocK:(void(^)(DeviceInfo * dInfo,int code)) block
{
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete FROM deviceInfo WHERE id='%@'",deviceInfo.devId];
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"删除数据成功");
            block(nil,1);
        }
        else {
            NSLog(@"删除数据失败");
            block(nil,0);
            
        }
    }];
}

- (void)selectDeviceFromUid:(NSString *)uidString returnBlocK:(void(^)(DeviceInfo * dInfo,int code)) block
{
    _queue = [self queue];
    DeviceInfo *uInfo = [[DeviceInfo alloc] init];
    __block NSInteger code = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM deviceInfo WHERE deviceUid='%@'",uidString];
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            NSString *devId         = [resultSet stringForColumn:@"id"];
            NSString *deviceUid     = [resultSet stringForColumn:@"deviceUid"];
            BOOL isShare            = [resultSet boolForColumn:@"isShare"];
            NSString *deviceAccount = [resultSet stringForColumn:@"deviceAccount"];
            NSString *deviceConfigs = [resultSet stringForColumn:@"deviceConfigs"];
            NSString *deviceInfoId  = [resultSet stringForColumn:@"deviceInfoId"];
            NSString *deviceName    = [resultSet stringForColumn:@"deviceName"];
            NSString *devicePwd     = [resultSet stringForColumn:@"devicePwd"];
            CLog(@"devicePwd111 = %@",devicePwd);
            NSString *deviceRemark  = [resultSet stringForColumn:@"deviceRemark"];
            NSString *deviceStatus  = [resultSet stringForColumn:@"deviceStatus"];
            NSString *deviceType    = [resultSet stringForColumn:@"deviceType"];
            NSString *deviceVersion = [resultSet stringForColumn:@"deviceVersion"];
            NSInteger ownFlag       = [resultSet intForColumn:@"ownFlag"];
            NSInteger connectState  = [resultSet intForColumn:@"connectState"];
            NSInteger isPtz         = [resultSet intForColumn:@"ptz"];

            uInfo.devId                 = devId;
            uInfo.deviceUid             = deviceUid;
            uInfo.isShare               = isShare;
            uInfo.deviceAccount         = deviceAccount;
            uInfo.deviceConfigs         = deviceConfigs;
            uInfo.deviceInfoId          = deviceInfoId;
            uInfo.deviceName            = deviceName;
            devicePwd                   = [DeDecEnc aesDecrypt:devicePwd];
            uInfo.devicePwd             = devicePwd ;
            uInfo.deviceRemark          = deviceRemark;
            uInfo.deviceStatus          = deviceStatus;
            uInfo.deviceType            = deviceType;
            uInfo.deviceVersion         = deviceVersion;
            uInfo.ownFlag               = ownFlag;
            uInfo.DeviceConnectState    = connectState;
            uInfo.isPtz                 = isPtz;
            code = 1;
        }
    }];
    block(uInfo,(int)code);
}

- (void)selectDevice:(DeviceInfo *)deviceInfo returnBlocK:(void(^)(DeviceInfo * dInfo,int code)) block
{
    _queue = [self queue];
    DeviceInfo *uInfo = [[DeviceInfo alloc] init];
    __block NSInteger code = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM deviceInfo WHERE id='%@'",deviceInfo.devId];
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            NSString *devId             = [resultSet stringForColumn:@"id"];
            NSString *deviceUid         = [resultSet stringForColumn:@"deviceUid"];
            BOOL isShare                = [resultSet boolForColumn:@"isShare"];
            NSString *deviceAccount     = [resultSet stringForColumn:@"deviceAccount"];
            NSString *deviceConfigs     = [resultSet stringForColumn:@"deviceConfigs"];
            NSString *deviceInfoId      = [resultSet stringForColumn:@"deviceInfoId"];
            NSString *deviceName        = [resultSet stringForColumn:@"deviceName"];
            NSString *devicePwd         = [resultSet stringForColumn:@"devicePwd"];
            NSString *deviceRemark      = [resultSet stringForColumn:@"deviceRemark"];
            NSString *deviceStatus      = [resultSet stringForColumn:@"deviceStatus"];
            NSString *deviceType        = [resultSet stringForColumn:@"deviceType"];
            
            NSString *deviceVersion     = [resultSet stringForColumn:@"deviceVersion"];
            NSInteger ownFlag           = [resultSet intForColumn:@"ownFlag"];
            NSInteger connectState      = [resultSet intForColumn:@"connectState"];
            NSInteger isPtz             = [resultSet intForColumn:@"ptz"];

            uInfo.devId                 = devId;
            uInfo.deviceUid             = deviceUid;
            uInfo.isShare               = isShare;
            uInfo.deviceAccount         = deviceAccount;
            uInfo.deviceConfigs         = deviceConfigs;
            uInfo.deviceInfoId          = deviceInfoId;
            uInfo.deviceName            = deviceName;
            devicePwd                   = [DeDecEnc aesDecrypt:devicePwd];
            uInfo.devicePwd             = devicePwd ;
            uInfo.deviceRemark          = deviceRemark;
            uInfo.deviceStatus          = deviceStatus;
            uInfo.deviceType            = deviceType;
            uInfo.deviceVersion         = deviceVersion;
            uInfo.ownFlag               = ownFlag;
            uInfo.DeviceConnectState    = connectState;
            uInfo.isPtz                 = isPtz;
            code = 1;
        }
    }];
    block(uInfo,(int)code);
}

/**
 *  获取所有数据
 *
 */
- (NSMutableArray *)getAllDeviceForUser:(NSString *)userAccount
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    __block NSInteger code = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
//        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM deviceInfo WHERE deviceAccount ='%@'",userAccount];
//        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM deviceInfo WHERE deviceUid='%@'",uidString];
//        FMResultSet *resultSet = [db executeQuery:sql];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM deviceInfo WHERE deviceAccount='%@'",userAccount];

        FMResultSet *resultSet = [db executeQuery:sql];
        
        while (resultSet.next) {
            
            DeviceInfo *uInfo = [[DeviceInfo alloc] init];
            NSString *devId         = [resultSet stringForColumn:@"id"];
            NSString *deviceUid     = [resultSet stringForColumn:@"deviceUid"];
            BOOL isShare            = [resultSet boolForColumn:@"isShare"];
            NSString *deviceAccount = [resultSet stringForColumn:@"deviceAccount"];
            NSString *deviceConfigs = [resultSet stringForColumn:@"deviceConfigs"];
            NSString *deviceInfoId  = [resultSet stringForColumn:@"deviceInfoId"];
            NSString *deviceName    = [resultSet stringForColumn:@"deviceName"];
            NSString *devicePwd     = [resultSet stringForColumn:@"devicePwd"];
            NSString *deviceRemark  = [resultSet stringForColumn:@"deviceRemark"];
            NSString *deviceStatus  = [resultSet stringForColumn:@"deviceStatus"];
            NSString *deviceType    = [resultSet stringForColumn:@"deviceType"];
            NSString *deviceVersion = [resultSet stringForColumn:@"deviceVersion"];
            NSInteger ownFlag       = [resultSet intForColumn:@"ownFlag"];
            NSInteger connectState  = [resultSet intForColumn:@"connectState"];
            
            uInfo.devId                 = devId;
            uInfo.deviceUid             = deviceUid;
            uInfo.isShare               = isShare;
            uInfo.deviceAccount         = deviceAccount;
            uInfo.deviceConfigs         = deviceConfigs;
            uInfo.deviceInfoId          = deviceInfoId;
            uInfo.deviceName            = deviceName;
            devicePwd                   = [DeDecEnc aesDecrypt:devicePwd];
            uInfo.devicePwd             = devicePwd;
            uInfo.deviceRemark          = deviceRemark;
            uInfo.deviceStatus          = deviceStatus;
            uInfo.deviceType            = deviceType;
            uInfo.deviceVersion         = deviceVersion;
            uInfo.ownFlag               = ownFlag;
            uInfo.DeviceConnectState    = connectState;
            code = 1;
            [dataArray addObject:uInfo];
            
        }
    }];
    return dataArray;
}

- (NSMutableArray *)getAllDevice
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    __block NSInteger code = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM deviceInfo"];
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            
            DeviceInfo *uInfo       = [[DeviceInfo alloc] init];
            NSString *devId         = [resultSet stringForColumn:@"id"];
            NSString *deviceUid     = [resultSet stringForColumn:@"deviceUid"];
            BOOL isShare            = [resultSet boolForColumn:@"isShare"];
            NSString *deviceAccount = [resultSet stringForColumn:@"deviceAccount"];
            NSString *deviceConfigs = [resultSet stringForColumn:@"deviceConfigs"];
            NSString *deviceInfoId  = [resultSet stringForColumn:@"deviceInfoId"];
            NSString *deviceName    = [resultSet stringForColumn:@"deviceName"];
            NSString *devicePwd     = [resultSet stringForColumn:@"devicePwd"];
            NSString *deviceRemark  = [resultSet stringForColumn:@"deviceRemark"];
            NSString *deviceStatus  = [resultSet stringForColumn:@"deviceStatus"];
            NSString *deviceType    = [resultSet stringForColumn:@"deviceType"];
            
            NSString *deviceVersion = [resultSet stringForColumn:@"deviceVersion"];
            NSInteger ownFlag       = [resultSet intForColumn:@"ownFlag"];
            NSInteger connectState  = [resultSet intForColumn:@"connectState"];

            uInfo.devId                 = devId;
            uInfo.deviceUid             = deviceUid;
            uInfo.isShare               = isShare;
            uInfo.deviceAccount         = deviceAccount;
            uInfo.deviceConfigs         = deviceConfigs;
            uInfo.deviceInfoId          = deviceInfoId;
            uInfo.deviceName            = deviceName;
            devicePwd                   = [DeDecEnc aesDecrypt:devicePwd];
            uInfo.devicePwd             = devicePwd;
            uInfo.deviceRemark          = deviceRemark;
            uInfo.deviceStatus          = deviceStatus;
            uInfo.deviceType            = deviceType;
            uInfo.deviceVersion         = deviceVersion;
            uInfo.ownFlag               = ownFlag;
            uInfo.DeviceConnectState    = connectState;

            code = 1;
            [dataArray addObject:uInfo];
        }
    }];
    return dataArray;
}

- (void)updateDevice:(DeviceInfo *)deviceInfo returnBlocK:(void(^)(DeviceInfo * dInfo,int code)) block
{
    [self.queue inDatabase:^(FMDatabase *db) {

        NSString *sql = [NSString stringWithFormat:@"UPDATE deviceInfo SET  deviceUid='%@', isShare=%d,deviceAccount='%@',deviceConfigs='%@',deviceInfoId='%@',deviceName='%@',devicePwd='%@',deviceRemark= '%@',deviceStatus='%@',deviceType='%@',deviceVersion='%@',ownFlag=%ld,connectState=%d WHERE id='%@'",deviceInfo.deviceUid,(int)deviceInfo.isShare,deviceInfo.deviceAccount,deviceInfo.deviceConfigs,deviceInfo.deviceInfoId,deviceInfo.deviceName,deviceInfo.devicePwd,deviceInfo.deviceRemark,deviceInfo.deviceStatus,deviceInfo.deviceType,deviceInfo.deviceVersion,(long)deviceInfo.ownFlag,(int)deviceInfo.DeviceConnectState,deviceInfo.devId];
        
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"更新数据成功");
            block(nil,1);
        }
        else {
            NSLog(@"更新数据失败");
            block(nil,0);
            
        }
    }];
}

@end
