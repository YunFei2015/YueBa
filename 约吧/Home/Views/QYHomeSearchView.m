//
//  QYHomeSearchView.m
//  约吧
//
//  Created by 云菲 on 4/11/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYHomeSearchView.h"

#import <BaiduMapAPI_Map/BMKMapView.h>

@interface QYHomeSearchView ()
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) UIView *animationView;


@end

@implementation QYHomeSearchView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
    }
    return self;
}

-(void)addSubViews{
    self.backgroundColor = [UIColor whiteColor];
    //地图
    CGFloat mapViewW = kScreenW - 20;
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(10, 10, mapViewW, mapViewW)];
    _mapView.scrollEnabled = NO;
    _mapView.layer.cornerRadius = mapViewW / 2.f;
    _mapView.layer.masksToBounds = YES;
    _mapView.zoomLevel = 15;
    [self addSubview:_mapView];
    
    //旋转view
    UIImageView *animationView = [[UIImageView alloc] initWithFrame:_mapView.frame];
    animationView.image = [UIImage imageNamed:@"message_spinner"];
    _animationView = animationView;
    [self addSubview:_animationView];

    
    //头像
    CGFloat iconW = mapViewW / 4.f;
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconW, iconW)];
    iconImageView.center = _mapView.center;
    iconImageView.image = [UIImage imageNamed:@"小丸子"];
    iconImageView.layer.cornerRadius = iconW / 2.f;
    iconImageView.layer.masksToBounds = YES;
    [self addSubview:iconImageView];
    
    //提示
    CGFloat tipY = 20 + mapViewW + 50;
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tipY, kScreenW, 21)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor lightGrayColor];
    _tipLabel = tipLabel;
    [self addSubview:_tipLabel];
    
    self.hasMore = YES;
    [self startRotating];
}


-(void)setHasMore:(BOOL)hasMore{
    _hasMore = hasMore;
    
//    [self startRotating];
    if (_hasMore) {
        _tipLabel.text = @"正在查找附近的人...";
    }else{
        _tipLabel.text = @"附近没有更多的人了...";
    }
    
}

-(void)startRotating{
    [_animationView.layer removeAllAnimations];
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [_animationView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}




@end
