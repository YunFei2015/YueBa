//
//  NSDate+Extension.m
//  约吧
//
//  Created by 云菲 on 4/7/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

-(NSString *)stringFromDateWithFormatter:(NSString *)formatter{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatter;
    return [dateFormatter stringFromDate:self];
}

+(NSDate *)dateFromDateString:(NSString *)dateString withFormatter:(NSString *)formatterString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = formatterString;
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}
@end
