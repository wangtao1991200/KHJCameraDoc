//
//  SaveManager.m
//  LawCourtAssistant
//
//  Created by cz on 2017/3/13.
//  Copyright © 2017年 cz. All rights reserved.
//

#import "KHJSaveManager.h"
#import <objc/runtime.h>

#define SET_USERINFO @"USERINFO"
#define SingleH(name) +(instancetype)share##name;

#if __has_feature(objc_arc)
//条件满足 ARC
#define SingleM(name) static id _instance;\
+(instancetype)allocWithZone:(struct _NSZone *)zone\
{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [super allocWithZone:zone];\
});\
\
return _instance;\
}\
\
+(instancetype)share##name\
{\
return [[self alloc]init];\
}\
\
-(id)copyWithZone:(NSZone *)zone\
{\
return _instance;\
}\
\
-(id)mutableCopyWithZone:(NSZone *)zone\
{\
return _instance;\
}

#else
//MRC
#define SingleM(name) static id _instance;\
+(instancetype)allocWithZone:(struct _NSZone *)zone\
{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [super allocWithZone:zone];\
});\
\
return _instance;\
}\
\
+(instancetype)share##name\
{\
return [[self alloc]init];\
}\
\
-(id)copyWithZone:(NSZone *)zone\
{\
return _instance;\
}\
\
-(id)mutableCopyWithZone:(NSZone *)zone\
{\
return _instance;\
}\
-(oneway void)release\
{\
}\
\
-(instancetype)retain\
{\
return _instance;\
}\
\
-(NSUInteger)retainCount\
{\
return MAXFLOAT;\
}
#endif

@implementation KHJSaveManager

SingleM(SaveManager)

/**
 用户信息

 @param userMess <#userMess description#>
 */
- (void)setUserMess:(NSMutableDictionary *)userMess
{
    
    if (!userMess) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SET_USERINFO];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:[self removeNullValueFromDicm:userMess] forKey:SET_USERINFO];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableDictionary *)userMess
{
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:SET_USERINFO]);
    NSMutableDictionary * dic = (NSMutableDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:SET_USERINFO];
    return dic;
}

/**
 从用户信息中移除空属性

 @param userMess <#userMess description#>
 */
- (NSMutableDictionary *)removeNullValueFromDicm:(NSDictionary *)userMess
{
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
    for (NSString *keyStr in userMess.allKeys) {
        if ([[userMess objectForKey:keyStr] isEqual:[NSNull null]]) {
            [mutableDic setObject:@"" forKey:keyStr];
        }
        else{
            [mutableDic setObject:[userMess objectForKey:keyStr] forKey:keyStr];
        }
    }
    return mutableDic;
}


+ (void)clearAllPropertiesisNil{
    
    //属性个数
    unsigned int outCount;
    //获取属性的结构体指针
    objc_property_t *properties = class_copyPropertyList(self, &outCount);
    
    //遍历所有属性
    for (int i = 0; i < outCount; i++)
    {
        //获取属性的结构体
        objc_property_t property = properties[i];
        
        //获取属性名字
        const char *name = property_getName(property);
        
        // const char *attStr = property_getAttributes(property);
        
        NSString *getterName = [NSString stringWithUTF8String:name];
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:getterName];
        
        
    }// for
    
    [[NSUserDefaults standardUserDefaults ]synchronize];
    free(properties);
    
}


- (void)clearAllPropertiesisNil
{
    [[self class] clearAllPropertiesisNil];
    
}

+ (void)clearAllValue
{
    //属性个数
    unsigned int outCount;
    //获取属性的结构体指针
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    //遍历所有属性
    for (int i = 0; i < outCount; i++)
    {
        //获取属性的结构体
        objc_property_t property = properties[i];
        
        //获取属性名字
        const char *name = property_getName(property);
        
        NSString *getterName = [NSString stringWithUTF8String:name];
        
        [[KHJSaveManager shareSaveManager] setValue:nil forKeyPath:getterName];
        
    }// for
    
    free(properties);

    
    
    
    
}




@end

@implementation KHJSaveManager (AddToUserDefault)

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self cjy_propertiesFromClass:[self class]];
        });
    }
    return self;
}

- (void)cjy_propertiesFromClass:(Class)class
{
    //属性个数
    unsigned int outCount;
    //获取属性的结构体指针
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    
    //遍历所有属性
    for (int i = 0; i < outCount; i++)
    {
        //获取属性的结构体
        objc_property_t property = properties[i];
        
        //获取属性名字
        const char *name = property_getName(property);
        
        NSString *getterName = [NSString stringWithUTF8String:name];
        
        id val = [[NSUserDefaults standardUserDefaults] objectForKey:getterName];
        
        if ([getterName containsString:@"serMess"]) {
            continue;
        }
        
        [self setValue:val forKey:getterName];
                
    }// for
    
    free(properties);
    
}



+ (void)load{
    
    unsigned int count = 0;
    
    Method * a = class_copyMethodList([self class], &count);
    
    for (unsigned int i = 0; i < count; i ++) {
        
        NSString * methodName = NSStringFromSelector(method_getName(a[i]));
        
        if ([methodName containsString:@"serMess"]) {
            continue;
        }
        
        //获得set方法，更改set
        if([methodName hasPrefix:@"set"]){
            method_setImplementation(a[i], (IMP)new_setter);
        }
    }
    
    free(a);
    
}




static NSString * getterForSetter(NSString *setter)
{
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    return key;
}

static void new_setter(id self, SEL _cmd, id newValue)
{
    //根据SEL获得setter方法名
    NSString * setterName = NSStringFromSelector(_cmd);
   
    //获得getter方法名
    NSString *getterName = getterForSetter(setterName);
    //异常处理

    if (!getterName) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        return;
    }
    
    unsigned int count ;
    
    //拼接变量名
    NSString * s = @"_";
    s = [s stringByAppendingString:getterName];
    
    //得到变量列表
    Ivar * members = class_copyIvarList([self class], &count);
    
    int index = -1;
    //遍历变量
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        //获得变量名
        const char *memberName = ivar_getName(var);
        
        //生成string
        NSString * memberNameStr = [NSString stringWithUTF8String:memberName];
        if ([s isEqualToString:memberNameStr]) {
            index = i;
            break ;
        }
        
    }
    
    //变量存在则赋值
    if (index > -1) {
        Ivar member= members[index];
        object_setIvar(self, member, newValue);
    }
    
    //你可以做所有你想做的事~
    if (newValue != nil) {
        if ([newValue isKindOfClass:[NSNull class]]) {
            
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:getterName];
            [[NSUserDefaults standardUserDefaults ]synchronize];
        }
        
    }
    
    //释放指针
    free(members);
    
}


@end


