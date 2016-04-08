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
@end
