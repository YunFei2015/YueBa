//
//  QYSelectModel.m
//  约吧
//
//  Created by Shreker on 16/5/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYSelectModel.h"
#import "NSString+Extension.h"

@implementation QYSelectModel

+ (instancetype)selectModelWithDictionary:(NSDictionary *)dicData {
    if (dicData == nil || [dicData isKindOfClass:[NSNull class]]) return nil;
    QYSelectModel *select = [self new];
    select.strText = [NSString getValidStringWithObject:dicData[@"<#name#>"]];
    
    return select;
}

@end
