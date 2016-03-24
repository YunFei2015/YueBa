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

//-(NSArray *)rangesOfSubString:(NSString *)subString{
//    NSMutableArray *ranges = [NSMutableArray array];
//    NSRange resultRange;
//    NSRange searchRange = NSMakeRange(0, self.length);
//    while ((resultRange = [self rangeOfString:subString options:0 range:searchRange]).location != NSNotFound) {
//        [ranges addObject:[NSValue valueWithRange:resultRange]];
//        searchRange = NSMakeRange(NSMaxRange(resultRange), self.length - NSMaxRange(resultRange));
//    }
//    
//    return [NSArray arrayWithArray:ranges];
//}

@end
