//
//  DanimationView.m
//  01-配配
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
@property(nonatomic,strong)NSArray *arr;
//标记当前是已经高亮 left Or right
@property(nonatomic)ENLIKETYPE type;
@end


@implementation QYHomeAnimationView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _arr = @[[UIColor redColor],[UIColor blueColor],[UIColor greenColor]];
        self.backgroundColor = [UIColor clearColor];
//        [self addSubviewForDisplay];
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
        [self nextUserBehindView:view];
//        [self sendSubviewToBack:view];
//        view.center    = CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
//        view.transform = CGAffineTransformMakeScale(1-.05*4, 1-.05*4);
//        view.transform = CGAffineTransformMakeTranslation(0,3*Kspace);
//        view.alpha     = 1;
//        [self changeTransform:view.center];

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
            //快速滑动
               [UIView animateWithDuration:.3 animations:^{
             //当前试图移除屏幕
               float moveX         = point.x>0?kScreenW*1.5:kScreenW/2.0*-1;
               gesture.view.center = CGPointMake(moveX, gesture.view.center.y);
               gesture.view.alpha=.2;
           }completion:^(BOOL finished) {
               UIView *view = gesture.view;
               [self nextUserBehindView:view];
//               [self sendSubviewToBack:gesture.view];
//               gesture.view.center = CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
//               view.transform      = CGAffineTransformMakeScale(1-.05*4, 1-.05*4);
//               view.transform      = CGAffineTransformMakeTranslation(0,3*Kspace);
//               gesture.view.alpha  = 1;
//               [self changeTransform:gesture.view.center];
           }];
            
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
//        view.image = [_users[i] iconImage];
        view.userInfo = _users[count - i];
        [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(Action:)]];
        view.tag=i+1;
        view.layer.borderWidth=1;
        view.layer.cornerRadius=10;
        view.layer.masksToBounds=YES;
        view.transform=CGAffineTransformMakeScale(1-.05*i, 1-.05*i);
        view.transform=CGAffineTransformMakeTranslation(0,i*Kspace);
    
        [self addSubview:view];
    }
    [_users removeObjectsInRange:NSMakeRange(0, count)];
}

-(void)setUsers:(NSMutableArray *)users{
    _users = users;

    [self addSubviewForDisplay];
}

-(void)nextUserBehindView:(UIView *)view{
    if (_users.count == 0) {
        [view removeFromSuperview];
        if (self.subviews.count == 0) {
            if ([self.delegate respondsToSelector:@selector(noMoreUser)]) {
                [self.delegate noMoreUser];
            }
        }
    }else{
        //UI
        [self sendSubviewToBack:view];
        view.center = CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
        view.transform      = CGAffineTransformMakeScale(1-.05*4, 1-.05*4);
        view.transform      = CGAffineTransformMakeTranslation(0,3*Kspace);
        view.alpha  = 1;
        [self changeTransform:view.center];
        
        //data
        QYUserInfoView *userInfoView = (QYUserInfoView *)view;
        userInfoView.userInfo = _users.firstObject;
        [_users removeObjectAtIndex:0];
    }
    
}


@end
