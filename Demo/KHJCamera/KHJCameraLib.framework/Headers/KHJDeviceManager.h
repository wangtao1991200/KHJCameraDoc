//
//  KHJDeviceManager.h
//  KHJCamera

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import "OpenGLView20.h"
#import "TimeInfo.h"

typedef NS_ENUM(NSInteger,KHJVideoQuality)
{
    KHJVideoQualityUnknown              = 0x00,
    KHJVideoQualityMax                  = 0x01,//HD
    KHJVideoQualityHigh                 = 0x02,//HD
    KHJVideoQualityMiddle               = 0x03,//SD
    KHJVideoQualityLow                  = 0x04,//SD
    KHJVideoQualityMin                  = 0x05
};

typedef enum : NSUInteger {
    KHJ_server,     // khj
    MAEVIA_sercer,  // MAEVIA
} KHJServerType;

@interface KHJDeviceManager : NSObject

@property(nonatomic,strong) OpenGLView20 *glView;

/**
Create Camera

@param deviceID deviceID
@param keyword keyword
*/
- (void)creatCameraBase:(NSString *)deviceID keyword:(NSString *)keyword;

/**
 Device connection
 
 @param pwd password
 @param uidStr deviceID
 @param resultBlock resultBlock
 @param offLineBlock offLineBlock
 @return result
 */
- (BOOL)connect:(NSString *)pwd
        withUid:(NSString *)uidStr
           flag:(int)flag
successCallBack:(void(^)(NSString *uidStr,NSInteger isSuccess))resultBlock
offLineCallBack:(void(^)(void))offLineBlock;

/**
 Reconnect device
 
 @param pwd password
 @param uidStr deviceID
 @param resultBlock resultBlock
 @param offLineBlock offLineBlock
 @return result
 */
- (BOOL)reConnect:(NSString *)pwd
          withUid:(NSString *)uidStr
             flag:(int)flag
  successCallBack:(void(^)(NSString *uidString, NSInteger isSuccess))resultBlock
  offLineCallBack:(void(^)(void))offLineBlock;

/**
 Disconnect
 */
- (BOOL)disconnect;

/**
 After adding a device, set up an account, bind users and devices.
 
 @param uAccount user account
 @param ssid wired connection does not pass
 @param passPwd Wired connection does not need to pass
 @param urlStr server address
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (BOOL)setAccount:(NSString *)uAccount
           andSsid:(NSString *)ssid
           andSPwd:(NSString *)passPwd
        andService:(NSString *)urlStr
       returnBlock:(void(^)(BOOL success))resultBlock;

/*
 * Query whether it is currently online
 * 0: Offline 1: Online 2: Connecting
 */
- (int)checkDeviceStatus;

/**
 Set device new password
 Process: Device Add - The device actively modifies the device password and passes it to the server. - When the app gets the device list, the server returns the device password. - The app initiates the device connection request.
 
 @param oldpassword device old password
 @param newpassword device new password
 @param uidStr device id
 @param resultBlock successful callback
 */
- (void)setPassword:(NSString *)oldpassword
        Newpassword:(NSString *)newpassword
            withUid:(NSString *)uidStr
     returnCallBack:(void(^)(BOOL b))resultBlock;

/**
 Device restart
 */
- (BOOL)deviceReboot;

/**
 Search all devices under the LAN
 */
+ (void)searchDevice:(void(^)(NSMutableArray *darray))resultBlock;

/**
 Stop searching for devices
 */
+ (void)stopSearchDevice;

/**
 Turn on the audio
 */
- (void)openAudio;

/**
 Turn off audio
 */
- (void)closeAudio;

/**
 Stop playing audio
 */
- (void)audioPlayStop;

/**
 Device screenshot method
 */
- (void)getTrueIamge:(NSString *)urlString
      returnCallBack:(void(^)(BOOL b))resultBlock;

/**
 Get video thumbnails - h264 format, h265 format
 
 @param fileName Video file name
 @param outFileName output file name
 @param dWidth image width
 @param dHeight Image height
 @return thumbnail
 */
