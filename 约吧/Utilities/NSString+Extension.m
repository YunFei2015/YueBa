//
//  NSString+Extension.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

-(CGSize)sizeWithFont:(UIFont *)font forSize:(CGSize)scheduleSize attributes:(NSDictionary *)attributes{
    CGRect rect = [self boundingRectWithSize:scheduleSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return rect.size;
}

+(BOOL)isTelephoneNumber:(NSString *)telephone{
    //检查是否为手机号
    //    电信号段:133/153/180/181/189/177
    //    联通号段:130/131/132/155/156/185/186/145/176
    //    移动号段:134/135/136/137/138/139/150/151/152/157/158/159/182/183/184/187/188/147/178
    //    虚拟运营商:170
    NSString *telFormat = @"^1(3\\d|4[57]|5[0-35-9]|7[06-8]|8\\d)\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telFormat];
    BOOL isTel = [predicate evaluateWithObject:telephone];
    return isTel;
}

@end
