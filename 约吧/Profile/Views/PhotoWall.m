//
//  PhotoWall.m
//  MoveView
//
//  Created by 青云-wjl on 16/4/17.
//  Copyright © 2016年 河南青云信息技术有限公司. All rights reserved.
//

#import "PhotoWall.h"
#import "QYImageTile.h"

#import "Masonry.h"

#define AnimationDamping             0.75
#define AnimationVelocity            0.5
#define AnimationDuration            0.25

@interface PhotoWall ()
@property (nonatomic)         BOOL isAnimationIng;              //表示当前有瓦片正在执行动画
@end

@implementation PhotoWall

+(instancetype)photoWall{
    PhotoWall *wall = [[PhotoWall alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenW)];
    [wall addSubImageViews];
    return wall;
}

//添加子视图
-(void)addSubImageViews{
    for (int i = 1; i < 7; i++) {
        QYImageTile *imageTile = [[QYImageTile alloc] init];
        [self addSubview:imageTile];
        imageTile.tileIndex = imageTile.tag = 100 + i;
        imageTile.image = [UIImage imageNamed:[NSString stringWithFormat:@"cat%d.jpg",i]];
        imageTile.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [imageTile addGestureRecognizer:pan];
    }
}

//处理pan手势
- (void)pan:(UIPanGestureRecognizer *)sender {
    //获取当前手势作用的视图panView
    QYImageTile *panView = (QYImageTile *)sender.view;
    __weak PhotoWall *weakSelf = self;
    if (sender.state == UIGestureRecognizerStateBegan){
        //1、把panView置顶
        [self bringSubviewToFront:panView];
        //2、获取手势作用的点（在当前self 照片墙上）
        CGPoint location = [sender locationInView:self];
        //3、重置panView的约束
        [panView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreenW / 4.0, kScreenW / 4.0));
            make.centerX.equalTo(weakSelf.mas_left).with.offset(location.x);
            make.centerY.equalTo(weakSelf.mas_top).with.offset(location.y);
        }];
        //4、添加动画
        [UIView animateWithDuration:AnimationDuration animations:^{
            [weakSelf layoutIfNeeded];
            //更改panView的透明度
            panView.alpha = 0.8;
        }];
    }else if (sender.state == UIGestureRecognizerStateChanged){
        //1、获取手势作用的点（在当前self 照片墙上）
        CGPoint point = [sender locationInView:self];
        //2、更改约束来实现panView随着手势的移动而移动
        [panView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScreenW / 4.0, kScreenW / 4.0));
            make.centerX.equalTo(weakSelf.mas_left).with.offset(point.x);
            make.centerY.equalTo(weakSelf.mas_top).with.offset(point.y);
        }];
        
        //3、找到当前手势点所在的视图的tag（除去panView）
        NSInteger findTag = [self pointInView:panView point:panView.center];
        //4、判断找到的tag有效([101-106]),并且现在没有在执行动画
        if (findTag != -1) {
            //设置动画状态为yes
            //_isAnimationIng = YES;
            //利用临时变量来保存找到的有效的findTag
            NSInteger tempTag = findTag;
            
            if (findTag > panView.tag) {
                //当findTag > panView.tag,让[(panView.tag + 1)-findTag]这个区间内的所有的视图的tag和tileIndex - 1
                [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.tag > panView.tag && obj.tag <= findTag) {
                        QYImageTile *tile = (QYImageTile *)obj;
                        tile.tileIndex = obj.tag -= 1;
                    }
                }];
            }else{
                //当findTag < panView.tag,让[findTag-(panView.tag - 1)]这个区间内的所有的视图的tag和tileIndex + 1
                [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.tag < panView.tag && obj.tag >= findTag) {
                        QYImageTile *tile = (QYImageTile *)obj;
                        tile.tileIndex = obj.tag += 1;
                    }
                }];
            }
            //把tempTag赋值给panView.tag
            panView.tag = tempTag;
            //执行动画
            [UIView animateWithDuration:AnimationDuration delay:0 usingSpringWithDamping:AnimationDamping initialSpringVelocity:AnimationVelocity options:UIViewAnimationOptionCurveLinear animations:^{
                [weakSelf layoutIfNeeded];
            } completion:^(BOOL finished) {}];
        }
        
    }else if (sender.state == UIGestureRecognizerStateEnded) {
        //1、更改panView的tileIndex
        panView.tileIndex = panView.tag;
        //2、执行panView的动画
        [UIView animateWithDuration:AnimationDuration delay:0 usingSpringWithDamping:AnimationDamping initialSpringVelocity:AnimationVelocity options:UIViewAnimationOptionCurveLinear animations:^{
            [weakSelf layoutIfNeeded];
            //更改透明度为1.0
            panView.alpha = 1.0;
        } completion:nil];
    }
}

//判断当前手势所在的点在self.subviews中的哪个视图中（除了当前手势作用的视图以外）
-(NSInteger)pointInView:(UIView *)view point:(CGPoint)p{
    __block NSInteger findTag = -1;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //判断obj不是手势作用的view
        if (obj != view) {
            //判断当前点p是否在view的frame矩形中
            if (CGRectContainsPoint(obj.frame, p)) {
                findTag = obj.tag;
                *stop = YES;
            }
        }
    }];
    return findTag;
}

@end
