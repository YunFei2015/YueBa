//
//  QYSelectModel.h
//  约吧
//
//  Created by Shreker on 16/5/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYSelectModel : NSObject

/** 文本内容 */
@property (nonatomic, copy) NSString *strText;
/** 当前的这个项目是否被选中 */
@property (nonatomic, assign, getter = isSelected) BOOL selected;

@property (nonatomic, copy) NSArray *arrSubitems;

+ (instancetype)selectModelWithDictionary:(NSDictionary *)dicData;

@end
