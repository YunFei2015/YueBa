//
//  ProFileCommon.h
//  约吧
//
//  Created by 青云-wjl on 16/5/11.
//  Copyright © 2016年 云菲. All rights reserved.
//

#ifndef ProfileCommon_h
#define ProfileCommon_h

typedef NS_ENUM(NSUInteger, MyProfileCellWillTransitionType) {
    //过渡选择界面
    MyProfileCellWillPresentedTypeSelection,
    //过渡输入界面
    MyProfileCellWillPresentedTypeInput
};

static NSString * const kProfileOccupation = @"occupation";
static NSString * const kProfileHometown = @"hometown";
static NSString * const kProfileHaunt = @"haunt";
static NSString * const kProfileSignature = @"signature";
static NSString * const kProfileWeixin = @"weixin";
static NSString * const kProfilePersonality = @"personality";
static NSString * const kProfileSports = @"sports";
static NSString * const kProfileMusic = @"music";
static NSString * const kProfileFood = @"food";
static NSString * const kProfileMovies = @"movies";
static NSString * const kProfileLiterature = @"literature";
static NSString * const kProfilePlaces = @"places";

#define kProfilePath [kDocumentDirectory stringByAppendingString:@"/profileInfo.data"]
#endif /* ProfileCommon_h */
