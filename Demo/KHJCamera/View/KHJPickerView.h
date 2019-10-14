//
//  KHJPickerView.h
//  TimeLineView
//
//  Created by hezewen on 2018/9/6.
//  Copyright © 2018年 zengjia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dateChanged)(NSString *str);

@interface DePickerView : UIView

-(void)dateChanged:(dateChanged)block;
- (UIButton *)getShowButton;
- (void)changeRightBtnState:(BOOL)isH;

@end
