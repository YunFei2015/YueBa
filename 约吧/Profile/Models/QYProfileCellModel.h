//
//  QYProfileSectionModel.h
//  约吧
//
//  Created by 青云-wjl on 16/6/7.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYProfileCellModel : NSObject<NSCoding>
/**
 title:单元格标题
 placeholder:在 "我的信息、我的社交账号" 中代表占位信息；在 "我的个性标签、我的兴趣" 中代表图片名称
 content:单元格内容
 key:单元格信息类型（occupation:职业、hometown:家乡、haunt:经常出没的地方、signature:个性签名、weixin:微信账号、personality:个性标签、sports:喜欢的运动、music:喜欢的音乐、food:喜欢的食物、movies:喜欢的电影、literature:喜欢的书和动漫、places:旅行足迹）
 type:过渡类型（0:过渡至选择控制器、1:过渡至输入控制器）
 */
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *key;
@property (nonatomic)         NSInteger type;

-(instancetype)initWithDictionary:(NSDictionary *)cellInfo;
+(instancetype)profileCellModelWithDictionary:(NSDictionary *)cellInfo;
@end
