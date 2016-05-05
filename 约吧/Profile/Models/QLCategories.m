//
//  QLCategories.m
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QLCategories.h"
#import "QYSelectModel.h"

@implementation QLCategories
{
    NSDictionary *_dicCategories;
}

QLSingletonImplementation(Categories)

- (instancetype)init {
    if (self = [super init]) {
        NSString *strPath = [[NSBundle mainBundle] pathForResource:@"CategorySuggestions" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:strPath];
        NSError *error = nil;
        NSDictionary *dicCategories = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (error) {
            NSAssert(0 > 1, @"数据解析出错,请查看");
        }
        NSMutableDictionary *dicMTemp = [NSMutableDictionary dictionaryWithCapacity:dicCategories.count];
        for (NSString *key in dicCategories) {
            id obj = dicCategories[key];
            if ([obj isKindOfClass:[NSArray class]]) {
                NSArray *arrTemp = obj;
                NSMutableArray *arrMTemp = [NSMutableArray arrayWithCapacity:arrTemp.count];
                for (id objMaybeText in arrTemp) {
                    if ([objMaybeText isKindOfClass:[NSString class]]) {
                        QYSelectModel *select = [QYSelectModel new];
                        select.strText = objMaybeText;
                        [arrMTemp addObject:select];
                    } else {
                        NSAssert(0 > 1, @"异常数据, 请查看");
                    }
                }
                [dicMTemp setObject:[arrMTemp copy] forKey:key];
            } else if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dicTemp = obj;
                NSMutableArray *arrMTemp = [NSMutableArray arrayWithCapacity:dicTemp.count];
                for (NSString *keyInternal in dicTemp) { // 代表遍历的是外层,如中国,澳大利亚...
                    QYSelectModel *select = [QYSelectModel new];
                    select.strText = keyInternal;
                    id obj = dicTemp[keyInternal];
                    if ([obj isKindOfClass:[NSArray class]]) {
                        NSArray *arrTemp = obj; // 所有的省份
                        NSMutableArray *arrMInternalTemp = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        for (id objMaybeText in arrTemp) { // 内层遍历, 如北京,上海...
                            if ([objMaybeText isKindOfClass:[NSString class]]) {
                                QYSelectModel *selectInternal = [QYSelectModel new];
                                selectInternal.strText = objMaybeText;
                                [arrMInternalTemp addObject:selectInternal];
                            } else {
                                NSAssert(0 > 1, @"异常数据, 请查看");
                            }
                        }
                        select.arrSubitems = [arrMInternalTemp copy];
                        if ([keyInternal isEqualToString:@"中国"]) {
                            [arrMTemp insertObject:select atIndex:0];
                        } else {
                            [arrMTemp addObject:select];
                        }
                    } else {
                        NSAssert(0 > 1, @"异常数据, 请查看");
                    }
                    [dicMTemp setObject:[arrMTemp copy] forKey:key];
                }
            } else {
                NSAssert(0 > 1, @"异常数据, 请查看");
            }
        }
        
        _dicCategories = [dicMTemp copy];
    }
    return self;
}

/** 职业 */
- (NSArray *)arrOccupations {
    return _dicCategories[QLKeyOccupations];
}

/** 来自 */
- (NSArray *)arrHometowns {
    return _dicCategories[QLKeyHometowns];
}

/** 我的个性标签 */
- (NSArray *)arrPersonalities {
    return _dicCategories[QLKeyPersonalities];
}

/** 我喜欢的运动 */
- (NSArray *)arrSports {
    return _dicCategories[QLKeySports];
}

/** 我喜欢的音乐 */
- (NSArray *)arrMusics {
    return _dicCategories[QLKeyMusics];
}

/** 我喜欢的食物 */
- (NSArray *)arrFoods {
    return _dicCategories[QLKeyFoods];
}

/** 我喜欢的电影 */
- (NSArray *)arrMovies {
    return _dicCategories[QLKeyMovies];
}

/** 我喜欢的书和动漫 */
- (NSArray *)arrLiteratures {
    return _dicCategories[QLKeyLiteratures];
}

/** 我的旅行足迹 */
- (NSArray *)arrPlaces {
    return _dicCategories[QLKeyPlaces];
}

@end