+ (UIImage *)getCoverImage:(NSString *)fileName
                outPutName:(NSString *)outFileName
                     width:(int)dWidth
                    height:(int)dHeight;

/**
 Video screen flip 180
 
 @param derect 0: Do not flip 1: Flip 180
 @param resultBlock
 - success YES flips successfully, NO reverses unsuccessfully
 */
- (BOOL)setFlippingWithDerect:(int)derect
                  returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get the current video screen flip status
 
 @param resultBlock
 - success YES has been flipped 180, NO original state
 */
- (BOOL)getFLipping:(void(^)(BOOL success))resultBlock;

/*
 Screenshot
 
 0: Success 1: No sd card 2: Failure
 */
- (BOOL)screenShot:(void(^)(BOOL b))resultBlock;

/**
 Device recording video -> SD card
 1. Send instructions by mobile phone
 2. Send instructions by embedded
 
 0: Success 1: No sd card 2: Failure
 */
- (BOOL)videoRecordingStart:(void(^)(BOOL b))resultBlock;

/**
 End device recording video -> SD card
 
 0: Success 1: No sd card 2: Failure
 */
- (BOOL)videoRecordingStop:(void(^)(BOOL b))resultBlock;

/**
 Get the saved video file in the SD card
 3 modes for recording video on SD card: continuous recording, alarm recording, and timing recording
 
 @param date Date Timestamp
 @param b Is this the first page?
 @param resultBlock
 - isContinue Is there still a next page (number of device records)
 - mArray next video list
 */
- (void)listVideoFileStart:(long)date
                 withStart:(bool)b
               returnBlock:(void(^)(BOOL isContinue, NSMutableArray *mArray))resultBlock;

/**
 Obtain the alarm picture file of the SD card
 
 @param date Date Timestamp
 @param b Is this the first page?
 @param resultBlock
 - isContinue Is there still a next page (number of device records)
 - mArray next video list
 */
- (void)listJpegFileStart:(long)date
                withStart:(bool)b
              returnBlock:(void(^)(BOOL isContinue, NSMutableArray *mArray))resultBlock;

/**
 Obtain device SD card information
 
 @param uid device id
 @param resultBlock query return parameter
 - allCapacity SDCard total memory
 - leftCapacity SDCard remaining memory
 - version device firmware version
 - model device type: IPC28
 - vendor Supplier
 - ffs reminds users to format sd card
 @return Get results
 */
- (BOOL)queryDeviceInfo:(NSString *)uid
            reternBlock:(void(^)(int allCapacity,
                                 int leftCapacity,
                                 int version,
                                 NSString *model,
                                 NSString *vendor,
                                 NSString *ffs))resultBlock;

/**
 Get all the videos in the SD card within the specified timestamp date
 
 @param timestamp query timestamp
 @param resultBlock
 - success YES get success, NO get failed
 - fileArr file list
 */
- (void)getAllVedioTime:(NSTimeInterval)timestamp
            returnBlock:(void(^)(BOOL success, NSMutableArray *fileArr))resultBlock;

/**
 Play back SD card video
 
 @param stringVedio SD card video file name
 @param isStart Whether to start playing, YES starts playing, NO stops playing
 @param startP 1
 @param uidStr device id
 @param resultBlock
 - mTotal
 - mCurrentP
 */
- (int)playSDVideo:(NSString *)stringVedio
         withStart:(BOOL)isStart
            seekTo:(NSInteger)startP
           withUid:(NSString *)uidStr
       returnBlock:(void(^)(int mTotal,int mCurrentP))resultBlock;

/**
 Download video file
 
 @param fileName Video file name
 @param uidStr device id
 @param resultBlock
 - data latest download return data, can be written to save data
 - hhSize downloaded video size
 - totalSize total video size
 */
- (int)downLoadVedioFile:(NSString *)fileName
                 withUid:(NSString *)uidStr
             returnBlock:(void(^)(NSData *data,int hhSize,int totalSize))resultBlock;

