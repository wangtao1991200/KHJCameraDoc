//
//  KHJSelectView.h
//  KHJCamera
//
//  Created by hezewen on 2018/7/18.
//  Copyright © 2018年 khj. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^selectCallback)(NSString *inputString);


@interface KHJSelectView : UIView
@property (nonatomic, copy)selectCallback selBlock;
@property (nonatomic, copy)NSString *cateStr;
- (void)show;

@end
