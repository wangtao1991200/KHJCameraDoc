 //
//  KHJNetWorkingManager.m
//  KHJCamera
//
//  Created by hezewen on 2018/5/22.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "KHJNetWorkingManager.h"
#import <AFNetworking.h>
#import "KHJUserInfo.h"
#import "JPUSHService.h"
#import "NAVVController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "KHJDecEnc.h"
@interface KHJNetWorkingManager()
{
    AFHTTPSessionManager *afhttpSessionManager;
    codeBlock mycodeBlock;
    NSArray *tabArray;

}
@end

@implementation KHJNetWorkingManager

+ (KHJNetWorkingManager *)sharedManager
{
    static KHJNetWorkingManager *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return instanceManager ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [KHJNetWorkingManager sharedManager] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [KHJNetWorkingManager sharedManager] ;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        afhttpSessionManager = [AFHTTPSessionManager manager];
//        afhttpSessionManager setSecurityPolicy:(AFSecurityPolicy * _Nonnull)
        afhttpSessionManager.requestSerializer.timeoutInterval = 8;
        // 声明上传的是json格式的参数，需要你和后台约定好，不然会出现后台无法获取到你上传的参数问题
        afhttpSessionManager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
        //    manager.requestSerializer = [AFJSONRequestSerializer serializer]; // 上传JSON格式
        // 声明获取到的数据格式
        afhttpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer]; // AFN不会解析,数据是data，需要自己解析
//        afhttpSessionManager.responseSerializer = [AFJSONResponseSerializer serializer]; // AFN会JSON解析返回的数据
        
        afhttpSessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        afhttpSessionManager.securityPolicy.allowInvalidCertificates = YES;
        [afhttpSessionManager.securityPolicy setValidatesDomainName:NO];
        tabArray = [NSArray arrayWithObjects:@"设备",@"发现",@"报警消息",@"我的", nil];

    }
    return self;
}
/**
 注册时获取手机验证码
 userPhone(必须)  用户手机号
 */
-(void)getValidatePhoneCode:(NSString *)userPhone returnCode:(void(^)(NSDictionary *dic,NSInteger code)) myblock
{
   
    //2.封装参数
    NSDictionary *dict = @{
                           @"userPhone":userPhone,
                           };
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"signup"];
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject );
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"字典为--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock([dict objectForKey:@"message"],[[dict objectForKey:@"code"] integerValue]);

        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        myblock(nil,[[dict objectForKey:@"code"] integerValue]);
        NSLog(@"%@", error);

    }];

}
/**
 userEmail(必须) 用户邮箱
 */
-(void)getValidateEmailCode:(NSString *)userEmail returnCode:(void(^)(NSDictionary *dic,NSInteger code)) myblock{
    
    //2.封装参数
    NSDictionary *dict = @{
                           @"userEmail":userEmail,
                           };
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"signup"];
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"邮箱验证返回--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
         myblock([dict objectForKey:@"message"],[[dict objectForKey:@"code"] integerValue]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);

    }];
    
}
/**
 userPhone(必须)  用户手机号
 userPwd(必须)    用户密码
 userEmail（必须) 用户邮箱
 code(必须)       验证码
 userConfigs(非必须) 用户配置信息，以json的格式存放
 userImages(非必须)  用户头像url地址
 userRemark(非必须)  用户备注
 
 */

-(void)registerWithPhone:(NSString *)userPhone
                passWord:(NSString *)userPwd
                   Email:(NSString *)userEmail
               shortCode:(NSString *)code
             cofigration:(NSString *)userConfigs
               userImage:(NSString *)userImages
              userRemark:(NSString *)userRemark
              returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    [self addEncFlag];
    //2.封装参数
    userPwd = [KHJDecEnc aesEncrypt:userPwd];
    NSDictionary *dict = @{
                           @"userPhone":userPhone,
                           @"userPwd":userPwd,
                           @"code":code
                           };
    
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"signup"];
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
        NSLog(@"%@", responseObject );
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"字典为--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"%@", error);
        myblock(nil,-100);

    }];
    
}
/**
 userEmail（必须) 用户邮箱
 userPwd(必须)    用户密码
 code(必须)       验证码
 userConfigs(非必须) 用户配置信息，以json的格式存放
 userImages(非必须)  用户头像url地址
 userRemark(非必须)  用户备注
 
 */
