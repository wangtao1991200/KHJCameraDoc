//
//  PublicDefine.h

#ifndef PublicDefine_h
#define PublicDefine_h

// 支付成功通知
#define PaySuccess_Noti             @"PaySuccess"
//
#define glGetError_Noti             @"glGetErrorNoti"
// 视频数据错误通知
#define VideoDecoderBadDataErrNotification_Noti @"VideoDecoderBadDataErrNotification"
// 修改设备名称
#define changeDeviceName_Noti       @"changeDeviceName"
// 删除设备通知
#define deleteDev_Noti              @"deleteDev"
// 设备ap模式通知
#define ap_Model_Noti               @"isCurrentAP"
// 刷新设备列表通知
#define needReloadList_Noti         @"isNeedRefreshList"
// 获取到uid通知
#define recieveUID_Noti             @"recieveUID"
//
#define recieveShare_Noti           @"recieveShare"
//
#define flushSoundID_Noti           @"flushSoundID"
// 录屏成功，刷新VideoViewController
#define reloadVideoVC_Noti          @"reloadVideoVC"

#define String(...)  [NSString stringWithFormat:__VA_ARGS__]

#endif /* PublicDefine_h */
