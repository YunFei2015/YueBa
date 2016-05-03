//
//  QLProfileInfo.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QLProfileInfo.h"
#import "QYProfileSectionModel.h"

@implementation QLProfileInfo

QLSingletonImplementation(ProfileInfo)

- (instancetype)init {
    if (self = [super init]) {
        NSString *strPath = [[NSBundle mainBundle] pathForResource:@"ProfileInfo" ofType:@"plist"];
        NSDictionary *dicProfileInfos = [NSDictionary dictionaryWithContentsOfFile:strPath];
        NSArray *arrProfileInfos = dicProfileInfos[@"sections"];
        NSMutableArray *arrMProfileInfoModels = [NSMutableArray arrayWithCapacity:arrProfileInfos.count];
        for (NSDictionary *dicSection in arrProfileInfos) {
            QYProfileSectionModel *sectionModel = [QYProfileSectionModel profileSectionModelWithDictionary:dicSection];
            [arrMProfileInfoModels addObject:sectionModel];
        }
        _arrProfileInfos = arrMProfileInfoModels;
    }
    return self;
}

@end