/**
 Cancel video download
 */
- (void)cancelDownLoadFile;

/**
 Download image file
 
 @param fileName Image file name
 @param resultBlock
 - data latest download return data, can be written to save data
 - hhSize downloaded video size
 - totalSize total video size
 
 @return
 -1: Transferring files
 -2: The device is offline and cannot download the SD card alarm picture.
 */
- (NSInteger)downLoadPhotoFile:(NSString *)fileName
                   returnBlock:(void(^)(NSData *data,int hhSize,int totalSize))resultBlock;

/**
 Universal upload file
 
 @param fileName file path
 @param name file name
 @param alias alias
 @param resultBlock
 - uint8_t: 0: successful, 1: file is too large 2: file is being sent 3: file is not supported 4: file reaches the upper limit, please delete after uploading 5: failed
 - uint32_t: total file size
 - uint32_t: How many bytes were sent
 
 @return
 0: Success
 -1: Transferring files
 -2: Device is no longer wired
 -3: File does not exist
 -4: The file name is too long
 */
- (int)uploadAudioFile:(NSString *)fileName
                  name:(NSString *)name
                 alias:(NSString *)alias
           returnBlock:(void(^)(uint8_t success,uint32_t totalSize,uint32_t hadSendSize))resultBlock;

/**
 upload files
 
 @param filePath file name
 @param resultBlock
 - uint8_t: 0: successful, 1: file is too large 2: file is being sent 3: file is not supported 4: file reaches the upper limit, please delete after uploading 5: failed
 - uint32_t: total file size
 - uint32_t: How many bytes were sent
 
 @return
 0: Success
 -1: Transferring files
 -2: Device is no longer wired
 -3: File does not exist
 -4: The file name is too long
 */
- (int)uploadFirmwareFile:(NSString *)filePath
              returnBlock:(void(^)(uint8_t success,uint32_t totalSize,uint32_t hadSendSize))resultBlock;

/*
 Cancel uploading .img installation package
 */
- (void)cancelUploadFirmwareFile;

/**
 Delete recording file
 
 @param fileName filename
 @param aliasName alias
 @param resultBlock resultBlock
 */
- (void)deleteAudioFileWithFileName:(NSString *)fileName
                          aliasName:(NSString *)aliasName
                         returnBloc:(void(^)(BOOL success))resultBlock;

/**
 Set default audio file
 
 @param fileName filename
 @param aliasName alias
 @param resultBlock resultBlock
 */
- (void)setDefaultAudioFileWithFileName:(NSString *)fileName
                              aliasName:(NSString *)aliasName
                             returnBloc:(void(^)(BOOL success))resultBlock;


/**
 播放录音文件
 
 @param fileName filename
 @param aliasName alias
 @param resultBlock resultBlock
 */
- (void)playAudioFileWithFileName:(NSString *)fileName
                        aliasName:(NSString *)aliasName
                       returnBloc:(void(^)(BOOL success))resultBlock;

/**
 获取录音文件列表
 
 @param resultBlock resultBlock
 */
- (void)getRecordAudioListWithReturnBlock:(void(^)(NSMutableArray *soundNameArr, NSMutableArray *soundAliasArr, int tag))resultBlock;

/**
 Camera enters the background
 */
+ (void)cameraEnterBackground;

/**
 The camera enters the foreground
 */
+ (void)cameraEnterForeground;

/**
 Destroy the Camera
 */
- (void)destroySelf;

/**
 Register the status of the listening device
 The device actively pushes the event to the app, event type + event parameter
 
 @param resultBlock
 - type Type: 0 Device is on 1 Device is off 2 Start recording 3 Stop recording 4 5 Device SD card insertion and playback 6 Video quality switching
 - dString such as: type == 0 type == 1, do not use dString
 Type == 6, will use dString
 - uidStr device id
 */
