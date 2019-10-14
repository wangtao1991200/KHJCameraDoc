//
//  DeUIPickDate.h
//  OCTest
//
//  Created by hezezewen on 2018/2/25.
//  Copyright        rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PassValue)(NSString *str);
typedef void(^CancelValue)(void);

@interface DeUIPickDate : UIView

@property (nonatomic, copy) CancelValue cancelBlock;

+ (instancetype)setDate;
- (void)passvalue:(PassValue)block;
- (void)cancelValue:(CancelValue)block;

@end
