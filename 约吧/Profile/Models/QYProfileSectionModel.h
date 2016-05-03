//
//  QYProfileSectionModel.h
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QYProfileSectionType) {
    /** 正常高度的 Section */
    QYProfileSectionTypeNormalHeight,
    
    /** 根据选择信息自动变换的行高的 Section */
    QYProfileSectionTypeAutoHeight
};

@interface QYProfileSectionModel : NSObject


@property (nonatomic, copy) NSString *strHeaderText;
@property (nonatomic, copy) NSString *strFooterText;
@property (nonatomic, copy) NSArray *arrModels;

+ (instancetype)profileSectionModelWithDictionary:(NSDictionary *)dicData;

@end
