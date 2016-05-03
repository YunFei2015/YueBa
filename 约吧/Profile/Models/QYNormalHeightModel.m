//
//  QYNormalHeightModel.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYNormalHeightModel.h"
#import "NSString+Extension.h"

@implementation QYNormalHeightModel

+ (instancetype)normalHeightModelWithDictionary:(NSDictionary *)dicData {
    if (dicData == nil || [dicData isKindOfClass:[NSNull class]]) return nil;
    QYNormalHeightModel *normalHeightModel = [self new];
    normalHeightModel.strTitle = [NSString getValidStringWithObject:dicData[@"title"]];
    normalHeightModel.strContent = [NSString getValidStringWithObject:dicData[@"content"]];
    normalHeightModel.strPlaceholder = [NSString getValidStringWithObject:dicData[@"placeholder"]];
    
    return normalHeightModel;
}

@end
