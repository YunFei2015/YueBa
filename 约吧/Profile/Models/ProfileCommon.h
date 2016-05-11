//
//  ProFileCommon.h
//  约吧
//
//  Created by 青云-wjl on 16/5/11.
//  Copyright © 2016年 云菲. All rights reserved.
//

#ifndef ProfileCommon_h
#define ProfileCommon_h

typedef NS_ENUM(NSUInteger, QYSelectionType) {
    /** 职业 */
    QYSelectionTypeOccupation,
    
    /** 来自 */
    QYSelectionTypeHometown,
    
    /** 我的个性标签 */
    QYSelectionTypePersonality,
    
    /** 我喜欢的运动 */
    QYSelectionTypeSports,
    
    /** 我喜欢的音乐 */
    QYSelectionTypeMusic,
    
    /** 我喜欢的食物 */
    QYSelectionTypeFood,
    
    /** 我喜欢的电影 */
    QYSelectionTypeMovies,
    
    /** 我喜欢的书和动漫 */
    QYSelectionTypeLiterature,
    
    /** 我的旅行足迹 */
    QYSelectionTypePlaces
};

typedef NS_ENUM(NSUInteger, QYCreateTextType) {
    /** 职业 */
    QYCreateTextTypeOccupation,
    
    /** 来自 */
    QYCreateTextTypeHometown,
    
    /** 经常出没 */
    QYCreateTextTypeHaunt,
    
    /** 个人签名 */
    QYCreateTextTypeSignature,
    
    /** 我的微信 */
    QYCreateTextTypeWeChat,
    
    /** none */
    QYCreateTextTypeNone,
};



#endif /* ProfileCommon_h */