- (void)registerActivePushListener:(void(^)(int type, NSString *dString, NSString *uidStr))resultBlock;

/**
 Unlist device status
 */
- (void)unregisterActivePushListener;

/**
 Notify device upgrade
 
 @param resultBlock
 - success 0 upgrade succeeded, 1 upgrade failed
 */
- (void)notifyUpgrade:(void(^)(int success))resultBlock;

/**
 The application exits the background for more than 40s. When it enters again, it calls reinitsocket, frees resources, and reconnects.
 */
+ (void)reinitsocket;

/**
 Turn on video reception
 
 @param isReceive Whether to start receiving data, YES starts receiving data, NO stops receiving data
 @param uidStr device id
 @param resultBlock callback method
 */
- (BOOL)startRecvVideo:(BOOL)isReceive
               withUid:(NSString *)uidStr
           reternBlock:(void(^)(BOOL k))resultBlock;

/**
 Query whether to auto-cruise again
 */
- (BOOL)getPtzAutoStatus:(void(^)(BOOL b))resultBlock;

/**
 Get the current recording status
 
 0: No recording 1: Recording
 */
- (int)getvideoRecordStatus;

/**
 Whether to play audio
 */
- (void)isPlayRecvAudio:(BOOL)isPlayAudio;

/**
 Start or end recording a video
 
 @param on Start recording (YES) End recording (NO)
 @param path video save path
 */
- (void)startRecordMp4:(BOOL)on path:(NSString *)path;

/*
 * Real-time audio thread, do not open during playback
 *
 * param1 char *: compressed data
 * param2 unsigned int : data length, each time is fixed size: 320
 * param3 unsigned int : pts data timestamp
 */
- (BOOL)startRecvAudio:(BOOL)on;

/**
 Set the shaking machine to rotate
 
 @param direction Direction of rotation
 @param step Step count
 */
- (BOOL)setRun:(NSInteger)direction withStep:(NSInteger)step;

/**
 Whether to record audio
 */
- (void)delayStopRerord:(BOOL)isStop;

/**
 Send audio
 
 @param on YES Send audio, NO stop sending audio
 */
- (BOOL)startSendAudio:(BOOL)on;

/**
 Get video picture quality
 
 @return
 KHJVideoQualityUnknown              = 0x00,
 KHJVideoQualityMax                  = 0x01,//HD
 KHJVideoQualityHigh                 = 0x02,//HD
 KHJVideoQualityMiddle               = 0x03,//SD
 KHJVideoQualityLow                  = 0x04,//SD
 KHJVideoQualityMin                  = 0x05
 */
- (KHJVideoQuality)getVideoQuality;

/**
 Get mac and ip
 
 @return
 - success 0 success other failure
 - mac mac address
 - ip ip address
 */
- (BOOL)getMacIp:(void(^)(int success, NSString *mac, NSString *ip))resultBlock;

/**
 Format SDCard
 
 @param resultBlock
 - 0: Success
 - -1: Failed
 - -2: No sdcard inserted
 */
- (void)formatSdcard:(void(^)(int success))resultBlock;

/**
 Set time zone
 
 @param timezone time zone
 - " -660 -600 -540 -480 -420 -360 -300 -240 -180 -120 -60 0 60 120 180 240 300 360 420 480 540 600 660 720 ”
 @param resultBlock
 - success true set success, false set failed
 */
- (void)setTimezone:(NSInteger)timezone returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get time zone
 
 @param resultBlock
 - success returns the time zone parameter
 - " -660 -600 -540 -480 -420 -360 -300 -240 -180 -120 -60 0 60 120 180 240 300 360 420 480 540 600 660 720 ”
 */
- (void)getTimeZone:(void(^)(int success))resultBlock;

/**
 Get the network of the device (current connection)
 
 @param resultBlock 0: WIFI 1: Network cable 2: ap hotspot 3: Get failed
 */
- (void)getNetworkLinkStatus:(void(^)(int mode))resultBlock;

