//
//  QYAutoHeightModel.h
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYAutoHeightModel : NSObject

@property (nonatomic, copy) NSString *strImageName;
@property (nonatomic, copy) NSString *strTitle;
@property (nonatomic, copy) NSArray *arrTags;           //已选中的标签

+ (instancetype)autoHeightModelWithDictionary:(NSDictionary *)dicData;

@end
