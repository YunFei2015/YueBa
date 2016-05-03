//
//  QLSingleton.h
//  单例宏定义
//
//  Created by 闫庆龙 on 14-4-29.
//  Copyright (c) 2014年 闫庆龙. All rights reserved.
//

#ifndef Demo_QLSingleton_QLSingleton_h
#define Demo_QLSingleton_QLSingleton_h

/**
 * @brief 单例的实例声明
 */
#define QLSingletonInterface(name)  + (QL##name *)shared##name;

/**
 * @brief 单例的实例实现
 */
#define QLSingletonImplementation(name)         \
static QL##name *_instance;                     \
+ (QL##name *)shared##name  {                   \
if (_instance == nil) {                         \
_instance = [[self alloc] init];        \
}                                           \
return _instance;                           \
}                                               \
+ (id)allocWithZone:(NSZone *)zone {            \
static dispatch_once_t onceToken;           \
dispatch_once(&onceToken, ^{                \
_instance = [super allocWithZone:zone]; \
});                                         \
return _instance;                           \
}                                               \
+ (id)copyWithZone:(struct _NSZone *)zone {     \
return _instance;                           \
}
//- (oneway void)release {                        \
//}                                               \
//- (id)autorelease {                             \
//    return _instance;                           \
//}                                               \
//- (id)retain {                                  \
//    return _instance;                           \
//}                                               \
//- (NSUInteger)retainCount {                     \
//    return 1;                                   \
//}                                               \

#endif