/**
 Query the wifi around the device
 
 @param wifiBlock
 - connectingWifiName The name of the wifi network being connected
 
 @param resultBlock
 - all wifi lists around the mArray device
 */
- (void)listWifiAp:(void(^)(NSString *connectingWifiName))wifiBlock
       returnBlock:(void(^)(NSMutableArray *mArray))resultBlock;

/**
 Open ap mode
 
 @param b YES: Turn on ap mode, NO: switch to normal mode
 */
- (void)switchingAp:(BOOL) b returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get device switch status
 
 @param resultBlock
 - uidString device id
 - success error code
 */
- (void)getDeviceCameraStatus:(void(^)(NSString *uidString,int success))resultBlock;

/**
 Device switch control
 
 @param isOpen YES Turn on the device, NO turn off the device
 @param resultBlock
 - uidString device id
 - success YES success, NO failure
 */
- (void)setDeviceCameraStatusWithOpen:(BOOL)isOpen
                          returnBlock:(void(^)(NSString *uidString,BOOL success))resultBlock;

/**
 Add a scheduled task for "Recording Video" (add all current tasks each time you add it)
 The data format is: "08:30-09:30\n10:00-12:30"
 Between groups and groups, use "\n" to separate up to 85 timed tasks
 
 @param array timer task array
 @param resultBlock
 - success YES success, NO failure
 */
- (void)addTimedRecordVideoTask:(NSArray *)array
                     returnBloc:(void(^)(BOOL success))resultBlock;

/**
 Get a timed list of devices "recorded video"
 
 @param resultBlock
 - mArray "recording video" timing list
 */
- (void)getTimedRecordVideoTask:(void(^)(NSMutableArray *mArray))resultBlock;

/**
 Get the timed task list of the device "time switch"
 
 @param resultBlock
 - mArray "switch machine" timing list
 */
- (void)getTimedCameraTask:(void(^)(NSMutableArray *mArray))resultBlock;

/**
 Add a timed task for "Timer Switching Machine" (add each current task each time you add it)
 The data format is: "08:30-09:30\n10:00-12:30"
 Between groups and groups, use "\n" to separate up to 85 timed tasks
 
 @param array timer task array
 @param resultBlock
 - success YES success, NO failure
 */
- (void)addTimedCameraTask:(NSArray *)array
                returnBloc:(void(^)(BOOL success))resultBlock;

/**
 Change the wifi of the device connection
 
 @param ssid wifi account, up to 31 characters
 @param pwd wifi password, up to 31 characters
 @param type wifi encryption, please see the enumeration AP_ENCTYPE, (wifi password type must pass 0x03)
 @param resultBlock
 - success YES success, NO failure
 */
- (void)setWifiAp:(NSString *)ssid
          withPwd:(NSString *)pwd
          andType:(NSInteger)type
       returnBloc:(void(^)(BOOL success))resultBlock;

/**
 Set video quality
 
 @param quality
 Super clear = 0x01,
 HD = 0x02,
 Medium = 0x03,
 SD = 0x04,
 Smooth = 0x05,
 @param resultBlock
 - success YES success, NO failure
 */
- (void)setVideoQuality:(int)quality
             returnBloc:(void(^)(BOOL success))resultBlock;

/**
 Get current viewers
 
 @param resultBlock
 - num number of viewers
 @return YES Gets success, NO gets failed
 */
- (BOOL)getCurrentWatchPeoples:(void(^)(int num))resultBlock;

/**
 Get device type
 */
- (int)getDeviceType;

/**
 Set the user's picture clarity when recording
 
 @param quality 1: Process, 2: SD, 3: HD
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (BOOL)setRecordVideoQuality:(int)quality
                  returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get the user's picture clarity when recording
 
 @param resultBlock
 - level 1: flow 2: standard definition 3: HD
 */
- (BOOL)getRecordVideoQuality:(void(^)(int level))resultBlock;

/**
 Get device volume
 
 @param resultBlock
 - volume volume: 0 - 100
 */
