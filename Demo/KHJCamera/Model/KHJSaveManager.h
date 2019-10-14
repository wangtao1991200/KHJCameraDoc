
//
//  SaveManager.h
//  LawCourtAssistant
//
//  Created by cz on 2017/3/13.
//  Copyright © 2017年 cz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHJSaveManager : NSObject

/*
   1. 此脚本命名必须小写开头 否则为空 
   2. 存数组只能存 NSArry 不可变数组 用strong
   3. 初始化的nsstring 输出来为 (null)  如果要判断 是这样if([SaveManager shareSaveManager].test == nil)
      如果已经设置值了 要单独清空这个值 就这样 [SaveManager shareSaveManager].test = nil ;
   4. 如果不赋值 输出来是 <null>  则这样： if([m_result isEqual：[NSNUll null]])
   5. 如何判断字典为空 [czAccountDict isKindOfClass:[NSNull class]]
 
*/


// 是否登入了
@property (nonatomic, strong) NSNumber *isLogined;
// 是否保存密码 下次进入应用直接登入
@property (nonatomic,strong) NSNumber *isSaveLogin ;
// 注册时 如果注册成功了 就保存下来用户名 这样登入的时候覆盖 以后用手势登入-都是默认登入这个用户名-除非重新注册和退出账号

@property(nonatomic,strong) NSString *usereNameRegis ;//要么是手机要么是邮箱
@property(nonatomic,strong) NSString *userePwd ;

// 用户账号- 不是登入账号 是注册后 服务器给当前用户的账号
@property(nonatomic,strong) NSString *usereAccount ;

// 用户用来登入的账号- 可能是手机 可能是邮箱 都可以用来登入 密码是通用的
@property(nonatomic,strong) NSString *usereAccountPhone ; // 手机
@property(nonatomic,strong) NSString *userAccountEmail ; // 邮箱

// 用户头像data 这是本地选取照片存的
@property(nonatomic,strong) NSData *headData ;
// 头像网络url地址
@property(nonatomic,strong) NSString *headURL ;

// 用户昵称
@property(nonatomic,strong) NSString *userNickname ;
/*
    保存至文件夹相关
 */

// 用户关联名 - 用来取文件夹名字的 保存手机文件夹要取名 动态名- 每个用户生成的不同 这个是登入账号的id
@property(nonatomic,strong) NSString *userID ;//等于usereAccount


// 这个设备uid
@property(nonatomic,strong) NSString *userDeviceUID ;

// 找到密码用的
@property(nonatomic,strong) NSString *userFindPwdUserF ;



/*
   通用设置相关 在Appdelegate.m里面初始化
*/
// 是否开启消息推送 默认开启
@property(nonatomic,strong) NSNumber *notification ;
// 是否进入监控默认关闭声音 默认关闭
@property(nonatomic,strong) NSNumber *shutMonitorVoice ;
// 清晰度 0 流畅 1 标清 2 高清 默认标清1
@property(nonatomic,strong) NSString *resolution ;
// 是否麦克风声音增强 默认不增强
@property(nonatomic,strong) NSNumber *microphoneAdd ;
// 是否关闭回访声音 默认不增强
@property(nonatomic,strong) NSNumber *shutBackVoice ;
// 报警是否自动开启视频片段录制 默认不开启
@property(nonatomic,strong) NSNumber *recordVideo ;
// 手势操作水平翻转 默认开启
@property(nonatomic,strong) NSNumber *flipOverH ;
// 水平操作竖直翻转
@property(nonatomic,strong) NSNumber *flipOverV ;
// 是否需要报警铃声 默认开启
@property(nonatomic,strong) NSNumber *isVoiceSoS ;




+ (instancetype)shareSaveManager ;

// 清楚所有保存的东西 需重启app生效 
+ (void)clearAllPropertiesisNil ;
-(void)clearAllPropertiesisNil ;

// 清楚所有保存的东西 立即清除
+ (void)clearAllValue ;
@end
