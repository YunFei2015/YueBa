//
//  QYImageWall.h
//  MoveView
//
//  Created by 青云-wjl on 16/4/19.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
//照片墙瓦片
@interface QYImageTile : UIImageView
//瓦片的索引
@property (nonatomic) NSInteger tileIndex;
//瓦片是否已经设置过图片
@property (nonatomic) BOOL hadImage;

//从瓦片删除图片
@property (nonatomic, copy) void (^deleteImageFormTile) (QYImageTile *tile);
//为瓦片添加图片
@property (nonatomic, copy) void (^addImageForTile) (UIImage *selectImage);
@end
