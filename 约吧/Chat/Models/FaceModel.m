//
//  FaceModel.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/11.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "FaceModel.h"

@implementation FaceModel

-(instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        _text = dict[@"faceName"];
        _imgName = dict[@"imgName"];
        _category = kFaceCategoryTT;
    }
    return self;
}

+(instancetype)faceModelWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDictionary:dict];
}

@end