-(void)registerWithEmail:(NSString *)userEmail
                passWord:(NSString *)userPwd
               shortCode:(NSString *)code
             cofigration:(NSString *)userConfigs
               userImage:(NSString *)userImages
              userRemark:(NSString *)userRemark
              returnCode:(void(^)(NSDictionary *dic,NSInteger code)) myblock{
    [self addEncFlag];
    userPwd = [KHJDecEnc aesEncrypt:userPwd];
    //2.封装参数
    NSDictionary *dict = @{
                           @"userEmail":userEmail,
                           @"userPwd":userPwd,
                           @"code":code
                           };
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"signup"];
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject);
        NSLog(@"%@", responseObject );
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"字典为--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        myblock(nil,-100);
        
    }];
    
}
/**

 userAccount(必须)   用户账号
 userPwd(必须)       用户密码(md5加密)
 rememberMe(必须)    是否记住密码   "true"-记住密码   "false"-不记住密码
 */
-(void)login:(NSString *)userAccount
    passWord:(NSString *)userPwd
  isRemenber:(BOOL) remenber
  returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock

{
    //2.封装参数
    [self addEncFlag];
    userPwd = [KHJDecEnc aesEncrypt:userPwd];
    NSString *rbstring = @"true";
    NSDictionary *dict = @{
                           @"userAccount":userAccount,
                           @"userPwd":userPwd,
                           @"rememberMe": rbstring
                           };
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"login"];
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSDictionary *allHeaders = response.allHeaderFields;
        NSString * setCookie = allHeaders[@"Set-Cookie"];
        [[NSUserDefaults standardUserDefaults] setObject:setCookie forKey:@"Set-Cookie"];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"登录后字典为--------%@",dict);
        
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
        if([[dict objectForKey:@"code"] integerValue] == 1)
        {
            NSNumber *userName = [[dict objectForKey:@"data"] objectForKey:@"userAccount"];
            NSString *uName = [userName stringValue];
            //极光推送设置别名
            [JPUSHService setTags:nil alias:uName callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        myblock(nil,-100);
    }];
}
- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}
/**
 退出登录
 */
-(void)logout:(void(^)(NSDictionary *dic,NSInteger code)) myblock{
    
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"logout"];
    //1.将token封装入请求头
    [self addSession];
    WeakSelf
    [afhttpSessionManager POST:rUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"退出登录返回--------%@",dict) ;
        [JPUSHService setTags:nil alias:@"" callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
        //退出登录成功则保存状态到数据库
        if([[dict objectForKey:@"code"] integerValue] == 1){
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [weakSelf saveUserState];
            });
        }
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)saveUserState//
{
    
    KHJDataBase *dB = [KHJDataBase sharedDataBase];
    KHJUserInfo *userInfo = [[KHJUserInfo alloc] init];
    userInfo.usereAccount = SaveManager.usereAccount;
    userInfo.isLogined = SaveManager.isLogined;
    userInfo.isSaveLogin = SaveManager.isSaveLogin;
    userInfo.usereNameRegis = SaveManager.usereNameRegis;
    userInfo.userePwd = SaveManager.userePwd;
    NSString *tString = SaveManager.usereAccountPhone;
    if (!tString || tString == nil) {
        tString = @"";
    }
    userInfo.usereAccountPhone =tString;
    tString = SaveManager.userAccountEmail;
    if (!tString || tString == nil) {
        tString = @"";
    }
    userInfo.userAccountEmail = tString;
    
    tString = SaveManager.headURL;
    if (!tString || tString == nil) {
        tString = @"";
    }
    userInfo.headURL = tString;
    
    tString = SaveManager.userNickname;
    if (!tString || tString == nil) {
        tString = @"";
    }
    userInfo.userNickname = tString;
    tString = SaveManager.userID;
    if (!tString || tString == nil) {
        tString = @"";
    }
    userInfo.userID = tString;
    
    tString = SaveManager.userFindPwdUserF;
    if (!tString || tString == nil) {
        tString = @"";
    }
    userInfo.userFindPwdUserF = tString;
    
    [dB selectPerson:userInfo returnBlocK:^(KHJUserInfo *uInfo, int code) {
       
        if (code == 1) {//更新数据
            [dB updatePerson:userInfo returnBlocK:^(KHJUserInfo *uInfo, int code) {
                
                if (code == 1) {
                    CLog(@"更新成功");
                }else{
                    CLog(@"更新失败");
                }
            }];
            
        }else{
            [dB addPerson:userInfo returnBlocK:^(KHJUserInfo *uInfo, int code) {
               
                if (code == 1) {
                    CLog(@"添加成功");
                }else{
                    CLog(@"添加失败");
                }
                
            }];
        }
        
    }];
}
//除了注册，所有和服务端的请求都需要添加请求头session
- (void)addSession
{
    //将token封装入请求头
    NSString *TOKEN11 = [[NSUserDefaults standardUserDefaults] objectForKey:@"Set-Cookie"];
    NSLog(@"TOKEN11 == %@",TOKEN11);
    [afhttpSessionManager.requestSerializer setValue:TOKEN11 forHTTPHeaderField:@"Cookie"];
    [self addEncFlag];
}
- (void)addEncFlag
{
    [afhttpSessionManager.requestSerializer setValue:@"hjtec" forHTTPHeaderField:@"sign"];
    [afhttpSessionManager.requestSerializer setValue:@"00000000" forHTTPHeaderField:@"companySign"];
}
/**
 获取用户设备列表
 */
