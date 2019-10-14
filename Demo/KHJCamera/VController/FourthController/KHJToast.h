//
//  KHJToastView.h
//
//
//
//
//

#import <Foundation/Foundation.h>
#import "FFToast.h"

typedef enum : NSUInteger {
    _SuccessType = 2,   //绿色背景+成功图标
    _ErrorType,         //红色背景+错误图标
    _WarningType,       //橙色背景+警告图标
    _TipType,           //灰蓝色背景+信息图标
} KHJToastType;

typedef enum : NSUInteger {
    _TopPostion = 0,    //在屏幕顶部
    _BottomPostion,     //在屏幕底部
    _CenterPostion,     //在屏幕中间
} KHJToastPosition;

@interface KHJToast : NSObject

+ (instancetype)share;

/**
 底部 - 轻量级toast
 */
- (void)showSingleToastWithContent:(NSString *)content;

/**
 中部 - toast
 */
- (void)showOKBtnToastWith:(NSString *)tip content:(NSString *)content;

/**
 状态提示：成功，失败，警告，提示
 
 @param type    toast类型
 @param postion toast位置（顶，中，下）
 @param tip     提示信息
 @param content 内容信息
 */
- (void)showToastActionWithToastType:(KHJToastType)type
                        toastPostion:(KHJToastPosition)postion
                                 tip:(NSString *)tip
                             content:(NSString *)content;

@end