- (BOOL)getDeviceVolume:(void(^)(int volume))resultBlock;

/**
 Set device volume
 
 @param resultBlock
 - volume volume: 0 - 100
 */
- (BOOL)setDeviceVolume:(int)voice
            returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Set device motion detection alarm switch
 
 @param isOn YES Device alarm is on, NO device is off
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (BOOL)setAlarmSwitch:(BOOL)isOn
           returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get device motion detection alarm switch status
 
 @param resultBlock
 - success YES device alarm is on, NO device alarm is off
 */
- (BOOL)getAlarmSwitch:(void(^)(BOOL success))resultBlock;

/**
 Get motion detection level on or off
 
 @param resultBlock
 - level from low to high level = [1,2,3,4,5]
 */
- (BOOL)getMotionDetect:(void(^)(int level))resultBlock;

/**
 Set the device "Motion Detection" level
 
 @param level From low to high level = [1,2,3,4,5]
 @param resultBlock
 - succcess YES setting is successful, NO setting failed
 */
- (BOOL)setMotiondetect:(int)level
            returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Set the heartbeat address of the device, the heartbeat between the device camera and the server
 
 @param serviceURL heartbeat address
 @param resultBlock
 - success YES heartbeat address is set successfully, NO setting fails
 */
- (void)setHeartbeatService:(NSString *)serviceURL
                returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get device heartbeat address
 
 @param resultBlock
 - sUrl returns the heartbeat address
 */
- (void)getHeartbeatService:(void(^)(NSString *sUrl))resultBlock;

/**
 Set heartbeat time
 
 @param beatTime 0: stop, >= 1 enable timer
 */
- (void)setHeartbeatTime:(int)beatTime
             returnBlock:(void(^)(int mTime))resultBlock;

/**
 Get heartbeat time
 
 @param resultBlock
 - mTime heartbeat time
 */
- (void)getHeartbeatTime:(void(^)(int mTime))resultBlock;

/**
 Set the device alarm address, call this address when an alarm is triggered
 
 @param ipAddress alarm address url
 @param resultBlock
 - success YES success, NO failure
 - serviceURL alarm server address
 */
- (void)setphpserver:(NSString *)ipAddress
         returnBlock:(void(^)(BOOL success,NSString *serviceURL))resultBlock;

/**
 Get device alarm address
 
 @param resultBlock
 - success YES success, NO failure
 - serviceURL alarm server address
 */
- (void)getPhpserver:(void(^)(BOOL success,NSString *serviceURL))resultBlock;

/**
 Get current device cloud storage information
 
 @param resultBlock
 - isOpen open cloud storage
 - cloundType cloud service type (1 full-day video, 0 alarm recording)
 - uidString device id
 */
- (void)getCloundStorage:(void(^)(BOOL isOpen,int cloundType,NSString *uidString))resultBlock;

/**
 Set device cloud storage
 
 @param isStart Whether to open cloud storage
 @param type Cloud service type (1 full-day video, 0 alarm recording)
 @param resultBlock
 - success YES Successfully opened, NO failed to open
 */
- (void)setCloundStorage:(BOOL)isStart
                 andType:(int)type
             returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get camera device capability set
 */
- (void)getDeviceFunctionList:(void(^)(int isOpen))resultBlock;

/**
 Set camera device capability set
 */
- (void)setDeviceFunctionListWith:(int)cap
                            block:(void(^)(int success))resultBlock;

/**
 Get the night vision mode of the device
 
 @param resultBlock
 - model 0: automatic, 1: manual (isOn YES, isOn NO) 2: timing
 - on model = 1, manual: YES on, NO off
 - timeString model = 2, timing: "start time - end time"
 */
- (void)getIrcutModelWithBlock:(void(^)(int modeType, int isOn, NSString *time))resultBlock;

