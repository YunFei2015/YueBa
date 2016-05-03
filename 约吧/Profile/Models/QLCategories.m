//
//  QLCategories.m
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QLCategories.h"

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
        _dicCategories = dicCategories;
    }
    return self;
}

/** 职业 */
- (NSArray *)arrOccupations {
    return _dicCategories[@"occupation"];
}

/** 来自 */
- (NSArray *)arrHometowns {
    return _dicCategories[@"hometown"];
}

/** 我的个性标签 */
- (NSArray *)arrPersonalities {
    return _dicCategories[@"personality"];
}

/** 我喜欢的运动 */
- (NSArray *)arrSports {
    return _dicCategories[@"sports"];
}

/** 我喜欢的音乐 */
- (NSArray *)arrMusics {
    return _dicCategories[@"music"];
}

/** 我喜欢的食物 */
- (NSArray *)arrFoods {
    return _dicCategories[@"food"];
}

/** 我喜欢的电影 */
- (NSArray *)arrMovies {
    return _dicCategories[@"movies"];
}

/** 我喜欢的书和动漫 */
- (NSArray *)arrLiteratures {
    return _dicCategories[@"literature"];
}

/** 我的旅行足迹 */
- (NSArray *)arrPlaces {
    return _dicCategories[@"places"];
}

@end
