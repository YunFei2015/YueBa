//
//  QYProfileSectionModel.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYProfileSectionModel.h"
#import "NSString+Extension.h"
#import "QYNormalHeightModel.h"
#import "QYAutoHeightModel.h"

@implementation QYProfileSectionModel

+ (instancetype)profileSectionModelWithDictionary:(NSDictionary *)dicData {
    if (dicData == nil || [dicData isKindOfClass:[NSNull class]]) return nil;
    QYProfileSectionModel *profileSection = [self new];
    profileSection.strHeaderText = [NSString getValidStringWithObject:dicData[@"headerText"]];
    profileSection.strFooterText = [NSString getValidStringWithObject:dicData[@"footerText"]];
    NSArray *arrModels = dicData[@"models"];
    if ([arrModels isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *arrMModels = [NSMutableArray arrayWithCapacity:arrModels.count];
        for (NSDictionary *dicModel in arrModels) {
            NSString *strType = [NSString getValidStringWithObject:dicModel[@"type"]];
            if ([strType isEqualToString:@"normalHeight"]) {
                QYNormalHeightModel *normalModel = [QYNormalHeightModel normalHeightModelWithDictionary:dicModel];
                [arrMModels addObject:normalModel];
            } else if ([strType isEqualToString:@"autoHeight"]) {
                QYAutoHeightModel *autoModel = [QYAutoHeightModel autoHeightModelWithDictionary:dicModel];
                [arrMModels addObject:autoModel];
            }
        }
        
        profileSection.arrModels = arrMModels;
    } else {
        profileSection.arrModels = nil;
    }
    
    return profileSection;
}

@end