- (void)getDeviceList:(void(^)(NSDictionary *dic,NSInteger code)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"deviceList"];
    [self addSession];
    afhttpSessionManager.requestSerializer.timeoutInterval = 6;
    [afhttpSessionManager POST:rUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"设备列表返回--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        myblock(nil,-100);
    }];
    
}
//给服务器上报是AP热点模式设备
- (void)update:(NSString *)uuidString withMark:(NSInteger )mode   returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *modeString = [NSString stringWithFormat:@"%ld",mode];
    //1.将token封装入请求头
    [self addSession];
    NSDictionary *dict = @{
                           @"deviceUid":uuidString,
                           @"deviceRemark":modeString
                           };
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"updateDeviceInfo"];
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"字典为--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        myblock(nil,-100);
        
    }];
}
//更新设备名称
- (void)updateDevName:(NSString *)uuidString withDeviceName:(NSString *)dName   returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    //1.将token封装入请求头
    [self addSession];
    NSDictionary *dict = @{
                           @"deviceUid":uuidString,
                           @"deviceName":dName
                           };
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"updateDeviceInfo"];
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"更新设备名称--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        myblock(nil,-100);
        
    }];
}
//10.添加设备
- (void)addDeviceToUser:(NSString *)deviceUid
                account:(NSString *)deviceAccount
                    pwd:(NSString *)devicePwd
               dVersion:(NSString *)deviceVersion
               dType:(NSString *)deviceType
               dName:(NSString *)deviceName
             returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock{
    
    //1.将token封装入请求头
    [self addSession];
    devicePwd = [KHJDecEnc aesEncrypt:devicePwd];
    //2.封装参数
    NSDictionary *dict = @{
                           @"deviceUid":deviceUid,
                           @"deviceAccount":deviceAccount,
                           @"devicePwd":devicePwd,
                           @"deviceType":@"A_SC_1000000",
                           @"deviceName":deviceName,
                           @"deviceVersion":deviceVersion
                           };
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"addDevice"];
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"字典为--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        myblock(nil,-100);
    }];
}
/**
 11.用户解绑设备
 设备uid deviceUid
 */
- (void)unbindDevice:(NSString *)deviceUid
          returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"unbindDevice"];
    [self addSession];
    
    NSDictionary *dict = @{
                           @"deviceUid":deviceUid
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"解绑设备--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
}

/**
 1.设备关联用户
 设备uid deviceUid
 */
- (void)getDeviceAllUser:(NSString *)deviceUid
              returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"shareUserAccountList"];
    [self addSession];
    NSDictionary *dict = @{
                           @"deviceUid":deviceUid
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"关联的用户--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
    
}

/**
 获取分享码
 设备uid deviceUid
 */
- (void)getDeviceShareCode:(NSString *)devUid returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"deviceShare"];
    [self addSession];
    
    NSDictionary *dict = @{
                           @"deviceUid":devUid
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"分享码--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
}
///deviceShareByAccount
- (void)shareDevice:(NSString *)devUid  andUserName:(NSString *)userName returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock{
   
    
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"deviceShareByAccount"];
//    NSString *rUrl = [NSString stringWithFormat:@"http://www.khjtecapp.com:8000/deviceShareByAccount"];

    [self addSession];
    NSDictionary *dict = @{
                           @"deviceUid":devUid,
                           @"userAccount":userName
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"分享设备--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
}



/**
 得到分享信息，分享设备。
 设备uid deviceUid
 服务端分享码 sCode
 */
- (void)shareDevice:(NSString *)devUid withCode:(NSString *)sCode returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"deviceShare"];
    [self addSession];
    
    NSDictionary *dict = @{
                           @"deviceUid":devUid,
                           @"code":sCode
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"分享设备--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
}
/**
 解除分享设备
 设备uid deviceUid
 分享用户的账号 userAccout
 */
