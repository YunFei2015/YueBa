//
//  FaceModel.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/11.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    kFaceCategoryTT=1,//探探自带的表情
    kFaceCategoryCharacter,//符号表情
    kFaceCategoryTusiji,//兔斯基
    kFaceCategoryRabbit,//玉兔
    kFaceCategoryRemove
}kFaceCategory;

@interface FaceModel : NSObject
@property (strong, nonatomic) NSString *text;//用于显示在文本框
@property (strong, nonatomic) NSString *imgName;//用于加载图片
@property (nonatomic) kFaceCategory category;

+(instancetype)faceModelWithDictionary:(NSDictionary *)dict;
-(instancetype)initWithDictionary:(NSDictionary *)dict;
@end
