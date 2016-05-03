//
//  NSString+Extension.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Extension)
- (CGSize)sizeWithFont:(UIFont *)font forSize:(CGSize)scheduleSize attributes:(NSDictionary *)attributes;

/**
 *  判断字符串是否为手机号
 *
 *  @param telephone 手机号码
 *
 *  @return 是/否
 */
+(BOOL)isTelephoneNumber:(NSString *)telephone;

/**
 *  获取指定文件名在Documents目录下的完整路径
 *
 *  @param fileName 文件名
 *
 *  @return 文件路径
 */
+(NSString *)pathInDocumentWithFileName:(NSString *)fileName;

/**
 *  获取指定文件名在Library目录下的完整路径
 *
 *  @param fileName 文件名
 *
 *  @return 文件路径
 */
+(NSString *)pathInLibraryWithFileName:(NSString *)fileName;

/**
 *  获取表情
 *
 *  @param message 表情字符串
 *
 *  @return 表情文本
 */
+(NSAttributedString *)faceAttributeTextWithMessage:(NSString *)message withAttributes:(NSDictionary *)attributes faceSize:(CGFloat)faceSize;

/**
 *  从给定的对象中获取有效字符串
 *
 *  @param obj 源数据
 *
 *  @return 返回获取到的字符串对象
 */
+ (instancetype)getValidStringWithObject:(id)obj;
@end
