//
//  KHJShakeObj.m
//  KHJCamera
//
//  Created by hezewen on 2018/7/18.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "KHJShakeObj.h"
#import <AVFoundation/AVFoundation.h>

@interface KHJShakeObj ()
{
    SystemSoundID sound;
    NSTimer *shakeTimer;
}
@end
@implementation KHJShakeObj


-(void)stopButton_cClickedAction{
    NSLog(@"stop button action");
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
}

-(void)stopAlertSoundWithSoundID:(SystemSoundID)sound {
    
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
}

-(void)startButton_cClickedAction{
    NSLog(@"start button action");
    //如果你想震动的提示播放音乐的话就在下面填入你的音乐文件
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"marbach" ofType:@"mp3"];
    //    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, soundCompleteCallback1, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //    AudioServicesPlaySystemSound(sound);
    
}

void soundCompleteCallback1(SystemSoundID sound,void * clientData) {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  //震动
    //    AudioServicesPlaySystemSound(sou·nd);
}

extern OSStatus
AudioServicesAddSystemSoundCompletion(  SystemSoundID               inSystemSoundID,
                                      CFRunLoopRef                         inRunLoop,
                                      CFStringRef                          inRunLoopMode,
                                      AudioServicesSystemSoundCompletionProc  inCompletionRoutine,
                                      void*                                inClientData)
__OSX_AVAILABLE_STARTING(__MAC_10_5,__IPHONE_2_0);

@end









