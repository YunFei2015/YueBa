//
//  QYImageWall.m
//  MoveView
//
//  Created by 青云-wjl on 16/4/19.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

#import "QYImageTile.h"
#import "Masonry.h"
@implementation QYImageTile
//通过重写setTileIndex方法来设置瓦片的约束，来固定瓦片的尺寸和位置
-(void)setTileIndex:(NSInteger)tileIndex{
    _tileIndex = tileIndex;
    NSLog(@"%@",NSStringFromCGRect(self.superview.frame));
    //计算各种瓦片的尺寸
    CGFloat width1 = kScreenW / 3;
    CGFloat width2 = 2 * width1;
    switch (tileIndex) {
        case 101:
        {
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width2, width2));
            }];
        }break;
        case 102:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.right.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
        case 103:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.centerY.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
        case 104:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.bottom.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
        case 105:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
                make.centerX.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
        case 106:{
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.bottom.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(width1, width1));
            }];
        }break;
            
        default:
            break;
    }
}
@end
