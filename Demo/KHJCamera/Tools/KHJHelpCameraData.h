//
//  KHJHelpCameraData.h
//  khj
//
//  Created by lxl on 2018/4/10.
//  Copyright © 2018年 lzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHJHelpCameraData : NSObject

// 类似于工具类  获取iOS文件夹下一些东西/路径 等

+ (KHJHelpCameraData *)sharedModel;

//获取当前用户文件夹下所有文件
- (NSArray *)getAllFile;
// 获取图片路径 存储的时候加上设备uid标记是哪一台设备的
- (NSString *)getTakeCameraDocPath ;
// 获取视频路径
- (NSString *)getTakeVideoDocPath ;
// 获取音频文件夹路径
- (NSString *)getAudioDocPath;
// 取得一个目录下得所有图片文件名
- (NSArray *)getPictureArray;
// 取得报警下载的图片
- (NSArray *)getAlarmPictureArray;
// 取得一个目录下得所有mp4视频文件名
- (NSArray *)getmp4VideoArray;
// 返回存储存储的照片或者视频的名字
- (NSString *)getVideoNameWithType:(NSString *)fileType;
// 获取SD卡下载视频或图片的名称
- (NSString *)getVideoNameWithType:(NSString *)fileType withDate:(NSString *)dateString andTime:(NSString *)timeString;
// 转换路径（sd卡录制的文件命名不同）
- (NSString *)changeName:(NSString *)fileName withType:(NSInteger) type;
//删除文件
- (BOOL)DeleateFileWithPath:(NSString *)path;
//自动生成10位随机密码
- (NSString *)getRandomPassword;
//wifi安全选项转换为nsstring
-(NSString *)switchEncptry:(int)enctype;

//报警图片文件夹
- (NSString *)getTakeAlarmDocPath;

@end


