/**
 Set smart night vision mode
 
 @param modeType 0: Auto, 1: Manual (isOn YES, isOn NO) 2: Timing
 @param isOn ..
 @param timeInfo timing information
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (void)setIrcutModeWithModelType:(int)modeType
                             isOn:(int)isOn
                         timeInfo:(TimeInfo *)timeInfo
                      resultBlock:(void(^)(BOOL success))resultBlock;

/**
 Get humanoid alarm switch status
 
 @param resultBlock
 - status YES Humanoid detection is on, NO is off
 */
- (void)getPersonShapeAlarmWithBlock:(void(^)(BOOL status))resultBlock;

/**
 Set the humanoid alarm switch
 
 @param isOn YES Turns on humanoid detection, NO turns off humanoid detection
 @param resultBlock
 - success YES success, NO failure
 */
- (void)setPersonShapeAlarmWith:(int)isOn
                    returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get face alarm switch status
 
 @param resultBlock
 - status YES Humanoid detection is on, NO is off
 */
- (void)getPersonFaceAlarmWithBlock:(void(^)(BOOL status))resultBlock;

/**
 Set face alarm switch
 
 @param isOn YES Turns on face detection, NO turns off face detection
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (void)setPersonFaceAlarmWith:(int)isOn
                   returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get the sound detection switch status
 
 @param resultBlock
 - isStart YES is on, NO is not on
 */
- (void)getSoundAlarm:(void(^)(BOOL isStart))resultBlock;

/**
 Set the sound detection switch
 
 @param isStart Whether to enable sound detection
 @param resultBlock
 - success YES is turned on successfully, NO is turned on failed
 */
- (void)setSoundAlarm:(BOOL)isStart
          returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Query video mode
 */
- (void)getVideoRecordType:(void(^)(int type))resultBlock;

/**
 Set the recording mode
 
 @param type Turn off recording, continuous recording, timing planning, alarm recording
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (void)setVideoRecordType:(int)type
               returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get the switch status of the device alarm sound
 
 @param resultBlock
 - isOpen YES turns on the alarm sound, NO turns off the alarm sound
 */
- (void)getDeviceAlarmVolume:(void(^)(BOOL isOpen))resultBlock;

/**
 Set device alarm sound switch
 
 @param isOpen YES Alarm is on, NO is off
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (void)setDeviceAlarmVolume:(BOOL)isOpen
                 returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get device power (Beckon Cat Device)
 
 @param resultBlock
 - electriLevel 16 empty electricity, 17 1 grid, 18 2 grids, 19 3 grids, 20 4 grids (full grid)
 */
- (void)getBatteryLevel:(void(^)(int electriLevel))resultBlock;

/**
 Get the alarm mailbox
 
 @param resultBlock
 - userStr sender mailbox
 - userPwd sending email password
 - serverStr mailbox server
 - sendTo recipient mailbox
 - mPort port
 */
- (void)getEmail:(void(^)( NSString *userStr,NSString *userPwd,NSString *serverStr,NSString *sendTo,int mPort))resultBlock;

/**
 Set the alarm mailbox
 
 @param user Sender mailbox
 @param pass Sending email password
 @param server Mailbox server
 @param sendO Sender's mailbox
 @param port Mailbox server port
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (void)setEmail:(NSString *)user
          andPwd:(NSString *)pass
       andServer:(NSString *)server
       andSendto:(NSString *)sendO
         andPort:(int)port
     returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get the mailbox alarm switch status
 
 @param resultBlock
 - isOpen YES on, NO off
 */
- (void)getEmailAlarm:(void(^)(BOOL isOpen))resultBlock;

/**
 Set the mailbox alarm switch
 
 @param isOpen YES on, NO off
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (void)setEmailAlarm:(BOOL)isOpen
          returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get device alias
 
 @param resultBlock
 - aliasName alias
 - uidString device id
 */
- (void)getDeviceAlias:(void(^)(NSString *aliasName,NSString *uidString))resultBlock;

/**
 Set device alias
 
 @param name alias
 @param resultBlock
 - success YES setting is successful, NO setting failed
 */
