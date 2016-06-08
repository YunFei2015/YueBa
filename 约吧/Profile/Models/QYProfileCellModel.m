//
//  QYProfileSectionModel.m
//  约吧
//
//  Created by 青云-wjl on 16/6/7.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYProfileCellModel.h"

@implementation QYProfileCellModel

-(instancetype)initWithDictionary:(NSDictionary *)cellInfo{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:cellInfo];
    }
    return self;
}

+(instancetype)profileCellModelWithDictionary:(NSDictionary *)cellInfo{
    return [[self alloc] initWithDictionary:cellInfo];
}

#pragma mark - archiver & unarchiver
// 解档 反序列化 解码 从data(file)->对象
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _placeholder = [aDecoder decodeObjectForKey:@"placeholder"];
        _content = [aDecoder decodeObjectForKey:@"content"];
        _key = [aDecoder decodeObjectForKey:@"key"];
        _type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}

// 归档 序列化 编码 从对象->data(file)
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_placeholder forKey:@"placeholder"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeInteger:_type forKey:@"type"];
}
@end
