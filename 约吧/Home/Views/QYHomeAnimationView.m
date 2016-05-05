//
//  DanimationView.m
//  约吧
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import "QYHomeAnimationView.h"
#import "QYUserInfoView.h"
#import "QYUserInfo.h"
#import <QuartzCore/QuartzCore.h>

#define KframeSizeWidth self.frame.size.width
//间隙
#define Kspace 10

@interface QYHomeAnimationView ()
@property(nonatomic)ENLIKETYPE type;

@property (strong, nonatomic) QYUserInfo *currentUser;

@end


@implementation QYHomeAnimationView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)changeTransform:(CGPoint)center{
    NSArray *subViewArr=self.subviews;
    NSInteger count = subViewArr.count;
    //判断间距
    for (int i=1;i<count;i++) {
    [UIView animateWithDuration:.5 delay:0.1 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        UIView *view=subViewArr[i];
        view.transform=CGAffineTransformMakeScale(1-.05*(count-i), 1-.05*(count-i));
        view.transform=CGAffineTransformMakeTranslation(0,(count-i)*Kspace);
    } completion:^(BOOL finished) {
    
    }];
   }
}

//结束恢复动画
-(void)FinishedInit{
    if (_delegate) {
        _type=-1;
        [_delegate FinishendValueType];
    }
}
//判断左滑还是右滑
-(void)judgeLeftOrRightFromPoint:(CGPoint)Point{
    if (_delegate) {
        if (Point.x-(KframeSizeWidth/2.0)<-30) {
            if (_type!=dislike) {
                _type=dislike;
                [_delegate ChangeValueType:dislike];
            }
        }else if(Point.x-(KframeSizeWidth/2.0)>30){
            if (_type!=like) {
                _type=like;
                [_delegate ChangeValueType:like];
            }
        }
    }
}

#pragma mark 左右滑动

-(void)selectLikeOnce:(ENLIKETYPE)dlike{
    UIView *view=[self.subviews lastObject];
    float moveX = dlike==like?kScreenW*1.5:kScreenW/2.0*(-1);
    //快速滑动
    [UIView animateWithDuration:.3 animations:^{
        //当前试图移除屏幕
        view.center = CGPointMake(moveX,view.center.y);
        view.alpha = .2;
        
    }completion:^(BOOL finished) {
        //按钮动画
        if ([self.delegate respondsToSelector:@selector(ChangeValueType:)]) {
            [self.delegate ChangeValueType:dlike];
        }
        
        //将当前用户标记为like或dislike
        if ([self.delegate respondsToSelector:@selector(markUser:asLike:)]) {
            [self.delegate markUser:_currentUser asLike:dlike];
        }
        
        //显示下一个用户
        [self nextUserBehindView:view];
        [self FinishedInit];
    }];
}


-(void)Action:(UIPanGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"=====开始");
            break;
        case UIGestureRecognizerStateChanged:{
            NSLog(@"=====改变");
            //滑动gest
            UIView *view=(UIView *)gesture.view;
            CGPoint point=[gesture translationInView:view.superview];
            //设置view的位置
            view.center = CGPointMake(point.x+view.center.x, point.y+view.center.y);
            //初始化
           // [self changeTransform:view.center];
            [gesture setTranslation:CGPointZero inView:view.superview];
        }break;
        case UIGestureRecognizerStateEnded:{
            NSLog(@"=====结束");
            CGPoint point=[gesture velocityInView:gesture.view.superview];
            if (ABS(point.x)>1500){
                ENLIKETYPE isLike = point.x > 0 ? like : dislike;
                [self selectLikeOnce:isLike];
        }else{
                /**
                 duration: 动画时长
                 delay: 延时开始的时间
                 damping: 弹簧阻尼系数 (0-1) 1：为最大阻尼，意味着没有弹簧效果
                 velocity: 初始动力大小 通常设为0，就会根据duration和damping自动调整动画效果
                 */
                [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:.4 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    //恢复到原来的位置
                    gesture.view.center=CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
         break;
        default:
            break;
    }
}
-(void)addSubviewForDisplay{
    NSInteger count = _users.count >= 4 ? 4 : _users.count;
    for (NSInteger i = count; i>0;i--) {
        
        QYUserInfoView *view = [[NSBundle mainBundle] loadNibNamed:@"QYUserInfoView" owner:nil options:nil][0];
        view.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
//        view.image=[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",i]];
        view.userInfo = _users[i - 1];
        [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(Action:)]];
        view.tag=i+1;
        view.layer.borderWidth=1;
        view.layer.cornerRadius=10;
        view.layer.masksToBounds=YES;
        view.transform=CGAffineTransformMakeScale(1-.05*i, 1-.05*i);
        view.transform=CGAffineTransformMakeTranslation(0,i*Kspace);
    
        [self addSubview:view];
    }
    _currentUser = _users.firstObject;
}

-(void)setUsers:(NSMutableArray *)users{
    _users = users;
    
    [self addSubviewForDisplay];
}

-(void)nextUserBehindView:(UIView *)view{
    if (_users.count < 4) {//如果当前已经是倒数第4个用户了，就把该视图直接删除
        [view removeFromSuperview];
    }else{
        //UI
        [self sendSubviewToBack:view];
        view.center = CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
        view.transform      = CGAffineTransformMakeScale(1-.05*4, 1-.05*4);
        view.transform      = CGAffineTransformMakeTranslation(0,3*Kspace);
        view.alpha  = 1;
        [self changeTransform:view.center];
        
        //视图被移到最后方后，填充内容
        //视图内容永远对应数组中第4个元素（每次移除最上面都会同步移除对应数据）
        QYUserInfoView *infoView = (QYUserInfoView *)view;
        infoView.userInfo = _users[3];
    }
    
    //注意：由于_users是强引用，因此_users和users是指向同一个内存地址的两个指针，like或dislike一个用户后，在homeVC已经删除了users[0]，因此_users的第0个元素就随之后移。
    _currentUser = _users.firstObject;
}


@end
