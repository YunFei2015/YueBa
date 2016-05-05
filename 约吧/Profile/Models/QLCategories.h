//
//  QLCategories.h
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QLSingleton.h"

#define QLKeyOccupations @"occupation"
#define QLKeyHometowns @"hometown"
#define QLKeyPersonalities @"personality"
#define QLKeySports @"sports"
#define QLKeyMusics @"music"
#define QLKeyFoods @"food"
#define QLKeyMovies @"movies"
#define QLKeyLiteratures @"literature"
#define QLKeyPlaces @"places"

@interface QLCategories : NSObject

QLSingletonInterface(Categories)

/** 职业 */
@property (nonatomic, copy, readonly) NSArray *arrOccupations;

/** 来自 */
@property (nonatomic, copy, readonly) NSArray *arrHometowns;

/** 我的个性标签 */
@property (nonatomic, copy, readonly) NSArray *arrPersonalities;

/** 我喜欢的运动 */
@property (nonatomic, copy, readonly) NSArray *arrSports;

/** 我喜欢的音乐 */
@property (nonatomic, copy, readonly) NSArray *arrMusics;

/** 我喜欢的食物 */
@property (nonatomic, copy, readonly) NSArray *arrFoods;

/** 我喜欢的电影 */
@property (nonatomic, copy, readonly) NSArray *arrMovies;

/** 我喜欢的书和动漫 */
@property (nonatomic, copy, readonly) NSArray *arrLiteratures;

/** 我的旅行足迹 */
@property (nonatomic, copy, readonly) NSArray *arrPlaces;

@end