- (void)unShareDevice:(NSString *)devUid withAccount:(NSString *)userAccount returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"deviceUnShared"];
    [self addSession];
    
    NSDictionary *dict = @{
                           @"deviceUid":devUid,
                           @"userAccount":userAccount
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"解绑设备--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
}
/**
 解绑手机
 用户手机 phoneNum
 登录密码 pwdString
 */
- (void)unbindPhone:(NSString *)phoneNum withPwd:(NSString *)pwdString returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"unbindUserPhone"];
    [self addSession];
    
    pwdString = [KHJDecEnc aesEncrypt:pwdString];
    NSDictionary *dict = @{
                           @"userPwd":pwdString,
                           @"userPhone":phoneNum
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"解绑手机--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
    
}
/**
 绑定新手机获取验证码
 userPhone(必须)  用户手机号
 */
-(void)getPhoneVCode:(NSString *)userPhone returnCode:(void(^)(NSDictionary *dic,NSInteger code)) myblock
{
    [self addSession];

    
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"bindUserPhone"];
    //2.封装参数
    NSDictionary *dict = @{
                           @"userPhone":userPhone,
                           };
    
    [afhttpSessionManager POST:rUrl parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@", responseObject );
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"验证码-------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        myblock(nil,[[dict objectForKey:@"code"] integerValue]);
        NSLog(@"%@", error);
        
    }];
}

/**
 绑定新手机
 用户手机 phoneNum
 验证码   codeString
 登录密码 pwdString
 */
- (void)bindPhone:(NSString *)phoneNum withVCode:(NSString *)codeString  andPwdString:(NSString *)pwdString returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock{
    
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"bindUserPhone"];
    [self addSession];
    pwdString = [KHJDecEnc aesEncrypt:pwdString];
    NSDictionary *dict = @{
                           @"userPwd":pwdString,
                           @"userPhone":phoneNum,
                           @"code":codeString

                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"绑定新手机--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
    
    
}
/**
 解绑手机
 用户邮箱 phoneNum
 登录密码 pwdString
 */
- (void)unbindEmail:(NSString *)userEmailStrig withPwd:(NSString *)pwdString returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"unbindUserEmail"];
    [self addSession];
    pwdString = [KHJDecEnc aesEncrypt:pwdString];
    NSDictionary *dict = @{
                           @"userPwd":pwdString,
                           @"userEmail":userEmailStrig
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"解绑邮箱--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
}
/**
 绑定新邮箱
 用户邮箱 phoneNum
 登录密码 pwdString
 */
- (void)bindEmail:(NSString *)userEmailStr   andPwdString:(NSString *)pwdString returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock;
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"bindUserEmail"];
    [self addSession];
    pwdString = [KHJDecEnc aesEncrypt:pwdString];
    NSDictionary *dict = @{
                           @"userPwd":pwdString,
                           @"userEmail":userEmailStr
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"绑定邮箱--------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
}
/**
 重置密码
 旧密码 oldPwdStr
 新密码 newPwdStr
 */
- (void)resetPwd:(NSString *)oldPwdStr andNewPwdStr:(NSString *)newPwdStr returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"userPwdReset"];
    [self addSession];
    
    oldPwdStr = [KHJDecEnc aesEncrypt:oldPwdStr];
    newPwdStr = [KHJDecEnc aesEncrypt:newPwdStr];
    NSDictionary *dict = @{
                           @"userPwd":oldPwdStr,
                           @"userPwdNew":newPwdStr
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"重置密码 --------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"%@", error);
        myblock(nil,-100);
    }];
}

/**
 邮箱找回密码
 邮箱 userEmail
 */
- (void)FindPwdWithEmail:(NSString *)userEmail  returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"userForgetPwd"];
    [self addSession];
    
    NSDictionary *dict = @{
                           @"userEmail":userEmail,
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"邮箱找回 --------%@",dict);
        myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"error = %@", error);
        myblock(nil,-100);
    }];
}

/**
 找回密码获取验证码
 userPhone(必须)  用户手机号
 */
-(void)getVCodeForFindPwd:(NSString *)userPhone returnCode:(void(^)(NSDictionary *dic,NSInteger code)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"userForgetPwd"];
    [self addSession];
    
    NSDictionary *dict = @{
                           @"userPhone":userPhone,
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"获取验证码 --------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"error = %@", error);
        myblock(nil,-100);
    }];
}
- (void)findPhonePwd:(NSString *)userPhone andNewPwdStr:(NSString *)newPwdStr andCode:(NSString *)code returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"userForgetPwd"];
    [self addSession];
    
    newPwdStr = [KHJDecEnc aesEncrypt:newPwdStr];
    NSDictionary *dict = @{
                           @"userPhone":userPhone,
                           @"userPwdNew":newPwdStr,
                           @"code":code,
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"手机找回密码 --------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"error = %@", error);
        myblock(nil,-100);
    }];
}
/**
 获取服务端固件版本号
 cateString  设备类型
 */
