//
//  QYAutoHeightModel.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYAutoHeightModel.h"
#import "NSString+Extension.h"

@implementation QYAutoHeightModel

+ (instancetype)autoHeightModelWithDictionary:(NSDictionary *)dicData {
    if (dicData == nil || [dicData isKindOfClass:[NSNull class]]) return nil;
    QYAutoHeightModel *autoHeight = [self new];
    autoHeight.strImageName = [NSString getValidStringWithObject:dicData[@"imageName"]];
    autoHeight.strTitle = [NSString getValidStringWithObject:dicData[@"title"]];
    
    NSArray *arrTags = dicData[@"tags"];
    if ([arrTags isKindOfClass:[NSArray class]]) {
        autoHeight.arrTags = arrTags;
    } else {
        autoHeight.arrTags = nil;
    }
    
    return autoHeight;
}

@end
