//
//  NSDate+Extension.m
//  约吧
//
//  Created by 云菲 on 4/7/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

-(NSString *)dateToStringWithFormatter:(NSString *)formatter{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatter;
    return [dateFormatter stringFromDate:self];
}

@end
