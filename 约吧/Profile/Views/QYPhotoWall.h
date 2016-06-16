//
//  PhotoWall.h
//  MoveView
//
//  Created by 青云-wjl on 16/4/17.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYPhotoWall : UIView

//照片墙中可用的图片
@property (nonatomic, strong) NSArray *imagesOfWall;

//声明类方法 初始化
+(instancetype)photoWallWithPhotos:(NSArray *)photos;
@end
