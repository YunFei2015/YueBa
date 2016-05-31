//
//  QYPhotoBrowserTransition.m
//  约吧
//
//  Created by 云菲 on 16/4/25.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYPhotoBrowserTransition.h"
#import "QYChatVC.h"
#import "QYPhotoBrowser.h"
#import "UIView+Extension.h"
#import <UIImageView+WebCache.h>

@implementation QYPhotoBrowserTransition

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if ([[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] isKindOfClass:[SWRevealViewController class]]) {
        
        //from控制器
        SWRevealViewController *revealVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UINavigationController *nav = (UINavigationController *)revealVC.rightViewController;
        QYChatVC *fromVC = (QYChatVC *)nav.viewControllers[1];
        
        //to控制器
        QYPhotoBrowser *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *container = [transitionContext containerView];
        
        //转场动画初始视图
        UIImageView *photoImageView = fromVC.selectedCell.photoImageView;
        UIImageView *snapShotView = [[UIImageView alloc] initWithImage:photoImageView.image];
        snapShotView.contentMode = UIViewContentModeScaleAspectFit;
        snapShotView.frame = [container convertRect:photoImageView.frame fromView:photoImageView.superview];
        snapShotView.backgroundColor = [UIColor blackColor];

        toVC.view.alpha = 0;
        [container addSubview:toVC.view];
        [container addSubview:snapShotView];
        
        //在transition结束后toVC的frame大小
        toVC.finalFrame = snapShotView.frame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            snapShotView.frame = toVC.view.frame;
        } completion:^(BOOL finished) {
            toVC.view.alpha = 1;
            [snapShotView removeFromSuperview];
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }else{
        QYPhotoBrowser *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        SWRevealViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UINavigationController *nav = (UINavigationController *)toVC.rightViewController;
        QYChatVC *chatVC = (QYChatVC *)nav.viewControllers[1];
        
        UIView *container = [transitionContext containerView];
        
        //转场动画初始视图
        UIImageView *photoImageView = fromVC.selectedCell.photoView;
        UIImageView *snapShotView = [[UIImageView alloc] initWithImage:photoImageView.image];
        snapShotView.contentMode = UIViewContentModeScaleAspectFit;
        snapShotView.frame = [container convertRect:photoImageView.frame fromView:photoImageView.superview];
        
        
        [container addSubview:toVC.view];
        [container addSubview:snapShotView];
      
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            snapShotView.frame = fromVC.finalFrame;
        } completion:^(BOOL finished) {
            [snapShotView removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

@end
