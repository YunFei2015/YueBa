//
//  DanimationView.m
//  01-配配
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import "DanimationView.h"
#import <QuartzCore/QuartzCore.h>


#define KscreenWidth  [UIScreen mainScreen].bounds.size.width
#define KscreenHeight [UIScreen mainScreen].bounds.size.height
//间隙
#define Kspace 10

@interface DanimationView ()
@property(nonatomic,strong)NSArray *arr;
@end


@implementation DanimationView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        _arr=@[[UIColor redColor],[UIColor blueColor],[UIColor greenColor]];
        [self addSubviewForDisplay];
    }
    
    return self;
}

-(void)changeTransform:(CGPoint)center{
    NSArray *subViewArr=self.subviews;
    //判断间距
    for (int i=1;i<4;i++) {
    [UIView animateWithDuration:.5 delay:0.1 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        UIView *view=subViewArr[i];
        view.transform=CGAffineTransformMakeScale(1-.05*(4-i), 1-.05*(4-i));
        view.transform=CGAffineTransformMakeTranslation(0,(4-i)*Kspace);
    } completion:^(BOOL finished) {
    
    }];
   }
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
            view.center=CGPointMake(point.x+view.center.x, point.y+view.center.y);
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
               float moveX=point.x>0?KscreenWidth*1.5:KscreenWidth/2.0*-1;
               gesture.view.center=CGPointMake(moveX, gesture.view.center.y);
               gesture.view.alpha=.2;
           }completion:^(BOOL finished) {
               UIView *view=gesture.view;
               [self sendSubviewToBack:gesture.view];
               gesture.view.center=CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
               view.transform=CGAffineTransformMakeScale(1-.05*4, 1-.05*4);
               view.transform=CGAffineTransformMakeTranslation(0,3*Kspace);
               gesture.view.alpha=1;
               [self changeTransform:gesture.view.center];
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
    for (int i=4; i>0;i--) {
         UIImageView *view=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
         view.image=[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
         view.userInteractionEnabled=YES;
         [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(Action:)]];
        view.tag=i+1;
       // view.layer.borderWidth=1;
        view.layer.cornerRadius=10;
        view.layer.masksToBounds=YES;
        view.transform=CGAffineTransformMakeScale(1-.05*i, 1-.05*i);
        view.transform=CGAffineTransformMakeTranslation(0,i*Kspace);
    
        [self addSubview:view];
    }
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
