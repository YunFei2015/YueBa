//
//  QLProfileInfo.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QLProfileInfo.h"
#import "ProfileCommon.h"
#import "QYProfileSectionModel.h"
#import "QYProfileCellModel.h"
@implementation QLProfileInfo

QLSingletonImplementation(ProfileInfo)

//个人信息
+(instancetype)profileInfo{
    return [[self alloc] initWithExceptEmpty:NO];
}

//排除空的个人信息
+(instancetype)profileInfoExceptEmpty{
    return [[self alloc] initWithExceptEmpty:YES];
}

- (instancetype)initWithExceptEmpty:(BOOL)isExcept{
    if (self = [super init]) {
        NSMutableArray *models = [NSMutableArray array];
        if ([[NSFileManager defaultManager] fileExistsAtPath:kProfilePath]) {
            self = [NSKeyedUnarchiver unarchiveObjectWithFile:kProfilePath];
            models = [NSMutableArray arrayWithArray:self.arrProfileInfos];
        }else{
            //把ProfileInfo存储在documents文件夹中
            NSString *profile = [[NSBundle mainBundle] pathForResource:@"ProfileInfo" ofType:@"plist"];
            //获取ProfileInfo1文件中数据
            NSArray *datas = [NSArray arrayWithContentsOfFile:profile];
            for (NSDictionary *sectionDict in datas) {
                QYProfileSectionModel *profileSectionModel = [QYProfileSectionModel profileSectionModelWithDictionary:sectionDict];
                [models addObject:profileSectionModel];
            }
            _arrProfileInfos = models;
            [NSKeyedArchiver archiveRootObject:self toFile:kProfilePath];
        }
        
        if (isExcept) {
            //排除内容为空的数据
            NSPredicate *cellPredicate = [NSPredicate predicateWithFormat:@"SELF.content.length > 0"];
            for (QYProfileSectionModel *sectionModel in models) {
                NSArray *filterArray = [sectionModel.celldatas filteredArrayUsingPredicate:cellPredicate];
                sectionModel.celldatas = [NSMutableArray arrayWithArray:filterArray];
            }
            
            NSPredicate *sectionPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return ((QYProfileSectionModel *)evaluatedObject).celldatas.count > 0;
            }];
            _arrProfileInfos = [models filteredArrayUsingPredicate:sectionPredicate];
        }else{
            _arrProfileInfos = models;
        }
    }
    return self;
}

#pragma mark - archiver & unarchiver
// 解档 反序列化 解码 从data(file)->对象
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _arrProfileInfos = [aDecoder decodeObjectForKey:@"arrProfileInfos"];
    }
    return self;
}

// 归档 序列化 编码 从对象->data(file)
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_arrProfileInfos forKey:@"arrProfileInfos"];
}
@end
