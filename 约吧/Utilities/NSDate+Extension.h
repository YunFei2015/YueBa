//
//  NSDate+Extension.h
//  约吧
//
//  Created by 云菲 on 4/7/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

/**
 *  将时间转化为字符串格式
 *
 *  @param formatter 指定字符串格式
 *
 *  @return 时间字符串
 */
-(NSString *)stringFromDateWithFormatter:(NSString *)formatter;

/**
 *  将字符串时间转化成NSDate
 *
 *  @param dateString      字符串时间
 *  @param formatterString 字符串格式
 *
 *  @return NSDate时间
 */
+(NSDate *)dateFromDateString:(NSString *)dateString withFormatter:(NSString *)formatterString;
@end
