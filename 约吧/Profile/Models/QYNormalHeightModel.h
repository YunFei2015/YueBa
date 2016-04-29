//
//  QYNormalHeightModel.h
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYNormalHeightModel : NSObject

@property (nonatomic, copy) NSString *strTitle;
@property (nonatomic, copy) NSString *strContent;
@property (nonatomic, copy) NSString *strPlaceholder;

+ (instancetype)normalHeightModelWithDictionary:(NSDictionary *)dicData;

@end
