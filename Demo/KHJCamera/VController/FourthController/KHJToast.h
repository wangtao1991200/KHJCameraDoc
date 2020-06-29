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
    _SuccessType = 2,
    _ErrorType,
    _WarningType,
    _TipType,
} KHJToastType;

typedef enum : NSUInteger {
    _TopPostion = 0,
    _BottomPostion,
    _CenterPostion,
} KHJToastPosition;

@interface KHJToast : NSObject

+ (instancetype)share;

/**
 底部 - 轻量级toast
 */

/**
Bottom-Lightweight toast
*/
- (void)showSingleToastWithContent:(NSString *)content;

/**
 中部 - toast
 */

/**
Central-toast
*/
- (void)showOKBtnToastWith:(NSString *)tip content:(NSString *)content;

/**
 状态提示：成功，失败，警告，提示
 
 @param type    toast类型
 @param postion toast位置（顶，中，下）
 @param tip     提示信息
 @param content 内容信息
 */

/**
 Status prompt: success, failure, warning, prompt

 @param type toast type
 @param postion toast location (top, middle, bottom)
 @param tip information
 @param content content information
 */
- (void)showToastActionWithToastType:(KHJToastType)type
                        toastPostion:(KHJToastPosition)postion
                                 tip:(NSString *)tip
                             content:(NSString *)content;

@end