- (void)getFirmwareVersion:(NSString *)cateString returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock;
{
//#define REQUEST_URL @"http://www.khjtecapp.com:8000/smartCamera_ucenter/"

    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"checkDevVer"];
    [self addSession];
    NSDictionary *dict = @{
                           @"deviceType":cateString
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"获取设备版本 --------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"error = %@", error);
        myblock(nil,-100);
    }];

}
//获取服务端app版本
- (void)getAppVersion:(void(^)(NSDictionary *dict, NSInteger c)) myblock//检查版本更新，未替换
{
//    NSString *rUrl = [NSString stringWithFormat:@"http://www.khjtecapp.com:8000/appUpdate"];
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"appUpdate"];
    [self addSession];
    
    NSString *tt = [[NSUserDefaults standardUserDefaults] objectForKey:@"Set-Cookie"];
    NSLog(@"tt222 == %@",tt);
    
    NSDictionary *dict = @{
                           @"appType":@"1"
                           };
    
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"版本号 --------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CLog(@"error = %@", error);
        myblock(nil,-100);
    }];
}

- (void)getAlarmList:(NSString *)deviceID andAnnunciator:(int)ann returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"alertWarn"];
    [self addSession];
    NSString *annStr = [NSString stringWithFormat:@"%d",ann];
    NSDictionary *dict = @{
                           @"deviceUid":deviceID,
                           @"annunciator":annStr,
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"获取分享提醒列表 --------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"error = %@", error);
        myblock(nil,-100);
    }];
}
- (void)setAlarmList:(NSString *)deviceID andAccount:(NSString *)userAccount andAnnunciator:(int)ann returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"accreditWarn"];
    [self addSession];
    NSString *annStr = [NSString stringWithFormat:@"%d",ann];
    NSDictionary *dict = @{
                           @"deviceUid":deviceID,
                           @"userAccount":userAccount,
                           @"annunciator":annStr
                           };
    [afhttpSessionManager POST:rUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"添加或者取消报警分享 --------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        CLog(@"error = %@", error);
        myblock(nil,-100);
    }];
}
//
- (void)upLoadUserImage:(UIImage *)image returnCode:(void(^)(NSDictionary *dict, NSInteger c)) myblock
{
//    NSString *postUrl = @"url";//URL
    NSString *rUrl = [REQUEST_URL stringByAppendingString:@"upload/avatar"];
    [self addSession];
    NSData *data = UIImagePNGRepresentation(image);

    NSDictionary *dict = @{
                           @"avatar":data
                           };
    afhttpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         nil];


    [afhttpSessionManager POST:rUrl parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        NSData *data = UIImagePNGRepresentation(image);
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:data
                                    name:@"avatar"
                                fileName:@"gauge.png"
                                mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        CLog(@"上传图片 --------%@",dict);
        if([[dict objectForKey:@"code"] integerValue] == 10110)
        {
            [self popLogin];
        }else{
            myblock(dict,[[dict objectForKey:@"code"] integerValue]);
        }
        NSLog(@"上传成功");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败%@",error);
    }];
}

//session过去，统一回到登录界面

-  (void)popLogin
{
    [JPUSHService setTags:nil alias:@"" callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];

    NSString *str =  [[NSUserDefaults standardUserDefaults] objectForKey:@"didSelectItem"];
    NSInteger sIndec = 0;
    for (NSString * cstr in tabArray) {
        if ([cstr isEqualToString:str]) {
            sIndec = [tabArray indexOfObject:cstr];
            break;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      
        LoginViewController *logv = [[LoginViewController alloc] init];
        NAVVController *nav = [[NAVVController alloc] initWithRootViewController:logv];
        [UIApplication sharedApplication].delegate.window.rootViewController = nav;
        
        [nav popToRootViewControllerAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.24* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
              [[KHJHub shareHub] showText:@" X 登录过期" addToView:[UIApplication sharedApplication].delegate.window];
            
           
            
        });
       
    });
}

//

@end


/*设备
 字典为--------{
 code = 1;
 data =     {
 devices =         (
 );
 sharedevices =         (
 );
 userAccount = 100063;
 };
 message = success;
 }
 */












