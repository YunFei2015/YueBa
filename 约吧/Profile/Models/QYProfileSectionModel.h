//
//  QYProfileSectionModel.h
//  约吧
//
//  Created by 青云-wjl on 16/6/7.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYProfileSectionModel : NSObject <NSCoding>
/**
 sectionheader:section头标题
 celldatas:section中的cell数据
 */
@property (nonatomic, strong) NSString *sectionheader;
@property (nonatomic, strong) NSMutableArray *celldatas;

-(instancetype)initWithDictionary:(NSDictionary *)sectionInfo;
+(instancetype)profileSectionModelWithDictionary:(NSDictionary *)sectionInfo;
@end
