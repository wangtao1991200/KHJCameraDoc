//
//  KHJPublicDefine.h

#ifndef KHJPublicDefine_h
#define KHJPublicDefine_h


// 视频数据错误通知
// Video data error notification
#define VideoDecoderBadDataErrNotification_Noti @"VideoDecoderBadDataErrNotification"
// 修改设备名称
// Modify the device name
#define changeDeviceName_Noti       @"changeDeviceName"
// 刷新设备列表通知
// Refresh the device list notification
#define needReloadList_Noti         @"isNeedRefreshList"
// 获取到uid通知
// get uid notification
#define recieveUID_Noti             @"recieveUID"
//
#define recieveShare_Noti           @"recieveShare"
// 设备ap模式通知
// Device ap mode notification
#define ap_Model_Noti               @"isCurrentAP"

#define String(...)  [NSString stringWithFormat:__VA_ARGS__]

#endif /* KHJPublicDefine_h */
