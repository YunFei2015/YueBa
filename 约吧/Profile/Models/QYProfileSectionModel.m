//
//  QYProfileSectionModel.m
//  约吧
//
//  Created by 青云-wjl on 16/6/7.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYProfileSectionModel.h"
#import "QYProfileCellModel.h"
@implementation QYProfileSectionModel

-(instancetype)initWithDictionary:(NSDictionary *)sectionInfo{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:sectionInfo];
        NSMutableArray *cellModels = [NSMutableArray array];
        for (NSDictionary *cellDict in self.celldatas) {
            QYProfileCellModel *cellModel = [QYProfileCellModel profileCellModelWithDictionary:cellDict];
            [cellModels addObject:cellModel];
        }
        self.celldatas = cellModels;
    }
    return self;
}

+(instancetype)profileSectionModelWithDictionary:(NSDictionary *)sectionInfo{
    return [[self alloc] initWithDictionary:sectionInfo];
}
#pragma mark - archiver & unarchiver
// 解档 反序列化 解码 从data(file)->对象
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _sectionheader = [aDecoder decodeObjectForKey:@"sectionheader"];
        _celldatas = [aDecoder decodeObjectForKey:@"celldatas"];
    }
    return self;
}

// 归档 序列化 编码 从对象->data(file)
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_sectionheader forKey:@"sectionheader"];
    [aCoder encodeObject:_celldatas forKey:@"celldatas"];
}

@end