- (void)setDeviceAlias:(NSString *)name
           returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get the status of various switches of the device, isOpen bitwise calculation
 
 @param resultBlock
 - No. 0 stands for gun white light
 - 1st place represents smart night vision
 - The second child represents the baby crying
 - The third representative represents object detection
 */
- (void)getLampOpen:(void(^)(int isOpen))resultBlock;

/**
 Set the status of various switches of the device, isOpen bitwise calculation
 
 @param isOpen
 - No. 0 stands for gun white light
 - 1st place represents smart night vision
 - The second child represents the baby crying
 - The third representative represents object detection
 */
- (void)setLampOpen:(int)isOpen
        returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Device General Command (433 Module Configuration Command)
 
 @param type
 - 0x2 Pairing instructions
 - 0x3 Rename directive
 - 0x4 Get 433 device list directive
 - 0x5 delete command
 - 0x6 Get 0 Disarm / 1 Arming Command
 - 0x7 Release 0 Disarm / 1 arming command
 - 0x8 Setting the alarm interval instruction
 - 0x9 Get the alarm interval instruction
 - 0x10 Firmware Address Configuration Query (not implemented)
 - 0x11 Firmware Address Configuration Settings (not implemented)
 - 0x12 Query alarm push switch
 - 0x13 Switch Alarm Push
 @param dataStr  json字符串
 0 remote control, 1 common sensor, 2 special sensor
 - 0x2 data={\"sensorType\":0}
 - 0x3 data={\"type\":8,\"name\":\"Smoke alarm\",\"sensorType\":0}
 - 0x4 data={\"sensorType\":0,\"page\":0}
 - 0x5 data={\"type\":8}
 @param resultBlock resultBlock
 */
- (void)sendCommomCMDWithType:(int)type
                     WithData:(NSString *)dataStr
                  returnBlock:(void(^)(BOOL success,int sType, NSString * fString))resultBlock;

/**
 Query arming status
 
 @param resultBlock
 - fenseState: 0 Disarming 1 Arming
 */
- (void)getDefenseState:(void(^)(int fenseState))resultBlock;
/**
 Set arming/disarming
 
 @param isDefense YES Arming, NO Disarming
 @param resultBlock instruction result
 */
- (void)setDefense:(BOOL)isDefense returnBlock:(void(^)(BOOL success))resultBlock;
/**
 Get alarm interval
 
 @param resultBlock
 - success is successful
 - interval
 */
- (void)getAlarmInterval:(void(^)(BOOL success,int interval))resultBlock;
/**
 Set the alarm interval
 
 @param interval interval seconds
 @param resultBlock
 - success
 */
- (void)setAlarmInterval:(int)interval returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Set device cloud storage URL

 @param url cloud Url
 @param resultBlock
 - success
*/
- (void)setDeviceCloudUrl:(NSString *)url returnCallBack:(void(^)(BOOL success))resultBlock;

/**
 Get device cloud storage URL

 @param resultBlock
 - cloudUrl
*/
- (void)getDeviceCloudUrl:(void(^)(NSString *cloudUrl))resultBlock;

/**
 Set device cloud storage upload URL

 @param url cloud upload url
 @param resultBlock
 - success
*/
- (void)setDeviceCloudUploadUrl:(NSString *)url returnCallBack:(void(^)(BOOL success))resultBlock;

/**
 Get device cloud storage upload URL

 @param resultBlock
 - cloudUrl
*/
- (void)getDeviceCloudUploadUrl:(void(^)(NSString *cloudUrl))resultBlock;

/**
 Set picture alarm address
 
 @param pictureUrl Picture alarm address
 @param resultBlock
 - success
*/
- (void)setPictureUrl:(NSString *)pictureUrl
          returnBlock:(void(^)(BOOL success))resultBlock;

/**
 Get picture alarm address
 
 @param resultBlock
 - pictureUrl Picture alarm address
 */
- (void)getPictureUrl:(void(^)(NSString *pictureUrl))resultBlock;

@end
