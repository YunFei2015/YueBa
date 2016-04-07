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
+(BOOL)isTelephoneNumber:(NSString *)telephone;
@end
